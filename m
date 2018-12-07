Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7EB6B7FF6
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:58:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so1726550ede.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:58:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor1986097edq.15.2018.12.07.01.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 01:58:03 -0800 (PST)
Date: Fri, 7 Dec 2018 09:58:01 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm, page_alloc: cleanup usemap_size() when SPARSEMEM
 is not set
Message-ID: <20181207095801.2s664cinhdk5vjql@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <20181205091905.27727-2-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205091905.27727-2-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Dec 05, 2018 at 05:19:05PM +0800, Wei Yang wrote:
>Two cleanups in this patch:
>
>  * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
>    and right shift pageblock_order could be replaced with
>    DIV_ROUND_UP()
>  * use BITS_TO_LONGS() to get number of bytes for bitmap
>
>This patch also fix one typo in comment.

Patch 1 maybe controversial, how about this one :-)

Look forward some comments.

>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> mm/page_alloc.c | 9 +++------
> 1 file changed, 3 insertions(+), 6 deletions(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 7c745c305332..baf473f80800 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -6204,7 +6204,7 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
> /*
>  * Calculate the size of the zone->blockflags rounded to an unsigned long
>  * Start by making sure zonesize is a multiple of pageblock_order by rounding
>- * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
>+ * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally
>  * round what is now in bits to nearest long in bits, then return it in
>  * bytes.
>  */
>@@ -6213,12 +6213,9 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
> 	unsigned long usemapsize;
> 
> 	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
>-	usemapsize = roundup(zonesize, pageblock_nr_pages);
>-	usemapsize = usemapsize >> pageblock_order;
>+	usemapsize = DIV_ROUND_UP(zonesize, pageblock_nr_pages);
> 	usemapsize *= NR_PAGEBLOCK_BITS;
>-	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
>-
>-	return usemapsize / 8;
>+	return BITS_TO_LONGS(usemapsize) * sizeof(unsigned long);
> }
> 
> static void __ref setup_usemap(struct pglist_data *pgdat,
>-- 
>2.15.1

-- 
Wei Yang
Help you, Help me
