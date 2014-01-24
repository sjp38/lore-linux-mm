From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Fri, 24 Jan 2014 11:09:07 +0800
Message-ID: <9605.03395549512$1390532995@news.gmane.org>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com>
 <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1401201612340.28048@nuc>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Christoph Lameter <cl@linux.com>
Cc: nacc@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, penberg@kernel.org, linux-mm@kvack.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org
List-Id: linux-mm.kvack.org

Hi Christoph,
On Mon, Jan 20, 2014 at 04:13:30PM -0600, Christoph Lameter wrote:
>On Mon, 20 Jan 2014, Wanpeng Li wrote:
>
>> >+       enum zone_type high_zoneidx = gfp_zone(flags);
>> >
>> >+       if (!node_present_pages(searchnode)) {
>> >+               zonelist = node_zonelist(searchnode, flags);
>> >+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>> >+                       searchnode = zone_to_nid(zone);
>> >+                       if (node_present_pages(searchnode))
>> >+                               break;
>> >+               }
>> >+       }
>> >        object = get_partial_node(s, get_node(s, searchnode), c, flags);
>> >        if (object || node != NUMA_NO_NODE)
>> >                return object;
>> >
>>
>> The patch fix the bug. However, the kernel crashed very quickly after running
>> stress tests for a short while:
>
>This is not a good way of fixing it. How about not asking for memory from
>nodes that are memoryless? Use numa_mem_id() which gives you the next node
>that has memory instead of numa_node_id() (gives you the current node
>regardless if it has memory or not).

diff --git a/mm/slub.c b/mm/slub.c
index 545a170..a1c6040 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1700,6 +1700,9 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	void *object;
	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;

+	if (!node_present_pages(searchnode))
+		searchnode = numa_mem_id();
+
	object = get_partial_node(s, get_node(s, searchnode), c, flags);
	if (object || node != NUMA_NO_NODE)
		return object;
