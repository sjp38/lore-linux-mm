Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id D605E6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:17:50 -0400 (EDT)
Received: by iedm5 with SMTP id m5so37398917ied.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:17:50 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id w20si3907994icc.3.2015.03.25.20.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 20:17:50 -0700 (PDT)
Received: by iedm5 with SMTP id m5so37398865ied.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:17:50 -0700 (PDT)
Date: Wed, 25 Mar 2015 20:17:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1503251754320.26501@davide-lnx3>
Message-ID: <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 25 Mar 2015, Davide Libenzi wrote:

> > When you say "tracking back to 3.2.x", I think you mean you've tried as
> > far back as 3.2.x and found the same behaviour, but not tried further?
> > 
> > From the source, it looks like this is unchanged since MAP_HUGETLB was
> > introduced in 2.6.32.  And is the same behaviour as you've been given
> > with hugetlbfs since it arrived in 2.5.46.
> 
> Went back checking the application logs, an I had to patch the code (the 
> application one - to align size on munmap()) on May 2014.
> But it might be we started noticing it at that time, because before the 
> allocation pattern was simply monotonic, so it could be it was always 
> there.
> The bug test app is ten lines of code, to verify that.
> 

I looked at this thread at http://marc.info/?t=141392508800001 since I 
didn't have it in my mailbox, and I didn't get a chance to actually run 
your test code.

In short, I think what you're saying is that

	ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...)
	munmap(ptr, 4KB) == EINVAL

> > The patch looks to me as if it will do what you want, and I agree
> > that it's displeasing that you can mmap a size, and then fail to
> > munmap that same size.
> > 
> > But I tend to think that's simply typical of the clunkiness we offer
> > you with hugetlbfs and MAP_HUGETLB: that it would have been better to
> > make a different choice all those years ago, but wrong to change the
> > user interface now.
> > 
> > Perhaps others will disagree.  And if I'm wrong, and the behaviour
> > got somehow changed in 3.2, then that's a different story and we
> > should fix it back.
> 
> This is not an interface change, in the sense old clients will continue to 
> work.
> This is simply respecting the mmap(2) POSIX specification, for a feature 
> which has been exposed via mmap(2).
> 

Respecting the mmap(2) POSIX specification?  I don't think 
mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...) mapping 2MB violates 
POSIX.1-2001 and not only because it obviously doesn't address 
MAP_HUGETLB, but I don't think the spec says the system cannot map more 
memory than len.

Using MAP_HUGETLB is really more a library function than anything else 
since you could easily implement the same behavior in a library.  That 
function includes aligning len to the hugepage size, so doing

	ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...)

is the equivalent to doing

	ptr = mmap(..., hugepage_size, ..., MAP_HUGETLB | ..., ...)

and that doesn't violate any spec.  But your patch doesn't change mmap() 
at all, so let's forget about that.

The question you pose is whether munmap(ptr, 4KB) should succeed for a 
hugetlb vma and in your patch you align this to the hugepage size of the 
vma in the same manner that munmap(ptr, 2KB) would be aligned to PAGE_SIZE 
for a non-hugetlb vma.

The munmap() spec says the whole pages that include any part of the passed 
length should be unmapped.  In spirit, I would agree with you that the 
page size for the vma is the hugepage size so that would be what would be 
unmapped.

But that's going by a spec that doesn't address hugepages and is worded in 
a way that {PAGE_SIZE} is the base unit that both mmap() and munmap() is 
done.  It carries no notion of variable page sizes and how hugepages 
should be handled with respect to pages of {PAGE_SIZE} length.  So I think 
this is beyond the scope of the spec: any length is aligned to PAGE_SIZE, 
but the munmap() behavior for hugetlb vmas is not restricted.

It would seem too dangerous at this point to change the behavior of 
munmap(ptr, 4KB) on a hugetlb vma and that userspace bugs could actually 
arise from aligning to the hugepage size.

Some applications purposefully reserve hugetlb pages by mmap() and never 
munmap() them so they have exclusive access to hugepages that were 
allocated either at boot or runtime by the sysadmin.  If they depend on 
the return value of munmap() to determine if memory to free is memory 
dynamically allocated by the application or reserved as hugetlb memory, 
then this would cause them to break.  I can't say for certain that no such 
application exists.

Since hugetlb memory is beyond the scope of the POSIX.1-2001 munmap() 
specification, and there's a potential userspace breakage if the length 
becomes hugepage aligned, I think the do_unmap() implementation is correct 
as it stands.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
