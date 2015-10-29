Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id A02C982F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:33:36 -0400 (EDT)
Received: by oiao187 with SMTP id o187so38021498oia.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:33:36 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id d7si1381991oeu.70.2015.10.29.08.33.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 08:33:35 -0700 (PDT)
Received: by oies66 with SMTP id s66so37753844oie.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013123028.GA12934@node>
References: <CACT4Y+aqaR8QYk2nyN1n1iaSZWofBEkWuffvsfcqpvmGGQyMAw@mail.gmail.com>
 <20151012122702.GC2544@node> <20151012174945.GC3170@linux-uzut.site>
 <20151012181040.GC6447@node> <20151012185533.GD3170@linux-uzut.site>
 <20151013031821.GA3052@linux-uzut.site> <20151013123028.GA12934@node>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 29 Oct 2015 23:33:14 +0800
Message-ID: <CACT4Y+ZBdLqPdW+fJm=-=zJfbVFgQsgiy+eqiDTWp9rW43u+tw@mail.gmail.com>
Subject: Re: GPF in shm_lock ipc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, dave.hansen@linux.intel.com, Hugh Dickins <hughd@google.com>, Joe Perches <joe@perches.com>, sds@tycho.nsa.gov, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, mhocko@suse.cz, gang.chen.5i5j@gmail.com, Peter Feiner <pfeiner@google.com>, aarcange@redhat.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>, Manfred Spraul <manfred@colorfullife.com>

On Tue, Oct 13, 2015 at 8:30 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Oct 12, 2015 at 08:18:21PM -0700, Davidlohr Bueso wrote:
>> On Mon, 12 Oct 2015, Bueso wrote:
>>
>> >On Mon, 12 Oct 2015, Kirill A. Shutemov wrote:
>> >
>> >>On Mon, Oct 12, 2015 at 10:49:45AM -0700, Davidlohr Bueso wrote:
>> >>>diff --git a/ipc/shm.c b/ipc/shm.c
>> >>>index 4178727..9615f19 100644
>> >>>--- a/ipc/shm.c
>> >>>+++ b/ipc/shm.c
>> >>>@@ -385,9 +385,25 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
>> >>>static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>> >>>{
>> >>>-  struct shm_file_data *sfd = shm_file_data(file);
>> >>>+  struct file *vma_file = vma->vm_file;
>> >>>+  struct shm_file_data *sfd = shm_file_data(vma_file);
>> >>>+  struct ipc_ids *ids = &shm_ids(sfd->ns);
>> >>>+  struct kern_ipc_perm *shp;
>> >>>   int ret;
>> >>>+  rcu_read_lock();
>> >>>+  shp = ipc_obtain_object_check(ids, sfd->id);
>> >>>+  if (IS_ERR(shp)) {
>> >>>+          ret = -EINVAL;
>> >>>+          goto err;
>> >>>+  }
>> >>>+
>> >>>+  if (!ipc_valid_object(shp)) {
>> >>>+          ret = -EIDRM;
>> >>>+          goto err;
>> >>>+  }
>> >>>+  rcu_read_unlock();
>> >>>+
>> >>
>> >>Hm. Isn't it racy? What prevents IPC_RMID from happening after this point?
>> >
>> >Nothing, but that is later caught by shm_open() doing similar checks. We
>> >basically end up doing a check between ->mmap() calls, which is fair imho.
>> >Note that this can occur anywhere in ipc as IPC_RMID is a user request/cmd,
>> >and we try to respect it -- thus you can argue this race anywhere, which is
>> >why we have EIDRM/EINVL. Ultimately the user should not be doing such hacks
>> >_anyway_. So I'm not really concerned about it.
>> >
>> >Another similar alternative would be perhaps to make shm_lock() return an
>> >error, and thus propagate that error to mmap return. That way we would have
>> >a silent way out of the warning scenario (afterward we cannot race as we
>> >hold the ipc object lock). However, the users would now have to take this
>> >into account...
>> >
>> >    [validity check lockless]
>> >    ->mmap()
>> >    [validity check lock]
>>
>> Something like this, maybe. Although I could easily be missing things...
>> I've tested it enough to see Dimitry's testcase handled ok, and put it
>> through ltp. Also adding Manfred to the Cc, who always catches my idiotic
>> mistakes.
>>
>> 8<---------------------------------------------------------------------
>> From: Davidlohr Bueso <dave@stgolabs.net>
>> Date: Mon, 12 Oct 2015 19:38:34 -0700
>> Subject: [PATCH] ipc/shm: fix handling of (re)attaching to a deleted segment
>>
>> There are currently two issues when dealing with segments that are
>> marked for deletion:
>>
>> (i) With d0edd8528362 (ipc: convert invalid scenarios to use WARN_ON)
>> we relaxed the system-wide impact of using a deleted segment. However,
>> we can now perfectly well trigger the warning and then deference a nil
>> pointer -- where shp does not exist.
>>
>> (ii) As of a399b29dfbaa (ipc,shm: fix shm_file deletion races) we
>> forbid attaching/mapping a previously deleted segment; a feature once
>> unique to Linux, but removed[1] as a side effect of lockless ipc object
>> lookups and security checks. Similarly, Dmitry Vyukov reported[2] a
>> simple test case that creates a new vma for a previously deleted
>> segment, triggering the WARN_ON mentioned in (i).
>>
>> This patch tries to address (i) by moving the shp error check out
>> of shm_lock() and handled by the caller instead. The benefit of this
>> is that it allows better handling out of situations where we end up
>> returning ERMID or EINVAL. Specifically, there are three callers
>> of shm_lock which we must look into:
>>
>>  - open/close -- which we ensure to never do any operations on
>>                  the pairs, thus becoming no-ops if found a prev
>>                IPC_RMID.
>>
>>  - loosing the reference of nattch upon shmat(2) -- not feasible.
>>
>> In addition, the common WARN_ON call is technically removed, but
>> we add a new one for the bogus shmat(2) case, which is definitely
>> unacceptable to race with RMID if nattch is bumped up.
>>
>> To address (ii), a new shm_check_vma_validity() helper is added
>> (for lack of a better name), which attempts to detect early on
>> any races with RMID, before doing the full ->mmap. There is still
>> a window between the callback and the shm_open call where we can
>> race with IPC_RMID. If this is the case, it is handled by the next
>> shm_lock().
>>
>> shm_mmap:
>>     [shm validity checks lockless]
>>     ->mmap()
>>     [shm validity checks lock] <-- at this point there after there
>>                                    is no race as we hold the ipc
>>                                    object lock.
>>
>> [1] https://lkml.org/lkml/2015/10/12/483
>> [2] https://lkml.org/lkml/2015/10/12/284
>>
>> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>> ---
>>  ipc/shm.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
>>  1 file changed, 73 insertions(+), 5 deletions(-)
>>
>> diff --git a/ipc/shm.c b/ipc/shm.c
>> index 4178727..47a7a67 100644
>> --- a/ipc/shm.c
>> +++ b/ipc/shm.c
>> @@ -156,11 +156,10 @@ static inline struct shmid_kernel *shm_lock(struct ipc_namespace *ns, int id)
>>       struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
>>       /*
>> -      * We raced in the idr lookup or with shm_destroy().  Either way, the
>> -      * ID is busted.
>> +      * Callers of shm_lock() must validate the status of the returned
>> +      * ipc object pointer (as returned by ipc_lock()), and error out as
>> +      * appropriate.
>>        */
>> -     WARN_ON(IS_ERR(ipcp));
>> -
>>       return container_of(ipcp, struct shmid_kernel, shm_perm);
>>  }
>> @@ -194,6 +193,15 @@ static void shm_open(struct vm_area_struct *vma)
>>       struct shmid_kernel *shp;
>>       shp = shm_lock(sfd->ns, sfd->id);
>> +     /*
>> +      * We raced in the idr lookup or with shm_destroy().
>> +      * Either way, the ID is busted. In the same scenario,
>> +      * but for the close counter-part, the nattch counter
>> +      * is never decreased, thus we can safely return.
>> +      */
>> +     if (IS_ERR(shp))
>> +             return; /* no-op */
>> +
>>       shp->shm_atim = get_seconds();
>>       shp->shm_lprid = task_tgid_vnr(current);
>>       shp->shm_nattch++;
>
> ...
>
>>  static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>>  {
>>       struct shm_file_data *sfd = shm_file_data(file);
>>       int ret;
>> +     /*
>> +      * Ensure that we have not raced with IPC_RMID, such that
>> +      * we avoid doing the ->mmap altogether. This is a preventive
>> +      * lockless check, and thus exposed to races during the mmap.
>> +      * However, this is later caught in shm_open(), and handled
>> +      * accordingly.
>> +      */
>> +     ret = shm_check_vma_validity(vma);
>> +     if (ret)
>> +             return ret;
>> +
>>       ret = sfd->file->f_op->mmap(sfd->file, vma);
>>       if (ret != 0)
>>               return ret;
>> +
>>       sfd->vm_ops = vma->vm_ops;
>>  #ifdef CONFIG_MMU
>>       WARN_ON(!sfd->vm_ops->fault);
>
> If I read it correctly, with the patch we would ignore locking failure
> inside shm_open() and mmap will succeed in this case. So the idea is to
> have shm_close() no-op and therefore symmetrical. That's look fragile to
> me. We would silently miss some other broken open/close pattern.
>
> I would rather propagate error to shm_mmap() caller and therefore to
> userspace. I guess it's better to opencode shm_open() in shm_mmap() and
> return error this way. shm_open() itself can have WARN_ON_ONCE() for
> failure or something.


Davidlohr, any updates on this? Is it committed? I don't see it in Linus tree.
What do you think about Kirill's comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
