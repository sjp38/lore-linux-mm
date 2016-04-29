Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id DAD926B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 20:44:34 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id e35so82596892qge.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:44:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o140si6169942qke.179.2016.04.28.17.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 17:44:34 -0700 (PDT)
Date: Thu, 28 Apr 2016 18:44:30 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160428184430.5ddef470@ul30vt.home>
In-Reply-To: <20160428232127.GL11700@redhat.com>
References: <20160428102051.17d1c728@t450s.home>
	<20160428181726.GA2847@node.shutemov.name>
	<20160428125808.29ad59e5@t450s.home>
	<20160428232127.GL11700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2016 01:21:27 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Hello Alex and Kirill,
> 
> On Thu, Apr 28, 2016 at 12:58:08PM -0600, Alex Williamson wrote:
> > > > specific fix to this code is not applicable.  It also still occurs on
> > > > kernels as recent as v4.6-rc5, so the issue hasn't been silently fixed
> > > > yet.  I'm able to reproduce this fairly quickly with the above test,
> > > > but it's not hard to imagine a test w/o any iommu dependencies which
> > > > simply does a user directed get_user_pages_fast() on a set of userspace
> > > > addresses, retains the reference, and at some point later rechecks that
> > > > a new get_user_pages_fast() results in the same page address.  It  
> 
> Can you try to "git revert 1f25fe20a76af0d960172fb104d4b13697cafa84"
> and then apply the below patch on top of the revert?

Looking good so far!  I haven't seen any errors yet with this
combination of v4.5, 1f25fe20a reverted, and your patch applied on
top.  I'll keep testing since reverting 1f25fe20a alone already made
the bug much more elusive.  Thanks Andrea!

Alex

> Totally untested... if I missed something and it isn't correct, I hope
> this brings us in the right direction faster at least.
> 
> Overall the problem I think is that we need to restore full accuracy
> and we can't deal with false positive COWs (which aren't entirely
> cheap either... reading 512 cachelines should be much faster than
> copying 2MB and using 4MB of CPU cache). 32k vs 4MB. The problem of
> course is when we really need a COW, we'll waste an additional 32k,
> but then it doesn't matter that much as we'd be forced to load 4MB of
> cache anyway in such case. There's room for optimizations but even the
> simple below patch would be ok for now.
> 
> From 09e3d1ff10b49fb9c3ab77f0b96a862848e30067 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Fri, 29 Apr 2016 01:05:06 +0200
> Subject: [PATCH 1/1] mm: thp: calculate page_mapcount() correctly for THP
>  pages
> 
> This allows to revert commit 1f25fe20a76af0d960172fb104d4b13697cafa84
> and it provides fully accuracy with wrprotect faults so page pinning
> will stop causing false positive copy-on-writes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/util.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 6cc81e7..a0b9f63 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -383,9 +383,10 @@ struct address_space *page_mapping(struct page *page)
>  /* Slow path of page_mapcount() for compound pages */
>  int __page_mapcount(struct page *page)
>  {
> -	int ret;
> +	int ret = 0, i;
>  
> -	ret = atomic_read(&page->_mapcount) + 1;
> +	for (i = 0; i < HPAGE_PMD_NR; i++)
> +		ret = max(ret, atomic_read(&page->_mapcount) + 1);
>  	page = compound_head(page);
>  	ret += atomic_read(compound_mapcount_ptr(page)) + 1;
>  	if (PageDoubleMap(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
