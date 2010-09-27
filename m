Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BE33A6B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 04:04:53 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
	<m1d3s19z38.fsf@fess.ebiederm.org>
	<AANLkTik=6cGkkpBJUfhNJ8ZhB8MfFrm=zXWtLOP-S_ZR@mail.gmail.com>
Date: Mon, 27 Sep 2010 01:04:44 -0700
In-Reply-To: <AANLkTik=6cGkkpBJUfhNJ8ZhB8MfFrm=zXWtLOP-S_ZR@mail.gmail.com>
	(Pekka Enberg's message of "Mon, 27 Sep 2010 10:15:14 +0300")
Message-ID: <m1vd5r628z.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 3/3] mm: Cause revoke_mappings to wait until all close methods have completed.
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@kernel.org> writes:

> On Sun, Sep 26, 2010 at 2:34 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
>
> The changelog is slightly too terse for me to review this. What's the
> race you're trying to avoid? If the point is to make the revoke task
> wait until everything has been closed, why can't we use the completion
> API here?

Because as far as I can tell completions don't map at all.
At best we have are times when the set of vmas goes empty.

The close_count is needed as we take vmas off the lists early
to avoid issues with truncate, and so we something to tell
when the close is actually finished.  If a close is actually
in progress.

I used a simple task to wake up instead of a wait queue as in all of the
revoke scenarios I know of, it make sense to serialize at a higher
level, and a task pointer is smaller than a wait queue head, and
I am reluctant to increase the size of struct inode to larger than
necessary.

The count at least has to be always present because objects could start
closing before we start the revoke.   We can't be ham handed and grab
all mm->mmap_sem's because mmput() revoke_vma is called without the
mmap_sem.

So it looked to me that the cleanest and smallest way to go was to write
an old fashioned schedule/wait loop that are usually hidden behind
completions, or wait queue logic.

It is my hope that we can be clever at some point and create a union
either in struct inode proper or in struct address space with a few
other fields that cannot be used while revoking a vma (like potentially
the truncate count) and reuse them.  But I am not clever enough today
to do something like that.

Eric

>> ---
>> =C2=A0include/linux/fs.h | =C2=A0 =C2=A02 ++
>> =C2=A0mm/mmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 13 ++++++++++=
++-
>> =C2=A0mm/revoke.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 18 +++++++++++++++=
---
>> =C2=A03 files changed, 29 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 76041b6..5d3d6b8 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -633,6 +633,8 @@ struct address_space {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct address_space_operations *a_ops;=
 =C2=A0 /* methods */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 flags; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* error bits/gfp mask */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct backing_dev_info *backing_dev_info; /*=
 device readahead, etc */
>> + =C2=A0 =C2=A0 =C2=A0 struct task_struct =C2=A0 =C2=A0 =C2=A0*revoke_ta=
sk; =C2=A0 /* Who to wake up when all vmas are closed */
>> + =C2=A0 =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0close_count; =C2=A0 =C2=A0/* Cover race conditions with revoke_mappin=
gs */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0private_lock; =C2=A0 /* for use by the address_space */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0p=
rivate_list; =C2=A0 /* ditto */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space =C2=A0 =C2=A0*assoc_mapp=
ing; /* ditto */
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 17dd003..3df3193 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -218,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_sp=
ace *mapping =3D file->f_mapping;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&mappin=
g->i_mmap_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__remove_shared_v=
m_struct(vma, file, mapping);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapping->close_count+=
+;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&mapp=
ing->i_mmap_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0}
>> @@ -233,9 +234,19 @@ static struct vm_area_struct *remove_vma(struct vm_=
area_struct *vma)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vma->vm_ops && vma->vm_ops->close)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vma->vm_ops->clos=
e(vma);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vma->vm_file) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fput(vma->vm_file);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct address_space =
*mapping =3D vma->vm_file->f_mapping;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vma->vm_flags=
 & VM_EXECUTABLE)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0removed_exe_file_vma(vma->vm_mm);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Decrement the clos=
e count and wake up a revoker if present */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&mapping->i=
_mmap_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapping->close_count-=
-;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((mapping->close_c=
ount =3D=3D 0) && mapping->revoke_task)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* Is wake_up_process the right variant of try_to_wake_up? */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 wake_up_process(mapping->revoke_task);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&mapping-=
>i_mmap_lock);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fput(vma->vm_file);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_put(vma_policy(vma));
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0kmem_cache_free(vm_area_cachep, vma);
>> diff --git a/mm/revoke.c b/mm/revoke.c
>> index a76cd1a..e19f7df 100644
>> --- a/mm/revoke.c
>> +++ b/mm/revoke.c
>> @@ -143,15 +143,17 @@ void revoke_mappings(struct address_space *mapping)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Make any access to previously mapped pages=
 trigger a SIGBUS,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * and stop calling vm_ops methods.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 *
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* When revoke_mappings returns invocations =
of vm_ops->close
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* may still be in progress, but no invocati=
ons of any other
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* vm_ops methods will be.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* When revoke_mappings no invocations of an=
y method will be
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* in progress.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct prio_tree_iter iter;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&mapping->i_mmap_lock);
>>
>> + =C2=A0 =C2=A0 =C2=A0 WARN_ON(mapping->revoke_task);
>> + =C2=A0 =C2=A0 =C2=A0 mapping->revoke_task =3D current;
>> +
>> =C2=A0restart_tree:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0vma_prio_tree_foreach(vma, &iter, &mapping->i=
_mmap, 0, ULONG_MAX) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (revoke_mappin=
g(mapping, vma->vm_mm, vma->vm_start))
>> @@ -164,6 +166,16 @@ restart_list:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0goto restart_list;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> + =C2=A0 =C2=A0 =C2=A0 while (!list_empty(&mapping->i_mmap_nonlinear) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0!prio_tree_empty(&mapp=
ing->i_mmap) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mapping->close_count)
>> + =C2=A0 =C2=A0 =C2=A0 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __set_current_state(T=
ASK_UNINTERRUPTIBLE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&mapping-=
>i_mmap_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&mapping->i=
_mmap_lock);
>> + =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 mapping->revoke_task =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&mapping->i_mmap_lock);
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL_GPL(revoke_mappings);
>> --
>> 1.7.2.3
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
