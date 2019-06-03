Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B215C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B99127A83
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B99127A83
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E36E6B000E; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 638946B000D; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32D7F6B0266; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3E4D6B000C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so27794316edv.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yR/+zkAXVY/QWPzunwBUOQ1BEAyvoEDYuTLXMqCG/4c=;
        b=Y4QkVlY1mBIW23iRj0Pyh4QLtKkQoQunRI2ArblVa6S/ftqnbuaHGBQJ94AS892+GN
         3aiDmT3AHo/QG/25wsrH9saGeTVKaUPi1ASENdl31LaEYDq0yqIXWXj9RjN6PujhdGWA
         AweGiw+6kKGuYvpGJAMIKb1jy0EAxvlstdaIFn4kzl/Bnt4boDMWwJG1zb3s+P8vJPDW
         zQWC9XXQEWpDdLigcgKciX0bB6sxP2HTKk3JS7ZHo5dqO9iplV36yPAv0r29Cjyj5IhB
         ghZnO7d4tSZ5A+EataQIH7PRuR7coqQ34zQ6n6YmbTCrlX2tjO1vRtfDkgvNOYeWRD42
         tcUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXh9Gsq/bSqR5LHulsP5MwOEgzlPwa2B/a3eJIYZN2eA/bJV0U6
	9uWrGIJqI4hqgaAC/vjoiIYOm7qjxh4TVJYcNgs2NcqRuhjWVISE218+HulY/sFjfmkxAW/92wp
	YWSaU2TFH/KaMSMtPYSsmDj1X3h4+68/XPJKiK4nremqWe5Pv3c0WGrg/ILmKj1IcfQ==
X-Received: by 2002:a17:906:c4f:: with SMTP id t15mr24082459ejf.190.1559572514152;
        Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsx1EMucoIIESnFO54DnRxgCmeQ/EJFhu0YNqd556A2W745ZxccwIS3HGrjghDPsXtB0WX
X-Received: by 2002:a17:906:c4f:: with SMTP id t15mr24082320ejf.190.1559572512669;
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572512; cv=none;
        d=google.com; s=arc-20160816;
        b=stNCMD9YHO38tVGIG3uutKTLmM2Ca9jXqgJqPRxfgRsqJYQ+daXjWArtAsM6reVFxS
         MX1oEetF+/5s3OpgtzINy3wqSad+w7t+kiQ4UllbsjZt0fkTQk+sWyMnBc19e8YxKW2C
         n7krQur/dz8HPjLJ0/1x7lQj4RTLWhbc6G4tRvkiOVnEvOPeFXkA4LtJT6Im62m840vz
         NH0P7Hmrr/cFwnWoJHSWJl8XY2XMTydYP04QVy+EPbfaU9uSvO+0fNj5hoL5Xd8veSKd
         S3+VNBijvThYy3+VO6kQHcDXV+gQ/KJFLZOZS79TPt70JoAbrlov53V/tx3RWjApa28/
         IHPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yR/+zkAXVY/QWPzunwBUOQ1BEAyvoEDYuTLXMqCG/4c=;
        b=PFIuvFyH4YdADYD5IbPbff1yiPI3XFHqWLYCwfGXnX87azkp3caEoN0+z/C1HbrwmJ
         lo0lQ5/ciDwfmzX/mODuquExjysqt239w9bm/Qm/bio9IvdxDQHAwWG4GdAXjQFuHKoH
         cn+3W7fiydHDlJOcKHlhNdHpxxETT7384QXBvlFO5Dc8LnG8EhKllVCnjwH6hGFrYI2n
         OUwtR8RhFeLV27mH8ipn1ziH24sjLrITbLnnq/Fn8D18NYE10qI3ScqSpJa88goFo+cW
         PtTkSB/f2pH1EUWQtVkOk2qnBqwwnMGu4Md/iIB/X/Av8TDGQsjBLyqTPGSeS5gWm9/g
         ws1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si782153ejk.38.2019.06.03.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F19ADADDA;
	Mon,  3 Jun 2019 14:35:11 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/3] mm, debug_pagelloc: use static keys to enable debugging
Date: Mon,  3 Jun 2019 16:34:49 +0200
Message-Id: <20190603143451.27353-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603143451.27353-1-vbabka@suse.cz>
References: <20190603143451.27353-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_DEBUG_PAGEALLOC has been redesigned by 031bc5743f15
("mm/debug-pagealloc: make debug-pagealloc boottime configurable") to allow
being always enabled in a distro kernel, but only perform its expensive
functionality when booted with debug_pagelloc=on. We can further reduce
the overhead when not boot-enabled (including page allocator fast paths) using
static keys. This patch introduces one for debug_pagealloc core functionality,
and another for the optional guard page functionality (enabled by booting with
debug_guardpage_minorder=X).

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h | 15 +++++++++++----
 mm/page_alloc.c    | 23 +++++++++++++++++------
 2 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..c71ed22769f3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2685,11 +2685,18 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
 					int enable) { }
 #endif
 
-extern bool _debug_pagealloc_enabled;
+#ifdef CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT
+DECLARE_STATIC_KEY_TRUE(_debug_pagealloc_enabled);
+#else
+DECLARE_STATIC_KEY_FALSE(_debug_pagealloc_enabled);
+#endif
 
 static inline bool debug_pagealloc_enabled(void)
 {
-	return IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) && _debug_pagealloc_enabled;
+	if (!IS_ENABLED(CONFIG_DEBUG_PAGEALLOC))
+		return false;
+
+	return static_branch_unlikely(&_debug_pagealloc_enabled);
 }
 
 #if defined(CONFIG_DEBUG_PAGEALLOC) || defined(CONFIG_ARCH_HAS_SET_DIRECT_MAP)
@@ -2843,7 +2850,7 @@ extern struct page_ext_operations debug_guardpage_ops;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern unsigned int _debug_guardpage_minorder;
-extern bool _debug_guardpage_enabled;
+DECLARE_STATIC_KEY_FALSE(_debug_guardpage_enabled);
 
 static inline unsigned int debug_guardpage_minorder(void)
 {
@@ -2852,7 +2859,7 @@ static inline unsigned int debug_guardpage_minorder(void)
 
 static inline bool debug_guardpage_enabled(void)
 {
-	return _debug_guardpage_enabled;
+	return static_branch_unlikely(&_debug_guardpage_enabled);
 }
 
 static inline bool page_is_guard(struct page *page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..639f1f9e74c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -646,16 +646,27 @@ void prep_compound_page(struct page *page, unsigned int order)
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 unsigned int _debug_guardpage_minorder;
-bool _debug_pagealloc_enabled __read_mostly
-			= IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
+
+#ifdef CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT
+DEFINE_STATIC_KEY_TRUE(_debug_pagealloc_enabled);
+#else
+DEFINE_STATIC_KEY_FALSE(_debug_pagealloc_enabled);
+#endif
 EXPORT_SYMBOL(_debug_pagealloc_enabled);
-bool _debug_guardpage_enabled __read_mostly;
+
+DEFINE_STATIC_KEY_FALSE(_debug_guardpage_enabled);
 
 static int __init early_debug_pagealloc(char *buf)
 {
-	if (!buf)
+	bool enable = false;
+
+	if (kstrtobool(buf, &enable))
 		return -EINVAL;
-	return kstrtobool(buf, &_debug_pagealloc_enabled);
+
+	if (enable)
+		static_branch_enable(&_debug_pagealloc_enabled);
+
+	return 0;
 }
 early_param("debug_pagealloc", early_debug_pagealloc);
 
@@ -679,7 +690,7 @@ static void init_debug_guardpage(void)
 	if (!debug_guardpage_minorder())
 		return;
 
-	_debug_guardpage_enabled = true;
+	static_branch_enable(&_debug_guardpage_enabled);
 }
 
 struct page_ext_operations debug_guardpage_ops = {
-- 
2.21.0

