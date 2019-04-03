Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47D67C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0526D20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0526D20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BFC66B0275; Wed,  3 Apr 2019 10:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56FFF6B0276; Wed,  3 Apr 2019 10:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45FC46B0277; Wed,  3 Apr 2019 10:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBDCD6B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e16so5111523edj.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=kE+sVUe0iQaOj1/JeQHzedg2Q96z4A+uPRI/xEn105QmIyZ51NnbaiyGCktgm9ZyVB
         NDTZltYBC3tpfTkH7uHCB2czxzDs8scTcjO2XCmGNOPmwYs1La3uoOti3qSTykXQD2sl
         npVM321XMX5nBf/gLoIXWldlNqcNN2cvu5EWPuUi/1i5B+j2pqJ5MceBQH+C6jishPiI
         gM4S3+fUuB/JKLBXkca5JQSQBD7PmzOsfeKxyShEAVPi0SxWGZJzQjn26AusXqKt5mH4
         vDBQ548kviqhrWSiSUvwVjnTHlMdISG40UX5L4s6JSruArBcu6NYhEumy+C6nRAhxJnG
         WNnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU0Ds/siq+L8/KeAW4ZpLSKtUBKSQMpCZIQ2IFf9qrOHQeH+hzG
	BPRp31RdiEq1vFKPTa/tNxMxco7wwher4UH2pPS+/uTQm87I5Vy+hCKFM/6IpQaoDzz6Rh5CzNG
	QBn00+2GmIB1GHJduMfatcya1k+CjTMgqkfEPze5FI3SLog291mpMiqObwq/9KId1qw==
X-Received: by 2002:a17:906:1984:: with SMTP id g4mr3667701ejd.260.1554301084474;
        Wed, 03 Apr 2019 07:18:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwj/dP4Xx7y/F/EpOTaoKi6FNbvXUZO/JotaOfpFhXTAx066Cd7sqGCiOrnBnAZVUR8Mr4g
X-Received: by 2002:a17:906:1984:: with SMTP id g4mr3667652ejd.260.1554301083540;
        Wed, 03 Apr 2019 07:18:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301083; cv=none;
        d=google.com; s=arc-20160816;
        b=YlSv7i1i7vbmnHn9C6kDMvCTOZFKwrUwQ8GddbG3eoQN7cQPJgImvk9k21CwE/O6a1
         gx94KQt2UC3jQ0F0j0pUo8UPr6ZfKXsdH5YFfIsAsKF4fRQEDzMGcRzP67S2Lh/m4SwC
         Vz7HgQTsk8Apf9O+4m19REXyoCyI8GyAzAK6tNmTT1DL+5a22eyxa+GvvJrf8LBJbS4A
         wlmmtvqbOu9pVqlY9Q1PRuwOmSUltgOQsQGAZP57va3ufzIv1f1hxwaifO90tYYG+o44
         SuHMjotqaHEQDoJAeptH39p8TlwcJ74ZDJfGYlwYGjf484BMFkf3PqzuvMymg2OJtsbS
         YFTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=iSbGLAx7sXAguuP8Pi8B5GuGkj7T60ehxGk8/hjRfdAla2JHnVYnijoghcHO+3MY5P
         6Ai/JsvWqnx8PLF8p3lk/JukStB4rcDVsoZ2mS3hcvW3WVYxP1AbdSGzf8dtl4o7ELSa
         Z0JRySJwqn7J0oBiLhEfNlP1bVCiaiO/eSQ9sqODtNVxhyWYd+CtX7KuCKz5JDd15LNJ
         KJbzUECz496kJTa6yNCajby25e6SvzK2AlpoTjf//TXJphZyyIjogOjQbkXA3TIuhuBO
         StlBL2VAgEWbqkHX0A8lsotToEoLsPXd/uM9vX40wKJ12M35xxEiLPmvlEAsqn7TcAXV
         gGBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g12si1185396eda.361.2019.04.03.07.18.03
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 804F21682;
	Wed,  3 Apr 2019 07:18:02 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 20DDA3F68F;
	Wed,  3 Apr 2019 07:17:58 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 13/20] mm: pagewalk: Add test_p?d callbacks
Date: Wed,  3 Apr 2019 15:16:20 +0100
Message-Id: <20190403141627.11664-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is useful to be able to skip parts of the page table tree even when
walking without VMAs. Add test_p?d callbacks similar to test_walk but
which are called just before a table at that level is walked. If the
callback returns non-zero then the entire table is skipped.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/mm.h | 11 +++++++++++
 mm/pagewalk.c      | 24 ++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6de08c116e6..a4c1ed255455 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1382,6 +1382,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             value means "do page table walk over the current vma,"
  *             and a negative one means "abort current page table walk
  *             right now." 1 means "skip the current vma."
+ * @test_pmd:  similar to test_walk(), but called for every pmd.
+ * @test_pud:  similar to test_walk(), but called for every pud.
+ * @test_p4d:  similar to test_walk(), but called for every p4d.
+ *             Returning 0 means walk this part of the page tables,
+ *             returning 1 means to skip this range.
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked (NULL if walking outside vmas)
  * @private:   private data for callbacks' usage
@@ -1406,6 +1411,12 @@ struct mm_walk {
 			     struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
+	int (*test_pmd)(unsigned long addr, unsigned long next,
+			pmd_t *pmd_start, struct mm_walk *walk);
+	int (*test_pud)(unsigned long addr, unsigned long next,
+			pud_t *pud_start, struct mm_walk *walk);
+	int (*test_p4d)(unsigned long addr, unsigned long next,
+			p4d_t *p4d_start, struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	void *private;
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index dac0c848b458..231655db1295 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -32,6 +32,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_pmd) {
+		err = walk->test_pmd(addr, end, pmd_offset(pud, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pmd = pmd_offset(pud, addr);
 	do {
 again:
@@ -82,6 +90,14 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_pud) {
+		err = walk->test_pud(addr, end, pud_offset(p4d, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pud = pud_offset(p4d, addr);
 	do {
  again:
@@ -124,6 +140,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_p4d) {
+		err = walk->test_p4d(addr, end, p4d_offset(pgd, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
-- 
2.20.1

