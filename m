Message-ID: <437B4EB0.3080908@kolumbus.fi>
Date: Wed, 16 Nov 2005 17:22:24 +0200
From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: DMA32 zone unusable
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

The new DMA32 zone (which at least x86-64 has) is quite "interesting" :

#define __GFP_DMA32    ((__force gfp_t)0x04) <-----!!!!!  

#define GFP_ZONEMASK    0x03   <------!!!!!

#define gfp_zone(mask) ((__force int)((mask) & (__force gfp_t)GFP_ZONEMASK))

static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
                        unsigned int order)
{
    if (unlikely(order >= MAX_ORDER))
        return NULL;

    return __alloc_pages(gfp_mask, order,
        NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
}


So with GFP_DMA32 you never get those pages (but DMA instead).

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
