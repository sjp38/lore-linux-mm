Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9DGVtHn014414
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 12:31:55 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9DGXwK3423320
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 10:33:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9DGXwBj031251
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 10:33:58 -0600
Message-ID: <434E8C72.5000909@austin.ibm.com>
Date: Thu, 13 Oct 2005 11:33:54 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Fragmentation Avoidance V17: 002_usemap
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>  <20051011151231.16178.58396.sendpatchset@skynet.csn.ul.ie> <1129211783.7780.7.camel@localhost> <Pine.LNX.4.58.0510131500020.7570@skynet>
In-Reply-To: <Pine.LNX.4.58.0510131500020.7570@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

>>>@@ -473,6 +491,15 @@ extern struct pglist_data contig_page_da
>>> #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
>>> #error Allocator MAX_ORDER exceeds SECTION_SIZE
>>> #endif
>>>+#if ((SECTION_SIZE_BITS - MAX_ORDER) * BITS_PER_RCLM_TYPE) > 64
>>>+#error free_area_usemap is not big enough
>>>+#endif
>>
>>Every time I look at these patches, I see this #if, and I don't remember
>>what that '64' means.  Can it please get a real name?
>>
> 
> 
> Joel, suggestions?

Oh yeah, blame it on me just because I wrote that bit of code.  How about
#define FREE_AREA_USEMAP_SIZE 64

> 
> 
>>>+/* Usemap initialisation */
>>>+#ifdef CONFIG_SPARSEMEM
>>>+static inline void setup_usemap(struct pglist_data *pgdat,
>>>+				struct zone *zone, unsigned long zonesize) {}
>>>+#endif /* CONFIG_SPARSEMEM */
>>>
>>> struct page;
>>> struct mem_section {
>>>@@ -485,6 +512,7 @@ struct mem_section {
>>> 	 * before using it wrong.
>>> 	 */
>>> 	unsigned long section_mem_map;
>>>+	DECLARE_BITMAP(free_area_usemap,64);
>>> };
>>
>>There's that '64' again!  You need a space after the comma, too.

Ditto.

>>>+ * RCLM_SHIFT is the number of bits that a gfp_mask has to be shifted right
>>>+ * to have just the __GFP_USER and __GFP_KERNRCLM bits. The static check is
>>>+ * made afterwards in case the GFP flags are not updated without updating
>>>+ * this number
>>>+ */
>>>+#define RCLM_SHIFT 19
>>>+#if (__GFP_USER >> RCLM_SHIFT) != RCLM_USER
>>>+#error __GFP_USER not mapping to RCLM_USER
>>>+#endif
>>>+#if (__GFP_KERNRCLM >> RCLM_SHIFT) != RCLM_KERN
>>>+#error __GFP_KERNRCLM not mapping to RCLM_KERN
>>>+#endif
>>
>>Should this really be in page_alloc.c, or should it be close to the
>>RCLM_* definitions?

I had the same first impression, but concluded this was the best place.  The 
compile time checks should keep things from getting out of sync.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
