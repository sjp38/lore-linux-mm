Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 93B886B0036
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:47 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 1/5] mm,fs: introduce helpers around i_mmap_mutex
Date: Mon, 24 Jun 2013 17:21:34 -0700
Message-Id: <1372119698-13147-2-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
References: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

Various parts of the kernel acquire and release this mutex,
so add i_mmap_lock_write() and immap_unlock_write() helper
functions that will encapsulate this logic. The next patch
will make use of these.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 include/linux/fs.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 65c2be2..1ea6c68 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -475,6 +475,16 @@ struct block_device {
 
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
