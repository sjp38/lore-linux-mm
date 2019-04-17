Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 382BEC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F205221773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:31:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F205221773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80D5E6B0008; Wed, 17 Apr 2019 01:31:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BC416B0266; Wed, 17 Apr 2019 01:31:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D2806B0269; Wed, 17 Apr 2019 01:31:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21E486B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:31:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e22so10505005edd.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:31:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3oOhKgf5++Zcd2NhUlCVUeA8BDKs7cw/2jMalEBWqIE=;
        b=JyxarhDBPQlimUyiNgAK7/JdC2uXxrJFb2GD9Yh/K7aqPXO7mV9jYDqUoS2Ka1Avqg
         J7z+FIfEqj3pKdJD6d89wl5U45tJWj2RK4Gtt0xrzWD4Uj4JGD/J87pqD0N86pJ/vSQp
         NnzNzdxDLV/vIxcZDyXImEHmNMuSSlSKolCucUB14E9XHoFwcQe1ZsoP1MeIw4BaqSJp
         7YkyKR2MJnfcoNMwAhDxwqwxgBWfPyAQSyPSC7CuvHmLW1lqqqlGpTaCA1mFTrl2qNRK
         3bgu0AAKu4VzPTkXGnIEiHNwiQVqtb3drZA2MJomaVtLkZKvQtkFC4w28nzEEuJ31WGW
         TXLQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAX4juyPqmm9nMLTT9TuHdd0GH/0LrUgrX8Nb+Cxa+A21367sNwe
	zXMyG2908ubLhy+RARGwG3MBiJk/lhkofhFCtStov92WCqPMcL/0NLmJZmfSuSmcNROYv00L9sg
	Rm0w9CP5zqyYFWdsoY+bSo4njmml/IOERMVhcsr1IQkq5v9MI/DUM/t++CcGchCE=
X-Received: by 2002:a50:b646:: with SMTP id c6mr53686590ede.150.1555479098616;
        Tue, 16 Apr 2019 22:31:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXlykVJBKY8sdHHFZRkjtuurjgt2A6cqcbbwVmaCpuW00R62E5YT/eRchNBR99Xy3qDal7
X-Received: by 2002:a50:b646:: with SMTP id c6mr53686551ede.150.1555479097804;
        Tue, 16 Apr 2019 22:31:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479097; cv=none;
        d=google.com; s=arc-20160816;
        b=WStiVbRQQU/tkO9b9pvNt8EOUIWcESLBvD6acGq3aT7nsLDv01nLm24OZmhZ+vjb/J
         aH4jSEUn4+DXXgKY5OMDtlnA5Wh/tZYfy8Qqrs1Enpuoy8UArKht3H+gXyKgZ3e9Neh7
         XtCD/PnS4mUxGthV6zme1COBJwU+8FZT/ShIytYQWcIZEZOBOPIHcuNdVN/js16mYuNh
         FeL8BH2yG6aqZDpaInRADpwzOJs8JCB+XL7Wj9mpZOMzmFWjKCkZCIOuLwvxXLQAuySR
         39yld9beziqLyKuu8HCFAaDxc8lhJ7S9YmYI7QnK7zd5iVDl97m5Gca1F0QsafvD2LUE
         MrUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3oOhKgf5++Zcd2NhUlCVUeA8BDKs7cw/2jMalEBWqIE=;
        b=ifKb+jJ8zm4dwnsjCPP0JP1BLhXSjof9G1bBZknbHxQ9v7cu8XM3AjVFeRaeGUuba9
         O4vLtfNhgESwR3X2zCQZvfoFG8cCflcQYYt7SolA/sx7gPyG93z/owPIYaF3JJ+PxUh1
         GJdy1JMccood5w/QJH7EP09sqPBKIPTbYI2uLDXSWtpBb261HVaixCV2QiGn6qx0kzXA
         OmhzlfFXPbjuxeymuxUTHgWmrIyegJnm2ifA9uGQq4H9dRFJGraBuTaEQ3tOTvMXz+wh
         loQv+LDBdUUTPKFO6xSpneFLLd1erxgQmje6qfzJl0hpTDEd37yJ/eyd64kt6Sn0BPG2
         jN3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id r5si1311983edy.227.2019.04.16.22.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:31:37 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 4BE7CFF804;
	Wed, 17 Apr 2019 05:31:33 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 08/11] mips: Properly account for stack randomization and stack guard gap
Date: Wed, 17 Apr 2019 01:22:44 -0400
Message-Id: <20190417052247.17809-9-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.
This fixes the problem uncovered and not fixed for mips here:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/mips/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 2f616ebeb7e0..3ff82c6f7e24 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

