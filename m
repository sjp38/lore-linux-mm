Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 392FF6B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 03:15:16 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6253810iwn.14
        for <linux-mm@kvack.org>; Mon, 27 Sep 2010 00:15:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m1d3s19z38.fsf@fess.ebiederm.org>
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
	<m1d3s19z38.fsf@fess.ebiederm.org>
Date: Mon, 27 Sep 2010 10:15:14 +0300
Message-ID: <AANLkTik=6cGkkpBJUfhNJ8ZhB8MfFrm=zXWtLOP-S_ZR@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: Cause revoke_mappings to wait until all close
 methods have completed.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 26, 2010 at 2:34 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

The changelog is slightly too terse for me to review this. What's the
race you're trying to avoid? If the point is to make the revoke task
wait until everything has been closed, why can't we use the completion
API here?

> ---
> =A0include/linux/fs.h | =A0 =A02 ++
> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0| =A0 13 ++++++++++++-
> =A0mm/revoke.c =A0 =A0 =A0 =A0| =A0 18 +++++++++++++++---
> =A03 files changed, 29 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 76041b6..5d3d6b8 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -633,6 +633,8 @@ struct address_space {
> =A0 =A0 =A0 =A0const struct address_space_operations *a_ops; =A0 /* metho=
ds */
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags; =A0 =A0 =A0 =A0 =
=A0/* error bits/gfp mask */
> =A0 =A0 =A0 =A0struct backing_dev_info *backing_dev_info; /* device reada=
head, etc */
> + =A0 =A0 =A0 struct task_struct =A0 =A0 =A0*revoke_task; =A0 /* Who to w=
ake up when all vmas are closed */
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0close_count; =A0 =A0/* =
Cover race conditions with revoke_mappings */
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0private_lock; =A0 /*=
 for use by the address_space */
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0private_list; =A0 /* ditto=
 */
> =A0 =A0 =A0 =A0struct address_space =A0 =A0*assoc_mapping; /* ditto */
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 17dd003..3df3193 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -218,6 +218,7 @@ void unlink_file_vma(struct vm_area_struct *vma)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct address_space *mapping =3D file->f_=
mapping;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&mapping->i_mmap_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__remove_shared_vm_struct(vma, file, mappi=
ng);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->close_count++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&mapping->i_mmap_lock);
> =A0 =A0 =A0 =A0}
> =A0}
> @@ -233,9 +234,19 @@ static struct vm_area_struct *remove_vma(struct vm_a=
rea_struct *vma)
> =A0 =A0 =A0 =A0if (vma->vm_ops && vma->vm_ops->close)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vma->vm_ops->close(vma);
> =A0 =A0 =A0 =A0if (vma->vm_file) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(vma->vm_file);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct address_space *mapping =3D vma->vm_f=
ile->f_mapping;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vma->vm_flags & VM_EXECUTABLE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0removed_exe_file_vma(vma->=
vm_mm);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Decrement the close count and wake up a =
revoker if present */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mapping->i_mmap_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->close_count--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((mapping->close_count =3D=3D 0) && mapp=
ing->revoke_task)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Is wake_up_process the r=
ight variant of try_to_wake_up? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_process(mapping->re=
voke_task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mapping->i_mmap_lock);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(vma->vm_file);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0mpol_put(vma_policy(vma));
> =A0 =A0 =A0 =A0kmem_cache_free(vm_area_cachep, vma);
> diff --git a/mm/revoke.c b/mm/revoke.c
> index a76cd1a..e19f7df 100644
> --- a/mm/revoke.c
> +++ b/mm/revoke.c
> @@ -143,15 +143,17 @@ void revoke_mappings(struct address_space *mapping)
> =A0 =A0 =A0 =A0/* Make any access to previously mapped pages trigger a SI=
GBUS,
> =A0 =A0 =A0 =A0 * and stop calling vm_ops methods.
> =A0 =A0 =A0 =A0 *
> - =A0 =A0 =A0 =A0* When revoke_mappings returns invocations of vm_ops->cl=
ose
> - =A0 =A0 =A0 =A0* may still be in progress, but no invocations of any ot=
her
> - =A0 =A0 =A0 =A0* vm_ops methods will be.
> + =A0 =A0 =A0 =A0* When revoke_mappings no invocations of any method will=
 be
> + =A0 =A0 =A0 =A0* in progress.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct vm_area_struct *vma;
> =A0 =A0 =A0 =A0struct prio_tree_iter iter;
>
> =A0 =A0 =A0 =A0spin_lock(&mapping->i_mmap_lock);
>
> + =A0 =A0 =A0 WARN_ON(mapping->revoke_task);
> + =A0 =A0 =A0 mapping->revoke_task =3D current;
> +
> =A0restart_tree:
> =A0 =A0 =A0 =A0vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULO=
NG_MAX) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (revoke_mapping(mapping, vma->vm_mm, vm=
a->vm_start))
> @@ -164,6 +166,16 @@ restart_list:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart_list;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 while (!list_empty(&mapping->i_mmap_nonlinear) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0!prio_tree_empty(&mapping->i_mmap) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0mapping->close_count)
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TASK_UNINTERRUPTIBLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mapping->i_mmap_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mapping->i_mmap_lock);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mapping->revoke_task =3D NULL;
> =A0 =A0 =A0 =A0spin_unlock(&mapping->i_mmap_lock);
> =A0}
> =A0EXPORT_SYMBOL_GPL(revoke_mappings);
> --
> 1.7.2.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
