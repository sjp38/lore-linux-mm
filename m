Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 5B30F6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:21:59 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 12:21:58 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 97C3719D8088
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:19:35 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIJcCV363644
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:19:38 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIJZhZ023513
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:19:37 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv9 8/8] zswap: add documentation
Date: Wed, 10 Apr 2013 13:19:00 -0500
Message-Id: <1365617940-21623-9-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch adds the documentation file for the zswap functionality

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 Documentation/vm/zsmalloc.txt |  2 +-
 Documentation/vm/zswap.txt    | 82 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/vm/zswap.txt

diff --git a/Documentation/vm/zsmalloc.txt b/Documentation/vm/zsmalloc.txt
index 85aa617..4133ade 100644
--- a/Documentation/vm/zsmalloc.txt
+++ b/Documentation/vm/zsmalloc.txt
@@ -65,4 +65,4 @@ zs_unmap_object(pool, handle);
 zs_free(pool, handle);
 
 /* destroy the pool */
-zs_destroy_pool(pool); 
+zs_destroy_pool(pool);
diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
new file mode 100644
index 0000000..f29b82f
--- /dev/null
+++ b/Documentation/vm/zswap.txt
@@ -0,0 +1,82 @@
+Overview:
+
+Zswap is a lightweight compressed cache for swap pages. It takes
+pages that are in the process of being swapped out and attempts to
+compress them into a dynamically allocated RAM-based memory pool.
+If this process is successful, the writeback to the swap device is
+deferred and, in many cases, avoided completely.A  This results in
+a significant I/O reduction and performance gains for systems that
+are swapping.
+
+Zswap provides compressed swap caching that basically trades CPU cycles
+for reduced swap I/O.A  This trade-off can result in a significant
+performance improvement as reads to/writes from to the compressed
+cache almost always faster that reading from a swap device
+which incurs the latency of an asynchronous block I/O read.
+
+Some potential benefits:
+* Desktop/laptop users with limited RAM capacities can mitigate the
+A A A  performance impact of swapping.
+* Overcommitted guests that share a common I/O resource can
+A A A  dramatically reduce their swap I/O pressure, avoiding heavy
+A A A  handed I/O throttling by the hypervisor.A  This allows more work
+A A A  to get done with less impact to the guest workload and guests
+A A A  sharing the I/O subsystem
+* Users with SSDs as swap devices can extend the life of the device by
+A A A  drastically reducing life-shortening writes.
+
+Zswap evicts pages from compressed cache on an LRU basis to the backing
+swap device when the compress pool reaches it size limit or the pool is
+unable to obtain additional pages from the buddy allocator.A  This
+requirement had been identified in prior community discussions.
+
+To enabled zswap, the "enabled" attribute must be set to 1 at boot time.
+e.g. zswap.enabled=1
+
+Design:
+
+Zswap receives pages for compression through the Frontswap API and
+is able to evict pages from its own compressed pool on an LRU basis
+and write them back to the backing swap device in the case that the
+compressed pool is full or unable to secure additional pages from
+the buddy allocator.
+
+Zswap makes use of zsmalloc for the managing the compressed memory
+pool.  This is because zsmalloc is specifically designed to minimize
+fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
+allocation in zsmalloc is not directly accessible by address.
+Rather, a handle is return by the allocation routine and that handle
+must be mapped before being accessed.  The compressed memory pool grows
+on demand and shrinks as compressed pages are freed.  The pool is
+not preallocated.
+
+When a swap page is passed from frontswap to zswap, zswap maintains
+a mapping of the swap entry, a combination of the swap type and swap
+offset, to the zsmalloc handle that references that compressed swap
+page.  This mapping is achieved with a red-black tree per swap type.
+The swap offset is the search key for the tree nodes.
+
+During a page fault on a PTE that is a swap entry, frontswap calls
+the zswap load function to decompress the page into the page
+allocated by the page fault handler.
+
+Once there are no PTEs referencing a swap page stored in zswap
+(i.e. the count in the swap_map goes to 0) the swap code calls
+the zswap invalidate function, via frontswap, to free the compressed
+entry.
+
+Zswap seeks to be simple in its policies.  Sysfs attributes allow for
+two user controlled policies:
+* max_compression_ratio - Maximum compression ratio, as as percentage,
+    for an acceptable compressed page. Any page that does not compress
+    by at least this ratio will be rejected.
+* max_pool_percent - The maximum percentage of memory that the compressed
+    pool can occupy.
+
+Zswap allows the compressor to be selected at kernel boot time by
+setting the a??compressora?? attribute.  The default compressor is lzo.
+e.g. zswap.compressor=deflate
+
+A debugfs interface is provided for various statistic about pool size,
+number of pages stored, and various counters for the reasons pages
+are rejected.
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
