Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 74A20828DE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 12:02:47 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id h5so51314369igh.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:02:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q8si8468253ige.33.2016.01.09.09.02.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Jan 2016 09:02:46 -0800 (PST)
Subject: What is oom_killer_disable() for?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201601100202.DHE57897.OVLJOMHFOtFFSQ@I-love.SAKURA.ne.jp>
Date: Sun, 10 Jan 2016 02:02:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com
Cc: linux-mm@kvack.org

I wonder what oom_killer_disable() wants to do.

(1) We need to save a consistent memory snapshot image when suspending,
    is this correct?

(2) To obtain a consistent memory snapshot image, we need to freeze all
    but current thread in order to avoid modifying on-memory data while
    saving to disk, is this correct?

(3) Then, what is the purpose of disabling the OOM killer? Why do we
    need to disable the OOM killer? Is it because the OOM killer thaws
    already frozen threads?

(4) Then, why do we wait for TIF_MEMDIE threads to terminate? We can
    freeze thawed threads again without waiting for TIF_MEMDIE threads,
    can't we? Is it because we need free memory for saving to disk?

(5) Then, why waiting for only TIF_MEMDIE threads is sufficient? There
    is no TIF_MEMDIE threads does not guarantee that we have free memory,
    for there might be !TIF_MEMDIE threads which are still sharing memory
    used by TIF_MEMDIE threads.

(6) Since oom_killer_disable() already disabled the OOM killer,
    !TIF_MEMDIE threads which are sharing memory used by TIF_MEMDIE
    threads cannot get TIF_MEMDIE by calling out_of_memory().
    Also, since out_of_memory() returns false after oom_killer_disable()
    disabled the OOM killer, allocation requests by these !TIF_MEMDIE
    threads start failing. Why do we need to give up with accepting
    undesirable errors (e.g. failure of syscalls which modify an object's
    attribute)? Why don't we abort suspend operation by marking that
    re-enabling of the OOM killer might caused modification of on-memory
    data (like patch shown below)? We can make final decision after memory
    image snapshot is saved to disk, can't we? We can reply users that
    "suspend operation was cancelled due to out of memory" and ask users
    to try again, instead of failing e.g. chmod() syscall and/or asking
    users to check serial console for errors after the OOM killer was
    disabled.

diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index b7342a2..665a559 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -588,6 +588,8 @@ int hibernation_platform_enter(void)
 	return error;
 }
 
+extern bool oom_killer_disable_aborted;
+
 /**
  * power_down - Shut the machine down for hibernation.
  *
@@ -600,6 +602,10 @@ static void power_down(void)
 #ifdef CONFIG_SUSPEND
 	int error;
 #endif
+	if (oom_killer_disable_aborted) {
+		printk(KERN_ERR "PM: Suspend aborted due to out of memory\n");
+		return;
+	}
 
 	switch (hibernation_mode) {
 	case HIBERNATION_REBOOT:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bafa6b2..07ed44a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -426,6 +426,7 @@ static atomic_t oom_victims = ATOMIC_INIT(0);
 static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 bool oom_killer_disabled __read_mostly;
+bool oom_killer_disable_aborted __read_mostly;
 
 #ifdef CONFIG_MMU
 /*
@@ -618,6 +619,7 @@ bool oom_killer_disable(void)
 	if (mutex_lock_killable(&oom_lock))
 		return false;
 	oom_killer_disabled = true;
+	oom_killer_disable_aborted = false;
 	mutex_unlock(&oom_lock);
 
 	/* Do not wait forever in case existing victims got stuck. */
@@ -632,6 +634,7 @@ bool oom_killer_disable(void)
  */
 void oom_killer_enable(void)
 {
+	oom_killer_disable_aborted = false;
 	oom_killer_disabled = false;
 }
 
@@ -840,8 +843,10 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
-	if (oom_killer_disabled)
-		return false;
+	if (oom_killer_disabled) {
+		oom_killer_disable_aborted = true;
+		oom_killer_disabled = false;
+	}
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
