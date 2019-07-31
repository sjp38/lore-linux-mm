Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D645AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D7E21850
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="kKXhGbR2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D7E21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B9218E0009; Wed, 31 Jul 2019 11:08:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F33F98E0001; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86B88E0009; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACD28E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so42560236edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AJU4EYtP5Ndll/OqHeAitrNwzvbF49Nst5sv0orja/w=;
        b=JtE90EiZpLPDDAIrlHOE+aC/qyCS4gt6V1oJaLPfWmGYvUR9a11e/AEHQgJeDQiyJv
         hlKPfIUkv5Rqee4XstPoJgUR5aV/5+6wGEeDhaLF/y349jzQQczIaqUynjRhglym20qT
         e6eoFOHoEJafZeIpYVHBHcf4Ssd2a8tRGpZIHpgc9MI63/jfd2TvP0xPu20mWrg9MrJI
         1RGmfyf4JNmtGr/C2EAoycbMKZNaNeh50IjBcnwRbvZtaFJTZIMUt71XSR7iLTYKuPt9
         3jvb4kSn0mTwiSafnj8IAZ36V8YADaoSb/3cnxkn8SPjbCkwtNdHn3iRx4Oau0TRDDwD
         hUMg==
X-Gm-Message-State: APjAAAW4cipr6qSKcW4dOG/sF8qPyZJSOYF5zOqf7Hb8A5ss6C2Tbfih
	HVAlixbP4IT3MdGbymOZmS13YfBAgHVb1bYe/IAoPIWlExzNxurNzxOO/W020EuAT6UBB8u3GQ4
	sCyig4q03kmLQq9hS/lFVRvVlQN9knf/NnkuNEENyKlOBBUY989b7ArgdZqBGcBU=
X-Received: by 2002:a50:95a1:: with SMTP id w30mr108194349eda.177.1564585701058;
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
X-Received: by 2002:a50:95a1:: with SMTP id w30mr108194248eda.177.1564585700157;
        Wed, 31 Jul 2019 08:08:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585700; cv=none;
        d=google.com; s=arc-20160816;
        b=mNaIDFUGDZsBYwFNsw7AFKw8NbypUlS9ScENoU9kVw3o3jhxGG0RlVAGKJpvsRRtkt
         1yN/eNVM5FYmykW7v3T19xDDq4d+a2xk6kR+4l2ouBMik+lVo0kGBYsNgSgl83lZb0fF
         Ph41eDwD4mkXva9j6LOElgPOMIrvpdMEnCLkYvHvNMO/30pt5w5UGivq1j0Kv3fvlRF1
         pUCx/p5+FUq9800ZgTaoTZrQ7O7adqEH4Q9UATdKBz1tCGfAlFJzdoZ6Ua20skZDPz7S
         R33LnDE6M87zxGw0OBecwRkJQ3HooV8GKEwHj6D2eTNlSX5HZN/DLeO1+a/KlvnaKA53
         m74A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AJU4EYtP5Ndll/OqHeAitrNwzvbF49Nst5sv0orja/w=;
        b=rfXpZ8+3192zA0E96oQ0MTidiq9ceJh3MGzjfstrmbIFtXFnHVbc7Iz1KOzeiDsbJf
         7nVLrmcbkM557zhtxTxpdLMS/Qno0Ao+S+ljtgqJoyTf+elrEiz7y2YISo+LTJ/y/Mew
         /tBu1SuL0hEc7LKfyNn8+Do7PkRG+DuGnjJN6oFqnAeTibHFHWGgGajAQSHKYtrUslAr
         HOz5fAHWz0XiPHCRPmUrvY9wI/26sZ0oa5C87UGbyHs8POlEjX6VW/p3ICKymC84xNUo
         H+vOds+2DRix2MxcUip0+3bkK988jh7/7rQ36hsl201efo7MhODMBJzPQpmAEpMX9Dbl
         Jr8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kKXhGbR2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor51960748edd.25.2019.07.31.08.08.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:20 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kKXhGbR2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AJU4EYtP5Ndll/OqHeAitrNwzvbF49Nst5sv0orja/w=;
        b=kKXhGbR2JDGE9bSyvxgjKsfR1EooQVCxUWsDBiB/ov2JhR22a80ZVWH6hsoT5t60hW
         ReQlX2VuPnyHZm+ht43QCRrwOTR4FXEx8N9KLDx8PA4ydWKsR2BIUMxIijk5qFFyJWJR
         2f083LoqCGdskXIuleu/ah0wA10Rm17n5y2ig4+kPBzijtTL3lkIw8/27JLPaHybuORM
         pzMd9bI4PnPnmBKajAUKL8D2paFeEh9jjqZZbZStBfag1gDyfG8bBCKhuARqXP5nW2Pq
         L1ZhDiLr0HWi2NeMxbyWk+wgHvu/5r9izvPURcblDhh/5L3ApkkaOd6gdu9AGvFSIsuM
         bwfA==
X-Google-Smtp-Source: APXvYqwybSsBXdcn4hH+cdquBQ7naCJOKUH1HBc36wrC3gr3IAtOhb7lLrFtZj0CqBrWNvtjPSNrNw==
X-Received: by 2002:aa7:da14:: with SMTP id r20mr107154184eds.65.1564585699886;
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id o22sm17282787edc.37.2019.07.31.08.08.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 17B6310131D; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 06/59] mm/khugepaged: Handle encrypted pages
Date: Wed, 31 Jul 2019 18:07:20 +0300
Message-Id: <20190731150813.26289-7-kirill.shutemov@linux.intel.com>
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

For !NUMA khugepaged allocates page in advance, before we found a VMA
for collapse. We don't yet know which KeyID to use for the allocation.

The page is allocated with KeyID-0. Once we know that the VMA is
suitable for collapsing, we prepare the page for KeyID we need, based on
vma_keyid().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b23215..ae9bd3b18aa1 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1059,6 +1059,16 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock_write(vma->anon_vma);
 
+	/*
+	 * At this point new_page is allocated as non-encrypted.
+	 * If VMA's KeyID is non-zero, we need to prepare it to be encrypted
+	 * before coping data.
+	 */
+	if (vma_keyid(vma)) {
+		prep_encrypted_page(new_page, HPAGE_PMD_ORDER,
+				vma_keyid(vma), false);
+	}
+
 	__collapse_huge_page_copy(pte, new_page, vma, address, pte_ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
-- 
2.21.0

