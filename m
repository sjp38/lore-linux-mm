Message-ID: <484FDCAB.9020002@firstfloor.org>
Date: Wed, 11 Jun 2008 16:09:47 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Removing node flags from page->flags was Re: [PATCH -mm 13/25] Noreclaim
 LRU Infrastructure II
References: <20080606180506.081f686a.akpm@linux-foundation.org>	<20080608163413.08d46427@bree.surriel.com>	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>	<20080608173244.0ac4ad9b@bree.surriel.com>	<20080608162208.a2683a6c.akpm@linux-foundation.org>	<20080608193420.2a9cc030@bree.surriel.com>	<20080608165434.67c87e5c.akpm@linux-foundation.org>	<Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>	<20080610153702.4019e042@cuia.bos.redhat.com>	<20080610143334.c53d7d8a.akpm@linux-foundation.org>	<20080611050914.GA27488@linux-sh.org> <20080610231642.6b4b5a53.akpm@linux-foundation.org>
In-Reply-To: <20080610231642.6b4b5a53.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

After some comptemplation I don't think we need to do anything for this.
Just add more page flags. The ifdef jungle in mm.h should handle it already.

#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
#define NODES_WIDTH             NODES_SHIFT
#else
#ifdef CONFIG_SPARSEMEM_VMEMMAP
#error "Vmemmap: No space for nodes field in page flags"
#endif
#define NODES_WIDTH             0
#endif


[btw the vmemmap case could be handled easily too by going through
the zone, but it's not used on 32bit]

and then

#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
#define NODE_NOT_IN_PAGE_FLAGS
#endif


and then

#ifdef NODE_NOT_IN_PAGE_FLAGS
extern int page_to_nid(struct page *page);
#else
static inline int page_to_nid(struct page *page)
{
        return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
}
#endif

and the sparse.c page_to_nid does a hash lookup.

So if NR_PAGEFLAGS is big enough it should work.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
