Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3460C6B00EA
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 21:38:22 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 27 Apr 2012 21:38:20 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 94C8238C803A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 21:38:17 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3S1cH8K25034858
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 21:38:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3S1cH4G009693
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 22:38:17 -0300
Date: Sat, 28 Apr 2012 09:38:02 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] MM: check limit while deallocating bootmem node
Message-ID: <20120428013802.GA8061@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1335498104-31900-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1335498104-31900-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335498104-31900-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: linux-mm@kvack.org

Hi Johannes,

Could you take a look on this while you have available time?

Thanks,
Gavin

>For the particular bootmem node, the minimal and maximal PFN (
>Page Frame Number) have been traced in the instance of "struct
>bootmem_data_t". On current implementation, the maximal PFN isn't
>checked while deallocating a bunch (BITS_PER_LONG) of page frames.
>So the current implementation won't work if the maximal PFN isn't
>aligned with BITS_PER_LONG.
>
>The patch will check the maximal PFN of the given bootmem node.
>Also, we needn't check all the bits map when the starting PFN isn't
>BITS_PER_LONG aligned. Actually, we should start from the offset
>of the bits map, which indicated by the starting PFN.
>
>Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>---
> mm/bootmem.c |   11 ++++++++---
> 1 files changed, 8 insertions(+), 3 deletions(-)
>
>diff --git a/mm/bootmem.c b/mm/bootmem.c
>index 5a04536..ebac3ba 100644
>--- a/mm/bootmem.c
>+++ b/mm/bootmem.c
>@@ -194,16 +194,20 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
> 		 * BITS_PER_LONG block of pages in front of us, free
> 		 * it in one go.
> 		 */
>-		if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL) {
>+		if (end - start >= BITS_PER_LONG &&
>+		    IS_ALIGNED(start, BITS_PER_LONG) &&
>+		    vec == ~0UL) {
> 			int order = ilog2(BITS_PER_LONG);
>
> 			__free_pages_bootmem(pfn_to_page(start), order);
> 			count += BITS_PER_LONG;
> 			start += BITS_PER_LONG;
> 		} else {
>-			unsigned long off = 0;
>+			unsigned long cursor = start;
>+			unsigned long off = cursor & (BITS_PER_LONG - 1);
>
>-			while (vec && off < BITS_PER_LONG) {
>+			vec >>= off;
>+			while (vec && off < BITS_PER_LONG && cursor < end) {
> 				if (vec & 1) {
> 					page = pfn_to_page(start + off);
> 					__free_pages_bootmem(page, 0);
>@@ -211,6 +215,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
> 				}
> 				vec >>= 1;
> 				off++;
>+				cursor++;
> 			}
> 			start = ALIGN(start + 1, BITS_PER_LONG);
> 		}
>-- 
>1.7.5.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
