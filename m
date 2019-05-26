Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 117B1C46460
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7E5B2075E
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:00:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7E5B2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9286B0003; Sun, 26 May 2019 10:00:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7435C6B0005; Sun, 26 May 2019 10:00:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4FA6B0007; Sun, 26 May 2019 10:00:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 074166B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 10:00:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so23344443edm.7
        for <linux-mm@kvack.org>; Sun, 26 May 2019 07:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B1xCAfwoo2VsupRz9LufscYM0z2KLMPO+UsoTLhSc0Y=;
        b=OKTCUCanGaxAbTa8vfMpdDl0erG7v98bgcw/KudUlw9U2tk234Jxg0kH3TJVMSvgyn
         3zFkdo1gJdCqFz+bc+lBu0f7AWGKBuqN8bBWVEeKO+xmFsIodEBmmX0lpzMsVHO6NCDN
         O7gg2QV29sRHoMMqx8tZf7jjGyXU4xQ5WATuCXnpSfaDqi7fMZ4V17UTfxwtX7Qa1BUE
         uxp+NMiPwRfA5uapL9nhJfuR9rM+bau4BlZbA6coZvOnkVUVYWnWKJuzv0e6+ouzdhzM
         cURc/0mKfq0NHzu8+RAiSoewgnx+8goE9j0jc6YwraN+0Vg2GNO2SD/VY1gm254fwMIi
         PwFQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV7gz2ygRMueSdbNgzcGkWJwQW95sbC/9YVK0b0NTmhCGFMj4gq
	T5xNAUf2UHKGnFd904ZP+eIucwsik4+Q5WiXE68zj5aHkW9NTDKJ/kX0jUZlwdl2NxehRzPc+nr
	BfJqN8i3xOoqvAKQPNnSMJqDhXrMdY+O7YbZ9XVxekf6SEQU0tVR/dXu3pRMhqZU=
X-Received: by 2002:a17:906:f112:: with SMTP id gv18mr9676295ejb.308.1558879221527;
        Sun, 26 May 2019 07:00:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt2SxknWjOgi6bDSPCzmDv2JolZnVTrIrvVudDkivx3pZwR2tA0P+yAFRpvNdU27QV4/LQ
X-Received: by 2002:a17:906:f112:: with SMTP id gv18mr9676211ejb.308.1558879220534;
        Sun, 26 May 2019 07:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879220; cv=none;
        d=google.com; s=arc-20160816;
        b=YqSBE9gn2hhRSFWOg8OCMboqDil0eq/XmRdmSEJTEAanqh9PlE4lNL4PD1nkE4+142
         evHG51W79IF+UKbtQbTluzIO4SmhVA+gxSiJl1A95CdvN46nZ853ZHc9B6smlYovi18r
         rUs2rEZ89eMfHswGzE1ZVlapSgeh+eLwu4QE92sO2/yz0xiWwga+xtQ8DcAoU1HFUsi5
         2ZDNWgsOedUhfiU9/B9b0+kSExTchYDcTd6To+OJ+GCNovWL1T/ZfjFxH6jkZOYuak2k
         xJog1q7xQp682KEtUC5Wp9gEjMOg5Pdu/jpM6p5U50lN4LzQSdZNiRZ8T54odc/U9w56
         9oDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=B1xCAfwoo2VsupRz9LufscYM0z2KLMPO+UsoTLhSc0Y=;
        b=ibhmOBXP5bk9826z47eUR2YSVWc8ItAFffyRLXw5PXKge8cnWneY0lDdzNcZUw24u6
         7Zn8NWcQ1w4AGgIyl8dpSQpFCfzHC9xQeFwypXTtqk5dZdvMqRUHzVcJameIlYn/KKqt
         si7G1Do1NwL4ljYjK66+QKFjVIHduSe4yIjfMXQtNCZHk42n+PGzK8lpXhPQWff2ppct
         1RQ6PQhA3jb3QmX9MOaX0rPTOF+ZUmpUunJKqsUr9ezQ9/1UtKzlpVVXlUlbo/BCtmJ1
         IooiBV7WyhSarxYrqhlFmQ2PDkutI1NrWQHV2fnV8TcydGguMHROfFTwMN+gsxQITQ0G
         PEAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id t22si897694ejj.240.2019.05.26.07.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 07:00:20 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 1A2206000A;
	Sun, 26 May 2019 14:00:15 +0000 (UTC)
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
Subject: [PATCH v4 11/14] mips: Adjust brk randomization offset to fit generic version
Date: Sun, 26 May 2019 09:47:43 -0400
Message-Id: <20190526134746.9315-12-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit simply bumps up to 32MB and 1GB the random offset
of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.

Suggested-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/mips/mm/mmap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index ffbe69f3a7d9..c052565b76fb 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -16,6 +16,7 @@
 #include <linux/random.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
+#include <linux/sizes.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
@@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
 	unsigned long rnd = get_random_long();
 
 	rnd = rnd << PAGE_SHIFT;
-	/* 8MB for 32bit, 256MB for 64bit */
+	/* 32MB for 32bit, 1GB for 64bit */
 	if (TASK_IS_32BIT_ADDR)
-		rnd = rnd & 0x7ffffful;
+		rnd = rnd & SZ_32M;
 	else
-		rnd = rnd & 0xffffffful;
+		rnd = rnd & SZ_1G;
 
 	return rnd;
 }
-- 
2.20.1

