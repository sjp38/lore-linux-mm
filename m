Date: Sat, 21 Jun 2008 17:18:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
In-Reply-To: <20080621224135.GD4692@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0806211711470.18719@schroedinger.engr.sgi.com>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
 <20080621224135.GD4692@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexander Beregalov <a.beregalov@gmail.com>, kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 21 Jun 2008, Mel Gorman wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1249,15 +1249,13 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
>  static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
>  					struct scan_control *sc)
>  {
> +	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  	unsigned long nr_reclaimed = 0;
> -	struct zone **zones = zonelist->zones;
> -	int i;
> -
> +	struct zone **z;
> +	struct zone *zone;
>  
>  	sc->all_unreclaimable = 1;
> -	for (i = 0; zones[i] != NULL; i++) {
> -		struct zone *zone = zones[i];
> -
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  		if (!populated_zone(zone))
>  			continue;
>  		/*
> 
> Code before - Walk the zonelist for GFP_KERNEL

Before the change we walk all zones of the zonelist.

> Code after - Filter zonelist based on what is allowed for GFP_KERNEL

After the change we walk only zones for GFP_KERNEL. Meaning no HIGHMEM 
and MOVABLE zones. Doesnt that mean that reclaim is limited to ZONE_DMA 
and ZONE_NORMAL? Is that really intended?

If not then the following patch should return us to old behavior:

---
 mm/vmscan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2008-06-21 17:15:45.597627317 -0700
+++ linux-2.6/mm/vmscan.c	2008-06-21 17:17:16.273293260 -0700
@@ -1249,13 +1249,12 @@ static unsigned long shrink_zone(int pri
 static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
-	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long nr_reclaimed = 0;
 	struct zoneref *z;
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
 		if (!populated_zone(zone))
 			continue;
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
