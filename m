Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE5ADC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65D7B2192B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65D7B2192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E22696B0008; Thu, 21 Mar 2019 17:45:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD3E06B000A; Thu, 21 Mar 2019 17:45:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEC156B000C; Thu, 21 Mar 2019 17:45:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A73166B0008
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:45:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so316807qtz.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:45:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=8zoApZhZWyc/zQDL8lsZCo2bpvcOvtsmY8WXGjwqfxs=;
        b=TKrQUXEpZh7QfjUSaxsmtscQpy7A9HzncR+WceBFuVHAZSK7gO0LRzvVpULdChix6L
         VJoD8SvF7JoyUWSgH+uLVYRiOhhQ1U11jFwUWIPT0OrTHKs5hC4b+5xryCj6H0qACJaa
         1bz3l6tBRNUENF69aHgzvwizujpaGU3XivpClFD76ZASg2Fq2gv3708LxIp/TI12yv4Y
         gtIhK1cDeuQjVHegAiOtEOAS8NnMK6FmM7gcpOPxeMLXSRgeyRw+k+wTiDfzzRIWEY4n
         EfYoaZyC6hEkmv3Hcu7rqW/1p3isRuWMCBMGL+v12kOVPPR4IutFcDvB9STm5YsRG5zs
         OP0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX7EOtArnqZzj+EKkI5O/rozvciFGFFrN6t3th8XtBfr0PZDCwQ
	37mUzkr16pbvOlM0Oz8cXKo0kriuRhItk6JeAxufxeR7PiI1LBi8J+HvRC6RMee+nEQOzmO6tzH
	BnGlH+8glFEt2hpK2wvvGOpTcivV2XzGKlkzuknD/h82e6enfbpYTnVvFDcgjuAxxIg==
X-Received: by 2002:ac8:30a1:: with SMTP id v30mr5044957qta.176.1553204742412;
        Thu, 21 Mar 2019 14:45:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbrIhp6N3aqrv1cuQtei2AqDKdsSOU3XuhDFw0kch2I/Kh8sp7cvF9wD5R0sbu/bWSF8lJ
X-Received: by 2002:ac8:30a1:: with SMTP id v30mr5044914qta.176.1553204741759;
        Thu, 21 Mar 2019 14:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553204741; cv=none;
        d=google.com; s=arc-20160816;
        b=S0S63kfm9NmBN/lacqBoLn8WLrrRjrPqk0chvsahovMMrxMLYttrAyXnJBZNGnbgHS
         lBGDYtUJONPA/H4TO9+u2v5zQS5KjOO1roKFr2Au5Qallg1D4sNWVqahNBQGOH+gvcIF
         nZMSSDACk9wPgzQqkGca87FtU9kR0cKNZLmy6OGO9ILBy3+Ki82vxJVnvQSlEcau1KhW
         NQLd0pIqMgMd6ui/n2Zfox7Fkk8BszHPaU3cGb8ITKGpaAfnuzXkFIDdzZcnNeH1cGiY
         7OC/20XFATWF8+RImwS1UrG3e+OHwEJOuQ0xOVAoDgEAts+gXwENiYMyqnhaFRtwojfR
         NyLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=8zoApZhZWyc/zQDL8lsZCo2bpvcOvtsmY8WXGjwqfxs=;
        b=PYNCjK+xNcnxMVbnt3DnBvy5U1SKBiY/iN3mqNRhWnzDM0d6ROUsNutr9XtMmlxBJg
         NS4/RgVcAfa1BctTmYCRJ9xC+JPv8p/d2x50ALjCPPMuZ9SDJLAKYv4W+2D2t7dIwxXU
         8kjXYfoVg14YE2Oau6Hdq1FJj1xEplIgslQqcdH6nVkT/jtczrCcLR8eO/xKglHSLo0M
         9tu8Yi3m4bcwOL2T04WJXkCk5OLCWMK62HHd1PofvqBbl4fN7Xq8loPqbzl19zwebqtO
         Te98zMSZdcAplev44wcZXiHnHfSqMWMNI1Xr1kRoaXqYM1rUS986J2dURc50e/0lKQvs
         U+xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si3896408qtu.222.2019.03.21.14.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:45:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D480C30821A3;
	Thu, 21 Mar 2019 21:45:40 +0000 (UTC)
Received: from llong.com (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 47A2A5C66D;
	Thu, 21 Mar 2019 21:45:39 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 3/4] signal: Add free_uid_to_q()
Date: Thu, 21 Mar 2019 17:45:11 -0400
Message-Id: <20190321214512.11524-4-longman@redhat.com>
In-Reply-To: <20190321214512.11524-1-longman@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 21 Mar 2019 21:45:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a new free_uid_to_q() function to put the user structure on
freeing queue instead of freeing it directly. That new function is then
called from __sigqueue_free() with a free_q parameter.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/sched/user.h |  3 +++
 kernel/signal.c            |  2 +-
 kernel/user.c              | 17 +++++++++++++----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index c7b5f86b91a1..77f28d5cb940 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -63,6 +63,9 @@ static inline struct user_struct *get_uid(struct user_struct *u)
 	refcount_inc(&u->__count);
 	return u;
 }
+
+struct kmem_free_q_head;
 extern void free_uid(struct user_struct *);
+extern void free_uid_to_q(struct user_struct *u, struct kmem_free_q_head *q);
 
 #endif /* _LINUX_SCHED_USER_H */
diff --git a/kernel/signal.c b/kernel/signal.c
index 04fb202c16bd..2ecb23b540eb 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -440,7 +440,7 @@ static void __sigqueue_free(struct sigqueue *q, struct kmem_free_q_head *free_q)
 	if (q->flags & SIGQUEUE_PREALLOC)
 		return;
 	atomic_dec(&q->user->sigpending);
-	free_uid(q->user);
+	free_uid_to_q(q->user, free_q);
 	if (free_q)
 		kmem_free_q_add(free_q, sigqueue_cachep, q);
 	else
diff --git a/kernel/user.c b/kernel/user.c
index 0df9b1640b2a..d92629bae546 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -135,14 +135,18 @@ static struct user_struct *uid_hash_find(kuid_t uid, struct hlist_head *hashent)
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags,
+		      struct kmem_free_q_head *free_q)
 	__releases(&uidhash_lock)
 {
 	uid_hash_remove(up);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
-	kmem_cache_free(uid_cachep, up);
+	if (free_q)
+		kmem_free_q_add(free_q, uid_cachep, up);
+	else
+		kmem_cache_free(uid_cachep, up);
 }
 
 /*
@@ -162,7 +166,7 @@ struct user_struct *find_user(kuid_t uid)
 	return ret;
 }
 
-void free_uid(struct user_struct *up)
+void free_uid_to_q(struct user_struct *up, struct kmem_free_q_head *free_q)
 {
 	unsigned long flags;
 
@@ -170,7 +174,12 @@ void free_uid(struct user_struct *up)
 		return;
 
 	if (refcount_dec_and_lock_irqsave(&up->__count, &uidhash_lock, &flags))
-		free_user(up, flags);
+		free_user(up, flags, free_q);
+}
+
+void free_uid(struct user_struct *up)
+{
+	free_uid_to_q(up, NULL);
 }
 
 struct user_struct *alloc_uid(kuid_t uid)
-- 
2.18.1

