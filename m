Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0136C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 781B020C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="uapI7QfQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 781B020C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71C288E0008; Wed, 31 Jul 2019 11:08:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9658E0001; Wed, 31 Jul 2019 11:08:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F8548E0008; Wed, 31 Jul 2019 11:08:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 036508E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c31so42646712ede.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=884ZxbzpLr443iBBzOV7VNSITHGDDguNP5NA41SiPjs=;
        b=lzftaOGd7My9VFnlPNzyc0WzPZBWTelHVut7MnKV5f2bdaP1E6LpjoVGkNxk3GSwPt
         pCJZ5archPa8Yrw8Og7R77ebkLo/wiVDUmUPbc6XV2/XIKakyuoZTXZKZtl0h40p6hlE
         PEx542b6SYdH8UAoXhtzt7ue481CT1U3cDCv40BRprHZ1aqvovfGCfoEjj5CJUYhniPI
         LQLOk1LWS6NGKz3tQrGcU7tj8pKWGKJBvxZNwgcZzF0qtWuap5aPnWLNohU1hk752pRX
         kTlyssrGwstyPuaxYbyhWFEENdSTOGIJS7uC28o1ZayKYD26yzJlBB7/9ZEesB0B4nEi
         2btg==
X-Gm-Message-State: APjAAAWxxqHHnBks6FYyXLUDtziLfWeDP0LQxUIkTWX9EvWjlwNXVPZV
	GD8zkNPphCiD3bjGxM4GceZ6HeKUYDn3tcAdO9MoWJO75DBMPMyhTWbWO895ShSb/4SvsPPVHBg
	tFV4y2rvmu8ozsdU+RX8j9/cvTIHjqJfY/m/W61qkiWehJhbdM4bd87/GT+cHgYg=
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr94575545ejz.270.1564585699537;
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr94575426ejz.270.1564585698323;
        Wed, 31 Jul 2019 08:08:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585698; cv=none;
        d=google.com; s=arc-20160816;
        b=dOfnBF8VIWhI3EUg7ph38RA8S7jOCz8X2iutzy+H7ssFDZ0+3A9wKkdn9y1kzvOdrq
         B5q8yCCNvkLL+h7vV5MHEvJS+8IhAopWzVIFSiYyDSZAVjhJgO2AkyRj4Cb1pDjoMsHU
         LmWnhObAM0r09anxEOgyAAYlzF3COF/eHNAyn20CFe+brGdAjfaTf8NJUKlxMn+TkiZd
         TaGTio8uS93FSOTiJL4SZ2lom/kBuGPcSnvKeWCPPlK7aBvp9nVC768X+MsmfgIYQX/t
         QEKS2sI8Qh1Go+4kXhE3kiKuQ6yQStMb3X8Xngm9AhTig/UOQXD6aDm3V9lu/W0hwjxF
         Z8fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=884ZxbzpLr443iBBzOV7VNSITHGDDguNP5NA41SiPjs=;
        b=HhcbeK5aQUu0D8wG4Zj3C14QxV/jXx58Mhtjb06rv+XK4Sghp6+Vq3jsASQcCyynLo
         FXdIOrYpjMXdKUCfePXLLlSyeiBypcB6uj6AC9PR9qtGDWuU2xoI2n1p+Q8rBXDbekbO
         cp9v6n89v4fhsfOUxC4DSWlHv4x1zDnnGB0wn9cXffDM3YXJgHzrS5/cPtWqt2NbA7vb
         MR8NB3wZve/LKJKsCd1KiWaYkkhm8qS46qeL19QPDV50sjx+H8eFBN0a5uSzQg9SrcEp
         +CEjpt8EaYmqmeRvEhMNEbqBWtJIPvHxalbHZ59MbyJEs4FHisvdPSVLUcF0AZ4jc+v8
         uVBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uapI7QfQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor52037290edv.14.2019.07.31.08.08.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uapI7QfQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=884ZxbzpLr443iBBzOV7VNSITHGDDguNP5NA41SiPjs=;
        b=uapI7QfQSFWrfufVSM7HiFX646OQeLiAul30+HPzHGLTEAyE1mlyQ4cfs8/lAJGW3W
         Tt7zm3MH7qjRyENcy8PkWhrnxtdtI8iaTGgI0/PL1v/DggmhR6NhObJkOFT00YyzaOrj
         Take1nVpfJ2NoPUc7KjzORoYT7UbY7JlN5HKiuzokOrb0OjCCFMEeDyXY9EOjEuhNnPf
         T/XVysxTCW8DaKpzjRLUEONeAMippaQbGF+ajea1j5fV5uemWPA4VqQFGgccNvC53hLa
         leX/D6UzbHLOHMfJMnrjKWDFygclW04/fSZvcc53kO9nqx0C1i5cnaESX8bXsXcjoUoD
         JtDg==
X-Google-Smtp-Source: APXvYqzJuBbLlWsZbHVSwq33uygKwm+4dMWF6225mCqR1QI8GR+My+vRb8mmhCMTG8y6ZThSvSiS7A==
X-Received: by 2002:aa7:da14:: with SMTP id r20mr107153958eds.65.1564585698000;
        Wed, 31 Jul 2019 08:08:18 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id by12sm12375107ejb.37.2019.07.31.08.08.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 0B25210131B; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 04/59] mm/page_alloc: Unify alloc_hugepage_vma()
Date: Wed, 31 Jul 2019 18:07:18 +0300
Message-Id: <20190731150813.26289-5-kirill.shutemov@linux.intel.com>
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

We don't need to have separate implementations of alloc_hugepage_vma()
for NUMA and non-NUMA. Using variant based on alloc_pages_vma() we would
cover both cases.

This is preparation patch for allocation encrypted pages.

alloc_pages_vma() will handle allocation of encrypted pages. With this
change we don' t need to cover alloc_hugepage_vma() separately.

The change makes typo in Alpha's implementation of
__alloc_zeroed_user_highpage() visible. Fix it too.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/alpha/include/asm/page.h | 2 +-
 include/linux/gfp.h           | 6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/alpha/include/asm/page.h b/arch/alpha/include/asm/page.h
index f3fb2848470a..9a6fbb5269f3 100644
--- a/arch/alpha/include/asm/page.h
+++ b/arch/alpha/include/asm/page.h
@@ -18,7 +18,7 @@ extern void clear_page(void *page);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 
 #define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
-	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vmaddr)
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 extern void copy_page(void * _to, void * _from);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b503dc45..3d4cb9fea417 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -511,21 +511,19 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
 	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
-	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
-- 
2.21.0

