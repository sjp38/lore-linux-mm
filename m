Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C104C76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 12:28:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1B9B2084C
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 12:28:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1B9B2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 905E78E000B; Sun, 21 Jul 2019 08:28:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B5778E0005; Sun, 21 Jul 2019 08:28:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CB848E000B; Sun, 21 Jul 2019 08:28:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBAB8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:28:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m25so32677519qtn.18
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 05:28:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=xeqzbQpEZe7708HS+/cbBpCLpTegfOHcZddgt74Ff14=;
        b=b+lGADaLUVEmDxoZihOw1TN8rDrMNnfcez0MRTSL2KtP0m4ZehgUqQ6UmAhwaapMid
         rSanzIppSCXVqjQ+pDNAoHOV6R0VBbcUw8bpM6hdWeZdGPaheeAz3y3DWLxhDyG1Bxdq
         /St69gf7CwOmCmTQI70IO3ou6BmlJgGeTcg4Nlpx+LzIyFwUDKaw9lxH8Q6SHhpkY4ro
         ewjxQujVAC51V6AAegjfO1N+dYega6WG8/zQNSchEd7BRwsSzh04xjjkMXwu6T9UxjZ9
         wRqTPbx5Y8ruempC15k/POdx2FqGlfuC0A0btrBRJb1jKrM9x7LNqVYM+f6ozPd70xEa
         hIRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpGupY4MDcKDXVW7lYakar8kDCI15e0rGdUcTyeiDydr5cu5P5
	4usR42Gq10nKhxSbWD5IgykVpx6M9dn2UnhR7EW1qqVQNGoLLREbknd0gcZ1RVWnM4ofyHZLZ7L
	1dhXRwUv6Z3maIkcIuNRvtsgKEjmtB28iJl784h8Baqtr3NnpFVgM5+isYFxzWikq1Q==
X-Received: by 2002:ac8:7611:: with SMTP id t17mr46445925qtq.112.1563712097151;
        Sun, 21 Jul 2019 05:28:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfpgLKMTJOOUMn9sIm3xMml+o05rJVQgkLYrlW8YnobujIObLb5mqbjzBs28ePQP4i1JqG
X-Received: by 2002:ac8:7611:: with SMTP id t17mr46445888qtq.112.1563712096487;
        Sun, 21 Jul 2019 05:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563712096; cv=none;
        d=google.com; s=arc-20160816;
        b=gvgs6LtDQF804T03ZsMwe4t1DdC0GXeFlGiSJPBzS2KlSK5zDiwZJ/vfgIC38XznoD
         XBMtc1CBW3vFN/V42mpMRQEQbJ+GXowrV+KS+qJC85bu2kelFplzZcv+3i4aMjbcBw9o
         N2WSuil26oZymfeYZCULa8BsQYG7WwB4O8QXY1yNPDvadRrWoyKUORivunAltvs8l0kZ
         c5YB+mSJwbFrdfUE6LU8ETLQJ0wW7eEFMMLQmFd7JZhWg90PgfxCgqaKhx3mmtcCrsEV
         lkZ7MxlLQdrTJFGAUMA9MDNMLuu3vKFQOuS7ElWosOvJyBrtB7MTaASOgAP5vfcFzbpP
         NfnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=xeqzbQpEZe7708HS+/cbBpCLpTegfOHcZddgt74Ff14=;
        b=NSnBFt/ibnB1uFquEGdvvIiCmHQP7+lGxoctEFGYcY3BJXlQOzaoD8GSRi2koRzuik
         idTik7y1lLgMcF5/88veIfq9ZPPByww1lFrbeqDStIos6iO+umQvC+CM01eG3k5GuhTI
         WOYynFFZX/Z7ZnZ7Zbq4ju/16guLzjRtdnJSHT1Nq65Ey+5DYVaJ+MxffDeIfQGYfV27
         cFA+KWRcWZQSjMALBTtQulowg6/g7Nk+HhCkQk7HEIhSc8mDKn5PpXS6+wglYxjTKHYr
         xcJWO9tUjyICDvXnfeyq4DYFQvOkD9e3uW9hDvbRATjdF2dpdRV8lFdoac7DvSv3ckrF
         djeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si25485411qtq.83.2019.07.21.05.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 05:28:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 422DB3082E24;
	Sun, 21 Jul 2019 12:28:15 +0000 (UTC)
Received: from redhat.com (ovpn-120-23.rdu2.redhat.com [10.10.120.23])
	by smtp.corp.redhat.com (Postfix) with SMTP id DD5C75F7C0;
	Sun, 21 Jul 2019 12:28:06 +0000 (UTC)
Date: Sun, 21 Jul 2019 08:28:05 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: paulmck@linux.vnet.ibm.com
Cc: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190721081933-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721044615-mutt-send-email-mst@kernel.org>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Sun, 21 Jul 2019 12:28:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Paul, others,

So it seems that vhost needs to call kfree_rcu from an ioctl. My worry
is what happens if userspace starts cycling through lots of these
ioctls.  Given we actually use rcu as an optimization, we could just
disable the optimization temporarily - but the question would be how to
detect an excessive rate without working too hard :) .

I guess we could define as excessive any rate where callback is
outstanding at the time when new structure is allocated.  I have very
little understanding of rcu internals - so I wanted to check that the
following more or less implements this heuristic before I spend time
actually testing it.

Could others pls take a look and let me know?

Thanks!

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>


diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
index 477b4eb44af5..067909521d72 100644
--- a/kernel/rcu/tiny.c
+++ b/kernel/rcu/tiny.c
@@ -125,6 +125,25 @@ void synchronize_rcu(void)
 }
 EXPORT_SYMBOL_GPL(synchronize_rcu);
 
+/*
+ * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
+ */
+bool call_rcu_outstanding(void)
+{
+	unsigned long flags;
+	struct rcu_data *rdp;
+	bool outstanding;
+
+	local_irq_save(flags);
+	rdp = this_cpu_ptr(&rcu_data);
+	outstanding = rcu_segcblist_empty(&rdp->cblist);
+	outstanding = rcu_ctrlblk.donetail != rcu_ctrlblk.curtail;
+	local_irq_restore(flags);
+
+	return outstanding;
+}
+EXPORT_SYMBOL_GPL(call_rcu_outstanding);
+
 /*
  * Post an RCU callback to be invoked after the end of an RCU grace
  * period.  But since we have but one CPU, that would be after any
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index a14e5fbbea46..d4b9d61e637d 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2482,6 +2482,24 @@ static void rcu_leak_callback(struct rcu_head *rhp)
 {
 }
 
+/*
+ * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
+ */
+bool call_rcu_outstanding(void)
+{
+	unsigned long flags;
+	struct rcu_data *rdp;
+	bool outstanding;
+
+	local_irq_save(flags);
+	rdp = this_cpu_ptr(&rcu_data);
+	outstanding = rcu_segcblist_empty(&rdp->cblist);
+	local_irq_restore(flags);
+
+	return outstanding;
+}
+EXPORT_SYMBOL_GPL(call_rcu_outstanding);
+
 /*
  * Helper function for call_rcu() and friends.  The cpu argument will
  * normally be -1, indicating "currently running CPU".  It may specify

