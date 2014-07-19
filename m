Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id E4FB66B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:12:02 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id hy4so9773557vcb.27
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:12:02 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id kt16si30516392icb.32.2014.07.19.09.12.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:12:01 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so5595145iec.29
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:12:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407090154070.7841@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-2-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407090154070.7841@eggly.anvils>
Date: Sat, 19 Jul 2014 18:12:01 +0200
Message-ID: <CANq1E4RRc5ZdCLyi7sp=M5faBWhper4A+Gb2oqicNr0GZ9Ff=g@mail.gmail.com>
Subject: Re: [PATCH v3 1/7] mm: allow drivers to prevent new writable mappings
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi Hugh

On Wed, Jul 9, 2014 at 10:55 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> The i_mmap_writable field counts existing writable mappings of an
>> address_space. To allow drivers to prevent new writable mappings, make
>> this counter signed and prevent new writable mappings if it is negative.
>> This is modelled after i_writecount and DENYWRITE.
>>
>> This will be required by the shmem-sealing infrastructure to prevent any
>> new writable mappings after the WRITE seal has been set. In case there
>> exists a writable mapping, this operation will fail with EBUSY.
>>
>> Note that we rely on the fact that iff you already own a writable mapping,
>> you can increase the counter without using the helpers. This is the same
>> that we do for i_writecount.
>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> I'm very pleased with the way you chose to do this in the end, following
> the way VM_DENYWRITE does it: it works out nicer than I had imagined.
>
> I do have some comments below, but the only one where I end up asking
> for a change is to remove the void "return "; but please read through
> in case any of my wonderings lead you to change your mind on something.
>
> I am very tempted to suggest that you add VM_WRITE into those VM_SHARED
> tests, and put the then necessary additional tests into mprotect.c: so
> that you would no longer have the odd case that a VM_SHARED !VM_WRITE
> area has to be unmapped before sealing the fd.
>
> But that would involve an audit of flush_dcache_page() architectures,
> and perhaps some mods to keep them safe across the mprotect(): let's
> put it down as a desirable future enhancement, just to remove an odd
> restriction.
>
> With the "return " gone,
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks for the review! Yes, allowing VM_SHARED without VM_WRITE would
be nice, but I think it would make this patchset more complex than it
already is. I agree that it's better done separately.

>> ---
>>  fs/inode.c         |  1 +
>>  include/linux/fs.h | 29 +++++++++++++++++++++++++++--
>>  kernel/fork.c      |  2 +-
>>  mm/mmap.c          | 24 ++++++++++++++++++------
>>  mm/swap_state.c    |  1 +
>>  5 files changed, 48 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/inode.c b/fs/inode.c
>> index 6eecb7f..9945b11 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -165,6 +165,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>>       mapping->a_ops = &empty_aops;
>>       mapping->host = inode;
>>       mapping->flags = 0;
>> +     atomic_set(&mapping->i_mmap_writable, 0);
>>       mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
>>       mapping->private_data = NULL;
>>       mapping->backing_dev_info = &default_backing_dev_info;
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 338e6f7..71d17c9 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -387,7 +387,7 @@ struct address_space {
>>       struct inode            *host;          /* owner: inode, block_device */
>>       struct radix_tree_root  page_tree;      /* radix tree of all pages */
>>       spinlock_t              tree_lock;      /* and lock protecting it */
>> -     unsigned int            i_mmap_writable;/* count VM_SHARED mappings */
>> +     atomic_t                i_mmap_writable;/* count VM_SHARED mappings */
>>       struct rb_root          i_mmap;         /* tree of private and shared mappings */
>>       struct list_head        i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
>>       struct mutex            i_mmap_mutex;   /* protect tree, count, list */
>> @@ -470,10 +470,35 @@ static inline int mapping_mapped(struct address_space *mapping)
>>   * Note that i_mmap_writable counts all VM_SHARED vmas: do_mmap_pgoff
>>   * marks vma as VM_SHARED if it is shared, and the file was opened for
>>   * writing i.e. vma may be mprotected writable even if now readonly.
>> + *
>> + * If i_mmap_writable is negative, no new writable mappings are allowed. You
>> + * can only deny writable mappings, if none exists right now.
>>   */
>>  static inline int mapping_writably_mapped(struct address_space *mapping)
>>  {
>> -     return mapping->i_mmap_writable != 0;
>> +     return atomic_read(&mapping->i_mmap_writable) > 0;
>
> I have a slight anxiety that you're halving the writable range here:
> but I think that if we can overflow with this change, we could overflow
> before; and there are int counts elsewhere which would overflow easier.

Currently you need a new vm_area_struct to increase that counter.
vm_area_struct is about 144 bytes, times INT_MAX is something around
300GB. This does indeed look like a limit that can be reached not far
from now on common machines. I somehow doubt it's the only atomic that
might overflow soon, though. And there's always RLIMIT_AS you can set
to avoid such attacks.

I wouldn't oppose to using atomic_long_t, though. Many VM counters
already use atomic_long_t instead of atomic_t.

>> +}
>> +
>> +static inline int mapping_map_writable(struct address_space *mapping)
>> +{
>> +     return atomic_inc_unless_negative(&mapping->i_mmap_writable) ?
>> +             0 : -EPERM;
>> +}
>> +
>> +static inline void mapping_unmap_writable(struct address_space *mapping)
>> +{
>> +     return atomic_dec(&mapping->i_mmap_writable);
>
> Better just
>
>         atomic_dec(&mapping->i_mmap_writable);
>
> I didn't realize before that the compiler allows you to return a void
> function from a void function without warning, but better not rely on that.

Fixed, thanks.

>> +}
>> +
>> +static inline int mapping_deny_writable(struct address_space *mapping)
>> +{
>> +     return atomic_dec_unless_positive(&mapping->i_mmap_writable) ?
>> +             0 : -EBUSY;
>> +}
>> +
>> +static inline void mapping_allow_writable(struct address_space *mapping)
>> +{
>> +     atomic_inc(&mapping->i_mmap_writable);
>>  }
>>
>>  /*
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index d2799d1..f1f127e 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -421,7 +421,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>>                               atomic_dec(&inode->i_writecount);
>>                       mutex_lock(&mapping->i_mmap_mutex);
>>                       if (tmp->vm_flags & VM_SHARED)
>> -                             mapping->i_mmap_writable++;
>> +                             atomic_inc(&mapping->i_mmap_writable);
>>                       flush_dcache_mmap_lock(mapping);
>>                       /* insert tmp into the share list, just after mpnt */
>>                       if (unlikely(tmp->vm_flags & VM_NONLINEAR))
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 129b847..19b6562 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -216,7 +216,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
>>       if (vma->vm_flags & VM_DENYWRITE)
>>               atomic_inc(&file_inode(file)->i_writecount);
>>       if (vma->vm_flags & VM_SHARED)
>> -             mapping->i_mmap_writable--;
>> +             mapping_unmap_writable(mapping);
>
> Okay.  I waste ridiculous time trying to decide whether it's better to say
>
>                 mapping_unmap_writable(mapping)
> or
>                 atomic_dec(&mapping->i_mmap_writable);
>
> here: there are consistency arguments both ways.  I usually solve this
> problem by not giving wrapper names to such operations, but in this case
> I think the answer is just to accept whatever you decided was best.
>
>>
>>       flush_dcache_mmap_lock(mapping);
>>       if (unlikely(vma->vm_flags & VM_NONLINEAR))
>> @@ -617,7 +617,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
>>               if (vma->vm_flags & VM_DENYWRITE)
>>                       atomic_dec(&file_inode(file)->i_writecount);
>>               if (vma->vm_flags & VM_SHARED)
>> -                     mapping->i_mmap_writable++;
>> +                     atomic_inc(&mapping->i_mmap_writable);
>>
>>               flush_dcache_mmap_lock(mapping);
>>               if (unlikely(vma->vm_flags & VM_NONLINEAR))
>> @@ -1572,6 +1572,11 @@ munmap_back:
>>                       if (error)
>>                               goto free_vma;
>>               }
>> +             if (vm_flags & VM_SHARED) {
>> +                     error = mapping_map_writable(file->f_mapping);
>> +                     if (error)
>> +                             goto allow_write_and_free_vma;
>> +             }
>>               vma->vm_file = get_file(file);
>>               error = file->f_op->mmap(file, vma);
>>               if (error)
>> @@ -1611,8 +1616,12 @@ munmap_back:
>>
>>       vma_link(mm, vma, prev, rb_link, rb_parent);
>>       /* Once vma denies write, undo our temporary denial count */
>> -     if (vm_flags & VM_DENYWRITE)
>> -             allow_write_access(file);
>> +     if (file) {
>> +             if (vm_flags & VM_SHARED)
>> +                     mapping_unmap_writable(file->f_mapping);
>> +             if (vm_flags & VM_DENYWRITE)
>> +                     allow_write_access(file);
>> +     }
>>       file = vma->vm_file;
>
> Very good.  A bit subtle, and for a while I was preparing to warn you
> of the odd shmem_zero_setup() case (which materializes a file when
> none came in), and the danger of the count going wrong on that.
>
> But you have it handled, with the "if (file)" block immediately before
> the new assignment of file, which should force anyone to think about it.
> And the ordering here, with respect to file and error exits, has always
> been tricky - I don't think you are making it any worse.

I tried to keep it as similar to VM_DENYWRITE as possible. It's not
really obvious and I had to read it several times, too. But looks all
fine to me now.

> Oh, more subtle than I realized above: I've just gone through a last
> minute "hey, it's wrong; oh, no, it's okay" waver here, remembering
> how mmap /dev/zero (and some others, I suppose) gives you a new file.
>
> That is okay: we don't even have to assume that sealing is limited
> to your memfd_create(): it's safe to assume that any device which
> forks you a new file, is safe to assert mapping_map_writable() upon
> temporarily; and the new file given could never come already sealed.
>
> But maybe a brief comment to reassure us in future?

I added a comment explaining that ->mmap has to make sure vma_link()
succeeds in raising these counters in case it modified vma->vm_file.
All users I found return files that haven't been exposed to user-space
at that point, therefore they're safe. They also don't do initial
sealing or VM_DENYWRITE, so they are safe in both regards.

>>  out:
>>       perf_event_mmap(vma);
>> @@ -1641,14 +1650,17 @@ out:
>>       return addr;
>>
>>  unmap_and_free_vma:
>> -     if (vm_flags & VM_DENYWRITE)
>> -             allow_write_access(file);
>>       vma->vm_file = NULL;
>>       fput(file);
>>
>>       /* Undo any partial mapping done by a device driver. */
>>       unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
>>       charged = 0;
>> +     if (vm_flags & VM_SHARED)
>> +             mapping_unmap_writable(file->f_mapping);
>> +allow_write_and_free_vma:
>> +     if (vm_flags & VM_DENYWRITE)
>> +             allow_write_access(file);
>
> Okay.  I don't enjoy that rearrangement, such that those two uses of
> file come after the fput(file); but I believe there are good reasons
> why it can never be the final fput(file), so I think you're okay.

Actually, the fput(file) should rather be "put(vma->vm_file). The
reference we free here is not the reference that we got passed by the
syscall-context, but it's the reference we took for vma->vm_file.
Therefore, I think it's fine to access "file" afterwards, as this is
an independent reference. The vma->vm_file reference is also taken
_after_ doing VM_DENYWRITE and VM_SHARED accounting. Therefore, I put
the cleanup of vma->vm_file before reverting the counters for
symmetry's sake.

Note that we cannot turn fput(file) into fput(vma->vm_file), though.
The vma->vm_file field might be left set to something else after
->mmap() failed.

Thanks
David

>>  free_vma:
>>       kmem_cache_free(vm_area_cachep, vma);
>>  unacct_error:
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 2972eee..31321fa 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -39,6 +39,7 @@ static struct backing_dev_info swap_backing_dev_info = {
>>  struct address_space swapper_spaces[MAX_SWAPFILES] = {
>>       [0 ... MAX_SWAPFILES - 1] = {
>>               .page_tree      = RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
>> +             .i_mmap_writable = ATOMIC_INIT(0),
>>               .a_ops          = &swap_aops,
>>               .backing_dev_info = &swap_backing_dev_info,
>>       }
>> --
>> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
