Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6A77E6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:20:53 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so7224900pbc.28
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 18:20:53 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id ye6si3204058pbc.350.2014.01.20.18.20.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 18:20:51 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 21 Jan 2014 07:50:48 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 025E7394004E
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:50:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0L2KU5l34996284
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:50:31 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0L2KhRe025879
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:50:43 +0530
Date: Tue, 21 Jan 2014 10:20:42 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <52ddd983.86f7440a.2a65.131cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401201612340.28048@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1401201612340.28048@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>

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

Thanks for your pointing out, I will do it and retest it later.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
