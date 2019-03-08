Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03954C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A9120857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c1B9mpz6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A9120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5FC8E0009; Fri,  8 Mar 2019 13:43:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 481D18E0002; Fri,  8 Mar 2019 13:43:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 374C58E0009; Fri,  8 Mar 2019 13:43:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06A318E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:41 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id g9so2566245ual.8
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=CEhrqtVYU2GGjH6ppRjAuHHm7jjOcyih+GpEA+oebn8=;
        b=nftQaUqqT5M3Kfojyyz0myS1ftvjAJrJWTrfirjatTIeMYufqRk3cbMFRhMxe18hsZ
         cIq1z+Matn6/KEOZY60SDH0Bi7OhCuNNM26ogQazcCyRSaENepxC+QOUx5wo++Dp51pa
         e1BLv6U+VPYao7ldwVtbpHtTZiX7yeZ9J1esccKgiohwhsypeNWZpJXkPL9RNxWlx7Ta
         T56a2V3SmEzkzn5GJITTeagpWD/bzuVgkoQ7eKHUmNp9yJ6XmcSYnGDKl1zqvoVwKtGz
         1HQL+NZ+LLx6gipLh63NxQqOv99c6YiHQxyMIg5Vnmm+4UiHeXBit3cQtzwk8C3swm7G
         fryg==
X-Gm-Message-State: APjAAAXtEWtA3630iKwa56bH4nz+/kWyzuc9vmjMd0BW6z9YEPAbmftR
	HC38VrzSiPJuB6MPTiggShJop9KWrnTNfnzKMX0Co0N05YjDew+YDYE0z2NxJ856mEmGQV1vRhp
	W/UIGVDVMWe/H1Qu9iMqkQLhRiKu5DUS5NElBjdVU27NBpXPRwvsXSlWh+FpA9XH1YJyybU3CGp
	HF04QIudkKvA/YA7dAIAIwOg/tRtlQYyguHEzmkPjw22f9S08u6Cfbp6sc2K/VfVyE74fGhlZhu
	HnsalSvhAyjz1ooO590SDg7/u4cJ4qQJ9ZR3uyPI0HBKElAt7qzs0rIwRTh9Y9vdvZRdGjP9yge
	2DFQzo5J5AoAumE4ye74DItm7tKTt3pfhp+d0Ch6rEYdeLhw8jGwATP1y5zYHOHUu12pB0dy8rD
	x
X-Received: by 2002:a67:f90e:: with SMTP id t14mr10648733vsq.181.1552070620640;
        Fri, 08 Mar 2019 10:43:40 -0800 (PST)
X-Received: by 2002:a67:f90e:: with SMTP id t14mr10648697vsq.181.1552070619935;
        Fri, 08 Mar 2019 10:43:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070619; cv=none;
        d=google.com; s=arc-20160816;
        b=jNPt/a/ZipKHtMx7hz+PHL1rM7mDEEmJkwCGxDaycXeycjlASX3jFL8Q3SikXIsVCO
         K9U8OslFCcdL/P+WjG29pE5c8y9mdE2Fq8TPaCF7CPn+00lBmoHmFe4oCl+QVMFf3epO
         I7CnFI/JU6VIezlMNJiLJP0Vyj+UpGUA+9pSKN18N5IeCn2iNz9NyDsnf2te+v/sPSJL
         S8tjU5CGdE08YF+s2kKVV8Sv20dKhmq375+yFgXeMlDUo7P7ZVd4rK5/+m2VgskZEeu8
         endQGEMjwF/EoJTFdSoiirW+d2CM1PoaKFHJwZYTcrRUADM1Hz5JPoddnoguOKVUGkkD
         pN6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=CEhrqtVYU2GGjH6ppRjAuHHm7jjOcyih+GpEA+oebn8=;
        b=HySEk6nripgGbeyN0L8A0I1IwVo5i2wlYD2/jUzti5XH1e87g9OAoV1THn8NQPuoSU
         oojZUa4k5M4BfAZmGZpqexX+eluAcbrpFC5NTvid71Y5oLnO2+4rhTS7oR48Q1slp5HN
         jehcS0PGf2vN8bU9zBan6QSrsEfLEhgH3aCEe5/lnCe306rB2RBb7rWOH2XaPtM8fObR
         7NYyMcHNRQrum/ajAqut0DbcU0yxt9Sy6Czgpa2EJqkrzpyRGOf/AyFGgWxc2sA6FjtD
         tuXb7ZGy6GkWNKRx0o9js074DruNueZAWcOr1aZHGcMltV5rh3e6pMiQD2bn48YU7QLE
         pUbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c1B9mpz6;
       spf=pass (google.com: domain of 327ecxaykceauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=327eCXAYKCEAuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b138sor5124071vkf.37.2019.03.08.10.43.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:39 -0800 (PST)
Received-SPF: pass (google.com: domain of 327ecxaykceauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c1B9mpz6;
       spf=pass (google.com: domain of 327ecxaykceauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=327eCXAYKCEAuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=CEhrqtVYU2GGjH6ppRjAuHHm7jjOcyih+GpEA+oebn8=;
        b=c1B9mpz6Jdou6pRY5OyrvSpDJl27rnNzP0KEjEWa2lnSzKi/TY8GKvZho04eqIPWmf
         Mbevkjhd2kB1p4b+u2RldlGvn2Q8iDTxMc777xOikyWl3V3hnX65J+i46DkaENmm3zXP
         ozcooURxLG/exN3rOJjFJdR1Ogw7wIrCqH2mzI50xZsiMCTvriahuZwLjq2O1Cljiul0
         K0ygd6c+lQS5P2P2rKrX8m+cmDot+mdoua/nr3GSl9KtOOGf5I97XVGRs4twCtOTiwdC
         aQoZP+Pvr8fOhYrbuPvxicE4lRRk5dgLyBHNiYroYQyHmB/+K5WjqAJKLwrTKLEZiYWj
         0MMA==
X-Google-Smtp-Source: APXvYqwN0/Nf7GBGjuQW1wdXf6SKvccB1lEA9aOmPCgozi8YOkJIIOWvh+1BhGa6Czel6AwwlTaUyObxUrY=
X-Received: by 2002:a1f:7d06:: with SMTP id y6mr12317055vkc.19.1552070619702;
 Fri, 08 Mar 2019 10:43:39 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:10 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-7-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 6/7] refactor header includes to allow kthread.h inclusion
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
 include/linux/kthread.h | 3 ++-
 include/linux/sched.h   | 1 -
 kernel/kthread.c        | 1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

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
2.21.0.360.g471c308f928-goog

