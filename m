Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69F8B6B0328
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 10:40:35 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so125740366ita.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 07:40:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d30si2724740ioj.19.2016.11.17.07.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 07:40:34 -0800 (PST)
Date: Thu, 17 Nov 2016 16:40:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
Message-ID: <20161117154031.GA10229@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
 <20161116182809.GC26185@redhat.com>
 <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Wed, Nov 16, 2016 at 10:53:39AM -0800, Mike Kravetz wrote:
> I was running some tests with error injection to exercise the error
> path and noticed the reservation leaks as the system eventually ran
> out of huge pages.  I need to think about it some more, but we may
> want to at least do something like the following before put_page (with
> a BIG comment):
> 
> 	if (unlikely(PagePrivate(page)))
> 		ClearPagePrivate(page);
> 
> That would at least keep the global reservation count from increasing.
> Let me look into that.

However what happens if the old vma got munmapped and a new compatible
vma was instantiated and passes revalidation fine? The reserved page
of the old vma goes to a different vma then?

This reservation code is complex and has lots of special cases anyway,
but the main concern at this point is the
set_page_private(subpool_vma(vma)) released by
hugetlb_vm_op_close->unlock_or_release_subpool.

Aside the accounting, what about the page_private(page) subpool? It's
used by huge_page_free which would get out of sync with vma/inode
destruction if we release the mmap_sem.

	struct hugepage_subpool *spool =
		(struct hugepage_subpool *)page_private(page);

I think in the revalidation code we need to check if
page_private(page) still matches the subpool_vma(vma), if it doesn't
and it's a stale pointer, we can't even call put_page before fixing up
the page_private first.

The other way to solve this is not to release the mmap_sem at all and
in the slow path call __get_user_pages(nonblocking=NULL). That's
slower than using the CPU TLB to reach the source data and it'd
prevent also to handle a userfault in the source address of
UFFDIO_COPY, because an userfault in the source would require the
mmap_sem to be released (i.e. it'd require get_user_pages_fast that
would again recurse on the mmap_sem and in turn we could as well stick
to the current nonblocking copy-user). We currently don't handle
nesting with non-cooperative anyway so it'd be ok for now not to
release the mmap_sem while copying in UFFDIO_COPY.


Offtopic here but while reading this code I also noticed
free_huge_page is wasting CPU and then noticed other places wasting
CPU.
