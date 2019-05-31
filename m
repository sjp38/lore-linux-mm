Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B27C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:43:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AE87264AE
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:43:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YldrKVod"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AE87264AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21C566B0278; Fri, 31 May 2019 02:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6066B027A; Fri, 31 May 2019 02:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01FF56B027C; Fri, 31 May 2019 02:43:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF1EA6B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:43:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f8so4057366pgp.9
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:43:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7TXnJy3Wfu+ssJbkFIL06uViagM5VHDrErGSsKQYVSM=;
        b=SIfeE3U/HsCKJ/9niiTHuHsoXgHqMMQYJercqAsPcUZXPg56DpQ8sowN95fWuv9gyb
         xGU3NMeHy6TOG3NKutPXk1D2LlIc7cJHI8VM31ymHppUuL/tdf80O9oHegV2JJAeqyXF
         +fNq7bhD8jTgB0dQfIOY+80nN5d2Xa3utv/wIGJtrmxsojYrWiz9QHLgl7E3ffZSHndS
         CWZX7svvajnmzuQWLy1ZuAKMlcr38OPmEUEUTOn7o5UF39g83xUT4dCPY/PSPO2c9r+J
         LKIxQOBV//C4Za4Y/EFj9dR5/5ICoxr6GtUE/BVvhH5S5jBithKLgoICMzI/EIs+Cc9W
         k1HA==
X-Gm-Message-State: APjAAAXGwrHse55FsPMWDhIXU4sweJJmCyzWvF9HY7kKTcM/ZIN21cBt
	qhS0zufUCoWaT2ip6O4Sy9jM/FEhJ1Md+fYa67a7KwuPGPWuKQ2ZbMfs9ZbIbugffPp6NE+XPO9
	BsdUvjAhoh0GT4VXN9dxpx0d6TKGcMSqAgyOe/r+O0UIDxqq2bQvanI2cRZupkow=
X-Received: by 2002:a17:90a:db0a:: with SMTP id g10mr7238688pjv.43.1559285016371;
        Thu, 30 May 2019 23:43:36 -0700 (PDT)
X-Received: by 2002:a17:90a:db0a:: with SMTP id g10mr7238641pjv.43.1559285015670;
        Thu, 30 May 2019 23:43:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559285015; cv=none;
        d=google.com; s=arc-20160816;
        b=JmrwcUXz8L5biD7mqprDvxmTc1Jh/cLja0IoCcLeen8XPU3s6+naZpO4yRdzx5gs9t
         BAfaP5CFlIlzXqiSHWyaZheo+mZxNkp6uA3MJlBiG+cHVnqjaRPY9SM9kJIgxJJhkxuJ
         Z6uOIJ1G+IJJ+OFrrCrsnquyy+/9NStLbRUtICr9POmVoDNhDN0MhibwaAgzgxvKKH+6
         aIZYCGCeaFMoFdfpJIRizJ0l2Cz7wgjjFe8YM5s4EqQhohpaBQC5rdN2j9JBqj3caZec
         hcudTaWG1Nf8bi2amKwMP7a4iCS8PjHvC7VvzF+y9WNQoVte9HrkCWY9RWpKvjS+H/wf
         XU4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=7TXnJy3Wfu+ssJbkFIL06uViagM5VHDrErGSsKQYVSM=;
        b=tfqTPcELD7XCHJiF1cgroAHc4jqoBUNwnxKY0dX9EYIB19mvsbXJwuP0b+pitCysWC
         m+KMmyHic+aE/VoqOS1+9xZKVtHf3iD4be2AvlFozpg+JDrknYaU6VD/56tdFdYD+rvR
         sIRwQIKSCnG2CWYZnXViyWnqBlzwEevryTawHc2B2qh9SCPmDbb4QT9v5KsKkdxIT7PQ
         PRc9/B1BIOt/z2YzLFeCvKFKJZXPb2Cq4CrZlmtk7XVsaqU8rFzEo1lXcblB9h+9JNH5
         RElNVFMHMO4+rDYjEHAaaN7YeEd9olybN7ZctEnJR2LOWi0cpckYZnMA685NGvFT9em6
         saNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YldrKVod;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor5567571pjv.16.2019.05.30.23.43.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 23:43:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YldrKVod;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7TXnJy3Wfu+ssJbkFIL06uViagM5VHDrErGSsKQYVSM=;
        b=YldrKVod3fVxNE60xQH2FBlSIRGcgnrEfJznpoRGFPlLTUui7kco8qaCVZtwA3bhxO
         hYV6qOtRKs9DEjdJuliqY1VcGmVNtDxRdK3B4xfQGI0oJHOdJIJHCnJRJKytoVYAyyqI
         pHPY1gaRCvxI7NnRrA1M3nQrDQqq/tdtwfsHpAg13+jhdHUbav7ntbJqZmk0XdHVZ657
         IAZ///cK1ZIILA1FYIIgdbVxUjBMd2zdujzy670NcJaHVlV2wlDGSYqZobqs/HEZZQTP
         iTASK90nsU/RVTkuQLt60xo5Xe29JCIA4qY6Oh/8/+p8Sh/PeL/kKnmcVQk25QOJ7eY8
         D7nQ==
X-Google-Smtp-Source: APXvYqzM1347jezqrPNnjPMerTz/Z/t9a00AGumOLAAOkc1KTRjEfpypi+voz0AAAFuUr2Q0lFTnCA==
X-Received: by 2002:a17:90a:af8e:: with SMTP id w14mr7384065pjq.89.1559285015283;
        Thu, 30 May 2019 23:43:35 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f30sm4243340pjg.13.2019.05.30.23.43.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:43:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	Minchan Kim <minchan@kernel.org>
Subject: [RFCv2 2/6] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Fri, 31 May 2019 15:43:09 +0900
Message-Id: <20190531064313.193437-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
In-Reply-To: <20190531064313.193437-1-minchan@kernel.org>
References: <20190531064313.193437-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with ignore_references to make it more clear.

This is a preparatory work for next patch.

* RFCv1
 * use ignore_referecnes as parameter name - hannes

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84dcb651d05c..0973a46a0472 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1116,7 +1116,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1247,7 +1247,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.rc1.257.g3120a18244-goog

