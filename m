Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC0936B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 06:58:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x23so5246549pfm.7
        for <linux-mm@kvack.org>; Wed, 02 May 2018 03:58:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q22-v6si1112783pgc.150.2018.05.02.03.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 03:58:42 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] kasan: record timestamp of memory allocation/free
Date: Wed,  2 May 2018 19:58:09 +0900
Message-Id: <1525258689-3430-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Serebryany <kcc@google.com>, Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>

syzbot is reporting many refcount/use-after-free bugs along with flood of
memory allocation fault injection messages. Showing timestamp of memory
allocation/free would help narrowing down kernel messages to examine.

Revive timestamp field which was removed by commit cd11016e5f5212c1
("mm, kasan: stackdepot implementation. Enable stackdepot for SLAB").

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Konstantin Serebryany <kcc@google.com>
Cc: Dmitry Chernenkov <dmitryc@google.com>
---
 mm/kasan/kasan.c  | 1 +
 mm/kasan/kasan.h  | 1 +
 mm/kasan/report.c | 3 ++-
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 135ce28..a336834 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -457,6 +457,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
 static inline void set_track(struct kasan_track *track, gfp_t flags)
 {
 	track->pid = current->pid;
+	track->when = jiffies;
 	track->stack = save_stack(flags);
 }
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c12dcfd..0e4951b 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -77,6 +77,7 @@ struct kasan_global {
 struct kasan_track {
 	u32 pid;
 	depot_stack_handle_t stack;
+	unsigned long when;
 };
 
 struct kasan_alloc_meta {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 5c169aa..062c8ae 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -183,7 +183,8 @@ static void kasan_end_report(unsigned long *flags)
 
 static void print_track(struct kasan_track *track, const char *prefix)
 {
-	pr_err("%s by task %u:\n", prefix, track->pid);
+	pr_err("%s by task %u (%lu jiffies ago):\n", prefix, track->pid,
+	       jiffies - track->when);
 	if (track->stack) {
 		struct stack_trace trace;
 
-- 
1.8.3.1
