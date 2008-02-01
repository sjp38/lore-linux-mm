Subject: [PATCH] fix spurious EBUSY on memory cgroup removal
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080201034624.770651E3C10@siro.lan>
Date: Fri,  1 Feb 2008 12:46:24 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.osdl.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

hi,

the following patch is to fix spurious EBUSY on cgroup removal.

YAMAMOTO Takashi


call mm_free_cgroup earlier.
otherwise a reference due to lazy mm switching can prevent cgroup removal.

Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

--- linux-2.6.24-rc8-mm1/kernel/fork.c.BACKUP	2008-01-23 14:43:29.000000000 +0900
+++ linux-2.6.24-rc8-mm1/kernel/fork.c	2008-01-31 17:26:31.000000000 +0900
@@ -393,7 +393,6 @@ void __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
-	mm_free_cgroup(mm);
 	destroy_context(mm);
 	free_mm(mm);
 }
@@ -415,6 +414,7 @@ void mmput(struct mm_struct *mm)
 			spin_unlock(&mmlist_lock);
 		}
 		put_swap_token(mm);
+		mm_free_cgroup(mm);
 		mmdrop(mm);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
