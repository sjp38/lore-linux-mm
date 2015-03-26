Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC406B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:15:26 -0400 (EDT)
Received: by igcau2 with SMTP id au2so1050109igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:15:26 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id k10si84085igx.62.2015.03.26.12.15.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 12:15:25 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so975921igb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:15:25 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:15:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1503260431290.2755@mbplnx>
Message-ID: <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503260431290.2755@mbplnx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 26 Mar 2015, Davide Libenzi wrote:

> > I looked at this thread at http://marc.info/?t=141392508800001 since I 
> > didn't have it in my mailbox, and I didn't get a chance to actually run 
> > your test code.
> > 
> > In short, I think what you're saying is that
> > 
> > 	ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...)
> > 	munmap(ptr, 4KB) == EINVAL
> 
> I am not sure you have read the email correctly:
> 
> munmap(mmap(size, HUGETLB), size) = EFAIL
> 
> For every size not multiple of the huge page size.
> Whereas:
> 
> munmap(mmap(size, HUGETLB), ALIGN(size, HUGEPAGE_SIZE)) = OK
> 

Yes, I read it correctly, and wrote how your test case should have failed 
above.  It fails when you do the 4KB mmap() with MAP_HUGETLB and pass 4KB 
to munmap(), correct?

I have no idea what EFAIL is, though.

> > The question you pose is whether munmap(ptr, 4KB) should succeed for a 
> > hugetlb vma and in your patch you align this to the hugepage size of the 
> > vma in the same manner that munmap(ptr, 2KB) would be aligned to PAGE_SIZE 
> > for a non-hugetlb vma.
> > 
> > The munmap() spec says the whole pages that include any part of the passed 
> > length should be unmapped.  In spirit, I would agree with you that the 
> > page size for the vma is the hugepage size so that would be what would be 
> > unmapped.
> > 
> > But that's going by a spec that doesn't address hugepages and is worded in 
> > a way that {PAGE_SIZE} is the base unit that both mmap() and munmap() is 
> > done.  It carries no notion of variable page sizes and how hugepages 
> > should be handled with respect to pages of {PAGE_SIZE} length.  So I think 
> > this is beyond the scope of the spec: any length is aligned to PAGE_SIZE, 
> > but the munmap() behavior for hugetlb vmas is not restricted.
> > 
> > It would seem too dangerous at this point to change the behavior of 
> > munmap(ptr, 4KB) on a hugetlb vma and that userspace bugs could actually 
> > arise from aligning to the hugepage size.
> 
> You mean, there is an harder failure than the current failure? :)
> 

Yes, this munmap() behavior of lengths <= hugepage_size - PAGE_SIZE for a 
hugetlb vma is long standing and there may be applications that break as a 
result of changing the behavior: a database that reserves all allocated 
hugetlb memory with mmap() so that it always has exclusive access to those 
hugepages, whether they are faulted or not, and maintains its own hugepage 
pool (which is common), may test the return value of munmap() and depend 
on it returning -EINVAL to determine if it is freeing memory that was 
either dynamically allocated or mapped from the hugetlb reserved pool.

> > Some applications purposefully reserve hugetlb pages by mmap() and never 
> > munmap() them so they have exclusive access to hugepages that were 
> > allocated either at boot or runtime by the sysadmin.  If they depend on 
> > the return value of munmap() to determine if memory to free is memory 
> > dynamically allocated by the application or reserved as hugetlb memory, 
> > then this would cause them to break.  I can't say for certain that no such 
> > application exists.
> 
> The fact that certain applications will seldomly call an API, should be no 
> reason for API to have bugs, or at the very least, a bahviour which not 
> only in not documented in the man pages, but also totally unrespectful of 
> the normal mmap/munmap semantics.

If we were to go back in time and decide this when the munmap() behavior 
for hugetlb vmas was originally introduced, that would be valid.  The 
problem is that it could lead to userspace breakage and that's a 
non-starter.

What we can do is improve the documentation and man-page to clearly 
specify the long-standing behavior so that nobody encounters unexpected 
results in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
