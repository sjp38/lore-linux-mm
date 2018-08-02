From: Tony Battersby <tonyb-vFAe+i1/wJI5UWNf+nJyDw@public.gmane.org>
Subject: [PATCH v2 1/9] dmapool: fix boundary comparison
Date: Thu, 2 Aug 2018 15:56:52 -0400
Message-ID: <f72e836c-e262-6c48-bca0-db53eaeda1a5@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matthew Wilcox <willy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Sathya Prakash <sathya.prakash-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Chaitra P B <chaitra.basappa-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Suganath Prabu Subramani <suganath-prabu.subramani-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, linux-scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
List-Id: linux-mm.kvack.org

Fix the boundary comparison when constructing the list of free blocks
for the case that 'size' is a power of two.  Since 'boundary' is also a
power of two, that would make 'boundary' a multiple of 'size', in which
case a single block would never cross the boundary.  This bug would
cause some of the allocated memory to be wasted (but not leaked).

Example:

size       = 512
boundary   = 2048
allocation = 4096

Address range
   0 -  511
 512 - 1023
1024 - 1535
1536 - 2047 *
2048 - 2559
2560 - 3071
3072 - 3583
3584 - 4095 *

Prior to this fix, the address ranges marked with "*" would not have
been used even though they didn't cross the given boundary.

Fixes: e34f44b3517f ("pool: Improve memory usage for devices which can't cross boundaries")
Signed-off-by: Tony Battersby <tonyb-vFAe+i1/wJI5UWNf+nJyDw@public.gmane.org>
---

As part of developing a later patch in the series ("dmapool: reduce
footprint in struct page"), I wrote a standalone program that iterates
over all the combinations of PAGE_SIZE, 'size', and 'boundary', and
performs a series of consistency checks on the math in some new
functions, and it turned up this bug.  With this change, all the
consistency checks pass.  So I am fairly confident that this change
doesn't break other combinations of parameters.

Even though I described this as a "fix", it does not seem important
enough to Cc: stable from a strict reading of the stable kernel rules. 
IOW, it is not "bothering" anyone.

--- linux/mm/dmapool.c.orig	2018-08-01 17:57:04.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-01 17:57:16.000000000 -0400
@@ -210,7 +210,7 @@ static void pool_initialise_page(struct 
 
 	do {
 		unsigned int next = offset + pool->size;
-		if (unlikely((next + pool->size) >= next_boundary)) {
+		if (unlikely((next + pool->size) > next_boundary)) {
 			next = next_boundary;
 			next_boundary += pool->boundary;
 		}
