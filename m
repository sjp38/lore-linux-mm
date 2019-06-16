Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A015C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 591A4216FD
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 591A4216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 704D28E0005; Sun, 16 Jun 2019 04:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F918E0001; Sun, 16 Jun 2019 04:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52C798E0005; Sun, 16 Jun 2019 04:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1A38E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:45 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u17so1032458wmd.6
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BH7q4sQxtlW7GBy0Ndsur0wfVLJQqa1DwxMiAYKl/M8=;
        b=dJ7Ym0q80iAZqo6WpGnwJBpyvRKn9kvtfBHFK9BQlhMmIPbUBkI9a23S+yDrhuF4UG
         f18iQG+j97bINxQP8HBLAsiGGvTTosKjFkoLeJQM4ScyMDHWxubDX7U4jBgo4NsaxGCo
         n+ZDihRLnTGQUlz+QXkCrJfE0p0JN1Dh3C30vgSNS1Nf1/kIVHZzzUNAc0idq5sjeGzx
         xBB10+FBEfEBtZHTJRt1QBn+OKQcrnbAmRbrCPzgVhwuX4w4GzMYynz/36aioV07B9PG
         A8eWZ5OhpM2V0lbdEo8x9lU/r15Cm6WK25RHMeDENfCRGpqp+mGFXFxdqA+n6k5DYeW7
         xSlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYkykA8yqf6HuUkoDYuu3ZhGvdyFq3CcmoZujA+8IQhUmZs/R6
	6mqyw7CPzZE0DckZZJVsidtC93co2Nn4NRfWqArLNBH2HiMDvpEqJaQuCNon9yHlb+N9ejg/Aq8
	uFjWqKijrNaq8T6CPx92jwU8OElCp8g5TRUo9HIQpcGxAD4YTcshELegNqtDVOGuGFQ==
X-Received: by 2002:a5d:6212:: with SMTP id y18mr24176816wru.178.1560675524667;
        Sun, 16 Jun 2019 01:58:44 -0700 (PDT)
X-Received: by 2002:a5d:6212:: with SMTP id y18mr24176778wru.178.1560675523983;
        Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675523; cv=none;
        d=google.com; s=arc-20160816;
        b=RW6Tmnf4UXWb5X95jwjlCr5lEJNGFwOq7JMnIT3JIzqpR1dQJ//oSw98E49K4bkV/5
         ddoFtLn9GOoml9ocmePvrfs9eNWRDB1lfxub54PK6zp4nvd9APa8iUtYuqpzUaL/xgpg
         xPw2oSaOl4L+Tj9zjUDofIDQnG2vvSEgIqFDJOobwER5WukANEW0O4xgz+cH3mbtueCR
         RNBbsJnoGVBGqw2BaO8PX0gxfDItMBRWDsNgaF/RtleB+57MWe/iwCo+ndn0va1yO9NB
         JXJAda8iJzMf997pmsRV3qY/MOSNjCqA1D439EWTXlLwX2LnFhjgWAmPj/MZZolQ+HNJ
         ayXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BH7q4sQxtlW7GBy0Ndsur0wfVLJQqa1DwxMiAYKl/M8=;
        b=YaLEAo1ealArPJPiCOWFUncelP9JkUX7ejY2R3s3L84/ERRV0NnBD5hdHrgA274Mbq
         bwIoT5tdn6P2v1mb36CicQXGNvkfEJOTTINew+r4iBkU11ZM988X/b/rn1KXrBVYo3wj
         KXGU0lrbpWLCfwFuiHQ+KlsRepzNPf07Oj/rqRNa6nMoDjqMSnKfrKbDa0fVHUitLbT/
         Pb0J4iC0dMddOk6UApjdk86XJXySlHnVhVPpG/4Ej7bqmgnn1csclAg5ou3N7byexzGu
         JuBFqkTO/117IjAHSfZ5PP0luCM7YpksKxGdSB/G7D8kFmFALre9hQN3U0ew76JxUbZa
         dPKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10sor5737969wrl.40.2019.06.16.01.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz8xNHGO6SpiHfeRXmpPOlMaBmRTs2Z+ZnB2utwNn6Sw4tv3GLfcp5kGY1tE4/gW0/NkQufFQ==
X-Received: by 2002:a5d:5702:: with SMTP id a2mr28113288wrv.89.1560675523661;
        Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id e7sm6195627wmd.0.2019.06.16.01.58.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 4/5] mm/madvise: employ mmget_still_valid for write lock
Date: Sun, 16 Jun 2019 10:58:34 +0200
Message-Id: <20190616085835.953-5-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190616085835.953-1-oleksandr@redhat.com>
References: <20190616085835.953-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do the very same trick as we already do since 04f5866e41fb. KSM hints
will require locking mmap_sem for write since they modify vm_flags, so
for remote KSM hinting this additional check is needed.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/madvise.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index 9755340da157..84f899b1b6da 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -1049,6 +1049,8 @@ static int madvise_common(struct task_struct *task, struct mm_struct *mm,
 	if (write) {
 		if (down_write_killable(&mm->mmap_sem))
 			return -EINTR;
+		if (current->mm != mm && !mmget_still_valid(mm))
+			goto skip_mm;
 	} else {
 		down_read(&mm->mmap_sem);
 	}
@@ -1099,6 +1101,7 @@ static int madvise_common(struct task_struct *task, struct mm_struct *mm,
 	}
 out:
 	blk_finish_plug(&plug);
+skip_mm:
 	if (write)
 		up_write(&mm->mmap_sem);
 	else
-- 
2.22.0

