Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8D8326B0036
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 16:34:44 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 16:34:42 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D576138C8042
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 16:34:39 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r53KYcJN266646
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 16:34:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r53KYO4n025711
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 16:34:29 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: =?UTF-8?q?=5BPATCHv13=204/4=5D=20zswap=3A=20add=20documentation?=
Date: Mon,  3 Jun 2013 15:33:05 -0500
Message-Id: <1370291585-26102-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch adds the documentation file for the zswap functionality

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 Documentation/vm/zswap.txt |   68 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)
 create mode 100644 Documentation/vm/zswap.txt

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
new file mode 100644
index 0000000..7e492d8
--- /dev/null
+++ b/Documentation/vm/zswap.txt
@@ -0,0 +1,68 @@
+Overview:
+
+Zswap is a lightweight compressed cache for swap pages. It takes pages that are
+in the process of being swapped out and attempts to compress them into a
+dynamically allocated RAM-based memory pool.  zswap basically trades CPU cycles
+for potentially reduced swap I/O.A  This trade-off can also result in a
+significant performance improvement if reads from the compressed cache are
+faster than reads from a swap device.
+
+NOTE: Zswap is a new feature as of v3.11 and interacts heavily with memory
+reclaim.  This interaction has not be fully explored on the large set of
+potential configurations and workloads that exist.  For this reason, zswap
+is a work in progress and should be considered experimental.
+
+Some potential benefits:
+* Desktop/laptop users with limited RAM capacities can mitigate the
+A A A  performance impact of swapping.
+* Overcommitted guests that share a common I/O resource can
+A A A  dramatically reduce their swap I/O pressure, avoiding heavy handed I/O
+    throttling by the hypervisor.A This allows more work to get done with less
+    impact to the guest workload and guests sharing the I/O subsystem
+* Users with SSDs as swap devices can extend the life of the device by
+A A A  drastically reducing life-shortening writes.
+
+Zswap evicts pages from compressed cache on an LRU basis to the backing swap
+device when the compressed pool reaches it size limit.  This requirement had
+been identified in prior community discussions.
+
+To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
+zswap.enabled=1
+
+Design:
+
+Zswap receives pages for compression through the Frontswap API and is able to
+evict pages from its own compressed pool on an LRU basis and write them back to
+the backing swap device in the case that the compressed pool is full.
+
+Zswap makes use of zbud for the managing the compressed memory pool.  Each
+allocation in zbud is not directly accessible by address.  Rather, a handle is
+return by the allocation routine and that handle must be mapped before being
+accessed.  The compressed memory pool grows on demand and shrinks as compressed
+pages are freed.  The pool is not preallocated.
+
+When a swap page is passed from frontswap to zswap, zswap maintains a mapping
+of the swap entry, a combination of the swap type and swap offset, to the zbud
+handle that references that compressed swap page.  This mapping is achieved
+with a red-black tree per swap type.  The swap offset is the search key for the
+tree nodes.
+
+During a page fault on a PTE that is a swap entry, frontswap calls the zswap
+load function to decompress the page into the page allocated by the page fault
+handler.
+
+Once there are no PTEs referencing a swap page stored in zswap (i.e. the count
+in the swap_map goes to 0) the swap code calls the zswap invalidate function,
+via frontswap, to free the compressed entry.
+
+Zswap seeks to be simple in its policies.  Sysfs attributes allow for one user
+controlled policies:
+* max_pool_percent - The maximum percentage of memory that the compressed
+    pool can occupy.
+
+Zswap allows the compressor to be selected at kernel boot time by setting the
+a??compressora?? attribute.  The default compressor is lzo.  e.g.
+zswap.compressor=deflate
+
+A debugfs interface is provided for various statistic about pool size, number
+of pages stored, and various counters for the reasons pages are rejected.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
