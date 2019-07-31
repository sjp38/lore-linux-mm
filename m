Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C50C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA12F20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="bZcGmOHw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA12F20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BB1B8E0028; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E1458E002E; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25AF38E0028; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B42228E002D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so42586055edc.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EvEqqoCYvSiaJViGsfZgvE8wYjGeg4BQWYRIZAIdYOQ=;
        b=MYDge2752n4xa9k5R0MimpCgRW+0jTmurKQvYafRH8NbnvGLHQ2gWph0RLlpNGSFoe
         rsDJjL/dC+84y+N/ou4QfUKVMj01XyWYonCnKCJ9gyF8BYGD3guoqFOxezGPkTRqr8Mk
         +VXtTIfsis095EsRyFFjroqr3hK19w3AEyMQIpkvgTxWTIPiR34U85yMJEAIfaQnoevo
         0nNBmix3inJviaMjpl7TVW0WfPiMMJQNorq6tefIhE+ERVObzCQfRQinAS+ke+FO3aub
         2dZjKpjc+UKXCsKJlbrAd8BN5p41Q+SEwNrBsdSN6HGbxl6TvN8sV5a27H4JXW0yrvCO
         8RMA==
X-Gm-Message-State: APjAAAUUJ3pyH5fPTQQMFZLyAn0wRYCBYUuH1iPiy8xR8AhgDfgv1Mig
	WdhBrA794iGZhWPxduK/7WPi990Se6iv4zBgx3aM+oAime3wivA+oqvffJqEqM1ZPBcVgryZEUF
	YSrXoVZWVbLlOR8qB/8Qfjz6jNYRqPqDRoIhFJvmCUe2UyTYHdcFp8EbTk8sCvX4=
X-Received: by 2002:a50:e618:: with SMTP id y24mr106992085edm.142.1564586036330;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Received: by 2002:a50:e618:: with SMTP id y24mr106991980edm.142.1564586035360;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586035; cv=none;
        d=google.com; s=arc-20160816;
        b=05DlqiGAsIu7LLoz1m6Cv4xVbIn96iY8pcafLHKh1QcvSdbDmqRWzo/87+RSsfMGqm
         tCpQEXgvSAvINz+Vd8slTT0SGjmDbOxqssp+LinMj2QgPxP57lT9qYlb5hr53BgVLJeA
         /2fjEQwTdQcCRmJ8Qc/PlrmUzA/v8/LCfSy6F+5pvQU/UZBxeFaq9c9HYe8rBVJmuKk4
         D6ZuXwRYtvYqZfVCi5fd2L9NiQo5nn9ducQSC6fl/6pl2m+llcT9QSt+Km8UaVPRv7gP
         B75UCID9DOdTFMDEmBxEvIxKPFwI0G83AMakXr7pXUbFTCRd971+H4DEjjyVHawItuhX
         6u0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EvEqqoCYvSiaJViGsfZgvE8wYjGeg4BQWYRIZAIdYOQ=;
        b=PjkmDcgz78RBAF+QPpMzDqFyDUhLOx64s/Zcw50mbExU95pgqs0OE/a6yR/aqKrAD9
         DzYWeBZM8jmUHHftDltUcWk2nsYUh1Ez6FpEElICGspFgDLW1EttxASjbtqkIzlGIpj/
         tvxZurvJ9MbJFPEF3lsW8MHeExH6yq1T6taJOq7DOSF/IV4+6wGA7ZafICqBVy/cpdey
         PBpskjlOvj8zPurFkyg28PbGi6t1DcqGrQDxlVSzBYK/NlCC36G3eOslMkE1ZHpWYgGt
         sCkOnaK2e6rb6k+GSz9nAttUZmQpDFE+IjXbjD2SG6w9nKLtcfFmHBCW43hWeX7xQLw1
         mNJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bZcGmOHw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor21736638ejm.5.2019.07.31.08.13.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bZcGmOHw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EvEqqoCYvSiaJViGsfZgvE8wYjGeg4BQWYRIZAIdYOQ=;
        b=bZcGmOHwm0gi6j5t/BbUGsKtOCIZr4doGxyXBg+bAsntyv91YXoAwS8iK8gYH/2Rhd
         EZoLChmRluivD3XLirlmMT5W1vFicn0Th6yRJbjlvSCthP29u5r3kvQbgKOL0NnWdm5O
         z6WKnsGxsng9YOVJ6s+hk1x3ysUEVhPOmeDyo07xX324wqjHjFQ9yfcsBJPs6sEkZfG/
         j1P95OYBR2KAtJYWJH/9fdcbulUD7i7ZdBv1U7AlRZ5qi7KMU65oMM+umaihE2hREq1N
         HFgl1iVKn4xa5Uwqe5PFQO1apPGzMbp3tx+aOQoTXOpVFI0CqNnOhoaQyl+Z3LmysdM7
         SIkg==
X-Google-Smtp-Source: APXvYqze/zmPMD1Bsfoldl9kgWqcWF2ltGwH8c0r7lo9vR1AXcu6XddkT5YuYdRgsgxlZcifb+OJkw==
X-Received: by 2002:a17:906:4d19:: with SMTP id r25mr94272907eju.125.1564586035045;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g7sm16945101eda.52.2019.07.31.08.13.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 874211030BD; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 22/59] mm/rmap: Clear vma->anon_vma on unlink_anon_vmas()
Date: Wed, 31 Jul 2019 18:07:36 +0300
Message-Id: <20190731150813.26289-23-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If all pages in the VMA got unmapped there's no reason to link it into
original anon VMA hierarchy: it cannot possibly share any pages with
other VMA.

Set vma->anon_vma to NULL on unlink_anon_vmas(). With the change VMA
can be reused. The new anon VMA will be allocated on the first fault.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..911367b5fb40 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -400,8 +400,10 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 		list_del(&avc->same_vma);
 		anon_vma_chain_free(avc);
 	}
-	if (vma->anon_vma)
+	if (vma->anon_vma) {
 		vma->anon_vma->degree--;
+		vma->anon_vma = NULL;
+	}
 	unlock_anon_vma_root(root);
 
 	/*
-- 
2.21.0

