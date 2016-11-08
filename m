Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B95C6B025E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 14:38:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p190so88816180wmp.3
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:16 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id m9si6896169wjr.174.2016.11.08.11.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 11:38:15 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id p190so267119284wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:15 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 1/2] stacktrace: fix print_stack_trace printing timestamp twice
Date: Tue,  8 Nov 2016 20:37:49 +0100
Message-Id: <9df5bd889e1b980d84aa41e7010e622005fd0665.1478632698.git.andreyknvl@google.com>
In-Reply-To: <cover.1478632698.git.andreyknvl@google.com>
References: <cover.1478632698.git.andreyknvl@google.com>
In-Reply-To: <cover.1478632698.git.andreyknvl@google.com>
References: <cover.1478632698.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Right now print_stack_trace prints timestamp twice, the first time
it's done by printk when printing spaces, the second - by print_ip_sym.
As a result, stack traces in KASAN reports have double timestamps:
[   18.822232] Allocated by task 3838:
[   18.822232]  [   18.822232] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
[   18.822232]  [   18.822232] [<ffffffff81509bd6>] save_stack+0x46/0xd0
[   18.822232]  [   18.822232] [<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0
....

Fix by calling printk only once.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/stacktrace.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index b6e4c16..56f510f 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -14,13 +14,15 @@
 void print_stack_trace(struct stack_trace *trace, int spaces)
 {
 	int i;
+	unsigned long ip;
 
 	if (WARN_ON(!trace->entries))
 		return;
 
 	for (i = 0; i < trace->nr_entries; i++) {
-		printk("%*c", 1 + spaces, ' ');
-		print_ip_sym(trace->entries[i]);
+		ip = trace->entries[i];
+		printk("%*c[<%p>] %pS\n", 1 + spaces, ' ',
+				(void *) ip, (void *) ip);
 	}
 }
 EXPORT_SYMBOL_GPL(print_stack_trace);
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
