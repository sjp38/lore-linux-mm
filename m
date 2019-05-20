Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CB7DC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 174562173C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="VqCtD+FG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 174562173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA80F6B000D; Mon, 20 May 2019 17:39:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55596B000E; Mon, 20 May 2019 17:39:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91D206B0010; Mon, 20 May 2019 17:39:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F60A6B000D
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:39:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so27216369edi.20
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:39:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EmM3y8RoE66pNVDPE35FtUxyGgXbfiMJbpXVG8+7zqI=;
        b=NSiEW/89Wq0u+IRQCWIwtlNzXO2zKN/bZSbbcSmK5PYy4fF3L5hyyncHuYh7kNLi2f
         +CI3SI/I24irGbxGZOWCFd+uD8zMms5ZiEu9ol5pfrFamRpU8InLbDQaE/So4mLV8q8t
         qJ1adYbRWu2Znb3IAiWsEHE+okPUhxgFz1JM4l0OcIFl+0JLQuxdQhl+mQ+GPZx+/3AE
         G8cm41vRiK+QdCWkXYvobILH4mLUQS8+NQPY9b4JAAeWZQpedaXFdUAHzo5Hg3OP7D9x
         PsNH2Bwnq+r5+oRnDEE+io9b+cDjtWxT6zE//YANr8oKirsRvso0JjcXmxNMFJ5H2uVJ
         lYzA==
X-Gm-Message-State: APjAAAUAxyKRY1QV5hspOlWSSuAXFxsPt7BSiyAgG5lvhXBAhS/HkTwl
	wA9KsBpeXZKKEqZhCJR+jptTf+Wsl8DBlg7SGV2XcAUez/Ne060HCxR03vmMyT+K2NSGdWNMWjK
	fnJ4pGeWRuo1My1ZNzET65mi6fKIl+WLhKKXPArfEw9uUSOSSvb+TImW+YUKffy6q8g==
X-Received: by 2002:a50:86a2:: with SMTP id r31mr77410544eda.259.1558388395707;
        Mon, 20 May 2019 14:39:55 -0700 (PDT)
X-Received: by 2002:a50:86a2:: with SMTP id r31mr77410457eda.259.1558388394213;
        Mon, 20 May 2019 14:39:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388394; cv=none;
        d=google.com; s=arc-20160816;
        b=VhcBmnnnRvQXqiXj8OO5pbPAj0QfFjlEBkc1XSZ08o1hOQfNpEWgt/FEdTPb9iG1Vk
         LxE5l41ZhZZrlx0KvUnzFqmDdPJ+95FNUlAnWF2k2y+nPGk9UlPMZlz3l+2+pKkQIi22
         wtW7SeYgL1bCZqCsY2AHnt4GW4C81vcLJyPj51EDdclwzkqhgfPjJJYvULbGM/4m0aFe
         EQTasqVbnMGb7/aOXTDzV0of+YwBjW7JBH8V6Fv45qJiLd06f2YLNxPPSWx2LNMqvzwm
         fw5z15g9qOi8AYbM2yv49eXIl7mISZzOhU8dLAHUkYn9MIY/yQakVQLNumkf2yEOGNoY
         cexQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EmM3y8RoE66pNVDPE35FtUxyGgXbfiMJbpXVG8+7zqI=;
        b=VA+djJSG5NxqlCTb7jK0+HzNXb0jg8p7qtzk+kf1Y1GTg2rlKLdZxOIlUVCymOhpFL
         x/BoXM/5x3ggkcHrAfQYpCBItsFV8DnjSQvtOPF5frlE8vf4r0LrLB6tXqp6y2XkeLPn
         Iut69wj/sU8Zxw1nsEBYngxuwtg3QHGjwO8uChm/TSVWtucS89vLWXgZ/ISCSktntPqM
         TW5S05a8tGTfqAGDIepH9TXExxKkLGzwCUnQMOD3k8+JwJyx2ezAEKp7ZDGZmKbx7Ca0
         lMSYb2GBmCP7+g84hoeHko0bza/0sFPIYC0Ul5my2uRGbk3iH/DpAM6AJxbH6U9aWIx5
         qI1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=VqCtD+FG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id jo15sor2885272ejb.37.2019.05.20.14.39.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:39:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=VqCtD+FG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EmM3y8RoE66pNVDPE35FtUxyGgXbfiMJbpXVG8+7zqI=;
        b=VqCtD+FGguTkslrrNgtc+3AsPTS7qL+QTDSCXi+eKgaqMA5bR+Vi1Zt3FimdTe93zi
         UUo6SSEc1uaTQZeWPxCi3yVl+T3Tk/MOF0wa5AgCnvXZvlQKsF/yAclCS1OGr15EZvta
         Zok9O7AuvN04KmdiIx3tL5Km97dnr+ZIZDhdM=
X-Google-Smtp-Source: APXvYqyKS9SIiB/xC4IsRJBze6IGM3GgILAOQy6WS8nllsilzSuF5yZIrT+jePyKYUY+nowSZNCWnw==
X-Received: by 2002:a17:906:35ca:: with SMTP id p10mr44566136ejb.244.1558388393833;
        Mon, 20 May 2019 14:39:53 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id v27sm3285772eja.68.2019.05.20.14.39.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:39:52 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 2/4] kernel.h: Add non_block_start/end()
Date: Mon, 20 May 2019 23:39:43 +0200
Message-Id: <20190520213945.17046-2-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In some special cases we must not block, but there's not a
spinlock, preempt-off, irqs-off or similar critical section already
that arms the might_sleep() debug checks. Add a non_block_start/end()
pair to annotate these.

This will be used in the oom paths of mmu-notifiers, where blocking is
not allowed to make sure there's forward progress. Quoting Michal:

"The notifier is called from quite a restricted context - oom_reaper -
which shouldn't depend on any locks or sleepable conditionals. The code
should be swift as well but we mostly do care about it to make a forward
progress. Checking for sleepable context is the best thing we could come
up with that would describe these demands at least partially."

Peter also asked whether we want to catch spinlocks on top, but Michal
said those are less of a problem because spinlocks can't have an
indirect dependency upon the page allocator and hence close the loop
with the oom reaper.

Suggested by Michal Hocko.

v2:
- Improve commit message (Michal)
- Also check in schedule, not just might_sleep (Peter)

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Wei Wang <wvw@google.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Jann Horn <jannh@google.com>
Cc: Feng Tang <feng.tang@intel.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org
Acked-by: Christian König <christian.koenig@amd.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/kernel.h | 10 +++++++++-
 include/linux/sched.h  |  4 ++++
 kernel/sched/core.c    | 19 ++++++++++++++-----
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 74b1ee9027f5..b5f2c2ff0eab 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -214,7 +214,9 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
  * might_sleep - annotation for functions that can sleep
  *
  * this macro will print a stack trace if it is executed in an atomic
- * context (spinlock, irq-handler, ...).
+ * context (spinlock, irq-handler, ...). Additional sections where blocking is
+ * not allowed can be annotated with non_block_start() and non_block_end()
+ * pairs.
  *
  * This is a useful debugging help to be able to catch problems early and not
  * be bitten later when the calling function happens to sleep when it is not
@@ -230,6 +232,10 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
 # define cant_sleep() \
 	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change = 0)
+# define non_block_start() \
+	do { current->non_block_count++; } while (0)
+# define non_block_end() \
+	do { WARN_ON(current->non_block_count-- == 0); } while (0)
 #else
   static inline void ___might_sleep(const char *file, int line,
 				   int preempt_offset) { }
@@ -238,6 +244,8 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
 # define might_sleep() do { might_resched(); } while (0)
 # define cant_sleep() do { } while (0)
 # define sched_annotate_sleep() do { } while (0)
+# define non_block_start() do { } while (0)
+# define non_block_end() do { } while (0)
 #endif
 
 #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 11837410690f..7f5b293e72df 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -908,6 +908,10 @@ struct task_struct {
 	struct mutex_waiter		*blocked_on;
 #endif
 
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	int				non_block_count;
+#endif
+
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int			irq_events;
 	unsigned long			hardirq_enable_ip;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 102dfcf0a29a..dd08d423947d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3264,13 +3264,22 @@ static noinline void __schedule_bug(struct task_struct *prev)
 /*
  * Various schedule()-time debugging checks and statistics:
  */
-static inline void schedule_debug(struct task_struct *prev)
+static inline void schedule_debug(struct task_struct *prev, bool preempt)
 {
 #ifdef CONFIG_SCHED_STACK_END_CHECK
 	if (task_stack_end_corrupted(prev))
 		panic("corrupted stack end detected inside scheduler\n");
 #endif
 
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	if (!preempt && prev->state && prev->non_block_count) {
+		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i\n",
+			prev->comm, prev->pid, prev->non_blocking_count);
+		dump_stack();
+		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
+	}
+#endif
+
 	if (unlikely(in_atomic_preempt_off())) {
 		__schedule_bug(prev);
 		preempt_count_set(PREEMPT_DISABLED);
@@ -3377,7 +3386,7 @@ static void __sched notrace __schedule(bool preempt)
 	rq = cpu_rq(cpu);
 	prev = rq->curr;
 
-	schedule_debug(prev);
+	schedule_debug(prev, preempt);
 
 	if (sched_feat(HRTICK))
 		hrtick_clear(rq);
@@ -6102,7 +6111,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 	rcu_sleep_check();
 
 	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
-	     !is_idle_task(current)) ||
+	     !is_idle_task(current) && !current->non_block_count) ||
 	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
 	    oops_in_progress)
 		return;
@@ -6118,8 +6127,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 		"BUG: sleeping function called from invalid context at %s:%d\n",
 			file, line);
 	printk(KERN_ERR
-		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
-			in_atomic(), irqs_disabled(),
+		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
+			in_atomic(), irqs_disabled(), current->non_block_count,
 			current->pid, current->comm);
 
 	if (task_stack_end_corrupted(current))
-- 
2.20.1

