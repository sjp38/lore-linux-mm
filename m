Date: Mon, 17 Sep 2007 19:57:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mm] fix swapoff breakage; however...
Message-ID: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

rc4-mm1's memory-controller-memory-accounting-v7.patch broke swapoff:
it extended unuse_pte_range's boolean "found" return code to allow an
error return too; but ended up returning found (1) as an error.
Replace that by success (0) before it gets to the upper level.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
More fundamentally, it looks like any container brought over its limit in
unuse_pte will abort swapoff: that doesn't doesn't seem "contained" to me.
Maybe unuse_pte should just let containers go over their limits without
error?  Or swap should be counted along with RSS?  Needs reconsideration.

 mm/swapfile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.23-rc4-mm1/mm/swapfile.c	2007-09-07 13:09:42.000000000 +0100
+++ linux/mm/swapfile.c	2007-09-17 15:14:47.000000000 +0100
@@ -642,7 +642,7 @@ static int unuse_mm(struct mm_struct *mm
 			break;
 	}
 	up_read(&mm->mmap_sem);
-	return ret;
+	return (ret < 0)? ret: 0;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
