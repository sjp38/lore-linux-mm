Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E1F706B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 15:29:28 -0500 (EST)
Received: by iajr24 with SMTP id r24so9828063iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 12:29:28 -0800 (PST)
Date: Tue, 6 Mar 2012 12:28:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mmap: EINVAL not ENOMEM when rejecting VM_GROWS
Message-ID: <alpine.LSU.2.00.1203061225500.17918@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently error is -ENOMEM when rejecting VM_GROWSDOWN|VM_GROWSUP
from shared anonymous: hoist the file case's -EINVAL up for both.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/mmap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 3.3.0-rc6+/mm/mmap.c	2012-03-05 16:38:23.741975593 -0800
+++ linux/mm/mmap.c	2012-03-06 12:14:32.704674576 -0800
@@ -1266,8 +1266,9 @@ munmap_back:
 	vma->vm_pgoff = pgoff;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 
+	error = -EINVAL;	/* when rejecting VM_GROWSDOWN|VM_GROWSUP */
+
 	if (file) {
-		error = -EINVAL;
 		if (vm_flags & (VM_GROWSDOWN|VM_GROWSUP))
 			goto free_vma;
 		if (vm_flags & VM_DENYWRITE) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
