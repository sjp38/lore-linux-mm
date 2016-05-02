Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 33C296B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 14:03:10 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id b14so304644950qge.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:03:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a88si15506046qgf.53.2016.05.02.11.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 11:03:09 -0700 (PDT)
Date: Mon, 2 May 2016 20:03:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160502180307.GB12310@redhat.com>
References: <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
 <20160502160042.GC24419@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502160042.GC24419@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 07:00:42PM +0300, Kirill A. Shutemov wrote:
> Sounds correct, but code is going to be ugly :-/

Now if a page is not shared in the parent, it is already in the local
anon_vma. The only thing we could lose here is a pmd split in the
child caused by swapping and then parent releases the page, child
reuse it but it stays in the anon_vma of the parent. It doesn't sound
like a major concern.

What we could to improve this though, is to do a rmap walk after the
physical split_huge_page succeeded, to relocate the page->mapping to
the local vma->anon_vma of the child if page_mapcount() is 1 before
releasing the (root) anon_vma lock. If a page got a pmd split it'll be
a candidate for a physical split if any of the ptes has been
unmapped.

If it wasn't because of THP in tmpfs the old THP refcounting overall I
think would have been simpler, it never had issues like these, but
having a single model for all THP sounds much easier to maintain over
time, instead of dealing with totally different models and rules and
locking for every filesystem and MM part. This is why I hope we'll
soon leverage all this work in tmpfs too. With tmpfs being able to map
the compound THP with both ptes and pmds is mandatory, the old
refcounting had a too big constraint to make compound THP work in tmpfs.

> I didn't say we shouldn't fix the problem on THP side. But the attitude
> "get_user_pages() would magically freeze page tables" worries me.

It doesn't need to freeze page tables, it only needs to prevent the
pages to be freed. In fact this bug cannot generate random kernel
corruption no matter what, but then userland view of the memory will
go out of sync and it can generate data corruption to userland (in RAM
or hardware device DMA).

What THP refcounting did is just to change some expectation on the
userland side in terms of when the view on the pinned pages would get
lost and replaced by copies, depending what userland did. A process to
invoke page pinning must have root (or enough capabilities anyway), so
it's somewhat connected to the kernel behavior, it's non standard.

However issues like this are userland visible even to not privileged
tasks, in fact it's strongly recommended to use MADV_DONTFORK on the
get_user_pages addresses, if a program is using
get_user_pages/O_DIRECT+fork+threads to avoid silent data corruption.

> Agreed. I just didn't see the two-refcounts solution.

If you didn't do it already or if you're busy with something else,
I can change the patch to the two refcount solution, which should
restore the old semantics without breaking rmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
