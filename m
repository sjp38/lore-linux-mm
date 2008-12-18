Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6706F6B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 13:14:39 -0500 (EST)
Message-ID: <494A9350.1060309@google.com>
Date: Thu, 18 Dec 2008 10:15:44 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu> <4949B4ED.9060805@google.com> <494A2F94.2090800@cs.columbia.edu>
In-Reply-To: <494A2F94.2090800@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Oren Laadan wrote:
> 
> Mike Waychison wrote:
>> Comments below.
> 
> Thanks for the detailed review.
> 
>> Oren Laadan wrote:
>>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>>> it will be followed by the file name. Then comes the actual contents,
>>> in one or more chunk: each chunk begins with a header that specifies
>>> how many pages it holds, then the virtual addresses of all the dumped
>>> pages in that chunk, followed by the actual contents of all dumped
>>> pages. A header with zero number of pages marks the end of the contents.
>>> Then comes the next VMA and so on.
>>>
> 
> [...]
> 
>>> +    mutex_lock(&mm->context.lock);
>>> +
>>> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
>>> +    hh->nldt = mm->context.size;
>>> +
>>> +    cr_debug("nldt %d\n", hh->nldt);
>>> +
>>> +    ret = cr_write_obj(ctx, &h, hh);
>>> +    cr_hbuf_put(ctx, sizeof(*hh));
>>> +    if (ret < 0)
>>> +        goto out;
>>> +
>>> +    ret = cr_kwrite(ctx, mm->context.ldt,
>>> +            mm->context.size * LDT_ENTRY_SIZE);
>> Do we really want to emit anything under lock?  I realize that this
>> patch goes and does a ton of writes with mmap_sem held for read -- is
>> this ok?
> 
> Because all tasks in the container must be frozen during the checkpoint,
> there is no performance penalty for keeping the locks. Although the object
> should not change in the interim anyways, the locks protects us from, e.g.
> the task unfreezing somehow, or being killed by the OOM killer, or any
> other change incurred from the "outside world" (even future code).
> 
> Put in other words - in the long run it is safer to assume that the
> underlying object may otherwise change.
> 
> (If we want to drop the lock here before cr_kwrite(), we need to copy the
> data to a temporary buffer first. If we also want to drop mmap_sem(), we
> need to be more careful with following the vma's.)
> 
> Do you see a reason to not keeping the locks ?
> 

I just thought it was a bit ugly, but I can't think of a case 
specifically where it's going to cause us harm.  If tasks are frozen, 
are they still subject to the oom killer?   Even that should be 
reasonably ok considering that the exit-path requires a 
down_read(mmap_sem) (at least, it used to..  I haven't gone over that 
path in a while..).



>>> +/* allocate a single page-array object */
>>> +static struct cr_pgarr *cr_pgarr_alloc_one(unsigned long flags)
>>> +{
>>> +    struct cr_pgarr *pgarr;
>>> +
>>> +    pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
>>> +    if (!pgarr)
>>> +        return NULL;
>>> +
>>> +    pgarr->vaddrs = kmalloc(CR_PGARR_TOTAL * sizeof(unsigned long),
>> You used PAGE_SIZE / sizeof(void *) above.   Why not __get_free_page()?
> 
> Hahaha .. well, it's a guaranteed method to keep Dave Hansen from
> barking about not using kmalloc ...
> 
> Personally I prefer __get_free_page() here, but not enough to keep
> arguing with him. Let me know when the two of you settle it :)

Alright, I just wasn't sure if it had been considered.



> 
>>> +{
>>> +    unsigned long end = vma->vm_end;
>>> +    unsigned long addr = *start;
>>> +    int orig_used = pgarr->nr_used;
>>> +
>>> +    /* this function is only for private memory (anon or file-mapped) */
>>> +    BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
>>> +
>>> +    while (addr < end) {
>>> +        struct page *page;
>>> +
>>> +        page = cr_private_follow_page(vma, addr);
>>> +        if (IS_ERR(page))
>>> +            return PTR_ERR(page);
>>> +
>>> +        if (page) {
>>> +            pgarr->pages[pgarr->nr_used] = page;
>>> +            pgarr->vaddrs[pgarr->nr_used] = addr;
>>> +            pgarr->nr_used++;
>> Should be something like:
>>
>> ret = cr_ctx_append_page(ctx, addr, page);
>> if (ret < 0)
>>   goto out;
> 
> My concern here is performance: keeping track of @pgarr avoids the
> reference through ctx. We may loop over MBs of memory, tens of
> thousands of pages, in individual VMAs.
> 

Even scanning over a large amount of memory, you aren't going to see a 
performance difference for accessing pgarr from an argument vs off of 
field in ctx which is going to be cache-hot.

> 
>>> +    if (vma->vm_file) {
>>> +        ret = cr_write_fname(ctx, &vma->vm_file->f_path, &ctx->fs_mnt);
>> Why is this using a filename, rather than a reference to a file?
> 
> Could be a reference to a file, but it isn't strictly necessary (*) and it
> won't improve performance that much. won't gain that much.
> 
> Not necessary: open files may be shared and then we _must_ use the same file
> pointer. In contrast, with memory mapping only needs _an_ open file.
> Won't gain much: because file pointers of mapped regions are usually only
> shared in the case of fork() without a following exec().
> 
> (*) It is strictly necessary when it comes to handling shared memory.
> 
> So I left this optimization for later.

I'm not sure I'm comfortable with churning on the file-format too much.

> 
>> Shouldn't this use the logic in patch 8/13?
> 
> Yes. But need to make sure (especially on the restart side) to consider the
> exceptions - e.g. a file in SHMFS used for anonymous shared memory, etc.
> 
> So yes, I'll add a FIXME comment there.

Right.

> 
>>> +        if (ret < 0)
>>> +            return ret;
>>> +    }
> 
> [...]
> 
>>> +enum vm_type {
>>> +    CR_VMA_ANON = 1,
>>> +    CR_VMA_FILE
>> We need to figure out what MAP_SHARED | MAP_ANONYMOUS should be exposed
>> as in this setup (much in the same way we need to start defining what
>> shm mappings look like).  Internally, they are 'file-backed', but to
>> userland, they aren't.
>>
>>
>> Thoughts?
> 
> Eventually we'll have CR_VMA_ANON_SHM, CR_VMA_FILE_SHM, CR_VMA_IPC_SHM,
> to identify the vma type. There will also be a flag "skip" that says that
> the actual contents of the memory has already been copied earlier. (And,
> for completeness, a flags "xfile" which indicated that the referenced
> file is unlinked, in the case of CR_VMA_FILE and CR_VMA_FILE_SHM).
> 
> It's not a lot of work, only that I'm actually holding back on adding
> more features, and focus on getting this into -mm tree first. I don't
> want to write lots of code and then modify it again and again...
> 
>>> +};
>>> +
>>> +struct cr_hdr_vma {
>>> +    __u32 vma_type;
>>> +    __u32 _padding;
>> Why padding?
> 
> For 64 bit architectures. See this threads:
> https://lists.linux-foundation.org/pipermail/containers/2008-August/012318.html
> 
> Quoting Arnd Bergmann:
>   "This structure has an odd multiple of 32-bit members, which means
>   that if you put it into a larger structure that also contains
>   64-bit members, the larger structure may get different alignment
>   on x86-32 and x86-64, which you might want to avoid.
>   I can't tell if this is an actual problem here.
>   ...
>   ...
>   In this case, I'm pretty sure that sizeof(cr_hdr_task) on x86-32 is
>   different from x86-64, since it will be 32-bit aligned on x86-32."
> 

Ok.  Please add the above note to the structure to explain it to the 
next wanderer reading this code :)

Mike Waychison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
