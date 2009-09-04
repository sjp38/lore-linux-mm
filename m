Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A10886B004D
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:27:16 -0400 (EDT)
Subject: [PATCH 3/4] proc: Clean up mmaps when a proc file is removed.
References: <m1fxb2wm0z.fsf@fess.ebiederm.org>
	<m1bplqwlzr.fsf@fess.ebiederm.org>
	<m17hwewlxr.fsf_-_@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 04 Sep 2009 12:27:21 -0700
In-Reply-To: <m17hwewlxr.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 04 Sep 2009 12\:26\:40 -0700")
Message-ID: <m13a72wlwm.fsf_-_@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


If a file such as /proc/bus/pci/*/* is mmaped and the underlying device
is hotunplugedd we can potentially run into all kinds of ugly things.

So implement unmap on remove by calling revoke_file_mappings.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/proc/generic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index fa678ab..42ce941 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -20,6 +20,7 @@
 #include <linux/bitops.h>
 #include <linux/spinlock.h>
 #include <linux/completion.h>
+#include <linux/mm.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -833,6 +834,7 @@ continue_removing:
 		pdeo = list_first_entry(&de->pde_openers, struct pde_opener, lh);
 		list_del(&pdeo->lh);
 		spin_unlock(&de->pde_unload_lock);
+		revoke_file_mappings(pdeo->file);
 		pdeo->release(pdeo->inode, pdeo->file);
 		kfree(pdeo);
 		spin_lock(&de->pde_unload_lock);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
