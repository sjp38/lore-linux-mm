Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AA4026B0255
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:52:36 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p66so99040174wmp.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 00:52:36 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id xs2si425382wjc.225.2015.12.15.00.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 00:52:35 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id n186so83356532wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 00:52:35 -0800 (PST)
Date: Tue, 15 Dec 2015 09:52:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: isolate_lru_page on !head pages
Message-ID: <20151215085232.GB14350@dhcp22.suse.cz>
References: <20151209130204.GD30907@dhcp22.suse.cz>
 <20151214120456.GA4201@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214120456.GA4201@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 14-12-15 14:04:56, Kirill A. Shutemov wrote:
> On Wed, Dec 09, 2015 at 02:02:05PM +0100, Michal Hocko wrote:
> > Hi Kirill,
> 
> [ sorry for late reply, just back from vacation. ]
> 
> > while looking at the issue reported by Minchan [1] I have noticed that
> > there is nothing to prevent from "isolating" a tail page from LRU because
> > isolate_lru_page checks PageLRU which is
> > PAGEFLAG(LRU, lru, PF_HEAD)
> > so it is checked on the head page rather than the given page directly
> > but the rest of the operation is done on the given (tail) page.
> 
> Looks like most (all?) callers already exclude PTE-mapped THP already one
> way or another.

I can see e.g. do_move_page_to_node_array not doing a similar thing. It
isolates and then migrates potentially a tail page. I haven't looked
closer whether there is other hand break on the way though. The
point I was trying to make is that this is really _subtle_. We are
changing something else than we operate later on.

> Probably, VM_BUG_ON_PAGE(PageTail(page), page) in isolate_lru_page() would
> be appropriate.
> 
> > This is really subtle because this expects that every caller of this
> > function checks for the tail page otherwise we would clobber statistics
> > and who knows what else (I haven't checked that in detail) as the page
> > cannot be on the LRU list and the operation makes sense only on the head
> > page.
> > 
> > Would it make more sense to make PageLRU PF_ANY? That would return
> > false for PageLRU on any tail page and so it would be ignored by
> > isolate_lru_page.
> 
> I don't think this is right way to go. What we put on LRU is compound
> page, not 4k subpages. PageLRU() should return true if the compound page
> is on LRU regardless if you ask for head or tail page.

Hmm, but then we should operate on the head page because that is what
PageLRU operated on, no?

 
> False-negatives PageLRU() can be as bad as bug Minchan reported, but
> perhaps more silent.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
