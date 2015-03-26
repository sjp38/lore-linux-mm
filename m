Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8CF6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:56:40 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so9911757pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:56:39 -0700 (PDT)
Received: from x35.xmailserver.org (x35.xmailserver.org. [64.71.152.41])
        by mx.google.com with ESMTPS id co6si8067221pdb.91.2015.03.26.04.56.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 04:56:38 -0700 (PDT)
Received: from mbplnx.local
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S42382A> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Thu, 26 Mar 2015 07:56:46 -0400
Date: Thu, 26 Mar 2015 04:56:33 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503260431290.2755@mbplnx>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 25 Mar 2015, David Rientjes wrote:

> I looked at this thread at http://marc.info/?t=141392508800001 since I 
> didn't have it in my mailbox, and I didn't get a chance to actually run 
> your test code.
> 
> In short, I think what you're saying is that
> 
> 	ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...)
> 	munmap(ptr, 4KB) == EINVAL

I am not sure you have read the email correctly:

munmap(mmap(size, HUGETLB), size) = EFAIL

For every size not multiple of the huge page size.
Whereas:

munmap(mmap(size, HUGETLB), ALIGN(size, HUGEPAGE_SIZE)) = OK


> Respecting the mmap(2) POSIX specification?  I don't think 
> mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...) mapping 2MB violates 
> POSIX.1-2001 and not only because it obviously doesn't address 
> MAP_HUGETLB, but I don't think the spec says the system cannot map more 
> memory than len.
> 
> Using MAP_HUGETLB is really more a library function than anything else 
> since you could easily implement the same behavior in a library.  That 
> function includes aligning len to the hugepage size, so doing
> 
> 	ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...)
> 
> is the equivalent to doing
> 
> 	ptr = mmap(..., hugepage_size, ..., MAP_HUGETLB | ..., ...)
> 
> and that doesn't violate any spec.  But your patch doesn't change mmap() 
> at all, so let's forget about that.

That is what every mmap() implementation does, irrespectively of any page 
size. And that is also what the POSIX spec states.
The size will be automatically rounded up to a multiple of the underline 
physical page size.
The problem is not mmap() though, in this case.


> The question you pose is whether munmap(ptr, 4KB) should succeed for a 
> hugetlb vma and in your patch you align this to the hugepage size of the 
> vma in the same manner that munmap(ptr, 2KB) would be aligned to PAGE_SIZE 
> for a non-hugetlb vma.
> 
> The munmap() spec says the whole pages that include any part of the passed 
> length should be unmapped.  In spirit, I would agree with you that the 
> page size for the vma is the hugepage size so that would be what would be 
> unmapped.
> 
> But that's going by a spec that doesn't address hugepages and is worded in 
> a way that {PAGE_SIZE} is the base unit that both mmap() and munmap() is 
> done.  It carries no notion of variable page sizes and how hugepages 
> should be handled with respect to pages of {PAGE_SIZE} length.  So I think 
> this is beyond the scope of the spec: any length is aligned to PAGE_SIZE, 
> but the munmap() behavior for hugetlb vmas is not restricted.
> 
> It would seem too dangerous at this point to change the behavior of 
> munmap(ptr, 4KB) on a hugetlb vma and that userspace bugs could actually 
> arise from aligning to the hugepage size.

You mean, there is an harder failure than the current failure? :)


> Some applications purposefully reserve hugetlb pages by mmap() and never 
> munmap() them so they have exclusive access to hugepages that were 
> allocated either at boot or runtime by the sysadmin.  If they depend on 
> the return value of munmap() to determine if memory to free is memory 
> dynamically allocated by the application or reserved as hugetlb memory, 
> then this would cause them to break.  I can't say for certain that no such 
> application exists.

The fact that certain applications will seldomly call an API, should be no 
reason for API to have bugs, or at the very least, a bahviour which not 
only in not documented in the man pages, but also totally unrespectful of 
the normal mmap/munmap semantics.
Again, the scenario that you are picturing, is one where an application 
relies on a permanent (that is what it is - it always fails unless the 
munmap size is multiple than huge page size) failure of munmap, to do some 
productive task.
An munmap() of huge page aligned size, will succeed in both case (vanilla, 
and patch).


> Since hugetlb memory is beyond the scope of the POSIX.1-2001 munmap() 
> specification, and there's a potential userspace breakage if the length 
> becomes hugepage aligned, I think the do_unmap() implementation is correct 
> as it stands.

If the length is huge page aligned, it will be working with or without 
patch applied.
The problem is for the other 2097151 out of 2097152 cases, where length is 
not indeed aligned to 2MB (or whatever hugepage size is for the 
architecture).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
