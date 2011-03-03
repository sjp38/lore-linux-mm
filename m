Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BE87F8D003A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:51:59 -0500 (EST)
Subject: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 12:50:52 -0500
Message-ID: <1299174652.2071.12.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Allowing unprivileged users to read /proc/slabinfo represents a security
risk, since revealing details of slab allocations can expose information
that is useful when exploiting kernel heap corruption issues.  This is
evidenced by observing that nearly all recent public exploits for heap
issues rely on feedback from /proc/slabinfo to manipulate heap layout
into an exploitable state.

Changing the permissions on this file to 0400 by default will make heap
corruption issues more difficult to exploit.  Ordinary usage should not
require unprivileged users to debug the running kernel; if this ability
is required, an admin can always chmod the file appropriately.


Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
---
 mm/slab.c |    3 ++-
 mm/slub.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 37961d1..7f719f6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4535,7 +4535,8 @@ static const struct file_operations proc_slabstats_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
+	proc_create("slabinfo", S_IWUSR|S_IRUSR, NULL,
+		    &proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index e15aa7f..5f57834 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4691,7 +4691,7 @@ static const struct file_operations proc_slabinfo_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo", S_IRUGO, NULL, &proc_slabinfo_operations);
+	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
 	return 0;
 }
 module_init(slab_proc_init);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
