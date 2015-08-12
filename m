Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id ABCD36B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 18:21:40 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so236375874wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 15:21:40 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id er6si362926wib.120.2015.08.12.15.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 15:21:39 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so129853169wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 15:21:38 -0700 (PDT)
Date: Thu, 13 Aug 2015 01:21:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page-flags behavior on compound pages: a worry
Message-ID: <20150812222136.GA15010@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
 <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
 <20150812143509.GA12320@node.dhcp.inet.fi>
 <20150812141644.ceb541e5b52d76049339a243@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150812141644.ceb541e5b52d76049339a243@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 12, 2015 at 02:16:44PM -0700, Andrew Morton wrote:
> On Wed, 12 Aug 2015 17:35:09 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Thu, Aug 06, 2015 at 12:24:22PM -0700, Hugh Dickins wrote:
> > > > IIUC, the only potentially problematic callsites left are physical memory
> > > > scanners. This code requires audit. I'll do that.
> > > 
> > > Please.
> > 
> > I haven't finished the exercise yet. But here's an issue I believe present
> > in current *Linus* tree:
> > 
> > >From e78eec7d7a8c4cba8b5952a997973f7741e704f4 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Wed, 12 Aug 2015 17:09:16 +0300
> > Subject: [PATCH] mm: fix potential race in isolate_migratepages_block()
> > 
> > Hugh has pointed that compound_head() call can be unsafe in some context.
> > There's one example:
> > 
> > 	CPU0					CPU1
> > 
> > isolate_migratepages_block()
> >   page_count()
> >     compound_head()
> >       !!PageTail() == true
> > 					put_page()
> > 					  tail->first_page = NULL
> >       head = tail->first_page
> > 					alloc_pages(__GFP_COMP)
> > 					   prep_compound_page()
> > 					     tail->first_page = head
> > 					     __SetPageTail(p);
> >       !!PageTail() == true
> >     <head == NULL dereferencing>
> > 
> > The race is pure theoretical. I don't it's possible to trigger it in
> > practice. But who knows.
> > 
> > This can be fixed by avoiding compound_head() in unsafe context.
> 
> This is nuts :( page_count() should Just Work without us having to
> worry about bizarre races against splitting.  Sigh.

Split is not involved. And this race is present even for THP=n. :(

> 
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -787,7 +787,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  		 * admittedly racy check.
> >  		 */
> >  		if (!page_mapping(page) &&
> > -		    page_count(page) > page_mapcount(page))
> > +		    atomic_read(&page->_count) > page_mapcount(page))
> >  			continue;
> 
> If we're going to do this sort of thing, can we please do it in a more
> transparent manner?  Let's not sprinkle unexplained and
> incomprehensible direct accesses to ->_count all over the place.
> 
> Create a formal function to do this, with an appropriate name and with
> documentation which fully explains what's going on.  Then use that
> here, and in has_unmovable_pages() (at least).

All this situation is ugly. I'm thinking on more general solution for
PageTail() vs. ->first_page race.

We would be able to avoid the race in first place if we encode PageTail()
and position of head page within the same word in struct page. This way we
update both thing in one shot without possibility of race.

Details get tricky.

I'm going to try tomorrow something like this: encode the position of head
as offset from the tail page and store it as negative number in the union
with ->mapping and ->s_mem. PageTail() can be implemented as check value
of the field to be in range -1..-MAX_ORDER_NR_PAGES. 

I'm not sure at all if it's going to work, especially looking on
ridiculously high CONFIG_FORCE_MAX_ZONEORDER some architectures allow.

We could also try to encode page order instead (again as negative number)
and calculate head page position based on alignment...

Any other ideas are welcome.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
