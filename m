Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02220C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1E3B2075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:30:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1E3B2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F516B0005; Tue, 26 Mar 2019 09:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 415E06B0006; Tue, 26 Mar 2019 09:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DD1F6B0007; Tue, 26 Mar 2019 09:30:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05A136B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:30:17 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f89so13544536qtb.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:30:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BaXjoPbnVGZvaRr5WlEoqLpuml+embjigfKBi8GHrUI=;
        b=BOREtk8g/7ghCRzGlX7wXx7HimxX8shtCg0vGUmLnunohFhPQWlfpLO4v1GvafWQ9M
         m2+ZI1VOKEGQOASujSEY+fyrara2gt2lAG/+/5AFZCTFAzvbjieuVG+blwBzz7Taq1rP
         9SjjMCb2gt7A8EadZgFGt05AzBZj12SHzmDL3nRqf5HcW5HavS/eSQlLDLtLcto/ymCM
         QNnqjUtu+DTyPzApAdtfanH9ci/kJw6yb+1ocCRWi2+VzarHXX7UAbzbHqFVB6EsU1jN
         4Dv2pNqghIBN+Eaj7F/Ulysqf5MMSBTutPjqxi5LzOldoDF2R06qMTj61NZ9dKZDGn5z
         vFDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUviOyqKlFERqh2HoLdWaKs4wX7K2XJaAL2URrbhtC7J2cFxS2X
	AS41Qe4FNWIZze963pVpFPw8BPs4cR4MRIsI8MqDq6/Brm1u8wnQauxY7vk5TSpJYF/ry+Fjfui
	ejTcBr0/DdO+CC0r6nU6WCUWVEQ5xAkKh8xUbrIbF8SDTJwmIkoRjaAiosGWKZCXYDw==
X-Received: by 2002:a0c:fac9:: with SMTP id p9mr25416446qvo.195.1553607016772;
        Tue, 26 Mar 2019 06:30:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtr1HO8/cdYl3sJVNjw3Rj0aMCEBIRnD4MHJ1rT6TMGw6jBofq5/aywI2tXNuqkVTeSB9m
X-Received: by 2002:a0c:fac9:: with SMTP id p9mr25416356qvo.195.1553607015798;
        Tue, 26 Mar 2019 06:30:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553607015; cv=none;
        d=google.com; s=arc-20160816;
        b=yUSv4GsYU16VmrFF5V4e9Ml1qmdnIdYPx7OdmRxBeT50CykOfBxOZMwu9YaikoNTSJ
         BdrqPBSBAipZxNmzYbJDPVgFT+DphRqrF9B49aEUMQ4clDCayj7YGzy8u3orFTnyjC2r
         KGSUb7csi/f4GVr4OAUfqJEO34oJpKLJIAB70XeUJhZmHeR4F1FMrQbQRJcqqC/ry1LK
         MZZFZ+txUDfFPpkKNyvYismYdtki6lEWO4VTFZfyQzArWR1aZ94J/kGdAePo6aZev0MJ
         6BwkRBF3LI5r0awK8AiJ9atMK4RU4XzgUrrxXpixUiW04R3Lbq+B8D7dYBWN9F1XU1MF
         T89g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BaXjoPbnVGZvaRr5WlEoqLpuml+embjigfKBi8GHrUI=;
        b=CPGO37O1+RUlmU8bMjSi5m90SYAdGcPjgibWSCks9xrISYaGiJAlqPvNyoyC4zJo60
         0B3KAefP75QqqC4V8EjkK0eFXaRXpxbwvylM1b3ApDrC3b03FqK8THbPfM6e+OgVlrOX
         uwQ0tn3UCTBGkoGo30VMzxJiAoOSAlMXYHDin8MVFJuPBB7oixx+zYkf2vqqTjuP+iDp
         6WSTxZAx4AIy+LTnLD2BeYjdHUd/AvsTYa7678+S8VKswtgltYqXCtOrT2/n5KeDwEht
         V+eUNUEpGR7SeDAdF1UxjnmCNhE0MxhEkjl9aOPjGFmFb5Nzsu9GDhA00/7hep54efDr
         thSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e12si1863047qvj.62.2019.03.26.06.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:30:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0CD7383F4C;
	Tue, 26 Mar 2019 13:30:04 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.68])
	by smtp.corp.redhat.com (Postfix) with SMTP id 68DF53843;
	Tue, 26 Mar 2019 13:29:57 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 26 Mar 2019 14:30:02 +0100 (CET)
Date: Tue, 26 Mar 2019 14:29:55 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: Waiman Long <longman@redhat.com>, Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
Message-ID: <20190326132955.GA16837@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
 <20190322111642.GA28876@redhat.com>
 <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 26 Mar 2019 13:30:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, I am sick and can't work, hopefully I'll return tomorrow.

On 03/22, Christopher Lameter wrote:
>
> On Fri, 22 Mar 2019, Waiman Long wrote:
>
> > I am looking forward to it.
>
> There is also alrady rcu being used in these paths. kfree_rcu() would not
> be enough? It is an estalished mechanism that is mature and well
> understood.

But why do we want to increase the number of rcu callbacks in flight?

For the moment, lets discuss the exiting tasks only. The only reason why
flush_sigqueue(&tsk->pending) needs spin_lock_irq() is the race with
release_posix_timer()->sigqueue_free() from another thread which can remove
a SIGQUEUE_PREALLOC'ed sigqueue from list. With the simple patch below
flush_sigqueue() can be called lockless with irqs enabled.

However, this change is not enough, we need to do something similar with
do_sigaction()->flush_sigqueue_mask(), and this is less simple.

So I won't really argue with kfree_rcu() but I am not sure this is the best
option.

Oleg.


--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -85,6 +85,17 @@ static void __unhash_process(struct task_struct *p, bool group_dead)
 	list_del_rcu(&p->thread_node);
 }
 
+// Rename me and move into signal.c
+void remove_prealloced(struct sigpending *queue)
+{
+	struct sigqueue *q, *t;
+
+	list_for_each_entry_safe(q, t, &queue->list, list) {
+		if (q->flags & SIGQUEUE_PREALLOC)
+			list_del_init(&q->list);
+	}
+}
+
 /*
  * This function expects the tasklist_lock write-locked.
  */
@@ -160,16 +171,15 @@ static void __exit_signal(struct task_struct *tsk)
 	 * Do this under ->siglock, we can race with another thread
 	 * doing sigqueue_free() if we have SIGQUEUE_PREALLOC signals.
 	 */
-	flush_sigqueue(&tsk->pending);
+	if (!group_dead)
+		remove_prealloced(&tsk->pending);
 	tsk->sighand = NULL;
 	spin_unlock(&sighand->siglock);
 
 	__cleanup_sighand(sighand);
 	clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
-	if (group_dead) {
-		flush_sigqueue(&sig->shared_pending);
+	if (group_dead)
 		tty_kref_put(tty);
-	}
 }
 
 static void delayed_put_task_struct(struct rcu_head *rhp)
@@ -221,6 +231,11 @@ void release_task(struct task_struct *p)
 	write_unlock_irq(&tasklist_lock);
 	cgroup_release(p);
 	release_thread(p);
+
+	flush_sigqueue(&p->pending);
+	if (thread_group_leader(p))
+		flush_sigqueue(&p->signal->shared_pending);
+
 	call_rcu(&p->rcu, delayed_put_task_struct);
 
 	p = leader;

