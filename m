Date: Wed, 12 Sep 2007 16:51:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] Embed zone_id information within the
 zonelist->zones pointer
Message-Id: <20070912165138.5deb4db4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070911213127.23507.34058.sendpatchset@skynet.skynet.ie>
References: <20070911213006.23507.19569.sendpatchset@skynet.skynet.ie>
	<20070911213127.23507.34058.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Sep 2007 22:31:27 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> Using two zonelists per node requires very frequent use of zone_idx(). This
> is costly as it involves a lookup of another structure and a substraction
> operation. As struct zone is always word aligned and normally cache-line
> aligned, the pointer values have a number of 0's at the least significant
> bits of the address.
> 
> This patch embeds the zone_id of a zone in the zonelist->zones pointers.
> The real zone pointer is retrieved using the zonelist_zone() helper function.
> The ID of the zone is found using zonelist_zone_idx().  To avoid accidental
> references, the zones field is renamed to _zones and the type changed to
> unsigned long.
> 
At first, I welcome this patch. thanks!.


A comment after reading all is, how about defining zonelist as following
instead of encoding in pointer ?
==
struct zone_pointer {
	struct zone *zone;
	int	     node_id;  
	int	     zone_idx;
};

struct zonelist {
	struct zone_pointer	_zones[MAX_ZONES_PER_ZONELIST + 1];
};

#define zonelist_zone(zl)      (zl)->zone
#define zonelist_zone_idx(zl)  (zl)->zone_idx
#ifdef CONFIG_NUMA
#define zonelist_zone_nid(zl)  (zl)->node_id
#else
#define zonelist_zone_nid(zl, i)  (0)
==

If we really want to avoid unnecessary access to "zone" while walking zonelist,
above may do something good.  Cons is this makes sizeof zonlist bigger.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
