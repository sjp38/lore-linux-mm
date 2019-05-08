Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9242FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5226621734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5226621734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9C156B029B; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6C36B0297; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6559D6B02A0; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 010386B0297
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a17so7477115pls.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iWsGKZByUQDlHk7Hz7enXJpmECuVWnapQVrzWNnNSAM=;
        b=Do6Dyk23Gcr+Td5flw4MxVB+Ekrikd9rKxEELlakRK8f4+XYn79/+dGLHorI7dU8CK
         Ai6XLTm1AoyNbcnooizJWUp1/cxJ/kP1JovyzRom3zyunWXd70usMNAZuV8xRrXR3EbA
         p6Gzb/yJTQAmuWJHR0A2iAGgdCVST3uHvOVJ1bEDVdzCaw7tkkGe1oR82BvhNmfvyosD
         lU6xYLlCBD1Jj9e15Gkvd4JNmRZmIvNjwCGLadBuRGXR9BOPfMAEmAR2IEhdxYsYe/2t
         YKmAw72DTvRPCkdSDPXl0NBmPXf4taQVbDPF3esnp7alG0pYYFXtUGhOesaXvoIZJibH
         DReA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUiFEJnIVbgd8LZt3WfvD51KWypi/rPobJQ2qJve4fno/TdaWHq
	wTFQwvsKGYEwQ76DcyTcjrcfXHppWwOtQAIdlAY6Ujzl3I7PNOnjelp2IZwoRBgxvCDOiL4/C7q
	S9K5QePelmerJLgWhyvzOaHnTncUz1YrIPsTeavJ3xum/Dx7uIMrJKbLIlZYNdsWl8A==
X-Received: by 2002:a17:902:9007:: with SMTP id a7mr3896872plp.221.1557326690648;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzewj+iod91hIAUdfUsxgxUrWhzoIxxwdHYbYAWIBOU0MYUBRe8iTbi88t+9S+1/R1yPYfv
X-Received: by 2002:a17:902:9007:: with SMTP id a7mr3896792plp.221.1557326689735;
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326689; cv=none;
        d=google.com; s=arc-20160816;
        b=d4qhO/KnyFDeartQbBHU2Ijvr11kwHuDEy/he65U7VOfsPaMlblkb19xdWm+n/XlKW
         +VxS42ZIiIvroa4B7tkIb967cuqQrSVlZR5W0Uj/TeWBqrz1QlckXL3QKY5kff8CogkZ
         bl+bKNvP5t3FiflX2UEPPSVmo9VbSPqpQDDHSYzvcBKsjfTFPake5gvTEiiVOkeZj2YX
         7/pyrzbGqj6XgDowFrvTofl16qkWE89D+ddg4pMxyhS3gvZWjK3XTVmbBcQ/QhjQQ666
         E3C3VooGOLOHYgNoGBbZ8Kh84QqopbfQq1e9MVTCyaSnqFczPgYMXgtIvOr69xEw4DmT
         yayA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iWsGKZByUQDlHk7Hz7enXJpmECuVWnapQVrzWNnNSAM=;
        b=nFpCAU51PoYLhytjWPrm0NQChXZaIJwqP/WjwGh8/xA0N3sbZztv+1sXr29cq8FsRi
         gnd4y1vFIgBOgrgext9GJvmV1aqd75RbdJqxCfzKZfzqTJ0RdF6ditgNwepF2Ri353Uz
         u+nk8plCYHS8mb2K/dy7D24S3GDkbmP8dLXX01ljOzjK2mNpfbktneqSIvBU1OgVNujb
         6P7EBPMVZIH6/Ai2RTspa54LbTY9NimLdx5mfdKl/Cy1D83+Li0E3BUnfACt5WQ02WNI
         LK/PiYld7RMTAAu/ehjByq03Mwy3mym2Ud1F2LDP006VVRNUU55x2m+IFbw090xCN9oN
         GFgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t16si6593003plm.65.2019.05.08.07.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:49 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:45 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 0BEE5F6B; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 46/62] x86/mm: Keep reference counts on encrypted VMAs for MKTME
Date: Wed,  8 May 2019 17:44:06 +0300
Message-Id: <20190508144422.13171-47-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

The MKTME (Multi-Key Total Memory Encryption) Key Service needs
a reference count on encrypted VMAs. This reference count is used
to determine when a hardware encryption KeyID is no longer in use
and can be freed and reassigned to another Userspace Key.

The MKTME Key service does the percpu_ref_init and _kill, so
these gets/puts on encrypted VMA's can be considered the
intermediaries in the lifetime of the key.

Increment/decrement the reference count during encrypt_mprotect()
system call for initial or updated encryption on a VMA.

Piggy back on the vm_area_dup/free() helpers. If the VMAs being
duplicated, or freed are encrypted, adjust the reference count.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  5 +++++
 arch/x86/mm/mktme.c          | 37 ++++++++++++++++++++++++++++++++++--
 include/linux/mm.h           |  2 ++
 kernel/fork.c                |  2 ++
 4 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 0e6df07f1921..14da002d2e85 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -16,6 +16,11 @@ extern int mktme_keyid_shift;
 extern void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
 				unsigned long start, unsigned long end);
 
+/* MTKME encrypt_count for VMAs */
+extern struct percpu_ref *encrypt_count;
+extern void vma_get_encrypt_ref(struct vm_area_struct *vma);
+extern void vma_put_encrypt_ref(struct vm_area_struct *vma);
+
 DECLARE_STATIC_KEY_FALSE(mktme_enabled_key);
 static inline bool mktme_enabled(void)
 {
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 91b49e88ca3f..df70651816a1 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -66,11 +66,12 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
 
 	if (oldkeyid == newkeyid)
 		return;
-
+	vma_put_encrypt_ref(vma);
 	newprot = pgprot_val(vma->vm_page_prot);
 	newprot &= ~mktme_keyid_mask;
 	newprot |= (unsigned long)newkeyid << mktme_keyid_shift;
 	vma->vm_page_prot = __pgprot(newprot);
+	vma_get_encrypt_ref(vma);
 
 	/*
 	 * The VMA doesn't have any inherited pages.
@@ -79,6 +80,18 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
 	unlink_anon_vmas(vma);
 }
 
+void vma_get_encrypt_ref(struct vm_area_struct *vma)
+{
+	if (vma_keyid(vma))
+		percpu_ref_get(&encrypt_count[vma_keyid(vma)]);
+}
+
+void vma_put_encrypt_ref(struct vm_area_struct *vma)
+{
+	if (vma_keyid(vma))
+		percpu_ref_put(&encrypt_count[vma_keyid(vma)]);
+}
+
 /* Prepare page to be used for encryption. Called from page allocator. */
 void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 {
@@ -102,6 +115,22 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 
 		page++;
 	}
+
+	/*
+	 * Make sure the KeyID cannot be freed until the last page that
+	 * uses the KeyID is gone.
+	 *
+	 * This is required because the page may live longer than VMA it
+	 * is mapped into (i.e. in get_user_pages() case) and having
+	 * refcounting per-VMA is not enough.
+	 *
+	 * Taking a reference per-4K helps in case if the page will be
+	 * split after the allocation. free_encrypted_page() will balance
+	 * out the refcount even if the page was split and freed as bunch
+	 * of 4K pages.
+	 */
+
+	percpu_ref_get_many(&encrypt_count[keyid], 1 << order);
 }
 
 /*
@@ -110,7 +139,9 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
  */
 void free_encrypted_page(struct page *page, int order)
 {
-	int i;
+	int i, keyid;
+
+	keyid = page_keyid(page);
 
 	/*
 	 * The hardware/CPU does not enforce coherency between mappings
@@ -125,6 +156,8 @@ void free_encrypted_page(struct page *page, int order)
 		lookup_page_ext(page)->keyid = 0;
 		page++;
 	}
+
+	percpu_ref_put_many(&encrypt_count[keyid], 1 << order);
 }
 
 static int sync_direct_mapping_pte(unsigned long keyid,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a7f52d053826..00c0fd70816b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2831,6 +2831,8 @@ static inline void mprotect_set_encrypt(struct vm_area_struct *vma,
 					int newkeyid,
 					unsigned long start,
 					unsigned long end) {}
+static inline void vma_get_encrypt_ref(struct vm_area_struct *vma) {}
+static inline void vma_put_encrypt_ref(struct vm_area_struct *vma) {}
 #endif /* CONFIG_X86_INTEL_MKTME */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..f0e35ed76f5a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -342,12 +342,14 @@ struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
 	if (new) {
 		*new = *orig;
 		INIT_LIST_HEAD(&new->anon_vma_chain);
+		vma_get_encrypt_ref(new);
 	}
 	return new;
 }
 
 void vm_area_free(struct vm_area_struct *vma)
 {
+	vma_put_encrypt_ref(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 }
 
-- 
2.20.1

