Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 99E286B0258
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 07:03:21 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n186so90837177wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 04:03:21 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id lm2si1439984wjc.94.2015.12.15.04.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 04:03:20 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id n186so161489706wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 04:03:20 -0800 (PST)
Date: Tue, 15 Dec 2015 14:03:18 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: isolate_lru_page on !head pages
Message-ID: <20151215120318.GA11497@node.shutemov.name>
References: <20151209130204.GD30907@dhcp22.suse.cz>
 <20151214120456.GA4201@node.shutemov.name>
 <20151215085232.GB14350@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151215085232.GB14350@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 15, 2015 at 09:52:33AM +0100, Michal Hocko wrote:
> On Mon 14-12-15 14:04:56, Kirill A. Shutemov wrote:
> > On Wed, Dec 09, 2015 at 02:02:05PM +0100, Michal Hocko wrote:
> > > Hi Kirill,
> > 
> > [ sorry for late reply, just back from vacation. ]
> > 
> > > while looking at the issue reported by Minchan [1] I have noticed that
> > > there is nothing to prevent from "isolating" a tail page from LRU because
> > > isolate_lru_page checks PageLRU which is
> > > PAGEFLAG(LRU, lru, PF_HEAD)
> > > so it is checked on the head page rather than the given page directly
> > > but the rest of the operation is done on the given (tail) page.
> > 
> > Looks like most (all?) callers already exclude PTE-mapped THP already one
> > way or another.
> 
> I can see e.g. do_move_page_to_node_array not doing a similar thing. It
> isolates and then migrates potentially a tail page.

No, it doesn't. follow_page(FOLL_SPLIT) would split THP pages.

> I haven't looked closer whether there is other hand break on the way
> though. The point I was trying to make is that this is really _subtle_.
> We are changing something else than we operate later on.
> 
> > Probably, VM_BUG_ON_PAGE(PageTail(page), page) in isolate_lru_page() would
> > be appropriate.
> > 
> > > This is really subtle because this expects that every caller of this
> > > function checks for the tail page otherwise we would clobber statistics
> > > and who knows what else (I haven't checked that in detail) as the page
> > > cannot be on the LRU list and the operation makes sense only on the head
> > > page.
> > > 
> > > Would it make more sense to make PageLRU PF_ANY? That would return
> > > false for PageLRU on any tail page and so it would be ignored by
> > > isolate_lru_page.
> > 
> > I don't think this is right way to go. What we put on LRU is compound
> > page, not 4k subpages. PageLRU() should return true if the compound page
> > is on LRU regardless if you ask for head or tail page.
> 
> Hmm, but then we should operate on the head page because that is what
> PageLRU operated on, no?

head page is what linked into LRU, but not nessesary the way we obtain the
page to check. If we check PageLRU(pte_page(*pte)) it should produce the
right result.

> > False-negatives PageLRU() can be as bad as bug Minchan reported, but
> > perhaps more silent.
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
