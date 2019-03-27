Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3749BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:37:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF522075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:37:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF522075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7828B6B0007; Wed, 27 Mar 2019 02:37:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 730F66B0008; Wed, 27 Mar 2019 02:37:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 648666B000A; Wed, 27 Mar 2019 02:37:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14BAE6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:37:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so4957328eda.10
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:37:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=saGsHe6SWwI7F1B+QUTepsxEqhSUvjCT04AuLnSKvBw=;
        b=UBcVCMSSi3HPQaAIKmtsmw50Bpff+950VaDgeWPG3YPB7HiO6/V1FDBV59X9AkV3vh
         fHz5V+xDaFepqNdSwTCcGXev0ViCbrtRv7bhv7FI8179DPj6ZjkB4tta+nFCabEggbWV
         bA/ieOzBoXwpPe6iaXH02VZI0sghiR3qqhkILrPEG8jhQ4c3abE7e+ugV8Tn4gB1CfaK
         cOX+UUTZgaFkksVajxjVgcXzpfm7Adfa05k++fYyhWcMphZcRqMBJ5ac4t5t+sJANb8w
         EX+eenR8b/8XuDsBLQp4P2bALPWsXL7MFJVAaIENmIVu2L/GnvmYk1f2fJTErqQO6nh/
         vkMA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXzO4ykeZXt4hN6LK4uePPPl4dlm9rYweMwD41hxlhaLGyuejvm
	f1pmFhLiIYHk/NxdxrRybdna76Mv2XG/DGMfREqLyWSWm0tFLnuBLNRKjTVEPQIVlKdoPFdVW1/
	pqONtJqzMxrp1tmgJ1gd5Had+S/Z7VohFLwRx+UVwzzNAOJGWm8UTGBXQZ0N9pn8=
X-Received: by 2002:a17:906:1ed7:: with SMTP id m23mr10621023ejj.198.1553668674518;
        Tue, 26 Mar 2019 23:37:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUmRXkdy4h1cziDZbLcDiMLhcTaWuAV8L9Za1gSdk+IKrCNiowLljJ09IgzdrYwBjHCZx8
X-Received: by 2002:a17:906:1ed7:: with SMTP id m23mr10620984ejj.198.1553668673635;
        Tue, 26 Mar 2019 23:37:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553668673; cv=none;
        d=google.com; s=arc-20160816;
        b=b1n8kbebU2arDeUc/xB6iOOPuGuUCfkjvlgcLFXN3ytJhQ6YAKqV+nFlv0MmmgLpVL
         lCHUZ5lRSDm/mTZ6M+1gMS0WYyJdlIEin6Uax8wl6c6qeJFrN3mJgLJi9OoDNpRWhAvi
         7azscqIco+kcfBMP+z6nXb3S+8dVeArqbYyqVJRu1Gh70/ZW4ohsMJTkCsIpJ7XkzTon
         m5pdzhfsIvz5q5w+U5DNv4xDejnwlcKnw24PzYq2LKs/utV27Y1hFCAqenAG4nJvvZbd
         UPH3iY+2IlGo7nDHwZ2N4MrMa/HNObueP3ryLjfG4oEQsjmF3y8afr8v6ydVfthI1Akp
         5r5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=saGsHe6SWwI7F1B+QUTepsxEqhSUvjCT04AuLnSKvBw=;
        b=fkZHyZdZr1bVUHxK4F02256kLRyy/bio+AHyqow8s+Kh7sMhBR/+pg9lZhXOsZdm9Y
         oT5DqhKKA2NukQJpQyaxqpG7AWYyPUeeaSexK/1xY8DHcRk+f50z8ET51J/CTNpVNYJs
         3neQSIeDASK5jDvQ2NcGjtsW8oLFkLATBSBwrlQklIy2r4uSv2Bso2av/bTD12CuwZ4e
         3QGIh5JONMoXbZ49FF5eOwYWmDHh+jE+6jjyyRKGuOIYykcB62KFp55Od4XshiK5napl
         CgQBIjWPihZdK8tuseXeE/UzdeWjaQwp6ldl/XuV0HOUskmRk3syp8dM1zfEKhThpXar
         xkHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id k16si4305219ejp.159.2019.03.26.23.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 23:37:53 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 53C3120004;
	Wed, 27 Mar 2019 06:37:39 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v8 1/4] sh: Advertise gigantic page support
Date: Wed, 27 Mar 2019 02:36:23 -0400
Message-Id: <20190327063626.18421-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190327063626.18421-1-alex@ghiti.fr>
References: <20190327063626.18421-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sh actually supports gigantic pages and selecting
ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
gigantic pages at runtime.

At least sdk7786_defconfig exposes such a configuration with
huge pages of 64MB, pages of 4KB and MAX_ORDER = 11:
HPAGE_SHIFT (26) - PAGE_SHIFT (12) = 14 >= MAX_ORDER (11)

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/sh/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index b1c91ea9a958..0d9fb2468e0b 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,6 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
-- 
2.20.1

