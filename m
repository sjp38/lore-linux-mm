Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0997EC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B40EB208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zYfX+Vek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B40EB208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FAE8E003F; Wed, 31 Jul 2019 11:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CD858E0041; Wed, 31 Jul 2019 11:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A6288E003F; Wed, 31 Jul 2019 11:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5C938E0041
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so42575232ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sk1PpCuzqYjEJOS8AE7r4czQNGxEA2XkbZsiPBCfi34=;
        b=aPNaM5Lb8NMtVXsNJvrf3lkMrzyuqtBGfcgeKcjsg/ZIE4QbhWcLRytTfWS6Tp4JNx
         f4vp+y6ukyCzqB+oALZqY+AKT2evB8DbNU4VNwshet6eY5Ss7Apr2m/Zvo/LoRQsn03i
         RMTcSVAKsf1cxmU8KMAagci9azqyCsda4ScsxkHoNroQCR1dAZC506iCMpFyAE9s31TP
         g6EBNfv2xhg/vAEOeZpvaifA7PfzNFFn6zEPvhpYoxi/maSWNIjaNsnkCmlP0JRQdKLy
         LLyfFw0HxYKlgqlCaxf1zCEncNATqWBZZDwLLyelrEvS+THFYdIwyFLWoUFxpPk6BeRz
         wQUQ==
X-Gm-Message-State: APjAAAWvr5R3Mh6JbE1CLbpbyAjffnbsxOX9CFAM3JO+Hm2guyDp4QxN
	ZYrZuaSUiquvWCauqHG6lxo+rLD/EQap6jo3mJdtBfT4r8I4ip5wpWgSH7Xd5XnMW2lm2DGBWU7
	wvRdGdSABrs6ouyY54ucyHiVmC5P7AuCuBwkp5z1uAVMAvIKMsLm8iBKDG336J2k=
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr107641995edq.251.1564586633242;
        Wed, 31 Jul 2019 08:23:53 -0700 (PDT)
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr107641883edq.251.1564586631922;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586631; cv=none;
        d=google.com; s=arc-20160816;
        b=rgtaMsiFuKdtV5Wl2vul0Amh7UBu8UKk4vvmplYr+x31Y867xnGo5id43nmSnMZrZz
         FC4d1x7Enwwvi4a/EggIyxq8IGqMBQ1I0mwYTo9SeKMpfipe+QhVRkH8hWu4v8+CFKj9
         baaJb3D8uUZpmRlN1aJGSbT4SjjzCGHAnVfjA+ujPSMOnen5KFMnPwaR22S5fhDyYRb2
         TN+pZryNc4QXs3MEMt3FzuJPVaFYNDL9hFnUgsKZ6ou2lI2kx5yhLtChDfVnyT5gL+GC
         B/+o+yM+6iZ7iDGtGxgoKFMoAiBB67gi3Sk87fJrxB0pkJL/zma0NBYq7iAt7d9zsYcS
         JOWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Sk1PpCuzqYjEJOS8AE7r4czQNGxEA2XkbZsiPBCfi34=;
        b=BaLhGlKGU2SsBmRolGw/LhhFDtfIxaCquyH7Qg1hMXqedORmHAOr35quRkjZz/oYwX
         gUlqTLp8bhus6A9vmvMUzBwgPSeEJ2lvvwYsOYADKDfW+98+wzQv4446csfGwSGj/+86
         RJwXzn3bS6Zzrl98otpzjXbsWawz3mkIPD9tDLbBwNCKoJp4sRrDh0hT+7pGuQ9U9qkP
         iXPS7JZUIXQ3LLuJQ1oMPuXmMqvdCwDA7op2ROWxv7zFge2x4/QZy2HrDj34ZyRi6lKy
         nHX1MVVQq2nWfjqVu6daXp1FcKmxcPPkpJrKvp6ZS/km8jeMpb5q8bbdkKyaMN/h9bZt
         Zt3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zYfX+Vek;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ob24sor12852266ejb.47.2019.07.31.08.23.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zYfX+Vek;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Sk1PpCuzqYjEJOS8AE7r4czQNGxEA2XkbZsiPBCfi34=;
        b=zYfX+VekOIhFWRJ2G/0zX9v39cKod648dVL8Af3HBA6yCma0NLUJ9wn4pQd/9Jkwxo
         plhgwkImm7vcYtinhJSQVqk1MAoTlKk+hJnnIdkIvREU+NvQYGke8sn2GbxcPE1Uwp3e
         d9FLk488jkV3wDUFrH43C8fjJoatF8ApGk6f2jTHHmYUNGl3G4HSu0Rs89UZ/sZW/KTq
         SN8gtRY0sjPahfYQyPAezYsBjck1HMmp6Edi2x1w5HyYUVMxaFgoLCv3ml6vi5zqcbZl
         hC9nZo//Dc9d/32cvuxLuf0GM7cH92tu+V/365Y+aSuMJt615iXOKFwOz3OBpdQimRaz
         LoJg==
X-Google-Smtp-Source: APXvYqweIFGj3MCq6N04mbC1BNfi3q/vQoLrR/zJQwa/pOxhj8VtISyLnD/wc39qKae2odfmqbvinQ==
X-Received: by 2002:a17:906:f10d:: with SMTP id gv13mr11602301ejb.151.1564586631547;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id e3sm7174587ejm.16.2019.07.31.08.23.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 33243104603; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 45/59] x86/mm: Keep reference counts on hardware key usage for MKTME
Date: Wed, 31 Jul 2019 18:07:59 +0300
Message-Id: <20190731150813.26289-46-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

The MKTME (Multi-Key Total Memory Encryption) Key Service needs
a reference count the key usage. This reference count is used
to determine when a hardware encryption KeyID is no longer in use
and can be freed and reassigned to another Userspace Key.

The MKTME Key service does the percpu_ref_init and _kill.

Encrypted VMA's and encrypted pages are included in the reference
counts per keyid.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  5 +++++
 arch/x86/mm/mktme.c          | 37 ++++++++++++++++++++++++++++++++++--
 include/linux/mm.h           |  2 ++
 kernel/fork.c                |  2 ++
 4 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index e8f7f80bb013..a5f664d3805b 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -20,6 +20,11 @@ extern unsigned int mktme_algs;
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
index 05bbf5058ade..17366d81c21b 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -84,11 +84,12 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
 
 	if (oldkeyid == newkeyid)
 		return;
-
+	vma_put_encrypt_ref(vma);
 	newprot = pgprot_val(vma->vm_page_prot);
 	newprot &= ~mktme_keyid_mask();
 	newprot |= (unsigned long)newkeyid << mktme_keyid_shift();
 	vma->vm_page_prot = __pgprot(newprot);
+	vma_get_encrypt_ref(vma);
 
 	/*
 	 * The VMA doesn't have any inherited pages.
@@ -97,6 +98,18 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
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
@@ -137,6 +150,22 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 
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
@@ -145,7 +174,9 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
  */
 void free_encrypted_page(struct page *page, int order)
 {
-	int i;
+	int i, keyid;
+
+	keyid = page_keyid(page);
 
 	/*
 	 * The hardware/CPU does not enforce coherency between mappings
@@ -177,6 +208,8 @@ void free_encrypted_page(struct page *page, int order)
 		lookup_page_ext(page)->keyid = 0;
 		page++;
 	}
+
+	percpu_ref_put_many(&encrypt_count[keyid], 1 << order);
 }
 
 static int sync_direct_mapping_pte(unsigned long keyid,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8551b5ebdedf..be27cb0cc0c7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2911,6 +2911,8 @@ static inline void mprotect_set_encrypt(struct vm_area_struct *vma,
 					int newkeyid,
 					unsigned long start,
 					unsigned long end) {}
+static inline void vma_get_encrypt_ref(struct vm_area_struct *vma) {}
+static inline void vma_put_encrypt_ref(struct vm_area_struct *vma) {}
 #endif /* CONFIG_X86_INTEL_MKTME */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index d8ae0f1b4148..00735092d370 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -349,12 +349,14 @@ struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
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
2.21.0

