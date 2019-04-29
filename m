Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56BF9C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:31:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCDFC2084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:31:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCDFC2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tkos.co.il
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 902586B0003; Mon, 29 Apr 2019 07:31:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B1C16B0006; Mon, 29 Apr 2019 07:31:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A29C6B0007; Mon, 29 Apr 2019 07:31:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 42F1F6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:31:36 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u14so12722916wrr.9
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:31:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=RSptvUkocPY29QT/I5ySseo8M6bLwBi6EYgO4uEv6BE=;
        b=mDE2czzFfVV//gQLkbohDSDuhEX4ARMp06N69Q4Z+tyYqTiE8McyTVnuzfZzOb6oVQ
         MnT9n+L//E8JDO/HvKJgbtNlWRPneg8f8EyXI5t3a0Ov8xC+IXyUmzs78rrpesoAYIhF
         Ooq6vQexKQHlx+ZBm8SqIZakKS3po91WIwyuA2mSbIZ2EJg6167GNxqsG9tECQHRhXkE
         QnVq7RmI2c5GTSm4b3Aa5iZE4A5vLrcPyxQU+5vBv8pyk2wFLqzF6MgeyL7G3GM/dt1j
         zSW3hAfaeoN1toDbkTOqgXeUcKKuUc+wUrhc8W4k46UMgilx7orSFOkgtnbbDt14mthV
         B8Yg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 192.115.133.116 is neither permitted nor denied by best guess record for domain of baruch@tkos.co.il) smtp.mailfrom=baruch@tkos.co.il
X-Gm-Message-State: APjAAAXk+3fjopObgc7F2sNhBxZxiQWvpjjtyTzngi/wQAsZ/tvWUVWk
	X0rGlRk3uX4o1xWkstLtcmKCWeLSd4CNIjVCTxLN0ifm/l3rqRv6qgW88eIBD2xNKB8ZNOolw9v
	ImBSIw7O95Ga7prtwLn+iYF1vYdCJ6MYjmCT7aw/ZQUZ97xPEeCIb3texcxGV8vY=
X-Received: by 2002:a7b:c086:: with SMTP id r6mr16186548wmh.123.1556537495810;
        Mon, 29 Apr 2019 04:31:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeRRffjfv47QoMxzCjcfBAKV2XuueOWQLsX4KpHq7T0FUL/XR0XHVoF0BgP/SSC5l4PZsG
X-Received: by 2002:a7b:c086:: with SMTP id r6mr16186498wmh.123.1556537495048;
        Mon, 29 Apr 2019 04:31:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556537495; cv=none;
        d=google.com; s=arc-20160816;
        b=QyVISSfuk09VwIhI4qEPhg3FRgtJ7fCokPfRvgdI2Bvz23FWuNRTw72pNv83HX/qYU
         o4t0+X4mNAPfLVZMV2Yqj4HnHAk8RlaCu/eGiDuYNUqIlRvPdF4iwMjA0KKqPiY1wA1P
         HkOYuDeQGhKcrtQtxYUHIire+wywH7WPwteNQRaR8sskvMUl31aVnqXVCMhAqvDL8IHo
         nkn+wDrOzQ6SRMbc0fc+onqQ9tYs45tksXOkW3gjt9/O92hzZhcFNc5B8cuAkcvMqZYy
         PSPhuFPqpVjMK8vjQC0+14ygJx5le8SniSn4rEevk6jDk7+MqApMFyFigNljzH1H7mUE
         Jg7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=RSptvUkocPY29QT/I5ySseo8M6bLwBi6EYgO4uEv6BE=;
        b=lJvnUbJX7XmOvSclgbqUhSiv86B6jx4by37NI7aDoa2EpQl2+CMZDNPQ1jMLUGfhL8
         imiUDlHoENVAhLJmy+IVf2trOcz+0HSg+I9FbRJQHhWQ+Bnz+TamDT53lst/E4sVjpLt
         cZM97lGQ7PtNsmfHa6BtagoqX0aItxa58nyt98B8ViIoyWN6gMUeZ8LO5q2zusg93Sr1
         N99281Ufq1e8ZRj8+s/cpDpaqoVUbcwQFCE4pNR7w0n35Fo3aLUfzyU1IJ77OAXmIiRV
         aG/uoW/2Bwxcr+5Pa4Da91aF9c2t3jw4VodV2SifayEGOzvXq+69GvL+NVJZIeE7Xcdl
         lNBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 192.115.133.116 is neither permitted nor denied by best guess record for domain of baruch@tkos.co.il) smtp.mailfrom=baruch@tkos.co.il
Received: from mx.tkos.co.il (guitar.tcltek.co.il. [192.115.133.116])
        by mx.google.com with ESMTPS id w12si4157019wrl.130.2019.04.29.04.31.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:31:35 -0700 (PDT)
Received-SPF: neutral (google.com: 192.115.133.116 is neither permitted nor denied by best guess record for domain of baruch@tkos.co.il) client-ip=192.115.133.116;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 192.115.133.116 is neither permitted nor denied by best guess record for domain of baruch@tkos.co.il) smtp.mailfrom=baruch@tkos.co.il
Received: from sapphire.lan (unknown [192.168.100.188])
	by mx.tkos.co.il (Postfix) with ESMTP id 3D067440061;
	Mon, 29 Apr 2019 14:31:33 +0300 (IDT)
From: Baruch Siach <baruch@tkos.co.il>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Baruch Siach <baruch@tkos.co.il>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm: update references to page _refcount
Date: Mon, 29 Apr 2019 14:31:15 +0300
Message-Id: <cedf87b02eb8a6b3eac57e8e91da53fb15c3c44c.1556537475.git.baruch@tkos.co.il>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 0139aa7b7fa ("mm: rename _count, field of the struct page, to
_refcount") left out a couple of references to the old field name. Fix
that.

Fixes: 0139aa7b7fa ("mm: rename _count, field of the struct page, to _refcount")
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 mm/debug.c      | 2 +-
 mm/page_alloc.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index eee9c221280c..8345bb6e4769 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -67,7 +67,7 @@ void __dump_page(struct page *page, const char *reason)
 	 */
 	mapcount = PageSlab(page) ? 0 : page_mapcount(page);
 
-	pr_warn("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
+	pr_warn("page:%px refcount:%d mapcount:%d mapping:%px index:%#lx",
 		  page, page_ref_count(page), mapcount,
 		  page->mapping, page_to_pgoff(page));
 	if (PageCompound(page))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c02cff1ed56e..113fa6eefa26 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1935,7 +1935,7 @@ static void check_new_page_bad(struct page *page)
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(page_ref_count(page) != 0))
-		bad_reason = "nonzero _count";
+		bad_reason = "nonzero _refcount";
 	if (unlikely(page->flags & __PG_HWPOISON)) {
 		bad_reason = "HWPoisoned (hardware-corrupted)";
 		bad_flags = __PG_HWPOISON;
-- 
2.20.1

