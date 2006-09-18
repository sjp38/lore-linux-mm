Date: Tue, 19 Sep 2006 08:25:09 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Message-ID: <20060918232509.GA8032@localhost.usen.ad.jp>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com> <20060918183655.19679.51633.sendpatchset@schroedinger.engr.sgi.com> <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com> <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com> <20060918135559.GB15096@infradead.org> <20060918152243.GA4320@localhost.na.rta> <Pine.LNX.4.64.0609181031420.19312@schroedinger.engr.sgi.com> <20060918224548.GA6284@localhost.usen.ad.jp> <Pine.LNX.4.64.0609181556430.29365@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609181556430.29365@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org, James Bottomley <James.Bottomley@steeleye.com>, Russell King <rmk@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 18, 2006 at 03:58:52PM -0700, Christoph Lameter wrote:
> On Tue, 19 Sep 2006, Paul Mundt wrote:
> > You've missed the other ZONE_DMA references, if you scroll a bit further
> > down that's where we fill in ZONE_DMA, this is simply the default zone
> > layout that we rely on for nommu.
> 
> Are you sure that sh does not need ZONE_DMA? There is code in there
> to check for the DMA boundary. The following patch disables that
> code if CONFIG_ZONE_DMA is not set.
> 
Yes, MAX_DMA_ADDRESS (in include/asm-sh/dma.h) is from when we needed it for
alloc_bootmem(), we have no interest in it, but we can't kill off the
definition either since some drivers seem to rely on it.. It was also left
around in case some CPU variants with an arbitrary limitation in their
respective DMACs popped up.

All lowmem fits < MAX_DMA_ADDRESS and so gets stuffed in ZONE_DMA, as
per:

                if (low < max_dma) {
                        zones_size[ZONE_DMA] = low - start_pfn;
                        zones_size[ZONE_NORMAL] = 0;

So we may as well just do away with it entirely, via something like this:

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 8ea27ca..40494f9 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -156,7 +156,6 @@ void __init paging_init(void)
 	 * Setup some defaults for the zone sizes.. these should be safe
 	 * regardless of distcontiguous memory or MMU settings.
 	 */
-	zones_size[ZONE_DMA] = 0 >> PAGE_SHIFT;
 	zones_size[ZONE_NORMAL] = __MEMORY_SIZE >> PAGE_SHIFT;
 #ifdef CONFIG_HIGHMEM
 	zones_size[ZONE_HIGHMEM] = 0 >> PAGE_SHIFT;
@@ -168,7 +167,7 @@ #ifdef CONFIG_MMU
 	 * the zone sizes accordingly, in addition to turning it on.
 	 */
 	{
-		unsigned long max_dma, low, start_pfn;
+		unsigned long low, start_pfn;
 		pgd_t *pg_dir;
 		int i;
 
@@ -183,16 +182,10 @@ #ifdef CONFIG_MMU
 
 		/* Fixup the zone sizes */
 		start_pfn = START_PFN;
-		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 		low = MAX_LOW_PFN;
 
-		if (low < max_dma) {
-			zones_size[ZONE_DMA] = low - start_pfn;
-			zones_size[ZONE_NORMAL] = 0;
-		} else {
-			zones_size[ZONE_DMA] = max_dma - start_pfn;
-			zones_size[ZONE_NORMAL] = low - max_dma;
-		}
+		/* No DMA limitation, shove all of lowmem in ZONE_NORMAL. */
+		zones_size[ZONE_NORMAL] = low - start_pfn;
 	}
 
 #elif defined(CONFIG_CPU_SH3) || defined(CONFIG_CPU_SH4)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
