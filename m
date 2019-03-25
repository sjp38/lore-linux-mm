Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46958C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B3E8206C0
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B3E8206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08F4C6B0266; Mon, 25 Mar 2019 18:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34EF6B026A; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD6226B026B; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8D8B6B0266
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g17so11795261qte.17
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:56:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Pg+ngYFMmyJ8lECB6vesVMArcBSQwLgdaATa835z1bQ=;
        b=qJCJLRrQ7j6btohVNkXunbsjpqFX0QYuVvW1HnHpgcdaR6gDqYkboRQlNlPtVsh2uI
         0Ym66Vh9ZgLRmPuNCmzgmyNeHkTTozKXBEyIEpa5nYHgFToG2KmjkjL9XeMqxaOFBhD+
         54oOY3ZwqxqQAm62Iqrc5roGDzymHVoNdb4uEnlR03PL5hWT5o2LKmDwXeMSZ7Iktake
         nk+bsHDlgXee7p5ZdamLMmXmSMicQ+F3x6M5RHM5ox4zeO1A/40tvy2KWckD3W8lLtSs
         AcUZWgeOabYKYapn6O61LgJ+B1e44uD2s/ozatoyJ+dvnacDO7AvHKLv+0Rcs0mK5HrG
         tCzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMiuPwiiDHUaeQFJku92sGj0OD42uErKvKfJb/uK54NC5axaxF
	40VbSUw/nTmbAAfIJhdkrn85/fwtW6dDpwvLKbT+B22wgB4VUD1kjUK8+YNGEmSYtW4dSb5fTv1
	jyfBELYIWfnQBKr/uAJMGq4q8uq8wjkjcEgJU6K4KzUMHBbjkgdGX/0uoRXrII4k3Nw==
X-Received: by 2002:ae9:e21a:: with SMTP id c26mr22269744qkc.293.1553554602496;
        Mon, 25 Mar 2019 15:56:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrygnrc1zbfAGc0A5jXZ1QVYKvGTxUF4nEWCROXaXDV9HreBwSS7JR7A7rAkxp4RcEhyZj
X-Received: by 2002:ae9:e21a:: with SMTP id c26mr22269692qkc.293.1553554601342;
        Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553554601; cv=none;
        d=google.com; s=arc-20160816;
        b=FWpDZ6dP6XRYoUqakPIDIc4a0nA95bC+PtmDGm+oKB7cOCE2vFU+6cTyzT8Dj+czBs
         QMKF24jyaKZQGTTi6Mu559yvEWnRZTS5X2o1bELtu6WSk0Fy3vFj4k+rtvacVIlWKBZP
         pLUxcCN4UamrGU0F6EJPKWCuVSmFmyveMljXNKECy+D4YA4SU97lbfvU53X6LkDtG8bV
         oGPhruCzrK1+VAvSj/KqFdHUO7rpWpnZDzStsNVu7SN/aXh/UkYUTTHzbf7WfBaxESk0
         OswaFL2hb0LN1W7WQLf3Zkzx+tKyqwJ3yjzJ6+tJuZNMzhKx0d5m6WnmTOeqeiA+LEdK
         QZdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Pg+ngYFMmyJ8lECB6vesVMArcBSQwLgdaATa835z1bQ=;
        b=jvd3dZNOIz4peABaJfhnEK+ZP/thd5zCQ0fkHCe97K951Mh+z6hm3u8ldpGzdOoqa1
         ZbCBP3aNoln9EzOdxyLZ6nPdJKPSvOy79n6uL+Cc+QNJxKC3NlO2j8cm5IVNoPmeuk5O
         uxscOImZtuGp34fTP5XuVe1X7tlYOGU5lykfFR49UjNvhq654NDp94DrNiKbDiIC6RiQ
         pukJRF/1sCmZCrch6WXtR8KTxVimp8o3Qn0Ug8kubIUNZPRucD0CHZxIrkeE7dr+Wvbg
         zDyTKqZ8gRP9dZfNo/ufGycWupDGs49lcNGNGz/X0vGLW7+eEdfwzvKLeHj/RHMkztcW
         7N2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si1547298qvi.23.2019.03.25.15.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6BB91C057F3D;
	Mon, 25 Mar 2019 22:56:40 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D93A51001E67;
	Mon, 25 Mar 2019 22:56:36 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 1/2] userfaultfd: use RCU to free the task struct when fork fails
Date: Mon, 25 Mar 2019 18:56:35 -0400
Message-Id: <20190325225636.11635-2-aarcange@redhat.com>
In-Reply-To: <20190325225636.11635-1-aarcange@redhat.com>
References: <20190325225636.11635-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 25 Mar 2019 22:56:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MEMCG depends on the task structure not to be freed under
rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
mm->owner.

An alternate possible fix would be to defer the delivery of the
userfaultfd contexts to the monitor until after fork() is guaranteed
to succeed. Such a change would require more changes because it would
create a strict ordering dependency where the uffd methods would need
to be called beyond the last potentially failing branch in order to be
safe. This solution as opposed only adds the dependency to common code
to set mm->owner to NULL and to free the task struct that was pointed
by mm->owner with RCU, if fork ends up failing. The userfaultfd
methods can still be called anywhere during the fork runtime and the
monitor will keep discarding orphaned "mm" coming from failed forks in
userland.

This race condition couldn't trigger if CONFIG_MEMCG was set =n at
build time.

Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
Cc: stable@kernel.org
Tested-by: zhong jiang <zhongjiang@huawei.com>
Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..a19790e27afd 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -952,6 +952,15 @@ static void mm_init_aio(struct mm_struct *mm)
 #endif
 }
 
+static __always_inline void mm_clear_owner(struct mm_struct *mm,
+					   struct task_struct *p)
+{
+#ifdef CONFIG_MEMCG
+	if (mm->owner == p)
+		WRITE_ONCE(mm->owner, NULL);
+#endif
+}
+
 static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 {
 #ifdef CONFIG_MEMCG
@@ -1331,6 +1340,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 free_pt:
 	/* don't put binfmt in mmput, we haven't got module yet */
 	mm->binfmt = NULL;
+	mm_init_owner(mm, NULL);
 	mmput(mm);
 
 fail_nomem:
@@ -1662,6 +1672,24 @@ static inline void rcu_copy_process(struct task_struct *p)
 #endif /* #ifdef CONFIG_TASKS_RCU */
 }
 
+#ifdef CONFIG_MEMCG
+static void __delayed_free_task(struct rcu_head *rhp)
+{
+	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
+
+	free_task(tsk);
+}
+#endif /* CONFIG_MEMCG */
+
+static __always_inline void delayed_free_task(struct task_struct *tsk)
+{
+#ifdef CONFIG_MEMCG
+	call_rcu(&tsk->rcu, __delayed_free_task);
+#else /* CONFIG_MEMCG */
+	free_task(tsk);
+#endif /* CONFIG_MEMCG */
+}
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -2123,8 +2151,10 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
-	if (p->mm)
+	if (p->mm) {
+		mm_clear_owner(p->mm, p);
 		mmput(p->mm);
+	}
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
@@ -2155,7 +2185,7 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_free:
 	p->state = TASK_DEAD;
 	put_task_stack(p);
-	free_task(p);
+	delayed_free_task(p);
 fork_out:
 	spin_lock_irq(&current->sighand->siglock);
 	hlist_del_init(&delayed.node);

