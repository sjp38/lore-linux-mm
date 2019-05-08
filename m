Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CBDFC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEEE62182B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEEE62182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47D156B0008; Wed,  8 May 2019 10:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1486B0005; Wed,  8 May 2019 10:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB6C26B0008; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B35986B000A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x13so12797339pgl.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=49lJbfvv15ZcHha4FIriTS/Z7arlGEdmOhAM+djd50M=;
        b=Dt/84YcFyVtOoJXDOk0sv2i7pg5FuhGi71Y/QZw3enasL31USjksQ3gQNqizGp7pst
         xdiZchzCxwCcwtkDfR4Tk9Nw3aQTpePDU1qDdoIpDzgcvUY/Ic4bwFkzJH+PudlQaPXE
         uPUdB+jAz44owjUEyL87jc8Q8G3BsH4L5iZZt1ABKHG4uifh45k70QieUXLb89w8jev+
         PSWbTY2NF8XysR4iTZRTSxXepQUWMVQFMRzQNMZgud4VBSgByx0eVC7Kem68knbSSBEi
         Ys4DJzwmdOeAjdfV0YHf57ahPPlGRm1ivW6WAparWOYG0WXcx1NGog23W9z0sKIGQr7L
         P0aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV8/6XoUNYzkBTlbLpvtvR0kIGcJxO42iyM7eAWQ1rYnOivOUOt
	6R5mYhAgfAZ6UFevNM5RcUt/1flWONw5fmQIBwGWhrhJN9cyUdtjRdKRuohiSkiFAOxBS3Evb7z
	D616/rF3AAjkQpMfO8JDYnMC/kOnnv8tS68pnsX4e7Q9jtxSAystNAH/ogYxaF8ECWg==
X-Received: by 2002:a17:902:b095:: with SMTP id p21mr47788112plr.40.1557326676351;
        Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXfqi2Kf9k4PjgORT6rQ97Lrz6DlFWWxwG4nGzHyNbm8L1sTWTn4zikc8yOQZUEXkyvU0t
X-Received: by 2002:a17:902:b095:: with SMTP id p21mr47787950plr.40.1557326674860;
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326674; cv=none;
        d=google.com; s=arc-20160816;
        b=YpEPQgCeJ2iSe3htfWkz7+VLZd52oNLGWxXAa9Gt9+28TmdNwtrZAxgLiIb29IsPLh
         x3Nd5tbh/KeQZedJsKPUtvURV0Scz+bjC2yZ8bO8K7R3o/PICM6M/toQHQb2LNJXAxQD
         yX0FpSTIqcZPTogBD1RPJQboo270MBFeNCN1B1U6SEdYh/Fcb7FlDH8m6fhcYFf0w3Uj
         t9QSm1a4dzqWMERJFL+LGrjsfuCRceX5xAI7DJuhwlC2DB3igtFl0DncsPBJ3bNIsa3z
         cfwniFAGwbOPHnh0OAghSV8DU3ggq8fQghjZWcoBIKIUQgpRpBywYjsD3+93JcXZRDrH
         TdJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=49lJbfvv15ZcHha4FIriTS/Z7arlGEdmOhAM+djd50M=;
        b=NCrKne+Knr+NyM1vEbZNMeFppCUuDiePsevDyZNXkrVNhiwh0GhIHTIW4JRVG4V9rP
         Yz85UO5wYZOvlKRXvZFxtq7YzL6kWw9pUilP5hYrAoHwoKKF8HdxXViOy7biw9cme5on
         a2Lks3YieuK0EcnzaCtLq4rm5zUzg6+riK8KRKVNZFNVMZ0qaSp/8JmW/udPsixZNQOD
         gwnYVG01A5kK+SnvXMq/8DqT1QLfcl0SuuFqY7RnNW/Ffkc+Mn4ApBZvNbfaDCkLHwDY
         w+oqa/c6dapS1LHMtKjURTGMpG43wd6CM+5Z/ChyIvoBeh4ebW6/PyT9w/7mFA4/GZu8
         Id7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w14si24148884ply.226.2019.05.08.07.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:34 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga004.jf.intel.com with ESMTP; 08 May 2019 07:44:29 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id C283D3D1; Wed,  8 May 2019 17:44:28 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
Subject: [PATCH, RFC 04/62] mm/page_alloc: Unify alloc_hugepage_vma()
Date: Wed,  8 May 2019 17:43:24 +0300
Message-Id: <20190508144422.13171-5-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
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
index fdab7de7490d..b101aa294157 100644
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
2.20.1

