Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91204C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 493412064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="BHAeXd7g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 493412064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374098E0015; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FF728E0013; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 178FF8E0018; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5A898E0013
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so42606570eda.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JEZNWwFcWS55jw+6SIN48eCAvZTaxQLDv71jatzDjOE=;
        b=II7PWekQWL3OKBC62Wy0DOyq3B3kOancNt6A6h2k76fwVPlLM3rmd4OJ8xTZk74djx
         KwNss+RvAmFKbBVPYEmOG3r2or6NaRVaGg+782/t9VR6+4WmI70zT+L3jJVvS/M4auZD
         PRJds+sj90WDii+NLJNkbOrqpa6GfCy/opQkMR7AundayzYzfEicftaXws4SmKrtnzjK
         oFtBF0T7sPbO62mGL82wqDqu9GCEv7yj05PdH+vVbO0j0+HMCNn//eOoJyfGBHp3v1Po
         sVlsm0hboWJ2Ir8GTUnxNwrRvySW21S9o6khyNX39kjVCdLPi4c9TUyyJWLzNTHP3QAf
         +zuA==
X-Gm-Message-State: APjAAAWT0PM9Cv7kUclBi0Kro/NMUomRzclSZxgZJISD52JjjYdjlWjm
	aejp68gGm9s86G06ALWeCw2Yfg2QPK4TLJ9dk3SxP0bmE5fFx1uh4zC1VreOuAmh30tpFrNu53k
	LZ8OGte6eqECK8XMuhkmyVWYYKI8FHAPwKm/03zO0Ykpl0bk0mIxbjvUaQHZ/WG8=
X-Received: by 2002:a50:b343:: with SMTP id r3mr104743404edd.16.1564585708378;
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
X-Received: by 2002:a50:b343:: with SMTP id r3mr104743054edd.16.1564585705106;
        Wed, 31 Jul 2019 08:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585705; cv=none;
        d=google.com; s=arc-20160816;
        b=R3C6CVDkbTBxU+yQjsHGvRDs/AGiSVoQixPjTd6Ngwl10YmPuPsMlYFtAfr6r1QXuE
         ZxqPNmAsUWqEhvWsmNjHzqWS8Z2x06rl4y5CNvLKmA7PKwoP/zeYDE8hzN+loTI/0ps/
         FUm4fx54xqBecaMnaKQrID7tMUhdYrma/yF7KKRpZfmkHrpW0uglt7TtONUXo2AAvybk
         jUE1yI8Q8pMSjRfxuVzJ/Yc0oCPZwYDCeXfx0tIP3qHS9cJCrrIMUzQueLAwqHH46t3f
         oe1K/6Ya0ld4dP5zYBaiFg6l/eDgVjVxXG3YZs4dD3lL7qA9zJKW/q/KjVoAhOFfmiuy
         OrFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JEZNWwFcWS55jw+6SIN48eCAvZTaxQLDv71jatzDjOE=;
        b=oytFYyRoztV4I926Vl5q8mr1asyajNmrRC2KrE6jSlh0ZnQ2GpkmuOwb5G+DgsC2jN
         H+9a5st30FEDoV9csoRfms59GCJKrrXiQgtsKaGNZhfimT5ayYxP6opEMTXJqTQJFrQb
         xXpTTpMVQ84szmJQuvyeHwLpmLpjV73bD83+d2Bv5lHADw2TeTVq6SN7/VwQY/Um8p60
         DlB2FZ9KvLlALwviVCxtBGGMkLpBW8MrafkANnn7oNrcKrYXg+foWs9HSsInmC/cMLBV
         hn+n1TLnoE10hK7Dy/YLQwc7+F3Gzv6oRVg2qvbNjR6NF41pBrUmGBZ+zQqZOMbqbES2
         uCiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BHAeXd7g;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g25sor52126592edc.19.2019.07.31.08.08.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:25 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BHAeXd7g;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JEZNWwFcWS55jw+6SIN48eCAvZTaxQLDv71jatzDjOE=;
        b=BHAeXd7gVXgBxYu3UUq38JWfB9LxZIY8nRNcqLidTcyniNbN1kGL7m8gr0DYCgHyfo
         bYCkEUg7twHqYl9//YYyF3oRucuIzp6d8krWu5AXZuwBtWBWqFWBt/UfnX3pxSNussqT
         vPwPX9shBW0HElOKWXJF5lb9bZsc1LRrg5iG4cMsZyUylv9NMvgzxJC+ak2MqH41uDGx
         kDLz4WiHVp5dMULHZ0AJck/7y17op+S1LY4RIr4iUP8aw3l+KaMe13SwSVOBLq30rQZD
         RxmVZou3sCnH16cwB+iAELC3TlHF1bUMdJfNLvVlBfrQL9P/s9szyRTBQ5Oj+oYcjPpJ
         mDPQ==
X-Google-Smtp-Source: APXvYqwrlyk+jtOIzcQNAVf6976bJtJVVuXE4BPNEUU4FrC1EBQZ1KrsVfR+sDVvD7XGNJvKjIp/UA==
X-Received: by 2002:a05:6402:1212:: with SMTP id c18mr108401816edw.7.1564585704701;
        Wed, 31 Jul 2019 08:08:24 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id w14sm17419509eda.69.2019.07.31.08.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 48F28101324; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 13/59] x86/mm: Add a helper to retrieve KeyID for a VMA
Date: Wed, 31 Jul 2019 18:07:27 +0300
Message-Id: <20190731150813.26289-14-kirill.shutemov@linux.intel.com>
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

We store KeyID in upper bits for vm_page_prot that match position of
KeyID in PTE. vma_keyid() extracts KeyID from vm_page_prot.

With KeyID in vm_page_prot we don't need to modify any page table helper
to propagate the KeyID to page table entires.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 12 ++++++++++++
 arch/x86/mm/mktme.c          |  7 +++++++
 2 files changed, 19 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 46041075f617..52b115b30a42 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -5,6 +5,8 @@
 #include <linux/page_ext.h>
 #include <linux/jump_label.h>
 
+struct vm_area_struct;
+
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t __mktme_keyid_mask;
 extern phys_addr_t mktme_keyid_mask(void);
@@ -31,6 +33,16 @@ static inline int page_keyid(const struct page *page)
 	return lookup_page_ext(page)->keyid;
 }
 
+#define vma_keyid vma_keyid
+int __vma_keyid(struct vm_area_struct *vma);
+static inline int vma_keyid(struct vm_area_struct *vma)
+{
+	if (!mktme_enabled())
+		return 0;
+
+	return __vma_keyid(vma);
+}
+
 #else
 #define mktme_keyid_mask()	((phys_addr_t)0)
 #define mktme_nr_keyids()	0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 48c2d4c97356..d02867212e33 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,3 +1,4 @@
+#include <linux/mm.h>
 #include <asm/mktme.h>
 
 /* Mask to extract KeyID from physical address. */
@@ -48,3 +49,9 @@ struct page_ext_operations page_mktme_ops = {
 	.need = need_page_mktme,
 	.init = init_page_mktme,
 };
+
+int __vma_keyid(struct vm_area_struct *vma)
+{
+	pgprotval_t prot = pgprot_val(vma->vm_page_prot);
+	return (prot & mktme_keyid_mask()) >> mktme_keyid_shift();
+}
-- 
2.21.0

