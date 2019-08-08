Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48286C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:29:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C90F21874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:29:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C90F21874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A94DB6B0006; Thu,  8 Aug 2019 02:29:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A456D6B000A; Thu,  8 Aug 2019 02:29:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90E796B000C; Thu,  8 Aug 2019 02:29:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 451516B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:29:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so57559516edm.21
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:29:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CozSP8ClhxqYRnTVyauC5EuB32xQZZhYjVFYo6YFdyo=;
        b=FoY0IiLGB1bYx8NiCSWkq7n+dpT6S/Kb8TFTUfNsepCuWxCU7KmbosHMR5pqaZPBaI
         GHGk8mVNvpqtaB4eaw1MCHyZMdqAe8ITKvMxR0Wk8Zaw+YotDqy/bz+bVZxiq0uvaHIv
         IsQftsZzeuAmU2k6xc+NJysuKodtryZYQ0rabklWzajx3WSVR/nFvcqXsO2mHLRYYX2+
         OCFhyG31xDtaBH01sI+Rs/gAPXBwSKco88Nci/+37+kt8emuAp9fIm9VokGDm4wrxz5Z
         zDFFHr5xTiTF8R9lpNPpULl+CckuFuRo0L4Db2mFgIOJhGTKhTjwEYEU8OnXt9E+eahz
         On7A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUQwCJqKfIK2VW9mnjh2tbrG44mmPf8se1UrXDrYXXvjrihE7Rx
	v31TDk8F+bdYSQZHzkBViiWWCnPaQe+V71H872TfCqe3WsPqgXxjBflbpDSksKEVW0qdXOfZRg+
	LCCTxpSEb+mhafHAxmHjnFph/uikXqNplIn+NnxvQN/Qv7sQVtrFWjcTg4BLLEyw=
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr13667990edm.89.1565245741871;
        Wed, 07 Aug 2019 23:29:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF2uaeEPrwm3AbvmJYHgzOyOtuEKxeZNK+WVPrpE1r1AvKzsNsNReg051sx0pHDGy+pzxD
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr13667950edm.89.1565245741179;
        Wed, 07 Aug 2019 23:29:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245741; cv=none;
        d=google.com; s=arc-20160816;
        b=Jij1u8rHyMeL/LhOP8IKbehQbbeWCk4jVZJrAtB0FRHpCPzl8etBeyvP1Ls8A89TWF
         aZmxdIev9bgIckW/nScNgGzRUyPwX6zM5W5DbyMfJAf8tFkOybAGjHoOUdfk8g9G0VeE
         y0G7usFH5y7O38rDfi/3okakkzdQuLxMLxKHqxvU0O4ld/tp7yXfKoFqBeGP68GSw+Gb
         A0s4NGII8iKHiR3NW0jMhaZtlmw3KqFDlJdLVgCrb07nWMIBL7UBtUS51IYbWqZ/wbXf
         pk5/A2eRsAZg1qbbb9JC1ZyXA/VxiXUsMOYEqWw1cV1fo6ioi0EgE83mUX/n7+Oo/PuG
         EktQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CozSP8ClhxqYRnTVyauC5EuB32xQZZhYjVFYo6YFdyo=;
        b=uura6PTn8hW5fGJXX3m/v1rRDOZyUcFQHKjlGB9t4jpz0r8Lb12boArjNgrsKU5BJ3
         ioF/ap/fuRy8YF93EedxJUoMxIdRcCC98bLx4do9CTPyQd1/8Vtjdn/bnOqaDXrJ1C+K
         EMoZuNT+det6E40dN1yXty17EQuzqQ0wBxu0tnQ3VHUPVylyO8hrKw/IYNCitLZyw+/A
         XoRWRqoGL8C+qMWHrRugqf5i5t6JzY6rKKjAAT3ECFWQCWgstudUxgTOIL/8Pjx5xEcg
         s5+QMAbWlw5Xb4IFUaBUQfyzYk4oIwoABtzxgywJQrFcV58TteIb19yhiXYk3D32R1En
         g5kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id x7si34915645edm.177.2019.08.07.23.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:29:01 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id A498660009;
	Thu,  8 Aug 2019 06:28:56 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 10/14] mips: Use STACK_TOP when computing mmap base address
Date: Thu,  8 Aug 2019 02:17:52 -0400
Message-Id: <20190808061756.19712-11-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index f5c778113384..a7e84b2e71d7 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 #define COLOUR_ALIGN(addr, pgoff)				\
-- 
2.20.1

