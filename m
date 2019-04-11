Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74BACC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17046204EC
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FsQW3DxU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17046204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC3376B0278; Wed, 10 Apr 2019 21:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B47096B027A; Wed, 10 Apr 2019 21:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA4C6B027B; Wed, 10 Apr 2019 21:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75CAE6B0278
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:44:06 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id i80so3173170ybg.22
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=PyLdI7PZk1GSB43N13T7W74jY1CSZ1+A35vi7emlRBQ=;
        b=dq2FjRxOf+jmsIFB5/Fh9HjTHWed64S70IWbjc366I8kCMlC1rDgFYBk2kOgxwOwwu
         K7ta0Agj50fT50G+E7MT/M/NPL1kIy/8eJZ/G8kxkyUWJQMPt1pf+Itl8ySgJaXdQgqn
         Hv05RdREAL2MWpeLfC9eU+s+I+ZGI5sI1yVtinKEtoO1a55BgwyAAD9Yk5ZCqwu7tWTj
         LIxUz6S7+7ZAzEu8U8iqzi3sLwAV/+0YCLSL2Ge3V0x+pXCx2z4PTeeVGj3Olgea2azY
         WlKt+tBoUqRJtUn2jRPtFD/YT3GrmSKaWHU1ybVe0YNEduRcvNqMnRMDcUW2eHO6OaF9
         Ts8w==
X-Gm-Message-State: APjAAAXBtSwPP2y3bUTfSAjVmt1+E3m1IbJvDabmiF4E8WhZW3bOkOHV
	wNs6df04iwobLuni4TWmq6dzF4wy2nVkdtO3iirvuNoABCXeT/rLZuIy96pIgX1NNrr5G3agf04
	Qe+S1b8T54YJhwxh+Q61O8IX6aBW0VlItxOEesXc87Mv13YjV9sfN0hLMGiY+XeVxjA==
X-Received: by 2002:a81:344b:: with SMTP id b72mr37236024ywa.38.1554947046107;
        Wed, 10 Apr 2019 18:44:06 -0700 (PDT)
X-Received: by 2002:a81:344b:: with SMTP id b72mr37235988ywa.38.1554947045332;
        Wed, 10 Apr 2019 18:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554947045; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8yArOsIhj/A8Odza0WSDno/hnOUaKwqSOHPvXeQ+Ix7e1tTjetM/wmhIieX0zf0FB
         7G6tG3+3E/0g0sBvthywiAB50coSNFfuHP66ve67L9WHmjwM969dUz/Q/em2rYDGrkcQ
         BFSBGWp9sZNr41jkdBUdRJnQ4TtI7EMYuZbylEeZ1bYvpszGPTnGxGN+EkT9g6Nn+cxz
         9BRsMDXz7gpJqwtAT+UPNnPw1NWOHIwk/Z0fQvaXw40iX8k5bFyx0FgThZTJTZ34iJrE
         yils5ncKFK3lmCBkDxZ8OaQTWVVX6qZAUqRdvBGRF21+RvNuRtYtTHphHmH7DBImb/QV
         wpRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=PyLdI7PZk1GSB43N13T7W74jY1CSZ1+A35vi7emlRBQ=;
        b=DBJKTiWVsD+RIiAb6IFyd4YMoje7lRwujLORW6VtwMc9oVcY6AikSwuU+ofiK6cCBA
         nvCwvxywuR+Ib1M4Ztek/2sUlmsLCmf0kybg+nbP7fWhbzFOSUe3Qch0UgM0H/U+E9Vp
         HfXX5mJMKtp4jAtzEMQFgAcAUIV4dRruwDZZ8ERwslrdB3OhJl2JpRYWJXckeSvZ9+S3
         FGXYgO18Pd+0keiU2tunvC8NHWW31RRo0NP+SR2gqu/sZYj6tJQTIaP63rRNjZlfMhDl
         lVPb18Dl1deKESUYIK+A/ibDH2veY4vN1GEVfK4h+K0X5dAhlxY15ZNowLqqfGsiF6kv
         gmpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FsQW3DxU;
       spf=pass (google.com: domain of 35juuxaykcmez1yluinvvnsl.jvtspu14-ttr2hjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35JuuXAYKCMEz1yluinvvnsl.jvtspu14-ttr2hjr.vyn@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z65sor15758224yba.179.2019.04.10.18.44.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 18:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of 35juuxaykcmez1yluinvvnsl.jvtspu14-ttr2hjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FsQW3DxU;
       spf=pass (google.com: domain of 35juuxaykcmez1yluinvvnsl.jvtspu14-ttr2hjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35JuuXAYKCMEz1yluinvvnsl.jvtspu14-ttr2hjr.vyn@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=PyLdI7PZk1GSB43N13T7W74jY1CSZ1+A35vi7emlRBQ=;
        b=FsQW3DxUQfr3UEIOZaRtKQ14YG36rNMZAoP4RXuDnHZhTnzx8vfU+n++RB/3o0dp0u
         SH9s3G7Hv6ADWQtomsgGHp312SSsN6EYFO/ZI8x3zaQMzGdV60aG2if6ijB0CU2Xj/5p
         Wr+u7Wyb361ndUXGOOmlpRDdcHAAPNwaAxiqvx8CH06ziaPdVT7gmlngsPDr1J560YOg
         I5i/EcCf6HzZpeddrmKyHhq3l9q6cka24b266kjFb1tp+leUWTHkX9an5xjDZPYer8TK
         J/UNaD9DJCmOSB51Myj5q3PE83dNf3d9ehU/VPU0ePxzOZUM8hhQHSuA7EePSmvIH3LA
         aFig==
X-Google-Smtp-Source: APXvYqzoYtryft6snCAH2tsCLNm6pZ/FkqZ/mICxzIwSzE/D420FbpbEJQwThBXlAukM5+6xtF5vw2sOQK0=
X-Received: by 2002:a25:5:: with SMTP id 5mr10518104yba.52.1554947044969; Wed,
 10 Apr 2019 18:44:04 -0700 (PDT)
Date: Wed, 10 Apr 2019 18:43:53 -0700
In-Reply-To: <20190411014353.113252-1-surenb@google.com>
Message-Id: <20190411014353.113252-3-surenb@google.com>
Mime-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
From: Suren Baghdasaryan <surenb@google.com>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, rientjes@google.com, willy@infradead.org, 
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com, 
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com, 
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org, 
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org, 
	jannh@google.com, surenb@google.com, linux-mm@kvack.org, 
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, 
	kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add new SS_EXPEDITE flag to be used when sending SIGKILL via
pidfd_send_signal() syscall to allow expedited memory reclaim of the
victim process. The usage of this flag is currently limited to SIGKILL
signal and only to privileged users.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 include/linux/sched/signal.h |  3 ++-
 include/linux/signal.h       | 11 ++++++++++-
 ipc/mqueue.c                 |  2 +-
 kernel/signal.c              | 37 ++++++++++++++++++++++++++++--------
 kernel/time/itimer.c         |  2 +-
 5 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index e412c092c1e8..8a227633a058 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -327,7 +327,8 @@ extern int send_sig_info(int, struct kernel_siginfo *, struct task_struct *);
 extern void force_sigsegv(int sig, struct task_struct *p);
 extern int force_sig_info(int, struct kernel_siginfo *, struct task_struct *);
 extern int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp);
-extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid);
+extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
+				bool expedite);
 extern int kill_pid_info_as_cred(int, struct kernel_siginfo *, struct pid *,
 				const struct cred *);
 extern int kill_pgrp(struct pid *pid, int sig, int priv);
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 9702016734b1..34b7852aa4a0 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -446,8 +446,17 @@ int __save_altstack(stack_t __user *, unsigned long);
 } while (0);
 
 #ifdef CONFIG_PROC_FS
+
+/*
+ * SS_FLAGS values used in pidfd_send_signal:
+ *
+ * SS_EXPEDITE indicates desire to expedite the operation.
+ */
+#define SS_EXPEDITE	0x00000001
+
 struct seq_file;
 extern void render_sigset_t(struct seq_file *, const char *, sigset_t *);
-#endif
+
+#endif /* CONFIG_PROC_FS */
 
 #endif /* _LINUX_SIGNAL_H */
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index aea30530c472..27c66296e08e 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -720,7 +720,7 @@ static void __do_notify(struct mqueue_inode_info *info)
 			rcu_read_unlock();
 
 			kill_pid_info(info->notify.sigev_signo,
-				      &sig_i, info->notify_owner);
+				      &sig_i, info->notify_owner, false);
 			break;
 		case SIGEV_THREAD:
 			set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
diff --git a/kernel/signal.c b/kernel/signal.c
index f98448cf2def..02ed4332d17c 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -43,6 +43,7 @@
 #include <linux/compiler.h>
 #include <linux/posix-timers.h>
 #include <linux/livepatch.h>
+#include <linux/oom.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
@@ -1394,7 +1395,8 @@ int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp)
 	return success ? 0 : retval;
 }
 
-int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
+int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
+				  bool expedite)
 {
 	int error = -ESRCH;
 	struct task_struct *p;
@@ -1402,8 +1404,17 @@ int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
 	for (;;) {
 		rcu_read_lock();
 		p = pid_task(pid, PIDTYPE_PID);
-		if (p)
+		if (p) {
 			error = group_send_sig_info(sig, info, p, PIDTYPE_TGID);
+
+			/*
+			 * Ignore expedite_reclaim return value, it is best
+			 * effort only.
+			 */
+			if (!error && expedite)
+				expedite_reclaim(p);
+		}
+
 		rcu_read_unlock();
 		if (likely(!p || error != -ESRCH))
 			return error;
@@ -1420,7 +1431,7 @@ static int kill_proc_info(int sig, struct kernel_siginfo *info, pid_t pid)
 {
 	int error;
 	rcu_read_lock();
-	error = kill_pid_info(sig, info, find_vpid(pid));
+	error = kill_pid_info(sig, info, find_vpid(pid), false);
 	rcu_read_unlock();
 	return error;
 }
@@ -1487,7 +1498,7 @@ static int kill_something_info(int sig, struct kernel_siginfo *info, pid_t pid)
 
 	if (pid > 0) {
 		rcu_read_lock();
-		ret = kill_pid_info(sig, info, find_vpid(pid));
+		ret = kill_pid_info(sig, info, find_vpid(pid), false);
 		rcu_read_unlock();
 		return ret;
 	}
@@ -1704,7 +1715,7 @@ EXPORT_SYMBOL(kill_pgrp);
 
 int kill_pid(struct pid *pid, int sig, int priv)
 {
-	return kill_pid_info(sig, __si_special(priv), pid);
+	return kill_pid_info(sig, __si_special(priv), pid, false);
 }
 EXPORT_SYMBOL(kill_pid);
 
@@ -3577,10 +3588,20 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
 	struct pid *pid;
 	kernel_siginfo_t kinfo;
 
-	/* Enforce flags be set to 0 until we add an extension. */
-	if (flags)
+	/* Enforce no unknown flags. */
+	if (flags & ~SS_EXPEDITE)
 		return -EINVAL;
 
+	if (flags & SS_EXPEDITE) {
+		/* Enforce SS_EXPEDITE to be used with SIGKILL only. */
+		if (sig != SIGKILL)
+			return -EINVAL;
+
+		/* Limit expedited killing to privileged users only. */
+		if (!capable(CAP_SYS_NICE))
+			return -EPERM;
+	}
+
 	f = fdget_raw(pidfd);
 	if (!f.file)
 		return -EBADF;
@@ -3614,7 +3635,7 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
 		prepare_kill_siginfo(sig, &kinfo);
 	}
 
-	ret = kill_pid_info(sig, &kinfo, pid);
+	ret = kill_pid_info(sig, &kinfo, pid, (flags & SS_EXPEDITE) != 0);
 
 err:
 	fdput(f);
diff --git a/kernel/time/itimer.c b/kernel/time/itimer.c
index 02068b2d5862..c926483cdb53 100644
--- a/kernel/time/itimer.c
+++ b/kernel/time/itimer.c
@@ -140,7 +140,7 @@ enum hrtimer_restart it_real_fn(struct hrtimer *timer)
 	struct pid *leader_pid = sig->pids[PIDTYPE_TGID];
 
 	trace_itimer_expire(ITIMER_REAL, leader_pid, 0);
-	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid);
+	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid, false);
 
 	return HRTIMER_NORESTART;
 }
-- 
2.21.0.392.gf8f6787159e-goog

