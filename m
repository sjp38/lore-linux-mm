Message-ID: <43F5311F.90900@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 11:12:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161739560.27091@schroedinger.engr.sgi.com> <200602170246.03172.ak@suse.de>
In-Reply-To: <200602170246.03172.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Friday 17 February 2006 02:40, Christoph Lameter wrote:
>> What happens if another node beyond higest_node comes online later?
>> Or one node in between comes online?
> 
> I don't know. Whoever implements node hotplug has to handle it.
> But I'm pretty sure the old code also didn't handle it, so it's not
> a regression.
> 
> My primary interest is just to get all these Opterons booting again.
> 

All existing pgdat's default zonelist should be refreshed when a new
node comes in. So,I think this patch wouldn't be problem.
It's node-hotplug's problem.


Goto is implementing it now by this:
==
+static int __build_all_zonelists(void *dummy)
+{
+	int i;
+	for_each_online_node(i)
+		build_zonelists(NODE_DATA(i));
+	/* XXX: Cpuset must be updated when node is hotplugged. */
+	return 0;
+}
<snip>
+	stop_machine_run(__build_all_zonelists, zone->zone_pgdat, NR_CPUS);
==

If this is ok, next problem is "how to remove pgdat/zone from all zonelist....".

If there are no performance problem, adding list and seqlock , callback to
zonelist is one way to manage add-remove-zone/pgdat to zonelist.
But this will make codes more complicated.

Thanks,

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
