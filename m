Date: Mon, 30 Jul 2007 18:52:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070730180642.0a25eed8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707301846400.26785@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070730180642.0a25eed8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Andrew Morton wrote:

> > zone reclaim only runs if there are unmapped file backed pages that can be 
> > reclaimed. If the pages are all unreclaimable then they are all mapped and 
> > global reclaim begins to run. The problem is with global reclaim as far as 
> > I know.
> 
> I don't understand how you conclude that.

That is how it is coded:

      if (zone_page_state(zone, NR_FILE_PAGES) -
                zone_page_state(zone, NR_FILE_MAPPED) >
                zone->min_unmapped_pages) {
                /*
                 * Free memory by calling shrink zone with increasing
                 * priorities until we have enough memory freed.
                 */
                priority = ZONE_RECLAIM_PRIORITY;
                do {
                        note_zone_scanning_priority(zone, priority);
                        nr_reclaimed += shrink_zone(priority, zone, &sc);
                        priority--;
                } while (priority >= 0 && nr_reclaimed < nr_pages);
        }
 
> - Kiran saw CPU meltdown when "one of the processes got into zone reclaim".

We have seen the meltdown with regular reclaim in a number of cases due to
unreclaimable pages on the LRU causing heavy lock contention.

AFAIK There must be file backed pages that are unmapped and are not 
reclaimable for zone reclaim to get into this state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
