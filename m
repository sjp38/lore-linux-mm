Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 06D446B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 22:14:22 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so2709784pbc.27
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 19:14:22 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id ot3si16298661pac.79.2014.01.23.19.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 19:14:21 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 08:44:18 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9AB1A1258053
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 08:45:55 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0O3DuiR51642428
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 08:43:56 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0O3EDgr009979
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 08:44:14 +0530
Date: Fri, 24 Jan 2014 11:14:12 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <52e1da8d.e3d8420a.1152.25afSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
 <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Fri, Jan 24, 2014 at 11:09:07AM +0800, Wanpeng Li wrote:
>Hi Christoph,
>On Mon, Jan 20, 2014 at 04:13:30PM -0600, Christoph Lameter wrote:
>>On Mon, 20 Jan 2014, Wanpeng Li wrote:
>>
>>> >+       enum zone_type high_zoneidx = gfp_zone(flags);
>>> >
>>> >+       if (!node_present_pages(searchnode)) {
>>> >+               zonelist = node_zonelist(searchnode, flags);
>>> >+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>>> >+                       searchnode = zone_to_nid(zone);
>>> >+                       if (node_present_pages(searchnode))
>>> >+                               break;
>>> >+               }
>>> >+       }
>>> >        object = get_partial_node(s, get_node(s, searchnode), c, flags);
>>> >        if (object || node != NUMA_NO_NODE)
>>> >                return object;
>>> >
>>>
>>> The patch fix the bug. However, the kernel crashed very quickly after running
>>> stress tests for a short while:
>>
>>This is not a good way of fixing it. How about not asking for memory from
>>nodes that are memoryless? Use numa_mem_id() which gives you the next node
>>that has memory instead of numa_node_id() (gives you the current node
>>regardless if it has memory or not).
>
>diff --git a/mm/slub.c b/mm/slub.c
>index 545a170..a1c6040 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1700,6 +1700,9 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> 	void *object;
>	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
>
>+	if (!node_present_pages(searchnode))
>+		searchnode = numa_mem_id();
>+
>	object = get_partial_node(s, get_node(s, searchnode), c, flags);
>	if (object || node != NUMA_NO_NODE)
>		return object;
>

The bug still can't be fixed w/ this patch. 

Regards,
Wanpeng Li 

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
