Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EEC226B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 03:20:30 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so13846639pde.3
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 00:20:30 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ol12si15141446pab.53.2015.01.19.00.20.28
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 00:20:29 -0800 (PST)
Message-ID: <54BE0FB3.1030008@intel.com>
Date: Tue, 20 Jan 2015 16:20:03 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: [PATCH] mm/util.c: add a none zero check of "len"
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, bill.c.roberts@gmail.com, rientjes@google.com, yanmin_zhang@linux.intel.com

Although this check should have been done by caller. But as it's exported to others,
It's better to add a none zero check of "len" like other functions.

Signed-off-by: xinhuix.pan <xinhuix.pan@intel.com>
---
  mm/util.c | 5 +++++
  1 file changed, 5 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index fec39d4..3dc2873 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -72,6 +72,9 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
  {
  	void *p;
  
+	if (unlikely(!len))
+		return ERR_PTR(-EINVAL);
+
  	p = kmalloc_track_caller(len, gfp);
  	if (p)
  		memcpy(p, src, len);
@@ -91,6 +94,8 @@ void *memdup_user(const void __user *src, size_t len)
  {
  	void *p;
  
+	if (unlikely(!len))
+		return ERR_PTR(-EINVAL);
  	/*
  	 * Always use GFP_KERNEL, since copy_from_user() can sleep and
  	 * cause pagefault, which makes it pointless to use GFP_NOFS
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
