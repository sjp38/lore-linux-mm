Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92C736B032F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:13:08 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id qs7so156631wjc.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 07:13:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr6si23027328wjd.218.2016.12.20.07.13.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Dec 2016 07:13:07 -0800 (PST)
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220091814.GC3769@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <233ed490-afb9-4644-6d84-c9f888882da2@suse.cz>
Date: Tue, 20 Dec 2016 16:13:02 +0100
MIME-Version: 1.0
In-Reply-To: <20161220091814.GC3769@dhcp22.suse.cz>
Content-Type: multipart/mixed;
 boundary="------------AE335033A9BCBF6CBA4E1C6E"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>Mel Gorman <mgorman@techsingularity.net>

This is a multi-part message in MIME format.
--------------AE335033A9BCBF6CBA4E1C6E
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 12/20/2016 10:18 AM, Michal Hocko wrote:
> On Mon 12-12-16 13:59:07, Jia He wrote:
>> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
>> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
>> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>>  z->node would not be equal to preferred_zone->node. That seems to be
>> incorrect.
> 
> I am sorry but I have hard time following the changelog. It is clear
> that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
> but it is not really clear when such thing happens. You are adding
> preferred_zone->node check. preferred_zone is the first zone in the
> requested zonelist. So for the most allocations it is a node from the
> local node. But if something request an explicit numa node (without
> __GFP_OTHER_NODE which would be the majority I suspect) then we could
> indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
> referenced patch indeed caused an unintended change of accounting AFAIU.

Since I could not quite wrap my head around all possible combinations,
I've got lazy and employed cbmc, inspired by [1] (test file attached if
anyone wants to play with it) and tried to test whether both commit
b9f00e147f27, and Jia He's patch are equivalent to pre-b9f00e147f27. The
tool found counter examples for both cases (there might be more
scenarios, but it only reports the first one it hits). Note that
decoding the output is not exactly trivial...

[1] http://paulmck.livejournal.com/38997.html

==============
Counterexample for commit b9f00e147f27 vs pre-b9f00e147f27:

numa_node_id() == 1
preferred_zone on node 0
allocated from zone on node 1
without __GFP_OTHER_NODE

pre-b9f00e147f27:
allocated zone (node 1) increased NUMA_MISS and NUMA_LOCAL
preferred zone (node 0) increased NUMA_FOREIGN

(that looks correct to me)

b9f00e147f27:
allocated zone (node 1) got NUMA_HIT and NUMA_LOCAL
there's no NUMA_FOREIGN

(that's wrong wrt HIT and FOREIGN)

==============
Counterexample for Jia He's patch vs pre-b9f00e147f27:

numa_node_id() == 0
preferred_zone on node 0
allocated from zone on node 1
without __GFP_OTHER_NODE

pre-b9f00e147f27:
allocated zone (node 1) increased NUMA_MISS and NUMA_OTHER
preferred zone (node 0) increased NUMA_FOREIGN

(that looks correct to me)

Jia He's patch:
allocated zone (node 1) increased NUMA_MISS
preferred zone (node 0) increased NUMA_FOREIGN

(it's missing NUMA_OTHER)

--------------AE335033A9BCBF6CBA4E1C6E
Content-Type: text/x-csrc;
 name="test-numa.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test-numa.c"

#include <stdio.h>

#define NODES	3
#define ZONES	2

enum zone_stat_item {
	NUMA_HIT,
	NUMA_MISS,
	NUMA_LOCAL,
	NUMA_OTHER,
	NUMA_FOREIGN,
	ZONE_STAT_ITEMS
};

struct node;
struct zone {
	struct node *zone_pgdat;
	int node;
	int vm_stat[ZONE_STAT_ITEMS];
};

struct node {
	int nid;
	struct zone node_zones[ZONES];
};

typedef int gfp_t;
#define __GFP_OTHER_NODE	1
#define unlikely(x) (x)

int local_nid;
int numa_node_id()
{
	return local_nid;
}

static void __inc_zone_state(struct zone *z, enum zone_stat_item stat)
{
	z->vm_stat[stat]++;
}

// before b9f00e147f27
void zone_statistics1(struct zone *preferred_zone, struct zone *z, gfp_t flags)
{
	if (z->zone_pgdat == preferred_zone->zone_pgdat) {
		__inc_zone_state(z, NUMA_HIT);
	} else {
		__inc_zone_state(z, NUMA_MISS);
		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
	}

	if (z->node == ((flags & __GFP_OTHER_NODE) ?
		preferred_zone->node : numa_node_id()))
                __inc_zone_state(z, NUMA_LOCAL);
        else
                __inc_zone_state(z, NUMA_OTHER);
}

// after b9f00e147f27
void zone_statistics2(struct zone *preferred_zone, struct zone *z, gfp_t flags)
{
        int local_nid = numa_node_id();
        enum zone_stat_item local_stat = NUMA_LOCAL;

        if (unlikely(flags & __GFP_OTHER_NODE)) {
                local_stat = NUMA_OTHER;
                local_nid = preferred_zone->node;
        }

        if (z->node == local_nid) {
                __inc_zone_state(z, NUMA_HIT);
                __inc_zone_state(z, local_stat);
        } else {
                __inc_zone_state(z, NUMA_MISS);
                __inc_zone_state(preferred_zone, NUMA_FOREIGN);
        }
}

// after Jia He's patch
static inline void zone_statistics3(struct zone *preferred_zone, struct zone *z,
                                                                gfp_t flags)
{
        int local_nid = numa_node_id();
        enum zone_stat_item local_stat = NUMA_LOCAL;

        if (unlikely(flags & __GFP_OTHER_NODE)) {
                local_stat = NUMA_OTHER;
                local_nid = preferred_zone->node;
        }

        if (z->node == local_nid) {
                __inc_zone_state(z, NUMA_HIT);
                __inc_zone_state(z, local_stat);
        } else if (z->node == preferred_zone->node) {
                __inc_zone_state(z, NUMA_HIT);
                __inc_zone_state(z, NUMA_OTHER);
        } else {
                __inc_zone_state(z, NUMA_MISS);
                __inc_zone_state(preferred_zone, NUMA_FOREIGN);
        }
}


void init_node(struct node * n, int nid)
{
	n->nid = nid;
	for (int i = 0; i < ZONES; i++) {
		struct zone * z = &n->node_zones[i];

		z->zone_pgdat = n;
		z->node = nid;
		for (int j = 0; j < ZONE_STAT_ITEMS; j++)
			z->vm_stat[j] = 0;
	}
}

struct node nodes1[NODES];
struct node nodes2[NODES];

void check_stats()
{
	for (int i = 0; i < NODES; i++)
		for (int j = 0; j < ZONES; j++)
			for (int k = 0; k < ZONE_STAT_ITEMS; k++)
				assert (nodes1[i].node_zones[j].vm_stat[k]
				     == nodes2[i].node_zones[j].vm_stat[k]);

}

int main(int argc, char *argv[])
{

	for (int i = 0; i < NODES; i++) {
		init_node(&nodes1[i], i);
		init_node(&nodes2[i], i);
	}

	local_nid = ((unsigned int)argv[1]) % NODES;
	int zone_nid = ((unsigned int)argv[2]) % NODES;
	int pzone_nid = ((unsigned int)argv[3]) % NODES;
	int zid = ((unsigned int)argv[4]) % ZONES;
	int pzid = ((unsigned int)argv[5]) % ZONES;

	/* we should not allocate from higher than preferred zone */
	if (zid > pzid)
		zid = pzid;

	gfp_t flags = ((unsigned int)argv[6]) & __GFP_OTHER_NODE;

	zone_statistics1(&nodes1[pzone_nid].node_zones[pzid],
			 &nodes1[zone_nid].node_zones[zid],
			 flags);

	zone_statistics3(&nodes2[pzone_nid].node_zones[pzid],
			 &nodes2[zone_nid].node_zones[zid],
			 flags);

	check_stats();
}


--------------AE335033A9BCBF6CBA4E1C6E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
