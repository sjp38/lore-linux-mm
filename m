Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63D31C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B53216B7
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="MWgO4tm5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B53216B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16A76B0008; Mon,  5 Aug 2019 13:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99EC76B000A; Mon,  5 Aug 2019 13:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88E2D6B000C; Mon,  5 Aug 2019 13:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5767D6B0008
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:05:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x19so53101692pgx.1
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hfTT9Vyh4lJ/Mb9rTCTCYXmmzA+mBf4ub6OXNmSq8us=;
        b=nvmEL9ZdY8Ya8HbR88U/esY1Iqxvq7+Rijs/GMBdqJG1WYQxy1SvOW1emlBukMT9pR
         FkQRoZ58HEor293d2iBDfQS4Fi/NivcvxZXzL4ANv3n/FzbDy47IMK+28Y+p03rR4KLS
         Y+sTqh2YWZqqKCSSdwoI5SiNE6AY5AuD2fOro1T1uQsYnlXdXQY6Jk13HUy9cl1mr+WQ
         gSXu1ZzC7Lzh6XutRrRT6c7fYd+sfUZzNWlbjG/HtEYGu5HFdqGZgQt0SBKi7/Iu4xWy
         tHYQAliVZuscmboBPtsDCIk74SvjgpNt5AQ2DnUQBWTgRfbnEb9KUkG8IqvNpUa2SLi2
         LNng==
X-Gm-Message-State: APjAAAV7Rkn/ayCUJkdaobm1mZ62Kc9auzWW4J8qZDiOeLr1+c/53p5C
	iCReOTC0vaWq3yUxC55Kt5EycGaD68ljn29n+Ch5LjRf8afYhw51snvYg85wln0nq/RhzRVMgH2
	SvXHS3SGX+mMGU/CNuYMi0OOwuT/V4JlKSHx/JyTP77q9yDGC/7PIjxGJ1Pg3zq/ltA==
X-Received: by 2002:a62:187:: with SMTP id 129mr74604184pfb.128.1565024717062;
        Mon, 05 Aug 2019 10:05:17 -0700 (PDT)
X-Received: by 2002:a62:187:: with SMTP id 129mr74604128pfb.128.1565024716427;
        Mon, 05 Aug 2019 10:05:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565024716; cv=none;
        d=google.com; s=arc-20160816;
        b=IhPq+juFoay+j8g4mjdqvRR+sPkRVcD242aFwKi5UHp0CNJTvyMjlbfY47kHIiT4uk
         LTfFOAM/GwwmhHouGyPj/zwe1FxArbUHcinfon/FKaV0DqcFycMh0SBEfp7eo5Kkxi7s
         GelAS6UG3SG3BROrsE42FHAE/N2OtQLng6vKB+nuYZZbhOUDjsmZuuF3cVYa7A0Mr5Hr
         cYLj09+HwnUXWb87HM+PNaMhcnLA9PG/Zymd5BI5JfCYdbxVvezZ3+IJlH87EvPuKUmr
         ucN0s8pJbQb25FY1n9P78upC2TZzNLC7mX8L3VOIt9jvVISKQdNwUHtfu8XIkucszcLC
         erpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hfTT9Vyh4lJ/Mb9rTCTCYXmmzA+mBf4ub6OXNmSq8us=;
        b=DtZ7xuKazoyEyYxyqbJWtKS0nNw1vdS8HoTDmXjX2CCTkZcn+qgO000UD6WkyAAP9v
         LtI3RDcBIzBrQhz02aroq0rDG2sfX4A+DJ4ztZXIuGAJonif4PbbG4PlgyghBOh4sudl
         XEEE++2WE8sblFGuJUBqqNmwossXsZxGTyyqFg+KMo7JtoCy5u26VBs5lpMet8cqPBNK
         7JQPiSx68fSGdot36qgyHLEeBcLWCJ7Y3AvnuAsbd76BqIssDWNpCONbtj1WLLZ+Mrmx
         UYb4kyxpZL31LnXpf2s6DezCM3JorAOlolfH5OKQ8gxrpo/tX5i7YnHQf9YIV6xdheRT
         +v5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=MWgO4tm5;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y21sor64389288pfm.25.2019.08.05.10.05.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:05:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=MWgO4tm5;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=hfTT9Vyh4lJ/Mb9rTCTCYXmmzA+mBf4ub6OXNmSq8us=;
        b=MWgO4tm5GTritoxl53gt5qNjI6dHxFHD3f2tmoGq9OJgzbnGXd/y+DqsRAV4dJJOe8
         mYeyo0j3HZzU6Tao9ECna4T86NUvCDpvt4gexDupdIGfVRUQxbA+88ArezoiE9kyDdqN
         Lu/GqdUdfcjbf1HEszwyMIgGK8XfBF0rg6oXU=
X-Google-Smtp-Source: APXvYqwNN1t4bVbzgmwIXdCDQSshCIBMOslB9kNDo+lLtbCe0bb0+FNBd/Sai0oabP93PogQiVJHkw==
X-Received: by 2002:a62:770e:: with SMTP id s14mr71578047pfc.150.1565024716052;
        Mon, 05 Aug 2019 10:05:16 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p23sm89832934pfn.10.2019.08.05.10.05.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 10:05:15 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	dancol@google.com,
	fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org,
	namhyung@google.com,
	paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Will Deacon <will@kernel.org>
Subject: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle tracking
Date: Mon,  5 Aug 2019 13:04:50 -0400
Message-Id: <20190805170451.26009-4-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190805170451.26009-1-joel@joelfernandes.org>
References: <20190805170451.26009-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

During idle tracking, we see that sometimes faulted anon pages are in
pagevec but are not drained to LRU. Idle tracking considers pages only
on LRU. Drain all CPU's LRU before starting idle tracking.

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 mm/page_idle.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index a5b00d63216c..2972367a599f 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -180,6 +180,8 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
 	unsigned long pfn, end_pfn;
 	int bit, ret;
 
+	lru_add_drain_all();
+
 	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
 	if (ret == -ENXIO)
 		return 0;  /* Reads beyond max_pfn do nothing */
@@ -211,6 +213,8 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
 	unsigned long pfn, end_pfn;
 	int bit, ret;
 
+	lru_add_drain_all();
+
 	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
 	if (ret)
 		return ret;
@@ -428,6 +432,8 @@ ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
 	walk.private = &priv;
 	walk.mm = mm;
 
+	lru_add_drain_all();
+
 	down_read(&mm->mmap_sem);
 
 	/*
-- 
2.22.0.770.g0f2c4a37fd-goog

