Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51DC9C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EFF120872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:29:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EFF120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1C9E6B0008; Wed, 17 Apr 2019 01:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF22D6B0266; Wed, 17 Apr 2019 01:29:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A09A26B0269; Wed, 17 Apr 2019 01:29:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 515CA6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:29:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y7so11976247eds.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:29:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qLIfa0rcn3uuBSuGdyQd2indykfbUvCgupWpuxIE69U=;
        b=r6ZL0rJwAkv/6sqNvjoNBtvgGMhHHeXC2+bt0faUWc7MyQkK87SL0qn6PyLyJnmb+x
         euyINaI/cS14MlZVO2jxp4Njt1RMu1R7/LQSZU4+XuaQe7EQXOVUc7B4jBHfc79t8aJp
         feDr9N/zl7/CN0U7tv6i+FjyxqVDwSw/UbP/Git6W9G8w6wdFvZQ3OXg4zrVds0tjLif
         UNx4eY2ObwJQNnjJIrHL7OxPyJ8TSV4yMIGnx1NrsYp7HCjP8I9DjHzarFk9jsOTvdDL
         My0tuGwUpWZmcerMNrZimeyidzoYRde01VvKb1jlCf0kwcxO+09IMKqNB8pYoCpvld6i
         1thQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAX+mkXd8fpfApPg98i7DSTZ2+o8NSY7L2C+SnS6aOoRLGXKsNvt
	caFNVz7z1qS+r9CY50xB20bwDikPGBdo8K1LsK7xaXPXMeHaT8juwDLUPJE3RYNimaUL0H8WOoE
	pek+vyO7/oVnNOgNoHX9PhMQxASkYd+kcwK3GCYO06+KEIWDvwTbJNbtoF0j5omM=
X-Received: by 2002:a17:906:b756:: with SMTP id fx22mr39746624ejb.192.1555478969850;
        Tue, 16 Apr 2019 22:29:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGqhVpboCJfqfJfIDYs5iB7GfqYlmKgbWcLMrWw2N7ryAXJqLErb8DoAJxoAxPFu+XKjQK
X-Received: by 2002:a17:906:b756:: with SMTP id fx22mr39746585ejb.192.1555478968722;
        Tue, 16 Apr 2019 22:29:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478968; cv=none;
        d=google.com; s=arc-20160816;
        b=v/YrMrd0IF5x9YAY9rv83Ko0hLkAefsr7PYX3+fLz4b1NPK+Tx8rkmeGkkxhfW8aWU
         GGqJxlBa8EbNoJag54tM+FoQpoAIfiYOMso9KXs3oSiZxNe7EIBBhqZ2N2H9enosJdDh
         v+VhxzC1CpntOIjzddWApJGMCfuHh5aqsJ/szj7OxL3fNal8FctmqX7y0wEymXfF/S4Q
         0EZTO8sQCn4nJa2SJJwigrHQvfUmPtiNbkOoY5XfHx+tPRswN17uLKqqzR7nNgnWZXup
         OIxmEwPEClaiR/YAb5tfhGT5oz5vO0zwVBm4HmywhBpa+Qd/SrZI6iMNhONNN/GEDJnm
         rDng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qLIfa0rcn3uuBSuGdyQd2indykfbUvCgupWpuxIE69U=;
        b=FdGCxJICe/vk2D9Ow4dcmumum92ko+pxYM5rVR8Zoc2FPZt7gC5m/v+S5LQ8V9kQZ/
         ZyNofQQrjLuqXGfmLutbOlDKZ3sGduaL6Zgolymaws2ceR+UPp0bHok39WXA7WMdvrvH
         xcY18wSWFbBvQZK1MVg8KxAX6Ojhfnm95NqDSgW1/WE+UaHCnEa2drOWom6aZtTNsaOQ
         mkDhUGOP0FvTW6OYf339z/vZZFnnTg8hRvK5V2aXYmboN1o+1GDpSNaMU7QHTRIT4kLx
         N/ct1BH20YcScKjyvbsn370zDm1Irz9Yq0+Elz8kVbom3qoGD8oDxox29ZhxtWi0Cgaf
         RZ1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id os14si3342628ejb.155.2019.04.16.22.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:29:28 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id AAD82240004;
	Wed, 17 Apr 2019 05:29:24 +0000 (UTC)
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
Subject: [PATCH v3 06/11] arm: Use STACK_TOP when computing mmap base address
Date: Wed, 17 Apr 2019 01:22:42 -0400
Message-Id: <20190417052247.17809-7-alex@ghiti.fr>
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

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index bff3d00bda5b..0b94b674aa91 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -19,7 +19,7 @@
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 /*
-- 
2.20.1

