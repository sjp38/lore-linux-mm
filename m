Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D842BC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4BE520815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:51:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4BE520815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 528826B0003; Sun, 26 May 2019 09:51:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B2B96B0005; Sun, 26 May 2019 09:51:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32BBC6B0007; Sun, 26 May 2019 09:51:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7D6E6B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:51:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so23301560edg.8
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:51:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VLvm0D1nmVy1ERihwkodjsjVqa9oiCwNeZg629ShJFQ=;
        b=oBu3mQWRwV3tYgCqzWXtb05PZNmjfvwuyhGvV+nQMQH917r24Fd5SBmPnSxNErOO4z
         6Pv6EdgxD76vtT/WBX4JfUP7BIyOrkKt5zVdGO/+NsqAA25RX+Aff9Q2elFTE8Wgoo1S
         fv2ZvZN1Cn3OhBWq3R+s8L97xnOm27FKEgjGhi7mudJvPfW3Ba8yPQFreMp/qn+w1qUy
         CrDrw5GTEpDCuAmZBGgCjP8TB5EScgIa6+RMnVf5rFekxnEEo1dJutAGRIaC6Eu/OD+V
         icjsESL6u8tFdC7bIozZqMeTFNQiHS+BFWf2rBacD9tLBtTgxiQ4+ZRel7gW8rKrF0mi
         b8BA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUZqUjtOEahfmDy+EOLQUZXEd0xY3XET3JxT0+iAgpdTPVXIFsl
	wEF4vIBiWpWDxHbOKKv2ZrJ5R9EsdDpu+76ok8N4rnLyAkpC79QHLyoRlP2bM/ctiKKL16eS6+P
	UVK0AHVhBAt+w1OpuMSP9a1ymaocDYLEE0Vxa17BnpkMesjDYaZCbcMzy0nxzK9A=
X-Received: by 2002:a50:893d:: with SMTP id e58mr112981017ede.244.1558878690393;
        Sun, 26 May 2019 06:51:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtxq8crbF51jOUOwNCUzwtcbjoQBF7wRSPZH1ibmZ0g7fEOIqrdYOKh33fUpxADdncZxZT
X-Received: by 2002:a50:893d:: with SMTP id e58mr112980963ede.244.1558878689493;
        Sun, 26 May 2019 06:51:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878689; cv=none;
        d=google.com; s=arc-20160816;
        b=I7kbKHpeDF7f9vftc0VjRhGXzQCWyQwPcucsELMckzxK8hbt53fpMGURQGJxeVhK0x
         apJnedEfL5lTZW8BBlus4tkqe3/R82OWixCmdFf+FPv0GMPTGSCmfJhjLTaDjOKX5sNl
         vxPGYqye/VE1Iug8uW3MQUJmS2n+soE3ACfUQlcrINo5PUq8/+MuDeTFLBuGYb4VRlnQ
         jAIOpJGfQuJ7NcTw8C4xy4NS6246c2/Cqx3U/OhoetQKq/FaK5vfW/ZMA2iuUYTSobb0
         3mVMb+5D5HOvWcjbvL0gmRhfK22rA+1ocWQ7lsuMu9eyS+y9CHfk18n3kEzLlZxThWHL
         g5Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VLvm0D1nmVy1ERihwkodjsjVqa9oiCwNeZg629ShJFQ=;
        b=WPjhhHtbQ9ZbpwKbhkwuZ6CZGLI5QH8C+kt1AFAGtFdB2RdBs8jApe2akRVS7Ln3pO
         ExWuz5FO7411pynxCqFIB9cySWv4ofLqfG+GAAp9YASc6EHTd//5xPekLM/qqQ6G7lhU
         DGGYlDMkdep/wzmVIuX3ykWW3QxES/WSN5WIIfcngi+uRJXj4WuCvIXw3MGpjw12fuHC
         hhd+4F0B0Yx0IZZ6rDZXMU5n0KzbxJjRqCL6V5vxeVPvGZ+gG83iOhTvVez+oGqc6KZw
         RmmOcgmt1cl6x8RZRVDwZtSl3DObYQddJJccIDN4+5uPOq/Ja+XlIDkEHOlVdgb/VzvB
         tpwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id 25si6722409edz.155.2019.05.26.06.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:51:29 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 56DEF1C000B;
	Sun, 26 May 2019 13:51:24 +0000 (UTC)
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
Subject: [PATCH v4 03/14] arm64: Consider stack randomization for mmap base only when necessary
Date: Sun, 26 May 2019 09:47:35 -0400
Message-Id: <20190526134746.9315-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not offset mmap base address because of stack randomization if
current task does not want randomization.
Note that x86 already implements this behaviour.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/mmap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index ed4f9915f2b8..ac89686c4af8 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -65,7 +65,11 @@ unsigned long arch_mmap_rnd(void)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
 
 	/* Values close to RLIM_INFINITY can overflow. */
 	if (gap + pad > gap)
-- 
2.20.1

