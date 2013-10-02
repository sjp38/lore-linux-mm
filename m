Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4B73A6B003B
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 16:18:07 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1399447pbb.33
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 13:18:06 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/2] mm,fs: introduce helpers around i_mmap_mutex
Date: Wed,  2 Oct 2013 13:17:45 -0700
Message-Id: <1380745066-9925-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
References: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr@hp.com>

Various parts of the kernel acquire and release this mutex,
so add i_mmap_lock_write() and immap_unlock_write() helper
functions that will encapsulate this logic. The next patch
will make use of these.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/fs.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..b32e64f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -478,6 +478,16 @@ struct block_device {
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
+static inline void i_mmap_lock_write(struct address_space *mapping)
+{
+	mutex_lock(&mapping->i_mmap_mutex);
+}
+
+static inline void i_mmap_unlock_write(struct address_space *mapping)
+{
+	mutex_unlock(&mapping->i_mmap_mutex);
+}
+
 /*
  * Might pages of this file be mapped into userspace?
  */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
