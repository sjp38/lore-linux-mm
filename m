Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9CA6B0008
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 19:26:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u188so2809091pfb.6
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:26:20 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id w9si6217434pgo.82.2018.02.26.16.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 16:26:18 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 4/4 v2] mm: use access_remote_vm() in get_cmdline()
Date: Tue, 27 Feb 2018 08:25:51 +0800
Message-Id: <1519691151-101999-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org, adobriyan@gmail.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

get_cmdline() is using access_process_vm() which increases mm reference
count, but the mm reference count has been increased before calling
access_process_vm() and it is kept across get_cmdline(). It sounds
unnecessary to get mm reference count increased twice, so replace
access_process_vm() to access_remote_vm() which requires caller increase
mm reference count.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/util.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index c125050..9b40637 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -732,7 +732,7 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (len > buflen)
 		len = buflen;
 
-	res = access_process_vm(task, arg_start, buffer, len, FOLL_FORCE);
+	res = access_remote_vm(mm, arg_start, buffer, len, FOLL_FORCE);
 
 	/*
 	 * If the nul at the end of args has been overwritten, then
@@ -746,7 +746,7 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 			len = env_end - env_start;
 			if (len > buflen - res)
 				len = buflen - res;
-			res += access_process_vm(task, env_start,
+			res += access_remote_vm(mm, env_start,
 						 buffer+res, len,
 						 FOLL_FORCE);
 			res = strnlen(buffer, res);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
