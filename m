Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6EE46B02DE
	for <linux-mm@kvack.org>; Tue,  8 May 2018 14:19:27 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u7-v6so2250341plq.3
        for <linux-mm@kvack.org>; Tue, 08 May 2018 11:19:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p84si24575850pfa.180.2018.05.08.11.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 11:19:26 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [PATCH v2] mm: expland documentation over __read_mostly
Date: Tue,  8 May 2018 11:19:24 -0700
Message-Id: <20180508181924.19939-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, arnd@arndb.de, cl@linux.com
Cc: keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, dhowells@redhat.com, willy@infradead.org, ebiederm@xmission.com, rdunlap@infradead.org, joel.opensrc@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

__read_mostly can easily be misused by folks, its not meant for
just read-only data. There are performance reasons for using it, but
we also don't provide any guidance about its use. Provide a bit more
guidance over it use.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 include/linux/cache.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/cache.h b/include/linux/cache.h
index 750621e41d1c..4967566ed08c 100644
--- a/include/linux/cache.h
+++ b/include/linux/cache.h
@@ -15,8 +15,16 @@
 
 /*
  * __read_mostly is used to keep rarely changing variables out of frequently
- * updated cachelines. If an architecture doesn't support it, ignore the
- * hint.
+ * updated cachelines. Its use should be reserved for data that is used
+ * frequently in hot paths. Performance traces can help decide when to use
+ * this. You want __read_mostly data to be tightly packed, so that in the
+ * best case multiple frequently read variables for a hot path will be next
+ * to each other in order to reduce the number of cachelines needed to
+ * execute a critial path. We should be mindful and selective of its use.
+ * ie: if you're going to use it please supply a *good* justification in your
+ * commit log.
+ *
+ * If an architecture doesn't support it, ignore the hint.
  */
 #ifndef __read_mostly
 #define __read_mostly
-- 
2.17.0
