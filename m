Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAA276B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:42:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o187so11983127qke.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:42:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y190si1627465qkc.96.2017.10.20.15.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 15:42:33 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
Date: Fri, 20 Oct 2017 15:42:25 -0700
MIME-Version: 1.0
In-Reply-To: <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/19/2017 12:34 AM, C.Wehrmeyer wrote:
> I apologise in case this message is going to arrive multiple times at the mailing list. I've had connection problems this morning while trying to push it through regardless, but it might or might not have been sent properly. I'm sorry for the inconvenience.
> 
> On 2017-10-08 18:47 Mike Kravetz wrote:
>> You are correct.  That check in function vma_to_resize() will prevent
>> mremap from growing or relocating hugetlb backed mappings.  This check
>> existed in the 2.6.0 linux kernel, so this restriction has existed for
>> a very long time.  I'm guessing that growing or relocating a hugetlb
>> mapping was never allowed.  Perhaps the mremap man page should list this
>> restriction.
> 
> I do not see such mentioning:
> 
> http://man7.org/linux/man-pages/man2/mremap.2.html
> 
> The author(s) deliberately use the term "page aligned", without specifying the page size that was used creating the initial mapping. And even more:
> 
>> mremap() uses the Linux page table scheme.  mremap() changes the
>> mapping between virtual addresses and memory pages.  This can be used
>> to implement a very efficient realloc(3).
> 
> There is not much of a very efficient realloc(3) left if you cannot modify mappings with a higher page size, is there?
> 
>> Is there a specific use case where the ability to grow hugetlb mappings
>> is desired?  Adding this functionality would involve more than simply
>> removing the above if statement.  One area of concern would be hugetlb
>> huge page reservations.  If there is a compelling use case, adding the
>> functionality may be worth consideration.  If not, I suggest we just
>> document the limitation.
> 
> Paging was introduced to the x86 processor family with the 80386 in 1985, with 4 KiBs per default. It's been 32 years since that, and modern CPUs in the consumer market have support for 2 MiB and 1 GiB pages, and yet default allocators usually just stick to the default without bothering whether or not there actually are hugepages available.
> 
> One 2-MiB page removes 512 4-KiB pages from the TLB, seeing as at least my TLBs are specialised in buffering one type of pages. I'm certain that at some point in the future the need for deliberately reserving hugepages via the kernel interface is going to be removed, and hugepages will become the usual way of allocating memory.
> 
> As for the specific use case: I've written my own allocator that is not bound on the same limitations that usual malloc/realloc/free allocators are bound. As such I want to be able to eliminate as many page walks as possible.
> 
> Just excepting the limitation would put Linux down on the same level as the Windows API, where no VirtualRealloc exists. My allocator needs to work with Linux and Windows; for the latter one I'm already managing a table of consecutive mappings in user-space that, if a relocation has to be made, creates an entirely new mapping into which the data of the previous mappings is copied. This is redundant, because the kernel and the process keep their own copies of the mapping table, and this is slow because the kernel could just re-adjust the position within the address space, whereas the process has to memcpy all the data from the old to the new mappings.
> 
> Those are the very problems mremap was supposed to remove in the first place. Making the limitation documented is the lazy way that will force implementers to workaround it.

mremap has never supported moving or growing hugetlb mappings.  Someone
(before git history) added this explicit check to the mremap code.  Perhaps
it was done when huge page support was introduced?

I am of the opinion that we should simply document this limitation.  AFAIK,
this this the first time anyone has asked about it in 15 years.  What is the
opinion of others?

>From a 'scope of work' perspective, I think moving hugetlb mappings should
be pretty straight forward.  The bigger issue is in growing, and managing
huge page reservations when growing.

-- 
Mike Kravetz

> 
> As for any kind of speed penalty that this might introduce (because flags have to be checked, interfaces to be changed, and constants to be replaced): hugepages will also remove the need to allocate memory. My allocator just doesn't call the kernel each time it requires memory, but only when it is absolutely necessary. That necessity can be postponed the larger the mapping is that I can allocate in one go.
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
