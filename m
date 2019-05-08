Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6BF7C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79FAF216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79FAF216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EA6C6B029F; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BB5D6B02A4; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B0766B02A1; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C04376B029E
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so8022716pgb.20
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kydsvhYmtwP97NfX0czsEbvBzrcWYd7w+jQjY0TdfJU=;
        b=eEXKtQI65aT/zKQCHT+yalChe7CQDA/OL5Qnq9L5mhYjzXjc+uU1Qa6kF9cUlINNzg
         eGb2EPTIf2sVu6pQ8uGMPB4wJCdtneEEexKe/r4w2pHYQPV9K1VKNdbBL4YQvAM8j9Xp
         ucJhDJnbiQdygUhCo0VSFBO1No7cobXktEgqMY2wTiMARamJM6D05NTugu0AK+mn/WY/
         CNICjeluSKQxTRPCYiaVjINW+uBtjQUQI7XuEoZJ70+U4PqL4MTXv6Ww/eArAA2xbjCm
         67BSQg3MgGJvDCA+p8BmF1/L01whMQrJE14+AKUW6DElOWvdoE8nyGSSbrnpqWSICay+
         CV5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWPzypFaPjB24sv11uAzaE7F+ZwxrLW9PqVnwzL1XlKIvMedPoC
	6MJTxsa9rWcAuB9mGSWhebkCxxSVP//ap1t++oCCUD0q+aE99+Hks5s6ALenMPcwUcSk9U7u4f8
	DZ/gJLdKHfIYpdb9z0xZw7VSCNPrGZP8XSPCWw8GI+t4ebqHPRyvyty60xEVYtvLavg==
X-Received: by 2002:a17:902:b20f:: with SMTP id t15mr48326012plr.341.1557326691430;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJejpCx5i9K3B0CPswE3h47FN6t/MfRZJCDnTbQwTRz5+4ieYNYzsYJqK/YIB68DIMm7hH
X-Received: by 2002:a17:902:b20f:: with SMTP id t15mr48325890plr.341.1557326690349;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326690; cv=none;
        d=google.com; s=arc-20160816;
        b=fR/mKVEpPYUtBS1AOh36MFBsc5Z6nz2LQ/R6WvfC5H8Ynrr3gt5tLa4F84jjiZdD9g
         WReCtRhLkNHg9knYeAoGyQxUgU8F5mbGSOAl+jJrCgHUOrhlgLN/mSVMyrrNsosU2lM7
         1ounjIdgejQJf211trT48mQ3PRTtDU3e+9XUG4WiOSoF07Cw5lO9RwyIh3PIP6wlJ+ap
         UQ252Vh4e47dA9LBSKEsZUKGH/7UoTIKDNmhRMHKXm+UR9VElY46nYywzhSotrp7aDrA
         3rCV8nH4CNKsoh42AyjzXS/xuWRfFd+IG/e5o4cCl1JqaFhKBuXo5EH+FHAP+BEzB7cw
         9KrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kydsvhYmtwP97NfX0czsEbvBzrcWYd7w+jQjY0TdfJU=;
        b=XXM5Jn71lOTHQy4NaHw+Ujx68eTl9JueLsoxRE5EkCqKITmRJfDegMqrd5KPuJbjmU
         wBwoNBcvbYLc+xgL/XGIdJEbuwuEyvGx3OQLTQZUP3BemG6650yXNieRJHW8wH/HKjGs
         pZ6eoX5/tN8g9ObH/6trLwmwzElJrXF1bxwC+b2FtsF12otCP8nxDRa1WfbagukkXzZ6
         IXB8a7q7vyAqb6gMlBO+lWUDlcQyMQ/Wtzcd6K9LyhT8+aKoiLM02NtF0LzrRy6GG3fj
         UbLmjS9ieCUrmba1XlTM6KkgLdwteLaLbirtTmwL3KEKOpzAdjkwRpNcsbsbTSM7QVTe
         NkTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d3si22507173pfc.278.2019.05.08.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga103.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga008.jf.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id F254AF65; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
Date: Wed,  8 May 2019 17:44:05 +0300
Message-Id: <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
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
index 2e0033348d8e..695c121b34b3 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -755,8 +755,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
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
index c027044de9bf..a7f52d053826 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1634,7 +1634,8 @@ extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long
 			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long newflags,
+			  int newkeyid);
 
 /*
  * doesn't attempt to fault and will return short.
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 23e680f4b1d5..38d766b5cc20 100644
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
@@ -347,7 +348,8 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	       unsigned long start, unsigned long end, unsigned long newflags,
+	       int newkeyid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long oldflags = vma->vm_flags;
@@ -357,7 +359,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
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
@@ -423,6 +432,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	}
 
 success:
+	if (newkeyid != NO_KEY)
+		mprotect_set_encrypt(vma, newkeyid, start, end);
 	/*
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
@@ -454,10 +465,15 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
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
@@ -555,7 +571,8 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags,
+				       keyid);
 		if (error)
 			goto out;
 		nstart = tmp;
@@ -580,7 +597,7 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_ext(start, len, prot, NO_KEY);
+	return do_mprotect_ext(start, len, prot, NO_KEY, NO_KEY);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -588,7 +605,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_ext(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey, NO_KEY);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
@@ -637,3 +654,40 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
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
2.20.1

