Message-ID: <43CCAEEF.5000403@jp.fujitsu.com>
Date: Tue, 17 Jan 2006 17:46:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Question:  new bind_zonelist uses only one zone type
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

in -mm4 (in linus.patch)
==
static struct zonelist *bind_zonelist(nodemask_t *nodes)
{
         struct zonelist *zl;
         int num, max, nd;

         max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
         zl = kmalloc(sizeof(void *) * max, GFP_KERNEL);
         if (!zl)
                 return NULL;
         num = 0;
         for_each_node_mask(nd, *nodes)
                 zl->zones[num++] = &NODE_DATA(nd)->node_zones[policy_zone];
         zl->zones[num] = NULL;
         return zl;
}
==
policy_zone is ZONE_DMA, ZONE_NORMAL, ZONE_HIGHMEM, depends on system.

If policy_zone is ZONE_NORMAL, returned zonelist will be
{Node(0)'s NORMAL, Node(1)'s NORMAL, Node(2)'s Normal.....}

If node0 has only DMA/DMA32 and Node1-NodeX has Normal, node0 will be ignored
and zonelist will include not-populated zone.

Is this intended ?


-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
