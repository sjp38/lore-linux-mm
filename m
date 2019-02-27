Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CC67C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6F4D20C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6F4D20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 933718E0018; Wed, 27 Feb 2019 12:07:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3148E0001; Wed, 27 Feb 2019 12:07:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F6A68E0018; Wed, 27 Feb 2019 12:07:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2670C8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h37so5546118eda.7
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=89tEVK8Z5Z1WJ+pAu/rmRwRDTPZdRvQi0xHgmC99Gas=;
        b=GuKknRizsBpGZQAxvcP1b753pxwAvfCaDewqxty/zPoWl4te3U7xhdirjDWl92X7Bz
         3OOlh62GkL7wC7ocx+EIE14FR3rWvkPgFw+QnT8+oQzI78h00qDhCASllSOcMKJl/r/h
         eP8qaOzsMkPTRfj5kxD2F6lu9nIb+UDCQrT1VKXJFXUkbP70WnaLlDyKBdj+uhaP8ybI
         zkMgREvI78i6ksqWlxCqWiPSLQvrzyHsiGJoxDUtpRb3F2HWgwKi9YLiPU5fm+y5tXoU
         /oPxpAphnrVwFn3UOidyL1TBtbymbOW8fgwnfmR3HUbLSWDPH2S6MKWDCjucmZcyA+LB
         z8Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuasedUbZeRYYVIxkL4I7xtF1SmBe6hlfXuIbTRuQfkdImdvsPkn
	Ecs5pKQE/JvDREmRyg/xaS0zjk4nRvOklbgRI21Bwu4RSadMDOe0XN7A8Bxt7fq/Xaz2Eb7ziwF
	UVdmhyvz9dzG/f4Nc22wxhL9kM06bth9S1C9VsfTaC94cSyGDM6Bh3HBM6dqrIU750Q==
X-Received: by 2002:a50:aa83:: with SMTP id q3mr3138027edc.63.1551287271669;
        Wed, 27 Feb 2019 09:07:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ73FE0tp8rtpDqznYpSgCJx+g2mWgjvIwEya3HWej8FrqgCf70WoO6LAJ4IUI5fidmejbK
X-Received: by 2002:a50:aa83:: with SMTP id q3mr3137955edc.63.1551287270388;
        Wed, 27 Feb 2019 09:07:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287270; cv=none;
        d=google.com; s=arc-20160816;
        b=g7M0ZOz+PrX9IQRIlv9KZ05/KlaGIem4rSR9HXojWdS7QuQnTyMo9Da7Dq1mTTbq7L
         U/tB5yPhvHlGi/09L8iiEyS3X1Y5hOz2pHdjEPW2e+COUSJdbqZHA5zP+dyUV03h9m3M
         pRC8Zf5GTym/6lSCadd+YQBs/6XynAXHB2J86nFAvb8hDs4VaAiYKr+aUySXtYh55SAh
         hQck204blxPw1ig3oGUmZNZV/HQhbRhs2COYvCmXABLmqCSxYzn9DmdYDWXGpDWMPkyv
         TUAeh28fXj74jfT9Cdg8Xyg+EHZ54KpBM80pEl0K4K5v4dVjoQCoTjrcOhqfyNlue+re
         Mc2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=89tEVK8Z5Z1WJ+pAu/rmRwRDTPZdRvQi0xHgmC99Gas=;
        b=J0eQr3XfmMXSMG4MKq4DyzpMZOJEatgIBWSOFw3fGJgOaDRneJezCi3RvQaj4sgBxy
         IX1Z+F0r8461Z3Zcb+tbb2nGNJIpI65lnbllPkeCPtJmigq6betsgRQ3V152iQhSQhTo
         y9YYRLBrdmbZD6bdXLVhZnxSGhPemkEWDkT9Hu7Oy0cxCNYOSZfro8OWdUSp0D4M+Dx8
         4nDG1cts59zwJxgGCPc84hAqtkvipn9+ws4031KJHXi/8wvqk5kqdR3EvxQbNa/VuQKZ
         kpni8D9PcdUDCZYt7IJy00z1vVQLU7QRm+cA4PLn/hZGYm1gGdh1kLC0vkojrcnGmcYj
         kI2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v6si6499448edm.178.2019.02.27.09.07.50
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:50 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 810B91684;
	Wed, 27 Feb 2019 09:07:49 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ABB0C3F738;
	Wed, 27 Feb 2019 09:07:45 -0800 (PST)
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
	Jeff Dike <jdike@addtoit.com>,
	Richard Weinberger <richard@nod.at>,
	Anton Ivanov <anton.ivanov@cambridgegreys.com>,
	linux-um@lists.infradead.org
Subject: [PATCH v3 21/34] um: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:55 +0000
Message-Id: <20190227170608.27963-22-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For um, we don't support large pages, so add stubs returning 0.

CC: Jeff Dike <jdike@addtoit.com>
CC: Richard Weinberger <richard@nod.at>
CC: Anton Ivanov <anton.ivanov@cambridgegreys.com>
CC: linux-um@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/um/include/asm/pgtable-3level.h | 1 +
 arch/um/include/asm/pgtable.h        | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index c4d876dfb9ac..2abf9aa5808e 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -57,6 +57,7 @@
 #define pud_none(x)	(!(pud_val(x) & ~_PAGE_NEWPAGE))
 #define	pud_bad(x)	((pud_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
 #define pud_present(x)	(pud_val(x) & _PAGE_PRESENT)
+#define pud_large(x)	(0)
 #define pud_populate(mm, pud, pmd) \
 	set_pud(pud, __pud(_PAGE_TABLE + __pa(pmd)))
 
diff --git a/arch/um/include/asm/pgtable.h b/arch/um/include/asm/pgtable.h
index 9c04562310b3..d5fa4e118dcc 100644
--- a/arch/um/include/asm/pgtable.h
+++ b/arch/um/include/asm/pgtable.h
@@ -100,6 +100,7 @@ extern unsigned long end_iomem;
 #define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
 
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
+#define pmd_large(x)	(0)
 #define pmd_clear(xp)	do { pmd_val(*(xp)) = _PAGE_NEWPAGE; } while (0)
 
 #define pmd_newpage(x)  (pmd_val(x) & _PAGE_NEWPAGE)
-- 
2.20.1

