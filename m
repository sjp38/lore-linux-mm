Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 108708D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 15:55:32 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 09/12] proc: disable mem_write after exec
Date: Sun, 13 Mar 2011 15:49:21 -0400
Message-Id: <1300045764-24168-10-git-send-email-wilsons@start.ca>
In-Reply-To: <1300045764-24168-1-git-send-email-wilsons@start.ca>
References: <1300045764-24168-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

This change makes mem_write() observe the same constraints as mem_read().  This
is particularly important for mem_write as an accidental leak of the fd across
an exec could result in arbitrary modification of the target process' memory.
IOW, /proc/pid/mem is implicitly close-on-exec.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/base.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9d096e8..e52702d 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -848,6 +848,10 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 	if (check_mem_permission(task))
 		goto out;
 
+	copied = -EIO;
+	if (file->private_data != (void *)((long)current->self_exec_id))
+		goto out;
+
 	copied = -ENOMEM;
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
