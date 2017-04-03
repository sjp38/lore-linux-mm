Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37EEF6B03AE
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 15:37:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v44so25616652wrc.9
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 12:37:33 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id t14si21246440wrb.43.2017.04.03.12.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 12:37:31 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id w43so36318133wrb.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 12:37:31 -0700 (PDT)
Date: Mon, 3 Apr 2017 22:37:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: ksmd lockup - kernel 4.11-rc series
Message-ID: <20170403193729.ypjweoqxyziymvu6@node.shutemov.name>
References: <003401d2a750$19f98190$4dec84b0$@net>
 <20170327233617.353obb3m4wz7n5kv@node.shutemov.name>
 <alpine.LSU.2.11.1703280008020.2599@eggly.anvils>
 <alpine.LSU.2.11.1704021651230.1618@eggly.anvils>
 <20170403140850.twnkdiglzqlsfecy@node.shutemov.name>
 <alpine.LSU.2.11.1704031104400.1118@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704031104400.1118@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Doug Smythies <dsmythies@telus.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Mon, Apr 03, 2017 at 11:08:41AM -0700, Hugh Dickins wrote:
> On Mon, 3 Apr 2017, Kirill A. Shutemov wrote:
> > On Sun, Apr 02, 2017 at 05:03:00PM -0700, Hugh Dickins wrote:
> > >  			return true;
> > > -next_pte:	do {
> > > +next_pte:
> > > +		if (!PageTransHuge(pvmw->page) || PageHuge(pvmw->page))
> > > +			return not_found(pvmw);
> > 
> > I guess it makes sense to drop the same check from the beginning of the
> > function and move the comment here.
> > 
> > Otherwise looks good. Thanks for tracking this down.
> 
> Oh that's much better, thanks, it would have annoyed me to notice that
> duplication later on.  Replacement patch...
> 
> 
> [PATCH] mm: fix page_vma_mapped_walk() for ksm pages
> 
> Doug Smythies reports oops with KSM in this backtrace,
> I've been seeing the same:
> 
> page_vma_mapped_walk+0xe6/0x5b0
> page_referenced_one+0x91/0x1a0
> rmap_walk_ksm+0x100/0x190
> rmap_walk+0x4f/0x60
> page_referenced+0x149/0x170
> shrink_active_list+0x1c2/0x430
> shrink_node_memcg+0x67a/0x7a0
> shrink_node+0xe1/0x320
> kswapd+0x34b/0x720
> 
> Just as 4b0ece6fa016 ("mm: migrate: fix remove_migration_pte() for ksm
> pages") observed, you cannot use page->index calculations on ksm pages.
> page_vma_mapped_walk() is relying on __vma_address(), where a ksm page
> can lead it off the end of the page table, and into whatever nonsense
> is in the next page, ending as an oops inside check_pte()'s pte_page().
> 
> KSM tells page_vma_mapped_walk() exactly where to look for the page,
> it does not need any page->index calculation: and that's so also for
> all the normal and file and anon pages - just not for THPs and their
> subpages.  Get out early in most cases: instead of a PageKsm test,
> move down the earlier not-THP-page test, as suggested by Kirill.
> 
> I'm also slightly worried that this loop can stray into other vmas,
> so added a vm_end test to prevent surprises; though I have not imagined
> anything worse than a very contrived case, in which a page mlocked in
> the next vma might be reclaimed because it is not mlocked in this vma.
> 
> Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
