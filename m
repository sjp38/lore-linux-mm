Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SG4oNX644056
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 12:04:50 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SG4oQU198856
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 10:04:50 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SG4o5e010820
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 10:04:50 -0600
Message-ID: <418118A1.9060004@us.ibm.com>
Date: Thu, 28 Oct 2004 09:04:49 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] sparsemem patches (was nonlinear)
References: <098973549.shadowen.org>
In-Reply-To: <098973549.shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Here are the current versions of my implmentation of
> CONFIG_SPARSEMEM; formerly CONFIG_NONLINEAR.  Mostly bug fixes to
> the alloc_remap() stuff and the conversion over to CONFIG_SPARSEMEM
> throughout.  The first few are esentially unchanged and only included
> for completeness.
> 
> As before they apply in numerical order.  This lot was diffed
> against 2.6.9 straight.
> 
> I take the view that the the breaking of V=P+c is an option
> to the memory model here.  So I'd expect to see something like
> CONFIG_SPARSEMEM_NONLINEAR or something.  So perhaps in the end this
> should be CONFIG_NONLINEAR if that happens.  But anyhow, changing
> its name now to SPARSEMEM will cirtainly help to reduce confusion :).

Thanks, Andy!

One thing that should simplify your code a bit are the no-buddy-bitmap 
patches which are sitting in -mm right now.  You might want to think 
about porting to -mm, it should reduce the total amount of code.

Also, after taking a bit more critical a look at the set, I'm not sure 
they're quite ready for merging yet.  There are still a pretty good 
number of #ifdefs

For instance, this:

+#ifdef HAVE_ARCH_ALLOC_REMAP
+		map = (unsigned long *) alloc_remap(pgdat->node_id,
+			bitmap_size);
+		if (!map)
+#endif
+			map = (unsigned long *)alloc_bootmem_node(pgdat,
+				bitmap_size);
+		zone->free_area[order].map = map;

Could all be solved by doing #ifdef in a header to declare alloc_remap() 
to return NULL if !HAVE_ARCH_ALLOC_REMAP.  In any case 
HAVE_ARCH_ALLOC_REMAP should be defined via a Kconfig file, not in a 
header.

Have you given any thought to using virt_to_page(page)->foo method to 
store section information instead of using page->flags?  It seems we're 
already sucking up page->flags left and right, and I'd hate to consume 
that many more.

Although simple arithmetically, the calculations for the flags shift 
does constitute a lot of code churn, and does add quite a bit of 
complexity.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
