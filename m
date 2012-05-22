Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 229D36B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 17:05:06 -0400 (EDT)
Date: Tue, 22 May 2012 16:05:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] hugetlb: fix resv_map leak in error path
In-Reply-To: <20120522134558.49255899.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1205221603290.21828@router.home>
References: <20120521202814.E01F0FE1@kernel> <20120522134558.49255899.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, mel@csn.ul.ie

On Tue, 22 May 2012, Andrew Morton wrote:

> On Mon, 21 May 2012 13:28:14 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>
> > When called for anonymous (non-shared) mappings,
> > hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
> > code in hugetlbfs's vm_ops->close() to release that allocation.
> >
> > However, in the mmap() failure path, we do a plain unmap_region()
> > without the remove_vma() which actually calls vm_ops->close().
> >
> > This is a decent fix.  This leak could get reintroduced if
> > new code (say, after hugetlb_reserve_pages() in
> > hugetlbfs_file_mmap()) decides to return an error.  But, I think
> > it would have to unroll the reservation anyway.
>
> How far back does this bug go?  The patch applies to 3.4 but gets
> rejects in 3.3 and earlier.

The earliest that I have seen it on was 2.6.32. I have rediffed the patch
against 2.6.32 and 3.2.0.

----
