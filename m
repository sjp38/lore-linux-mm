Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84EB9C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E2A52064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="gbgwfZZp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E2A52064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 225FA8E001A; Wed, 31 Jul 2019 11:08:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F32F08E001E; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0F988E001A; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 782978E001C
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so42596442edx.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WXT2KCVQy2E86WIHV388gpcH/h/cqapkcTgzB8ITRTY=;
        b=N9gamUZ+/DQUQrnfaFZz6wcyMRJX10DsN/Hlkn1pXa9a0aGEo54BwY71zu3aKXqt0Z
         PJI0Ae8YvIlv30sMY5EjlJkRBCGsg9OEfnPxM6T8k4Ye5008a2uPp1pJ+kA8B3NX/xv6
         vtjTzYIM1a0e2x05VKeFHX8+IStXff1hNYZkL5LtBYAR4ypZV9zFdu95dTIM/Cerhff4
         IJgjc2SYiB9zBJHzd6+eQ9VnuVhbpsPalVtA9pZg4DL6GyjTaUR3Q31Guf8AyNWY/swi
         82jzGJiehOXd+UiMtcaMpmrSUrUNHTyUBPVn7TYiQ9DfCa7R6K2MXLcWu8acG8Q3TRcj
         CGbA==
X-Gm-Message-State: APjAAAVS6pEw3eb2/j67Sqe95MosEogPXgC39EdAOW6yedRvxeceMTDW
	0eaHPd91OlP15J2W06q2VpoufqNk4gNBJWsbf9sl57EqXHzqZpK3F9+i9P+5tF6G4yJuQ0CmXgi
	DYHzPdtlzXWmei2PZr+n8AKLwyPaYVqRMMPjWL9MTDUJITzy/LRA/JBdoSpfOxUA=
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr109791867edt.149.1564585714043;
        Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr109791677edt.149.1564585712403;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585712; cv=none;
        d=google.com; s=arc-20160816;
        b=l+UfXVkKVEowfyGPDB2l23mSCD8GuMQqsxG7v7C5KhIPtb5dNRX8ov0bj89S5W+PQn
         bWxoG6Hd3+2vG1o8cOd/UHur+LOplR2H3tvcMNIw2gOOaujw8M222oZBKO2GjnyoCPTJ
         kybzwSp+ImTUuPBH8GMLWzkZ1ghAblw7yYEOSTaj6Omdxy+Do2ikL397PfpVK50otYGR
         keE7vt0vUdfC1aSGAo+7kv2octSgP1xpkNFFgYtvRS2ddbV/nNw7u6Yo9WDApHHKZHt5
         y09SLzUthhWIX0x40B2v5AQ1R1NUJ+22F5irNnwCwoPW2MHahCL2cSML264o7I6cVygx
         8oOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WXT2KCVQy2E86WIHV388gpcH/h/cqapkcTgzB8ITRTY=;
        b=eib3nVt9LOxSUDY9Hi9Hh6cpO3LEuH03ovHRC7cklr6CIOu/uiL9vadwz3BEQ+gV89
         rp+avCnHLuQkJbVVOpTt/VQxNEt+6CvLkjLcfanYVV7StbfbT9aZVhDy9H9TCGTLOZzT
         YhMdc8SkA92HkbkYDV8UFJPj7UzH6TNET4fNsrVGAZsm4fhxk0Fd/4FWLT6WEjRJAZo8
         I7X5czITYgCQLXs6CHdnoHXrSIuiwcJK6bbDK9GR6zzaX//DVHIqx6XzgGlv/RPJ7qU7
         MBEF2sg3LdQZbhJDBeZ9szU6ZkFAG8fV3HrCNlh3jbTYskDUgc9/ba9eigDNKnPuYV+i
         r8Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gbgwfZZp;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor52293247ede.5.2019.07.31.08.08.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gbgwfZZp;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WXT2KCVQy2E86WIHV388gpcH/h/cqapkcTgzB8ITRTY=;
        b=gbgwfZZpKF7Zw4y/Cy0+El8MhN5OgIgEsj0rN2nkj9PakelkWIC/N62lsNpt78P51H
         jvP8xx7Juipvx0RgC4SB4vNCw1P4PSVg2b2+doiEir7dfWiW3vsGXqpbQGM6KNexQSTP
         r3fNkw3L7doZwwJenk62AM3aDDoLUPKu0t7NkU1I3mRXbo3XJ9NXobg93l8rusAKYuRo
         dypVLFF2TyUrUJhBYMTvoExAgOrk1M4x1MfzcZx90KOF0LZV+HC3Q1R85RN5+Yd5tXFt
         ULtpKhZLGf3u8jhLzjctfNyP1AJ1tjB1U+mn3PJugnraGtaxozLw2DlDsbKDrENsFSdN
         bcCQ==
X-Google-Smtp-Source: APXvYqwiaqlBMCu7NWbE38q/iVndeTnZvf7qpo+nZ6NbB+Pm6uXYyVJ+okRcWjQSuw2bxKJtzce2+A==
X-Received: by 2002:a50:f70c:: with SMTP id g12mr108973248edn.139.1564585712069;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id b15sm5578799ejj.5.2019.07.31.08.08.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 2C437104602; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 44/59] mm: Add the encrypt_mprotect() system call for MKTME
Date: Wed, 31 Jul 2019 18:07:58 +0300
Message-Id: <20190731150813.26289-45-kirill.shutemov@linux.intel.com>
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

Implement memory encryption for MKTME (Multi-Key Total Memory
Encryption) with a new system call that is an extension of the
legacy mprotect() system call.

In encrypt_mprotect the caller must pass a handle to a previously
allocated and programmed MKTME encryption key. The key can be
obtained through the kernel key service type "mktme". The caller
must have KEY_NEED_VIEW permission on the key.

MKTME places an additional restriction on the protected data:
The length of the data must be page aligned. This is in addition
to the existing mprotect restriction that the addr must be page
aligned.

encrypt_mprotect() will lookup the hardware keyid for the given
userspace key. It will use previously defined helpers to insert
that keyid in the VMAs during legacy mprotect() execution.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/exec.c          |  4 +--
 include/linux/mm.h |  3 +-
 mm/mprotect.c      | 68 +++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 65 insertions(+), 10 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c71cbfe6826a..261e81b7e3a4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -756,8 +756,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	vm_flags |= mm->def_flags;
 	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
-	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
-			vm_flags);
+	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags,
+			     -1);
 	if (ret)
 		goto out_unlock;
 	BUG_ON(prev != vma);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 98a6d2bd66a6..8551b5ebdedf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1660,7 +1660,8 @@ extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long
 			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long newflags,
+			  int newkeyid);
 
 /*
  * doesn't attempt to fault and will return short.
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 4d55725228e3..518d75582e7b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,6 +28,7 @@
 #include <linux/ksm.h>
 #include <linux/uaccess.h>
 #include <linux/mm_inline.h>
+#include <linux/key.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
@@ -348,7 +349,8 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	       unsigned long start, unsigned long end, unsigned long newflags,
+	       int newkeyid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long oldflags = vma->vm_flags;
@@ -358,7 +360,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	int error;
 	int dirty_accountable = 0;
 
-	if (newflags == oldflags) {
+	/*
+	 * Flags match and Keyids match or we have NO_KEY.
+	 * This _fixup is usually called from do_mprotect_ext() except
+	 * for one special case: caller fs/exec.c/setup_arg_pages()
+	 * In that case, newkeyid is passed as -1 (NO_KEY).
+	 */
+	if (newflags == oldflags &&
+	    (newkeyid == vma_keyid(vma) || newkeyid == NO_KEY)) {
 		*pprev = vma;
 		return 0;
 	}
@@ -424,6 +433,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	}
 
 success:
+	if (newkeyid != NO_KEY)
+		mprotect_set_encrypt(vma, newkeyid, start, end);
 	/*
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
@@ -455,10 +466,15 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 }
 
 /*
- * When pkey==NO_KEY we get legacy mprotect behavior here.
+ * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
+ * for Protection Keys and Memory Encryption Keys. These extensions are
+ * mutually exclusive and the behavior is:
+ *	(pkey==NO_KEY && keyid==NO_KEY) ==> legacy mprotect
+ *	(pkey is valid)  ==> legacy mprotect plus Protection Key extensions
+ *	(keyid is valid) ==> legacy mprotect plus Encryption Key extensions
  */
 static int do_mprotect_ext(unsigned long start, size_t len,
-		unsigned long prot, int pkey)
+			   unsigned long prot, int pkey, int keyid)
 {
 	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
@@ -556,7 +572,8 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags,
+				       keyid);
 		if (error)
 			goto out;
 		nstart = tmp;
@@ -581,7 +598,7 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_ext(start, len, prot, NO_KEY);
+	return do_mprotect_ext(start, len, prot, NO_KEY, NO_KEY);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -589,7 +606,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_ext(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey, NO_KEY);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
@@ -638,3 +655,40 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 }
 
 #endif /* CONFIG_ARCH_HAS_PKEYS */
+
+#ifdef CONFIG_X86_INTEL_MKTME
+
+extern int mktme_keyid_from_key(struct key *key);
+
+SYSCALL_DEFINE4(encrypt_mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot, key_serial_t, serial)
+{
+	key_ref_t key_ref;
+	struct key *key;
+	int ret, keyid;
+
+	/* MKTME restriction */
+	if (!PAGE_ALIGNED(len))
+		return -EINVAL;
+
+	/*
+	 * key_ref prevents the destruction of the key
+	 * while the memory encryption is being set up.
+	 */
+
+	key_ref = lookup_user_key(serial, 0, KEY_NEED_VIEW);
+	if (IS_ERR(key_ref))
+		return PTR_ERR(key_ref);
+
+	key = key_ref_to_ptr(key_ref);
+	keyid = mktme_keyid_from_key(key);
+	if (!keyid) {
+		key_ref_put(key_ref);
+		return -EINVAL;
+	}
+	ret = do_mprotect_ext(start, len, prot, NO_KEY, keyid);
+	key_ref_put(key_ref);
+	return ret;
+}
+
+#endif /* CONFIG_X86_INTEL_MKTME */
-- 
2.21.0

