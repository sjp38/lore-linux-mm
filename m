Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FD8CC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ACBC218FD
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="cpS86uEm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ACBC218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE56D6B000D; Wed,  7 Aug 2019 13:16:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6EC76B000E; Wed,  7 Aug 2019 13:16:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEA4F6B0010; Wed,  7 Aug 2019 13:16:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95B256B000D
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 13:16:25 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k9so53150326pls.13
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 10:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xT1EUv7l9ELnBbW3Pj9GyH6zMTpmJcDHOSB5E5y40eQ=;
        b=B/1bY5YJ/heHouRlEAIadImmWHI8a4l2cNhwcOD3wHuBljkjsTZ7XeNUFU3SX3iXNU
         tabhfKyJC/negHOgcjBuy+/vYx2kAunzVE6PjzOtJABdZQx5CR5wgCwQHgu0KG6XpCNw
         PjjICEKXgO5ly0SGfMwwiGyeaEQJaacOjJA53F9oJssdVpuWyiDBXpgJFgz2JXTkdcn8
         QmJT9z6wlwlxKAOnJwP9r0rQ7DZA2TQNp8MnxB2kKrjamucOoK3dj3kvPPf/bnNoBB5j
         iG/qij41g1ANz9o1n8X/nD48auIA3kUFlCqkuwPwjrhEcjfYOAthbiU+jVJMHXyHhX62
         Lw8g==
X-Gm-Message-State: APjAAAXwGyKp/nG5ppFgd4jESSfZbbwIDiPmufG9y3wkH99XdHwtCHFY
	dpAEVP+E8p7r/5kBff7TkZpuejq9zdn4KANGt5Tt/NGg1ShpAmxWAFG/0VY6ciyS0qojZykNLXr
	3Kyj/vsMSjtS59bcg/WsBwRgr395/wedFV41OvlghyXx843KDYGuKyBjEpTgKUFiX/Q==
X-Received: by 2002:a65:4189:: with SMTP id a9mr8365003pgq.399.1565198185167;
        Wed, 07 Aug 2019 10:16:25 -0700 (PDT)
X-Received: by 2002:a65:4189:: with SMTP id a9mr8364943pgq.399.1565198184270;
        Wed, 07 Aug 2019 10:16:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565198184; cv=none;
        d=google.com; s=arc-20160816;
        b=Ymx46tka09zxmD+MPpKn8CC3pYl/XwNgoa+9rTR+fPOpRD8/04ZCeY2yHBMVGeVm1A
         uVPj/72l8qb2QvP4toQM7omzhjc/ADm+VZ38WRg7R2b61YSE14W5u6DBKT3A0efH36iM
         niY7w425reWEzR9Z/WsE+Hzw5nMIY4Z5m9u4XSORkA63JGjd2incsZAfWR6Zm/FItIIY
         zxTnoj6Ngo8SwtdOx8Gtn1sHy9aoNnejyVHU62WQgUA1L0IUaSnIQZ3qUs1sqVJ2rpNR
         M+9KkNcfwWM+uLAShunA5YJ6BCsXXWyKH+qko8Ss7mgDSQ1TlumNQK9SCCmdpFXwB5Aq
         IWLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xT1EUv7l9ELnBbW3Pj9GyH6zMTpmJcDHOSB5E5y40eQ=;
        b=zwTpqBvtx7eQWP9eGbeHeIXLdokqOU0d3rd3GQpVGEQUiVoZQjxh5rTZaUwr98vY9Z
         Qx0U48eJIajynzie709VTKYu569igF/kO0MpUN8Oro80u9KX8o4rw4+jePqYoSgAXQtO
         4RDZrqfhzS7R8JR9UNxA3XnvVkVKt9W7XB1G6qgUszBHPEvYAv5vT+yFXLHggqEaEmrH
         y85wG3nU2AvoSz+83ifBR32JWPxFe5zTINrduq+g7P/7nJcoiAV0tm5hwWB/l2MUC3Fr
         vJ0sJxEtX34UWTAiizWbejiIT4Uqytu28EDPk3XsxPRYkBnfeX2ordji/7mwQwZrAIlD
         2U0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=cpS86uEm;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ca12sor819380pjb.6.2019.08.07.10.16.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 10:16:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=cpS86uEm;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xT1EUv7l9ELnBbW3Pj9GyH6zMTpmJcDHOSB5E5y40eQ=;
        b=cpS86uEmYIzhxFzCySaqqOeImVDTWodZUXCQVQcRGqqRAGGDs1sNZw0oH3tmy2iZOE
         XkIu9l2OhfxN0xt6NyH+lVLF+8mXgqz7NSPIIJ+egtHoGZEtUgQY7iySTu1NQl565je/
         qL/IqLU05tBxt6AwDFcVVWZEJCirczwMCOG/I=
X-Google-Smtp-Source: APXvYqwugi3AW6n6dfP+TB/Uc5APuLJqoUYRpEzJ6Mn8Htn03idxWxXllDnzug9Hw6aLl8p384B8Ag==
X-Received: by 2002:a17:90a:1785:: with SMTP id q5mr950338pja.106.1565198183794;
        Wed, 07 Aug 2019 10:16:23 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a1sm62692130pgh.61.2019.08.07.10.16.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 10:16:23 -0700 (PDT)
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
Subject: [PATCH v5 5/6] page_idle: Drain all LRU pagevec before idle tracking
Date: Wed,  7 Aug 2019 13:15:58 -0400
Message-Id: <20190807171559.182301-5-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190807171559.182301-1-joel@joelfernandes.org>
References: <20190807171559.182301-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

During idle page tracking, we see that sometimes faulted anon pages are in
pagevec but are not drained to LRU. Idle page tracking only considers pages
on LRU.

I am able to find multiple issues involving this. One issue looks like
idle tracking is completely broken. It shows up in my testing as if a
page that is marked as idle is always "accessed" -- because it was never
marked as idle (due to not draining of pagevec).

The other issue shows up as a failure during swapping (support for which
this series adds), with the following sequence:
 1. Allocate some pages
 2. Write to them
 3. Mark them as idle                                  <--- fails
 4. Introduce some memory pressure to induce swapping.
 5. Check the swap bit I introduced in this series.    <--- fails to set idle
                                                            bit in swap PTE.

To fix this, this patch drains all CPU's pagevec before starting idle tracking.

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 mm/page_idle.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 2766d4ab348c..26440a497609 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -180,6 +180,13 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
 	unsigned long pfn, end_pfn;
 	int bit, ret;
 
+	/*
+	 * Idle page tracking currently works only on LRU pages, so drain
+	 * them. This can cause slowness, but in the future we could
+	 * remove this operation if we are tracking non-LRU pages too.
+	 */
+	lru_add_drain_all();
+
 	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
 	if (ret == -ENXIO)
 		return 0;  /* Reads beyond max_pfn do nothing */
@@ -211,6 +218,13 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
 	unsigned long pfn, end_pfn;
 	int bit, ret;
 
+	/*
+	 * Idle page tracking currently works only on LRU pages, so drain
+	 * them. This can cause slowness, but in the future we could
+	 * remove this operation if we are tracking non-LRU pages too.
+	 */
+	lru_add_drain_all();
+
 	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
 	if (ret)
 		return ret;
@@ -428,6 +442,13 @@ ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
 	walk.private = &priv;
 	walk.mm = mm;
 
+	/*
+	 * Idle page tracking currently works only on LRU pages, so drain
+	 * them. This can cause slowness, but in the future we could
+	 * remove this operation if we are tracking non-LRU pages too.
+	 */
+	lru_add_drain_all();
+
 	down_read(&mm->mmap_sem);
 
 	/*
-- 
2.22.0.770.g0f2c4a37fd-goog

