Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1LMOjYF025074
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 17:24:45 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1LMOj0H237402
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 17:24:45 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1LMOiD5028743
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 17:24:45 -0500
Subject: Re: [RFC] [Patch] For booting a i386 numa system with no memory in
	a node
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1109023409.9817.1667.camel@knk>
References: <1106881119.2040.122.camel@cog.beaverton.ibm.com>
	 <1106882150.2040.126.camel@cog.beaverton.ibm.com>
	 <1106937253.27125.6.camel@knk>  <1106938993.14330.65.camel@localhost>
	 <1106941547.27125.25.camel@knk>  <1106942832.17936.3.camel@arrakis>
	 <1108611260.9817.1227.camel@knk>  <1108654782.19395.9.camel@localhost>
	 <1108664637.9817.1259.camel@knk>  <1108666091.19395.29.camel@localhost>
	 <1108671423.9817.1266.camel@knk>  <421510E9.3000901@us.ibm.com>
	 <1108677113.32193.8.camel@localhost> <42152690.4030508@us.ibm.com>
	 <9230000.1108666127@flay>  <1108686742.6482.51.camel@localhost>
	 <1109017040.9817.1638.camel@knk>  <1109018361.21720.3.camel@localhost>
	 <1109023409.9817.1667.camel@knk>
Content-Type: text/plain
Date: Mon, 21 Feb 2005 14:24:40 -0800
Message-Id: <1109024680.25666.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>, matt dobson <colpatch@us.ibm.com>, John Stultz <johnstul@us.ibm.com>, Andy Whitcroft <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-02-21 at 14:03 -0800, keith wrote:
> On Mon, 2005-02-21 at 12:39, Dave Hansen wrote:
> > On Mon, 2005-02-21 at 12:17 -0800, keith wrote:
> > > +               if (node_has_online_mem(nid)){
> > > +                       if (start > low) {
> > 
> > Instead of indenting another level, can you just put a continue in the
> > loop?  I think it makes it much easier to read.  
> 
> I cannot put a continue here.  I know it makes ugly code worse but we
> have to call free area_init_node in all cases.   

If !node_has_online_mem(nid), then (node_start_pfn[nid] ==
node_end_pfn[nid]), and running through this if() won't hurt anything
here:

>                         if (start > low) {
> #ifdef CONFIG_HIGHMEM
>                                 BUG_ON(start > high);
>                                 zones_size[ZONE_HIGHMEM] = high - start;
> #endif
>                         }

high==start, so the bug won't trip, and it will set
zones_size[ZONE_HIGHMEM]=0, which is also OK.  Can you do this?

-               if (start > low) {
+               if (node_has_online_mem(nid) || (start > low)) {


> +#define node_has_online_mem(nid) !(node_start_pfn[nid] == node_end_pfn[nid]) 
> +/*
> +inline int __node_has_online_mem(int nid) {
> +        return !(node_start_pfn[nid]== node_end_pfn[nid]);
> +}
> +*/

You probably want to kill the extra definition.  Also, I prefer

	(node_start_pfn[nid] != node_end_pfn[nid])

to

	!(node_start_pfn[nid] == node_end_pfn[nid])

But, that's the most minor of nits.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
