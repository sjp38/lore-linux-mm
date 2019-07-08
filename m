Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60955C606AF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 11:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 001D0214AF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 11:48:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S9GQayeH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 001D0214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42CE38E000F; Mon,  8 Jul 2019 07:48:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DDF98E0002; Mon,  8 Jul 2019 07:48:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC0A8E000F; Mon,  8 Jul 2019 07:48:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC5338E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 07:48:12 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id t2so3603871ljj.13
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 04:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-transfer-encoding;
        bh=NI3QEPrQIr80BSUs7n24DIiPSAw9kPLEpr0qpD9OC4g=;
        b=RVsr28NhKRf/7bCzpxK02sxavgvSRFmbqC3SmIdyH3phlXfMKR7J927qHQwwChQd7s
         Jzof7TGWHXw6wlrT8+1yagQCjHiMN8u7NVdrXN3KrRkGwIpyei/4EME+soCc/Ef//+lj
         RO6XSOODizP+VxrFtTx3GdhhFLJnusZB4JamLoQKb7FJ/Ux0ith+AWU++z5pKGl7IgHN
         43DJJa27Wnfi8CtCZL/Xrr7QHfh3MJMN5BnCz6GD4kcghyYF+Ax6gLqXiYZKyPlhc+AT
         9yhW3DCoRnsi7WgSEGMv6oK4+viJJBorJKQjOAsp9yQaCa2f576Gb/SKBM2wGN6QK02i
         sfSg==
X-Gm-Message-State: APjAAAUkQk4kiNjm2WbPgYBcMWf4qvRMsbVKJmYhduBcAgifYuZMNICa
	iWAKqUGYWe400kQGS2G32k+sGMrLngO2+pJl2n1ViNz3dozRtd78iAO0c3/IbV+Tl+2mGHyR2rz
	6N2nefkcLJPW9Zmi2NxcN55OKQ/q9WFUzoobDJn0pBO91acFt90ZwkhT/2d8YoarZoQ==
X-Received: by 2002:ac2:5442:: with SMTP id d2mr8807944lfn.70.1562586491928;
        Mon, 08 Jul 2019 04:48:11 -0700 (PDT)
X-Received: by 2002:ac2:5442:: with SMTP id d2mr8807899lfn.70.1562586490604;
        Mon, 08 Jul 2019 04:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562586490; cv=none;
        d=google.com; s=arc-20160816;
        b=xxS9p71lzc+9ukCSA6CpaCl8cwk78YoYBGRpoJ9VL0Za2XwYdGmcd9tSZNwNC4oGmu
         gvcbS2c/I8TbqMxEBXf/m4A3ldh7vibD+7X2qx1Jd2usNfVuR6zXMd/MHOrfPH/Efz8E
         WBJlhyJsDwqQmh3KIy7fnFlKQ1rNOck/ASQdU9V6lWv3087lFQgZVRarufKy54krCgtD
         QxAKOLOwYWveIQyKXk1JELkUk5Xyoqu6jwY7jXgQTguZwbRxV7RuDy4T3Zb+hnHS5Fxz
         ILh97NE5liXOW2hwO904q7mehqdrFGluPllW8wRfP1cXQTFehWdyepzyXuZVz+PQnyRh
         bvmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date:dkim-signature;
        bh=NI3QEPrQIr80BSUs7n24DIiPSAw9kPLEpr0qpD9OC4g=;
        b=AlXn3o6fFJr1+1gQExZQuupImYNkVfNpq8l+re8sdI4F1PW9+tt8n4GqCmXxVEkTVn
         JinVuDVSwZageF9sccfZe1diLMBrRRMULESLEXNrg9xSbXgoYm+0qdlqX34Qp/HVg40z
         vd4HZd8TToUusp0bSFmfFLlxGHZm6I604cdCRGz593ydzVbnOfHWA/U/APEHSfkpfjOZ
         Y4zqTan9u6IaRHvC+fzhd9++ZkNahpE0pOloXi7MCnNAY+nJlC8/WmC//t+p06AG1B/T
         MC5KQZsWX8HI4fNcRSZTmG78BLsQx0uWhk8XXgGRPkq2rRdF+wpbuSMcSVoxMblq/kS4
         oHVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S9GQayeH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor8686120lja.30.2019.07.08.04.48.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 04:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S9GQayeH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=NI3QEPrQIr80BSUs7n24DIiPSAw9kPLEpr0qpD9OC4g=;
        b=S9GQayeHFQ731dT5yJcM/ihOV6PmnB9JiGGWT8EA0FW6/OnrP7Tu3j1AFDYYFTfyWb
         WHF9GBQKnWQ9ThaeB8hccX46QXszkGJFg2f1Lhsa5v90xGgQQBPsCOqgiKgeXAAOVg7s
         BB9cPsgId6WgH6lk4Tgs+NizD9QwDz2nLcvfdRWKBCf6+SVC1xQbsv1ym2LTMTXqeASt
         +2ylCWebiVrsaBtr+u9szHDElMRxFIhQ3ithCuk17+yZzxC2oE0QEPQhQ5Su9EjB/Ah0
         OoxjVjK4tH5+FjedWOLcdf93lzRbERfL8bKRt6DHoVTcT1lvTPKHgUImTpPt7SAuvgDu
         YHZA==
X-Google-Smtp-Source: APXvYqwobzmzNJMY8JHCnmkFYX2leQw1uuMNkq4cZtY/HXbrqG7LWkvAoipYWg4C8v4VY3KRfW1fxg==
X-Received: by 2002:a2e:2d12:: with SMTP id t18mr10478511ljt.175.1562586490182;
        Mon, 08 Jul 2019 04:48:10 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.39])
        by smtp.gmail.com with ESMTPSA id s7sm3612057lje.95.2019.07.08.04.48.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 04:48:09 -0700 (PDT)
Date: Mon, 8 Jul 2019 13:48:08 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Henry Burns <henryburns@google.com>, Andrew Morton
 <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Jonathan
 Adams <jwadams@google.com>
Subject: [PATCH] mm/z3fold.c: don't try to use buddy slots after free
Message-Id: <20190708134808.e89f3bfadd9f6ffd7eff9ba9@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From fd87fdc38ea195e5a694102a57bd4d59fc177433 Mon Sep 17 00:00:00 2001
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 8 Jul 2019 13:41:02 +0200
[PATCH] mm/z3fold: don't try to use buddy slots after free

As reported by Henry Burns:

Running z3fold stress testing with address sanitization
showed zhdr->slots was being used after it was freed.

z3fold_free(z3fold_pool, handle)
  free_handle(handle)
    kmem_cache_free(pool->c_handle, zhdr->slots)
  release_z3fold_page_locked_list(kref)
    __release_z3fold_page(zhdr, true)
      zhdr_to_pool(zhdr)
        slots_to_pool(zhdr->slots)  *BOOM*

To fix this, add pointer to the pool back to z3fold_header and modify
zhdr_to_pool to return zhdr->pool.

Fixes: 7c2b8baa61fe  ("mm/z3fold.c: add structure for buddy handles")

Reported-by: Henry Burns <henryburns@google.com>
Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 985732c8b025..e1686bf6d689 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -101,6 +101,7 @@ struct z3fold_buddy_slots {
  * @refcount:		reference count for the z3fold page
  * @work:		work_struct for page layout optimization
  * @slots:		pointer to the structure holding buddy slots
+ * @pool:		pointer to the containing pool
  * @cpu:		CPU which this page "belongs" to
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
@@ -114,6 +115,7 @@ struct z3fold_header {
 	struct kref refcount;
 	struct work_struct work;
 	struct z3fold_buddy_slots *slots;
+	struct z3fold_pool *pool;
 	short cpu;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
@@ -320,6 +322,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	zhdr->start_middle = 0;
 	zhdr->cpu = -1;
 	zhdr->slots = slots;
+	zhdr->pool = pool;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
@@ -426,7 +429,7 @@ static enum buddy handle_to_buddy(unsigned long handle)
 
 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
 {
-	return slots_to_pool(zhdr->slots);
+	return zhdr->pool;
 }
 
 static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
-- 
2.17.1

