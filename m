Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 681BDC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3182B217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3182B217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AB8A8E00E3; Wed,  6 Feb 2019 13:00:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 507618E00D1; Wed,  6 Feb 2019 13:00:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3827B8E00E3; Wed,  6 Feb 2019 13:00:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D042B8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so5420073pls.11
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=etR86pjRrJPXMhNrdnqovLk/Iu8sR1pSlvW/S3et7H4=;
        b=Pcki+WI3XjPRs1eChRlDT4FT/dCp8+K0e2LsOQTw4c9AjF1/dV+jrIOkR2BFNESU0x
         uuW98gN7b3e4APB4CRtwRyilBrwn/6S8oMGaVY+GaM99bTu4+XcMITO6aNyMNnhQaAFk
         tz37SuUon1BzMc2ChKfRDyFMqT5qKG0XVaL2e0Ud8Z1pl0yy1MJbxBwsPdGvRdLQbSur
         w5QiKng1y8zGFpMhE+Z/eLk+H1hmaGb0cJV1GHIO8P+qlFIkSwtYtXuvlgpROLeQmLpy
         8ixD1MARp+3rEoW9ExMjJDpiPz5059TsU5+Jo0oeqqhCZbFWu7CV0iJHY2buFQRJv496
         xuDA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYw78v28yO5bsW2LeGf7HBKV42oO1kZKcJuxNqk0mefMs8PkXO9
	ZepKp1wB/7EpROHy1h2EMYTX1ujH9ef4etg3t7XueO5rSoaEsvVtuQ2C3AIxe+D5srhAxcqHo5y
	OsQumFcqRLAPzZT4sPMcQkQ0fuFRvVd6j060LpCGTuYaASzFDBbpSJGecF7nZit4=
X-Received: by 2002:a63:e655:: with SMTP id p21mr10645346pgj.70.1549476007427;
        Wed, 06 Feb 2019 10:00:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYWY52JeZFEJOt8/w/kgrMvBP6R+E7w1c+X9LwkwXy/2Bj1dGlMcl94OwVy2g8IH9wEWE7l
X-Received: by 2002:a63:e655:: with SMTP id p21mr10645262pgj.70.1549476006247;
        Wed, 06 Feb 2019 10:00:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476006; cv=none;
        d=google.com; s=arc-20160816;
        b=Mpv8jMvkmAOvAg8SxHvxqCuLcokcbrzgyqTmzvsKp55Vkebt9fRChG8A82dCZT7MH+
         5hqbZIeWsSmFeo0CZUhBFln4vFssew7mK7VC9wZHEUp0i0e6HTYsjKfmtElOR3wMqty0
         2L7SXRTC0IYhDyNyp31nkOK9cJyPVXmHYGN/6sJnuEPLreT9JH8b9uCIeImkychapEtz
         jd5wfDCBhTYT9DQH8WHViM31FGHbWP7HxX7meZfgHaFVGZsw8RD5FuZjuVBGrrxwqgNM
         rwW3GeK3UvYbbcwkKiAGn+fTWNWLUa33mOHI7qYh0cjlFPsTdGa75wG5Cycscj8NX4pn
         YLUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=etR86pjRrJPXMhNrdnqovLk/Iu8sR1pSlvW/S3et7H4=;
        b=YNTT90IMHw6EhgzAlhIdVjOfA36Gr4q3WS/d5AzzeoKL3kYpuqqGwnbr5qMoMyKpKX
         rPm6wKc9Au5Sjcqwy4xFzr2hsXpzghmp1U7+ZKMtZ2AgisGsF1cd3oGRl1sgJ5u762sM
         4G99llTyIc+SFO0ZT05aVFiKTopgw6Ct3MJH/ed9qYVzv4oZ/rQvqNdrIK+2sVCUAs6n
         OggnZck5eNubAl4cKaXjOH/F1oenMiXNeL/ZqmRYNyj+5a/eeoBGoIKSAdFFaExL393o
         Y29ZZ7X68OVeDA2JiLJdhkwWrzGaijUZBUV8SSBMulrESrKooEnY5Y9jvof0RM4vixjJ
         40Og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id q25si6117300pgv.541.2019.02.06.10.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:00:06 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 19:00:03 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:50 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca,
	akpm@linux-foundation.org
Cc: dledford@redhat.com,
	jgg@mellanox.com,
	jack@suse.cz,
	willy@infradead.org,
	ira.weiny@intel.com,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.det>
Subject: [PATCH 4/6] drivers/IB,hfi1: do not se mmap_sem
Date: Wed,  6 Feb 2019 09:59:18 -0800
Message-Id: <20190206175920.31082-5-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
References: <20190206175920.31082-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This driver already uses gup_fast() and thus we can just drop
the mmap_sem protection around the pinned_vm counter. Note that
the window between when hfi1_can_pin_pages() is called and the
actual counter is incremented remains the same as mmap_sem was
_only_ used for when ->pinned_vm was touched.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.det>
---
 drivers/infiniband/hw/hfi1/user_pages.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 40a6e434190f..24b592c6522e 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -91,9 +91,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	/* Convert to number of pages */
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
-	down_read(&mm->mmap_sem);
 	pinned = atomic64_read(&mm->pinned_vm);
-	up_read(&mm->mmap_sem);
 
 	/* First, check the absolute limit against all pinned pages. */
 	if (pinned + npages >= ulimit && !can_lock)
@@ -111,9 +109,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 	if (ret < 0)
 		return ret;
 
-	down_write(&mm->mmap_sem);
 	atomic64_add(ret, &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 
 	return ret;
 }
@@ -130,8 +126,6 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
-		down_write(&mm->mmap_sem);
 		atomic64_sub(npages, &mm->pinned_vm);
-		up_write(&mm->mmap_sem);
 	}
 }
-- 
2.16.4

