From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Tue, 7 Jan 2014 16:48:40 +0800
Message-ID: <47097.8799429306$1389084588@news.gmane.org>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20140107074136.GA4011@lge.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: cl@linux-foundation.org, nacc@linux.vnet.ibm.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org
List-Id: linux-mm.kvack.org

Hi Joonsoo,
On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
>On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>> 
[...]
>Hello,
>
>I think that we need more efforts to solve unbalanced node problem.
>
>With this patch, even if node of current cpu slab is not favorable to
>unbalanced node, allocation would proceed and we would get the unintended memory.
>

We have a machine:

[    0.000000] Node 0 Memory:
[    0.000000] Node 4 Memory: 0x0-0x10000000 0x20000000-0x60000000 0x80000000-0xc0000000
[    0.000000] Node 6 Memory: 0x10000000-0x20000000 0x60000000-0x80000000
[    0.000000] Node 10 Memory: 0xc0000000-0x180000000

[    0.041486] Node 0 CPUs: 0-19
[    0.041490] Node 4 CPUs:
[    0.041492] Node 6 CPUs:
[    0.041495] Node 10 CPUs:

The pages of current cpu slab should be allocated from fallback zones/nodes 
of the memoryless node in buddy system, how can not favorable happen? 

>And there is one more problem. Even if we have some partial slabs on
>compatible node, we would allocate new slab, because get_partial() cannot handle
>this unbalance node case.
>
>To fix this correctly, how about following patch?
>

So I think we should fold both of your two patches to one.

Regards,
Wanpeng Li 

>Thanks.
>
>------------->8--------------------
>diff --git a/mm/slub.c b/mm/slub.c
>index c3eb3d3..a1f6dfa 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1672,7 +1672,19 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> {
>        void *object;
>        int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
>+       struct zonelist *zonelist;
>+       struct zoneref *z;
>+       struct zone *zone;
>+       enum zone_type high_zoneidx = gfp_zone(flags);
>
>+       if (!node_present_pages(searchnode)) {
>+               zonelist = node_zonelist(searchnode, flags);
>+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>+                       searchnode = zone_to_nid(zone);
>+                       if (node_present_pages(searchnode))
>+                               break;
>+               }
>+       }
>        object = get_partial_node(s, get_node(s, searchnode), c, flags);
>        if (object || node != NUMA_NO_NODE)
>                return object;
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
