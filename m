Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060214072917.926A97402D@sv1.valinux.co.jp>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20060214072917.926A97402D@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Wed, 15 Feb 2006 07:35:08 +0100
Message-Id: <1139985308.6722.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-02-14 at 16:29 +0900, IWAMOTO Toshihiro wrote:
> At Fri, 30 Dec 2005 23:43:34 +0100,
> Peter Zijlstra wrote:
> > Index: linux-2.6-git/mm/clockpro.c
> > ===================================================================
> > --- /dev/null
> > +++ linux-2.6-git/mm/clockpro.c
> > @@ -0,0 +1,557 @@
> 
> > +/*
> > + * Insert page into @zones clock and update adaptive parameters.
> > + *
> > + * Several page flags are used for insertion hints:
> > + *  PG_active - insert as an active page
> > + *  PG_test - use the use-once logic
> > + *
> > + * For now we will ignore the active hint; the use once logic is
> > + * explained below.
> > + *
> > + * @zone: target zone.
> > + * @page: new page.
> > + */
> > +void __page_replace_insert(struct zone *zone, struct page *page)
> > +{
> > +	unsigned int rflags;
> > +
> > +	rflags = nonresident_get(page_mapping(page), page_index(page));
> > +
> > +	/* ignore the PG_active hint */
> > +	ClearPageActive(page);
> > +
> > +	/* abuse the PG_test flag for pagecache use-once */
> > +	if (!TestClearPageTest(page)) {
> > +		/*
> > +		 * Insert (hot) when found in the nonresident list, otherwise
> > +		 * insert as (cold,test). Insert at the head of the Hhot list,
> > +		 * ie. right behind Hcold.
> > +		 */
> > +		if (rflags & NR_found) {
> > +			SetPageActive(page);
> > +			__cold_target_inc(zone, 1);
> > +		} else {
> > +			SetPageTest(page);
> > +			++zone->nr_cold;
> > +		}
> > +		++zone->nr_resident;
> > +		__select_list_hand(zone, &zone->list_hand[hand_hot]);
> > +		list_add(&page->lru, &zone->list_hand[hand_hot]);
> 
> Why do you put non-pagecache pages into hot lists?
> For hot pages, it means less time allowed to get their reference bits
> set.  For cold test pages, test bits will be just cleared when Hhot
> passes.

My assumption was that since that is the position just vacated, it will
be the position for new pages, as in CLOCK. I've just reread the paper
once again, but fail to see any part dealing with the insertion of new
pages (might be my bad, it's way too early - please point me to the
relevant section if you do find it).

> > +	} else {
> > +		/*
> > +		 * Pagecache insert; we want to avoid activation on the first
> > +		 * reference (which we know will come); use-once logic.
> 
> --
> IWAMOTO Toshihiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
