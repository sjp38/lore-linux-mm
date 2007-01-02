Date: Wed, 3 Jan 2007 06:03:22 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] Sanely size hash tables when using large base pages. take 2.
Message-ID: <20070102210322.GA20697@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a resubmission of the earlier patch with the pidhash bits
dropped.

At the moment the inode/dentry cache hash tables (common by way of
alloc_large_system_hash()) are incorrectly sized by their respective
detection logic when we attempt to use large base pages on systems
with little memory.

This results in odd behaviour when using a 64kB PAGE_SIZE, such as:

Dentry cache hash table entries: 8192 (order: -1, 32768 bytes)
Inode-cache hash table entries: 4096 (order: -2, 16384 bytes)

The mount cache hash table is seemingly the only one that gets this right
by directly taking PAGE_SIZE in to account.

The following patch attempts to catch the bogus values and round it up to
at least 0-order.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/page_alloc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8c1a116..4a9a83f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3321,6 +3321,10 @@ void *__init alloc_large_system_hash(con
 			numentries >>= (scale - PAGE_SHIFT);
 		else
 			numentries <<= (PAGE_SHIFT - scale);
+
+		/* Make sure we've got at least a 0-order allocation.. */
+		if (unlikely((numentries * bucketsize) < PAGE_SIZE))
+			numentries = PAGE_SIZE / bucketsize;
 	}
 	numentries = roundup_pow_of_two(numentries);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
