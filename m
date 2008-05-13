Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m4DIqh1k044534
	for <linux-mm@kvack.org>; Tue, 13 May 2008 18:52:43 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DIqhlj2469890
	for <linux-mm@kvack.org>; Tue, 13 May 2008 19:52:43 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DIqgWO016864
	for <linux-mm@kvack.org>; Tue, 13 May 2008 19:52:43 +0100
Date: Tue, 13 May 2008 20:52:42 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: memory_hotplug: always initialize pageblock bitmap.
Message-ID: <20080513185242.GA6465@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com> <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com> <20080510124501.GA4796@osiris.boeblingen.de.ibm.com> <20080512105500.ff89c0d3.kamezawa.hiroyu@jp.fujitsu.com> <20080512181928.cd41c055.kamezawa.hiroyu@jp.fujitsu.com> <20080513115825.GB12339@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080513115825.GB12339@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 01:58:25PM +0200, Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Trying to online a new memory section that was added via memory hotplug
> sometimes results in crashes when the new pages are added via __free_page.
> Reason for that is that the pageblock bitmap isn't initialized and hence
> contains random stuff.  That means that get_pageblock_migratetype() returns
> also random stuff and therefore
> 
> 	list_add(&page->lru,
> 		&zone->free_area[order].free_list[migratetype]);
> 
> in __free_one_page() tries to do a list_add to something that isn't even
> necessarily a list.
> 
> This happens since 86051ca5eaf5e560113ec7673462804c54284456
> ("mm: fix usemap initialization") which makes sure that the pageblock
> bitmap gets only initialized for pages present in a zone.
> Unfortunately for hot-added memory the zones "grow" after the memmap
> and the pageblock memmap have been initialized. Which means that the
> new pages have an unitialized bitmap.
> To solve this the calls to grow_zone_span() and grow_pgdat_span() are
> moved to __add_zone() just before the initialization happens.
> 
> The patch also moves the two functions since __add_zone() is the only
> caller and I didn't want to add a forward declaration.
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Oops... the patch is tested and works for me. However it was not Signed-off
by Andrew. And in addition I forgot to add [PATCH] to the subject.
Sorry about that!

If all agree that this patch is ok it should probably also go into
-stable, since it fixes the above mentioned regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
