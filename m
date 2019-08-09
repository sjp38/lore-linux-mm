Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8527C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:18:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DE4820B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:18:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t4ojcX4z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DE4820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A01E6B0003; Fri,  9 Aug 2019 14:18:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0520A6B0007; Fri,  9 Aug 2019 14:18:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E81596B000C; Fri,  9 Aug 2019 14:18:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C34B06B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:18:38 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e22so23888523qtp.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:18:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=1tTOS0Kr72a3ig2rpitn9bCmZeR/zOLT1qe1/3whgEM=;
        b=dZeO4jiHLKibj7XxaKl+3iaLyztq+xwss/HuE12EZVuWvt8eElY2MpqZcuospzQsim
         t7woIE/hkxJnBQbgLDOLodr+jIfm9AMrMaF9XHX9mIv4duhsDSTU7Fpim8phzsrKPW8R
         KbDYdGHkoyZvQk1WM/+Jc+g220N6+Ozx5RCZQdsJ3Xjxu/PKdAzHli7SP1RPn3m4XlH2
         bLB04KJfj5fp0Bd6btFJ8epU21tqnW2OJMuOANfQ/6Alsa+e2JRO9I2cDgaKQL1r79bm
         h5UREGs6EOa6c84qQAfuKSGpkGiNZWLZnOPGyYXx0K4thY2Ck2F9CSMZuZP+OpqUQgso
         +s9A==
X-Gm-Message-State: APjAAAXNDToXwqYFlxwZpr+JmDoGNzzF1Qvo8COHl/MllNapawKRYtyj
	Vmwb8Z+UkKc9mvxtCSUQjZGIFJQSYpOA/7dUHsEaw4nunTVmy0+M3l8HW86CHAXD/FstXl/y8eU
	cddaejxNeqzHnFlBx+LsaAX7Z4eLWCVWsWL9bR9pvbWf76UeCnaQF7+h5X9k0r+3ukA==
X-Received: by 2002:a37:4cd2:: with SMTP id z201mr17630909qka.284.1565374718560;
        Fri, 09 Aug 2019 11:18:38 -0700 (PDT)
X-Received: by 2002:a37:4cd2:: with SMTP id z201mr17630869qka.284.1565374717949;
        Fri, 09 Aug 2019 11:18:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565374717; cv=none;
        d=google.com; s=arc-20160816;
        b=TBSPJ91Ay7g0sjK64JvGh9uqCWtWY9GbNCiAdfvfcPg+GvgVBK9Qk41QFJKwqk+gIF
         dBl+W5TK8Fp0poqhlnGFE4folRucPusUSCO4rA/DAE++K8AIOk3fvAh87nRgQ0+zlm1A
         B5836vpYHW42xfR35441HdA0/AgGNX+fz+gn5wN9DkYOoXaJQYsD9qaGjQT4eSrXmTCA
         MxYT1L3dLsHoxfjdtKMi3/VQxbbiQXumEtnZzjzFrtv/W9C8snOoVv7vY6aY1k6rIf54
         GEwneiI07osIZ0+Om+YkJKP9pG4X6bHb8aGR45/ljUKJD0TBXlC3sPKBQxLlB0vR2y4o
         pjUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=1tTOS0Kr72a3ig2rpitn9bCmZeR/zOLT1qe1/3whgEM=;
        b=0PS6SGmt5tYx2+DqyQZjlJZa7xh4p8p/ZOugGS6TAs6MkSIePAZ3QNlgXyQNdrdWTg
         PSZiLSQA5IjdkW8BvhImTekkibUra/lONRe3K1pYJUAE5A6Rk4a7tWkI4rUkOdMehsOE
         S4G+1eZxB49VtYymNjY53Z/AYm4HDfm0rWWjzk312HDtMBahbxxWbrrHJ2YGO8QXiuW7
         5VjqXmYSMeOh3UIZXb/IC+6ePWvIcAepOuRdT0uOwSsZZyjPP4dWbFMVFHEctw50i9GU
         8nezgS5rkvwdQBYawG9Eh3tmQ2Yv2LOAeW3Hr1p5pWHzU5nfwY2na51mPhBc9dg8W/hT
         XZoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t4ojcX4z;
       spf=pass (google.com: domain of 3_bhnxqokcjy74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_bhNXQoKCJY74DHO1KHDI6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c135sor5146710qkg.35.2019.08.09.11.18.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 11:18:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3_bhnxqokcjy74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t4ojcX4z;
       spf=pass (google.com: domain of 3_bhnxqokcjy74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_bhNXQoKCJY74DHO1KHDI6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=1tTOS0Kr72a3ig2rpitn9bCmZeR/zOLT1qe1/3whgEM=;
        b=t4ojcX4zM3ReDMDWCqGhCTvaqHBK+DuPIlzAdeiU72qvxO9xy9fn1Q6XpZm7bG1TY9
         DcTgReEoKCXV6hx6uhDkgrOBydyAG7m95uH2GgH+MpjoY5dBW1XlJuSLaiClxd80i9wQ
         uGWlwouFz2kNGMsP82G5m5c3QdsA3UTgtCzOWJZbC62mlfPkPyeTb/PGohfZneqJjjII
         e4TziFLEBwXH8c7dph/NR4Cf/P3BHtpNUUqq70fVcaV4P871k09OTx/GBiyEROIIHgAO
         qjIIeON5PngXGZ9T/XsUQBgx8jcAvK93OCFYAvJHYk8d6nDQ7VHqphneeXOaVwdVn+9U
         YyWA==
X-Google-Smtp-Source: APXvYqw2K/VdYvQblbTHJHxoM6dqlB8YfnUUHpG4eYjJSnSc4X/YL0P/7AjXqV062axKFffWbIEPqpGDJf00/gB/
X-Received: by 2002:a37:5e04:: with SMTP id s4mr15541529qkb.268.1565374717530;
 Fri, 09 Aug 2019 11:18:37 -0700 (PDT)
Date: Fri,  9 Aug 2019 11:17:50 -0700
Message-Id: <20190809181751.219326-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH 1/2 v2] mm/zsmalloc.c: Migration can leave pages in ZS_EMPTY indefinitely
From: Henry Burns <henryburns@google.com>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, HenryBurns <henrywolfeburns@gmail.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000272, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In zs_page_migrate() we call putback_zspage() after we have finished
migrating all pages in this zspage. However, the return value is ignored.
If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
freeing the last object in the zspage, putback_zspage() will leave the page
in ZS_EMPTY for potentially an unbounded amount of time.

To fix this, we need to do the same thing as zs_page_putback() does:
schedule free_work to occur.  To avoid duplicated code, move the
sequence to a new putback_zspage_deferred() function which both
zs_page_migrate() and zs_page_putback() call.

Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
Signed-off-by: Henry Burns <henryburns@google.com>
---
 Changelog since v1:
 - Moved the comment from putback_zspage_deferred() to
   zs_page_putback().

 mm/zsmalloc.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 57fbb7ced69f..5105b9b66653 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1862,6 +1862,18 @@ static void dec_zspage_isolation(struct zspage *zspage)
 	zspage->isolated--;
 }
 
+static void putback_zspage_deferred(struct zs_pool *pool,
+				    struct size_class *class,
+				    struct zspage *zspage)
+{
+	enum fullness_group fg;
+
+	fg = putback_zspage(class, zspage);
+	if (fg == ZS_EMPTY)
+		schedule_work(&pool->free_work);
+
+}
+
 static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 				struct page *newpage, struct page *oldpage)
 {
@@ -2031,7 +2043,7 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
 	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+		putback_zspage_deferred(pool, class, zspage);
 
 	reset_page(page);
 	put_page(page);
@@ -2077,14 +2089,13 @@ static void zs_page_putback(struct page *page)
 	spin_lock(&class->lock);
 	dec_zspage_isolation(zspage);
 	if (!is_zspage_isolated(zspage)) {
-		fg = putback_zspage(class, zspage);
 		/*
 		 * Due to page_lock, we cannot free zspage immediately
 		 * so let's defer.
 		 */
-		if (fg == ZS_EMPTY)
-			schedule_work(&pool->free_work);
+		putback_zspage_deferred(pool, class, zspage);
 	}
+
 	spin_unlock(&class->lock);
 }
 
-- 
2.23.0.rc1.153.gdeed80330f-goog

