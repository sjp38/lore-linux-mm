Date: Sun, 1 Aug 2004 04:05:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] token based thrashing control
Message-Id: <20040801040553.305f0275.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, sjiang@cs.wm.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
>
> The following experimental patch implements token based thrashing
>  protection, 

Thanks for this - it is certainly needed.

As you say, qsbench throughput is greatly increased (4x here).  But the old
`make -j4 vmlinux' with mem=64m shows no benefit at all.

I figured it was the short-lived processes, so I added the below, which
passes the token to the child across exec, and back to the parent on exit. 
Although it appears to work correctly, it too make no difference.

btw, in page_referenced_one():

+	if (mm != current->mm && has_swap_token(mm))
+		referenced++;

what's the reason for the `mm != current->mm' test?



diff -puN fs/exec.c~token-based-thrashing-control-inheritance fs/exec.c
--- 25/fs/exec.c~token-based-thrashing-control-inheritance	2004-08-01 03:42:04.191461248 -0700
+++ 25-akpm/fs/exec.c	2004-08-01 03:42:04.199460032 -0700
@@ -1146,6 +1146,7 @@ int do_execve(char * filename,
 
 		/* execve success */
 		security_bprm_free(&bprm);
+		take_swap_token();
 		return retval;
 	}
 
diff -puN include/linux/swap.h~token-based-thrashing-control-inheritance include/linux/swap.h
--- 25/include/linux/swap.h~token-based-thrashing-control-inheritance	2004-08-01 03:42:04.193460944 -0700
+++ 25-akpm/include/linux/swap.h	2004-08-01 03:42:04.198460184 -0700
@@ -209,6 +209,7 @@ extern struct page * read_swap_cache_asy
 extern struct mm_struct * swap_token_mm;
 extern void grab_swap_token(void);
 extern void __put_swap_token(struct mm_struct *);
+extern void take_swap_token(void);
 
 static inline int has_swap_token(struct mm_struct *mm)
 {
diff -puN mm/thrash.c~token-based-thrashing-control-inheritance mm/thrash.c
--- 25/mm/thrash.c~token-based-thrashing-control-inheritance	2004-08-01 03:42:04.194460792 -0700
+++ 25-akpm/mm/thrash.c	2004-08-01 03:53:13.590697096 -0700
@@ -93,8 +93,34 @@ void __put_swap_token(struct mm_struct *
 {
 	spin_lock(&swap_token_lock);
 	if (mm == swap_token_mm) {
-		swap_token_mm = &init_mm;
-		swap_token_check = jiffies;
+		struct task_struct *parent;
+
+		read_lock(&tasklist_lock);
+		parent = current->parent;
+		if (parent && parent->mm) {
+			parent->mm->swap_token_time = mm->swap_token_time;
+			parent->mm->recent_pagein = mm->recent_pagein;
+			swap_token_mm = parent->mm;
+			printk("%s gives token back to parent %s\n",
+					current->comm, parent->comm);
+		} else {
+			swap_token_mm = &init_mm;
+			swap_token_check = jiffies;
+		}
+		read_unlock(&tasklist_lock);
 	}
 	spin_unlock(&swap_token_lock);
 }
+
+void take_swap_token(void)
+{
+	struct task_struct *parent;
+
+	read_lock(&tasklist_lock);
+	parent = current->parent;
+	if (parent && current->mm && parent->mm == swap_token_mm) {
+		printk("%s takes token from %s\n", current->comm, parent->comm);
+		swap_token_mm = current->mm;
+	}
+	read_unlock(&tasklist_lock);
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
