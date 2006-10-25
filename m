Date: Wed, 25 Oct 2006 03:31:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/3] hugetlb: fix size=4G parsing
Message-ID: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 32-bit machines, mount -t hugetlbfs -o size=4G gave a 0GB filesystem,
size=5G gave a 1GB filesystem etc: there's no point in masking size with
HPAGE_MASK just before shifting its lower bits away, and since HPAGE_MASK
is a UL, that removed all the higher bits of the unsigned long long size.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
___

 fs/hugetlbfs/inode.c |    1 -
 1 file changed, 1 deletion(-)

--- 2.6.19-rc3/fs/hugetlbfs/inode.c	2006-10-24 04:34:28.000000000 +0100
+++ linux/fs/hugetlbfs/inode.c	2006-10-24 17:43:08.000000000 +0100
@@ -624,7 +624,6 @@ hugetlbfs_parse_options(char *options, s
 				do_div(size, 100);
 				rest++;
 			}
-			size &= HPAGE_MASK;
 			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
 			value = rest;
 		} else if (!strcmp(opt,"nr_inodes")) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
