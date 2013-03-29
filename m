Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id DCFFE6B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 01:30:23 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id r10so68992lbi.36
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 22:30:21 -0700 (PDT)
Message-ID: <515526EA.3090807@openvz.org>
Date: Fri, 29 Mar 2013 09:30:18 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] hugetlbfs: stop setting VM_DONTDUMP in initializing
 vma(VM_HUGETLB)
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com> <515477D4.1060206@openvz.org> <1364495358-2gnie765-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1364495358-2gnie765-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya Horiguchi wrote:
> On Thu, Mar 28, 2013 at 09:03:16PM +0400, Konstantin Khlebnikov wrote:
>> Naoya Horiguchi wrote:
>>> Currently we fail to include any data on hugepages into coredump,
>>> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
>>> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
>>> mm->reserved_vm counter". This looks to me a serious regression,
>>> so let's fix it.
>>
>> That was introduced in my patch? Really?
>> Here was VM_RESERVED and it had the same effect as VM_DONTDUMP. At least I thought so.
> 
> vma_dump_size() does like this (the diff is the one in 314e51b98):
> 
>     static unsigned long vma_dump_size(struct vm_area_struct *vma,
>     				   unsigned long mm_flags)
>     {
>     #define FILTER(type)	(mm_flags&  (1UL<<  MMF_DUMP_##type))
> 
>     	/* always dump the vdso and vsyscall sections */
>     	if (always_dump_vma(vma))
>     		goto whole;
> 
>    	if (vma->vm_flags&  VM_DONTDUMP)
>     		return 0;
> 
>     	/* Hugetlb memory check */
>     	if (vma->vm_flags&  VM_HUGETLB) {
>     		if ((vma->vm_flags&  VM_SHARED)&&  FILTER(HUGETLB_SHARED))
>     			goto whole;
>     		if (!(vma->vm_flags&  VM_SHARED)&&  FILTER(HUGETLB_PRIVATE))
>     			goto whole;
>     	}
> 
>     	/* Do not dump I/O mapped devices or special mappings */
>    -	if (vma->vm_flags&  (VM_IO | VM_RESERVED))
>    +	if (vma->vm_flags&  VM_IO)
>     		return 0;
> 
> We have hugetlb memory check after VM_DONTDUMP check, so the following
> changed the behavior.

Ok, I missed this in my patch.

> 
>    --- a/fs/hugetlbfs/inode.c
>    +++ b/fs/hugetlbfs/inode.c
>    @@ -110,7 +110,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>             * way when do_mmap_pgoff unwinds (may be important on powerpc
>             * and ia64).
>             */
>    -       vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
>    +       vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
>            vma->vm_ops =&hugetlb_vm_ops;
> 
>            if (vma->vm_pgoff&  (~huge_page_mask(h)>>  PAGE_SHIFT))
> 
> I think we don't have to set VM_DONTDUMP on hugetlbfs's vma.

Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

> 
> Thanks,
> Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
