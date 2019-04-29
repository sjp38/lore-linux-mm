Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9ADBC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 03:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 803A1206BF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 03:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 803A1206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E501A6B0003; Sun, 28 Apr 2019 23:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFD6A6B0006; Sun, 28 Apr 2019 23:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEE566B0007; Sun, 28 Apr 2019 23:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB6F66B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 23:57:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so9224162qtb.0
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 20:57:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qw7LGc3PzWxRIfLm+S1LdNT7srQ75jXenKC/2hMbiHQ=;
        b=nE2t8wAzV+RrGi+lHM0qDbZ4Rn1QhaQzwtSdrQ8fjq5zvmeKk5fQdV0wkpIpvZCC9q
         1YlVOjevMnhH9+W/MzA8sI/nzoSajbos5prDAWWRrwhur/dxwGTyyMmTnC6m1K9lPSmw
         vmk5a5tXYFpjApU5vDreOKNKxTqh8YrksQz1C0PmN1fPa//OnJ88r0KbrD2McPVSsfug
         hKruArohGgtG9HruhpecvZYJaJJY9DMYpxxwKLtLyu+IQtIalh72uD4zhl0ltPzjunmN
         iL6crgng/8wQlZLSsvocOpDVKKdaB3W/iXInKxttFqtYkYWTNG+/gy+IE1Zn1W+s49JS
         8HkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVlkZMWZck+VR3aaD9gRCu49KWGJzHfUrS5y7K6hZKV/CHo6V5l
	nfmrINnCVfO22W5Wcy6GiLuok5S8bsUrZCmqebtCUMfgFIID6hVPUNk5MIxhP2d58uZ1ZKRQw/3
	DRyRpfRLaPsVu5ZD0aUFXWFla0CK76hOBOFbB/uXOOYRyjrBoyOQvbKiO1AOcgcBsTg==
X-Received: by 2002:a0c:9a43:: with SMTP id q3mr28869675qvd.68.1556510277359;
        Sun, 28 Apr 2019 20:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnMmEg3JdKST3o0tr6q4oSbXVUXYkuYI2OeRC0L365z9n6pR00VCyUw7b0lmAlgZXLDd03
X-Received: by 2002:a0c:9a43:: with SMTP id q3mr28869648qvd.68.1556510276548;
        Sun, 28 Apr 2019 20:57:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556510276; cv=none;
        d=google.com; s=arc-20160816;
        b=rIXDtA9Uy7R8mvGzRrgNGxnlnlzyLCBSUtHebXmJqQ13LBQa9/vLc/aAQHiq5SfS0R
         s5SwAgpIvxM/oOP3PRFBIzrKdKNNBI6EI6cE2pe6EVLwpN3//81YaF46GaugrDcOmpm8
         BTEAj25REB6Q9j+zfcFWNko7uYl2rdXAConoCYubC8ZnF23oXI0d+To26XNdj3dFIDf/
         SbIE6WKSOk1Rx5CebDuzDJlHobUEtyyApAGgJt61SKkS5t7z9vGCwsSZ4FDwvF+H6tVV
         fkPKi6eGQxUk2zA/mLlf2mqtuBZcaYLyKvlEYVw4IpBDL5zhkefBeRxNVTG3PvCbTybE
         vM/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qw7LGc3PzWxRIfLm+S1LdNT7srQ75jXenKC/2hMbiHQ=;
        b=Rg6JbIZBfEfwab9C2hsdS+ScOVA3xuJBL2ShBZaDh6HISxz0oOaD+6SD+bQBf1SsKv
         doaXuIo+tRHgcNRLRx14qE6XdxunhIWNABIiMPZu5L0LIKHHwBw0g1nLIrDhvOALs8pv
         zBpIvfVU/i/kgeT58PxNvApzEKX427Hh6V2+QHAzlqX7Z93Wxn5qjfMRXjfGFx3FP+hR
         DU8ImMplic4+/u2KIBwdsHru1KiAPFTnT4JII7Iz//7jGWCUnAFVXK5gQo1vTX5mWjGG
         3SKpznd3u5gcn9NqpOqROBXs5KRY2cBbe9oDagk1RH73FfhTlaQb0/DlGVEdnoczw7ev
         HGvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y66si78621qke.252.2019.04.28.20.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 20:57:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 745D83082162;
	Mon, 29 Apr 2019 03:57:55 +0000 (UTC)
Received: from ultra.random (ovpn-120-18.rdu2.redhat.com [10.10.120.18])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D292645D6;
	Mon, 29 Apr 2019 03:57:52 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 1/1 v2] userfaultfd: use RCU to free the task struct when fork fails
Date: Sun, 28 Apr 2019 23:57:51 -0400
Message-Id: <20190429035752.4508-1-aarcange@redhat.com>
In-Reply-To: <20190327084912.GC11927@dhcp22.suse.cz>
References: <20190327084912.GC11927@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 29 Apr 2019 03:57:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The task structure is freed while get_mem_cgroup_from_mm() holds
rcu_read_lock() and dereferences mm->owner.

get_mem_cgroup_from_mm()                failing fork()
----                                    ---
task = mm->owner
                                        mm->owner = NULL;
                                        free(task)
if (task) *task; /* use after free */

The fix consists in freeing the task with RCU also in the fork failure
case, exactly like it always happens for the regular exit(2)
path. That is enough to make the rcu_read_lock hold in
get_mem_cgroup_from_mm() (left side above) effective to avoid a use
after free when dereferencing the task structure.

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

v2: improved commit header and reduced #ifdef material suggested by
Michal Hocko.

Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
Cc: stable@kernel.org
Tested-by: zhong jiang <zhongjiang@huawei.com>
Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..2628f3773ca8 100644
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
@@ -1662,6 +1672,21 @@ static inline void rcu_copy_process(struct task_struct *p)
 #endif /* #ifdef CONFIG_TASKS_RCU */
 }
 
+static void __delayed_free_task(struct rcu_head *rhp)
+{
+	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
+
+	free_task(tsk);
+}
+
+static __always_inline void delayed_free_task(struct task_struct *tsk)
+{
+	if (IS_ENABLED(CONFIG_MEMCG))
+		call_rcu(&tsk->rcu, __delayed_free_task);
+	else
+		free_task(tsk);
+}
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -2123,8 +2148,10 @@ static __latent_entropy struct task_struct *copy_process(
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
@@ -2155,7 +2182,7 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_free:
 	p->state = TASK_DEAD;
 	put_task_stack(p);
-	free_task(p);
+	delayed_free_task(p);
 fork_out:
 	spin_lock_irq(&current->sighand->siglock);
 	hlist_del_init(&delayed.node);

