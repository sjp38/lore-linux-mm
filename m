Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j51Il50c121398
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 14:47:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j51Il5MM150204
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 12:47:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j51Il4Hf022599
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 12:47:05 -0600
Subject: Re: [PATCH] Periodically drain non local pagesets
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 01 Jun 2005 11:46:58 -0700
Message-Id: <1117651618.13600.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-01 at 10:48 -0700, Christoph Lameter wrote:
> +               struct per_cpu_pageset *pset;
> +
> +               /* Do not drain local pagesets */
> +               if (zone == zone_table[numa_node_id()])
> +                       continue;
> +

It's best to avoid using NUMA-specific data structures, even in #ifdef
NUMA code.  This particular use is incorrect, as the zone_table[] is not
indexed by numa_node_id(), but rather by a combination of the node
number and the zone number (see NODEZONE()).

I'd suggest using something like this:

	if (zone->zone_pgdat->node_id == numa_node_id())

It might be nice to have a zone_node_id() macro that hides this as well.
With a macro like that that #defines to 0 when !CONFIG_NUMA, the #ifdef
around that function could probably go away.  

Also, are you sure that you need the local_irq_en/disable()?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
