Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 97BED6B0088
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:47 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 16:56:46 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3F7296E803A
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:36 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBBLua0331522900
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:36 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBBLuaDc027634
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:36 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: =?UTF-8?q?=5BPATCH=208/8=5D=20zswap=3A=20add=20documentation?=
Date: Tue, 11 Dec 2012 15:56:06 -0600
Message-Id: <1355262966-15281-9-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch adds the documentation file for the zswap functionality

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 Documentation/vm/zswap.txt |   74 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 74 insertions(+)
 create mode 100644 Documentation/vm/zswap.txt

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
new file mode 100644
index 0000000..f12d690
--- /dev/null
+++ b/Documentation/vm/zswap.txt
@@ -0,0 +1,74 @@
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
+
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
