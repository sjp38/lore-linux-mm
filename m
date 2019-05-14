Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C783C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10AF220879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10AF220879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0849A6B000A; Tue, 14 May 2019 09:17:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 009246B000C; Tue, 14 May 2019 09:17:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18316B000D; Tue, 14 May 2019 09:17:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7EE6B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:17:00 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z13so3995582wrn.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:17:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vA0P95K9fRheR4E+ESk+WXsmN1wAOY/rldukfhup8+8=;
        b=MDOj4Vgjgohm+4PiuCfRrIXBXv4LNsn1sun03j23vv/xyrTrB9aO+BPhRpRd5NKw0J
         nRTg8jOF5J909iQGHxDYDZ0EZRcClXiqUgt3/6jmIpRlHX2izCS4ZMXfoVZVv6KOMz4J
         Q6IiMh4URyrVhEzQ/iD3ZHDk8TS1NTs8NTPc4fZ0WEXdqxwpAEvxFwDf30XeEvGkFhLx
         qh0A7ZjDGUxxFfjBkcKtkU1eHpX8ttGtrHFD1juQbvW9qmr9ErHl3X6P91NxmesvqP1H
         YxiewVor/qbih14IWS9I6dgAoNhAedbAHVfeVYNU3S7LWNvCuoaRSPXHTX69KOP5yxJc
         AhfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQoTw0btkfV642D0dRL1je9IVxkXzRzIPC237tmpbNyhon7k6f
	O9Xi3UDgP7dm5bmRwuj5vvbkg2PhYgkSobPq2qNP4HnB5n675O1WCSUmxK8zMTRHdNtK1006xYc
	Czato/yKTzonYYA3RSoiC38wfpeNvI6glo/egxg2Uukikk6PRKMhHR5V5x1AnJUNFww==
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr21522399wrv.163.1557839819961;
        Tue, 14 May 2019 06:16:59 -0700 (PDT)
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr21522327wrv.163.1557839818628;
        Tue, 14 May 2019 06:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839818; cv=none;
        d=google.com; s=arc-20160816;
        b=BANEWZjRW+AyGPQI/l44nPNouoCKgodV7bbCwT+QJPaM9KnaFI8Svfy/aZbSbSBncI
         +TTA9HeO2hSs8YiPZT23Cih03+mUKrG2QkMcIm7pldqPyXmHyTaNZvnHs7DOdqTKrQi6
         6XGWRPFcnHZ9Rc9euX+WiT/VhDYnp0hD4NYcPMCi2ByDn9EDFVKvA+sVKYe4oHihYNqR
         oAoUU4coqcFyN3e6wKLVoRIp3GRB14eksY0UkG/6ICUrAtjCtXaxaCzwpHVqAv6K/LZd
         VXtAkCtfmJ5SlKOu1rn6tJojCcty832DIzgRqPbomHI9CVS+vln1vPBY1Je5vHp/UcHE
         hy2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vA0P95K9fRheR4E+ESk+WXsmN1wAOY/rldukfhup8+8=;
        b=adJarf9WzthDSHDzrKfkMzy9vR7sTPVkdN4wIrkTZPTpW5So2HYpTRzi54TLKM5HEt
         wWTxdHjWwRxtFI8Y7c8XG29Hy3ynltHVKUlZubu9ll9OXei9oPQctJBRQ86ZyLohoZcY
         wZXtDO1YGwAXg/eHZT5vcyGDE0HbLV7O60RltUe+5a2OMjNTG4V4ZJSH8cENiwMu2BH4
         Y586luRJfvOKB1Jsnj/OYYNG96M0qRLUjpnXWn0o7vMpR08XW/tjbTkseVpV2E5KFJAC
         h91LOI0Pn0n5bpxV/L7Q+1mjEyumgunxxV13Iy+z+9OulQUIwKOISiG+ZfLLh0rUO29F
         Wyiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor3132975wrm.43.2019.05.14.06.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:16:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyA7ev1bORFUVmblymk/lrv+ZsAH07hD7NalfDAhNsPNHuNGBskFQiodfLrs4do1an3hLlNeQ==
X-Received: by 2002:adf:c149:: with SMTP id w9mr10697762wre.40.1557839818301;
        Tue, 14 May 2019 06:16:58 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id b2sm16325220wrt.20.2019.05.14.06.16.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:16:57 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC v2 1/4] mm/ksm: introduce ksm_enter() helper
Date: Tue, 14 May 2019 15:16:51 +0200
Message-Id: <20190514131654.25463-2-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190514131654.25463-1-oleksandr@redhat.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move MADV_MERGEABLE part of ksm_madvise() into a dedicated helper since
it will be further used for marking VMAs to be merged forcibly.

This does not bring any functional changes.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/ksm.c | 60 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 36 insertions(+), 24 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874dc6f4..02fdbee394cc 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2442,41 +2442,53 @@ static int ksm_scan_thread(void *nothing)
 	return 0;
 }
 
-int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+static int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long *vm_flags)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
-	switch (advice) {
-	case MADV_MERGEABLE:
-		/*
-		 * Be somewhat over-protective for now!
-		 */
-		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
-				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_MIXEDMAP))
-			return 0;		/* just ignore the advice */
+	/*
+	 * Be somewhat over-protective for now!
+	 */
+	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+			 VM_HUGETLB | VM_MIXEDMAP))
+		return 0;		/* just ignore the advice */
 
-		if (vma_is_dax(vma))
-			return 0;
+	if (vma_is_dax(vma))
+		return 0;
 
 #ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
-			return 0;
+	if (*vm_flags & VM_SAO)
+		return 0;
 #endif
 #ifdef VM_SPARC_ADI
-		if (*vm_flags & VM_SPARC_ADI)
-			return 0;
+	if (*vm_flags & VM_SPARC_ADI)
+		return 0;
 #endif
 
-		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
-			err = __ksm_enter(mm);
-			if (err)
-				return err;
-		}
+	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		err = __ksm_enter(mm);
+		if (err)
+			return err;
+	}
+
+	*vm_flags |= VM_MERGEABLE;
+
+	return 0;
+}
 
-		*vm_flags |= VM_MERGEABLE;
+int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, int advice, unsigned long *vm_flags)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int err;
+
+	switch (advice) {
+	case MADV_MERGEABLE:
+		err = ksm_enter(mm, vma, vm_flags);
+		if (err)
+			return err;
 		break;
 
 	case MADV_UNMERGEABLE:
-- 
2.21.0

