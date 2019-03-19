Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E349C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E73C2183E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JEDIRq0N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E73C2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98D936B000D; Tue, 19 Mar 2019 19:56:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8794C6B000E; Tue, 19 Mar 2019 19:56:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 716366B0010; Tue, 19 Mar 2019 19:56:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 515246B000D
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:44 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d49so627840qtk.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=CF4+E5UIa39xAKg6YCWVn7zIouVA3+WI4DKW8uAVCQw=;
        b=Dr+J79VURYgcYBh336H9Rs8puoLuVPi/+FjLTK7ILJsCT1A2xICZbY8Gmbcmva3N41
         MrUhLbkHNwmnXSfuhKLUMUCGdQqVRssW0qW5MPnkbHCaJP3CH4wEnGyc+kHC1F4u8WMM
         yGLGUNgryW99WRGLazZ9u63lu0n1FEPPJ4hoUi2hfwsZWJ+r1IakPxNyO9da/EAppg3K
         pxkKoZpZu6sk+PfB6tif5XaZmVB3lrqfdCvrk+ZMpFdZ6l4Lz2HTVU/MuGqStDIx1mX0
         qeEK2Fx93o0rhajcLGiwB9zUyRlgrdlmsgVnrv77E9diNBnh0XzoQ5iV3znLqCOOvlnB
         bOJA==
X-Gm-Message-State: APjAAAXcbyZOHG/ZuO1kZ6BW8Oz60umIcuXlhdTLskqonLjjYoFDz/cq
	Qst+C7AET38HUdHmmMsxmir6mGGmuK5n4Ch/QAIQh5sLj3RCExwylQxMfQccHV6d5QRF5OjQq4p
	2ljoAaDpDWkWvgBqjCld3IzoD7j8gNS0oh93/RfFom2a7CTE6B43/br1yFqJuSCtDFQ==
X-Received: by 2002:ac8:67d6:: with SMTP id r22mr4351425qtp.183.1553039804067;
        Tue, 19 Mar 2019 16:56:44 -0700 (PDT)
X-Received: by 2002:ac8:67d6:: with SMTP id r22mr4351388qtp.183.1553039803287;
        Tue, 19 Mar 2019 16:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039803; cv=none;
        d=google.com; s=arc-20160816;
        b=KsnemkV1IWfHA2Oxb8d0NWK5IXFSEbOHwFxzwRu5IMq/28HaQLjdxCwHu1hUpMIAyU
         q+P10eV9GbTsm62/DjjkHvCurddyNRA3W+UfXZDd7Dh5i5oQ/j965C2KNQXBvY8fjH3T
         BtXZMMt4tESZrVansfGGdDuV5GnObYmI/7Xptnty6mStcOL9XVKUtSGytf/+OUhip4Tl
         3pm9D4sNPt5AqItfD/VHbm/rZJXNnJ1OX8qKAA4WtKVQ0vhpDgLJCkTRg6Z93xOD74iL
         4y/oNG4dnquU6z5BMkN1+nyVNwMoEtb7FY5V7FQLjKadZj4kx5v3ZieB23giSIHQIc5n
         sRzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=CF4+E5UIa39xAKg6YCWVn7zIouVA3+WI4DKW8uAVCQw=;
        b=lXKNZ6WNepgGCgzPNmzgIxJTcDOjRIzomY3DybS94mwDGcMrmIt3/dLRjTFZaNcnDE
         pBv9+/3JPNp714aQbma4Q/38m+DuuASEg5Va1zeNLllr4k76f28yKxfcDQZZn4AR62rF
         iAnusnzK/E+iVn9gwW7F9zcCcFiGUcp98b0koHgERgX78OWQ/mmxJ0N5DKtKiBQ2iMqj
         wq+NHBHjRd1D9KjbuJjB+yJXnHZXHHePv9GOehuhyfrlhEc6tu8R4MGic28GHO2h15sB
         8rhCZhPcRoLC3Da+XKaU/rLMKJwXXJ+lUbq/wGegusvXo81NzThFpyPWs1sTTPXSjnyw
         X0xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JEDIRq0N;
       spf=pass (google.com: domain of 3uogrxaykco0hjgtcqvddvat.rdbaxcjm-bbzkprz.dgv@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uoGRXAYKCO0hjgTcQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f8sor847639qtb.16.2019.03.19.16.56.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uogrxaykco0hjgtcqvddvat.rdbaxcjm-bbzkprz.dgv@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JEDIRq0N;
       spf=pass (google.com: domain of 3uogrxaykco0hjgtcqvddvat.rdbaxcjm-bbzkprz.dgv@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uoGRXAYKCO0hjgTcQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=CF4+E5UIa39xAKg6YCWVn7zIouVA3+WI4DKW8uAVCQw=;
        b=JEDIRq0NpHszfqFfgtVD61U2sHtyH+5HwG104koBNiR1CVnOdbZIQ4T7vm1xgqB50H
         thW4tUOnS/p6aXoascAN+Dz6Gdx60R0hL2NJtBGym4V5OdgxsWlooDMVXhqauD5dvIf0
         9+CLQTjHPP5q5QCRpzsZTUK0lbWDcn9aM5ow9098GJcCbaDlHtZLL8xqoZoW3weRMuVU
         Kgiw2eXJz/3tDBSIvexT6rGnLTcBKSeiNpmE4SWVOOBbgwyWNVKTStkLtZKteam1R6sI
         KT563q/OieuZG9lPrc1cm2wdB93lDHzC3hFQkJ9EXZhD7gqcLNh6exFuVacN12aIAOqa
         yjEQ==
X-Google-Smtp-Source: APXvYqwuz5jKuNXMD5ZfZA8ooeSpOd7bbNe9/PlToDa4czqg8Eac9fU4fj1gxy1+OtwlgZ9K0uuqCz4n/Cc=
X-Received: by 2002:ac8:277d:: with SMTP id h58mr4998590qth.31.1553039802970;
 Tue, 19 Mar 2019 16:56:42 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:18 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-7-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 6/7] refactor header includes to allow kthread.h inclusion
 in psi_types.h
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kthread.h can't be included in psi_types.h because it creates a circular
inclusion with kthread.h eventually including psi_types.h and complaining
on kthread structures not being defined because they are defined further
in the kthread.h. Resolve this by removing psi_types.h inclusion from the
headers included from kthread.h.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 drivers/spi/spi-rockchip.c | 1 +
 include/linux/kthread.h    | 3 ++-
 include/linux/sched.h      | 1 -
 kernel/kthread.c           | 1 +
 4 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/spi/spi-rockchip.c b/drivers/spi/spi-rockchip.c
index 3912526ead66..cdb613d38062 100644
--- a/drivers/spi/spi-rockchip.c
+++ b/drivers/spi/spi-rockchip.c
@@ -15,6 +15,7 @@
 
 #include <linux/clk.h>
 #include <linux/dmaengine.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/of.h>
 #include <linux/pinctrl/consumer.h>
diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 2c89e60bc752..0f9da966934e 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -4,7 +4,6 @@
 /* Simple interface for creating and stopping kernel threads without mess. */
 #include <linux/err.h>
 #include <linux/sched.h>
-#include <linux/cgroup.h>
 
 __printf(4, 5)
 struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
@@ -198,6 +197,8 @@ bool kthread_cancel_delayed_work_sync(struct kthread_delayed_work *work);
 
 void kthread_destroy_worker(struct kthread_worker *worker);
 
+struct cgroup_subsys_state;
+
 #ifdef CONFIG_BLK_CGROUP
 void kthread_associate_blkcg(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *kthread_blkcg(void);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1549584a1538..20b9f03399a7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -26,7 +26,6 @@
 #include <linux/latencytop.h>
 #include <linux/sched/prio.h>
 #include <linux/signal_types.h>
-#include <linux/psi_types.h>
 #include <linux/mm_types_task.h>
 #include <linux/task_io_accounting.h>
 #include <linux/rseq.h>
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 5942eeafb9ac..be4e8795561a 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -11,6 +11,7 @@
 #include <linux/kthread.h>
 #include <linux/completion.h>
 #include <linux/err.h>
+#include <linux/cgroup.h>
 #include <linux/cpuset.h>
 #include <linux/unistd.h>
 #include <linux/file.h>
-- 
2.21.0.225.g810b269d1ac-goog

