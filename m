Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 63D926B0039
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:39 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wn1so4875103obc.27
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:39 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id gu3si2215244obc.18.2014.05.22.20.33.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:38 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/5] mm,fs: introduce helpers around i_mmap_mutex
Date: Thu, 22 May 2014 20:33:22 -0700
Message-Id: <1400816006-3083-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Various parts of the kernel acquire and release this mutex,
so add i_mmap_lock_write() and immap_unlock_write() helper
functions that will encapsulate this logic. The next patch
will make use of these.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/fs.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1cab2f8..524d2c1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -456,6 +456,16 @@ struct block_device {
 
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
