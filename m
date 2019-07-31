Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05333C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B44352184B
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="RoXYiUX1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B44352184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45CA98E0003; Wed, 31 Jul 2019 11:08:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40ED88E001A; Wed, 31 Jul 2019 11:08:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212A68E0003; Wed, 31 Jul 2019 11:08:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7F008E001A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so42557473edd.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IPsK2XRosHpKRDn42pkA1hocZnIJH8axKf5oqIqvF+0=;
        b=amRsmvFs0S4XhSpax78buvgeCNnbWvfXiQZweekF50QtGUYDn1831SsSuKbzp0jXEJ
         IJ8oiY69hFO1A24aViEOBeM+VvslJhH9wEcFnJbJl3AjVYj2NpXWDPR9/G6UeT3ZgIBv
         6g7X6K4CdQeaeFH3jd9uLst0+E+x+XcnEKDf9i6FsRi6RhRp2x9LAGCbWoECx5vgkwub
         aBTMuk3FdVcE/Y6XVBolPK7EG6vS1wTgWQqjHug4Ot0IwMY5xIpAdKypMDUu20qypR1d
         4twzsXImqRzXfKdweNTKuY1+fNxTBgmdWb9b6Po2DWY3fLFKlVVO92dx6nf33C2gmr2W
         McTQ==
X-Gm-Message-State: APjAAAVM7Kex9VSr6EJwq+HdXPudXlgmELAuL8Z5H0TP+nOxfPr3UTsY
	QL1UKecw9OBef7rHneH2/h6n6TW1MyMle0xo5jwwM9wMD8enAh4ippw+/f7grE0tvUlHCmO5Dmt
	5K4uv1cGyiwxLm8ihePwFxRFv4BLkCniIiEcJM5xJw4TLsom6c/UIGWpD6V43RBY=
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr68176220edr.210.1564585712195;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr68176086edr.210.1564585710989;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585710; cv=none;
        d=google.com; s=arc-20160816;
        b=tNV646nl0sfW/VO154c9gL7lTmVRwj9SzeZ1xgUumIqrz5jF5kTF+h23v5vZ3o6DQR
         mRhwK3RgENThaIIeeITSocLHBjwyWViA3+uCSaNWOCBvE7iHTabywTvkKy4MD04Fj3pl
         P+Y+zLH0XHmCFPdQHbIsV6B5QU/tje+3eUS/MMM/As5Rauf10oRyM4HBcsMtmSk2ZO2U
         kUYhk5FfAq8jv6tdD+tBcbktrj3sHNMzh1lWYoHhN+5/kiaWoG1TkTUorqP4f19470Eo
         amEgyTFZXzvShd2qvR0shwV1jjgd0jl20g62Rf2RFjwqvT2tJkKLNxXN6Ckgvm9vAL1E
         Hzgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IPsK2XRosHpKRDn42pkA1hocZnIJH8axKf5oqIqvF+0=;
        b=Rg5AkPYqCUsR05GoMs2LlDh9TZ9HCMFIxjPVepWczXTOaKZL1ZOtoEjQTtFTx8EgtA
         mjVwYVu2FbyWYzuQP4Tnx1j7yJofG8bxOkCZEBX9jrGOPaMB1Ucmi035fr3YB72xbNoe
         NW3wdrcy6fMyCSUOMmhUT7Dpit7H+ZhempwxAmBnTJ3rEv1A6Hlt127jCrIAL+B6fqVx
         1bPsX+aEXAtWsGDgtJgbILcIw6vKjTaubfAX2NVpx9koBz3kRFHX+HCAH4xGr+uFG2Ad
         ybIyVIpcDXAF3lFXwtesVmEaEXOFjXSp5eMCoZMgZS4LjoI0gFI6TiL0YLJWQQxzqoCT
         3+QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=RoXYiUX1;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12sor22491441ejc.9.2019.07.31.08.08.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=RoXYiUX1;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IPsK2XRosHpKRDn42pkA1hocZnIJH8axKf5oqIqvF+0=;
        b=RoXYiUX1XnPhAzuEc/754GCS7jv20HjdtnuA0D6/z6EQWRYWWlJYLUmYCp5A9gF6t0
         xmdTvGf/RDPJGsWdvfduqJSiPxD1iQy03XbdfaIQyAILVGsn2EfooQl1HvX68XEmvKvE
         YLVQ2+mjfACH42lwtOVvTBDcZBjRVOCatWgbntGFkKnEMI7/phw5FB2FZk9Pt9J7I72/
         XSOCXiRLBenu+N9P+C9H7h3JIHVw5uD4w9ATyXvDePOwu1HaCpJlCNydaVH+dgiEvjFc
         icfbQU69vCZT3uQOtoM3gTX73RLNevnI2i7LMnV1I9DzMb0PsfE3TEa5CJMzEo4Nvk/X
         DA6w==
X-Google-Smtp-Source: APXvYqw++kl/s7OZc/atZ5tqKoJq5up6RoggcbrTF/G7ZR/ZGQU8Rbyr5OdWAhG3JNmHVdhx6GXBWA==
X-Received: by 2002:a17:906:914:: with SMTP id i20mr28046601ejd.213.1564585710645;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id uz27sm12533468ejb.24.2019.07.31.08.08.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 1E0E2104600; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 42/59] syscall/x86: Wire up a system call for MKTME encryption keys
Date: Wed, 31 Jul 2019 18:07:56 +0300
Message-Id: <20190731150813.26289-43-kirill.shutemov@linux.intel.com>
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

encrypt_mprotect() is a new system call to support memory encryption.

It takes the same parameters as legacy mprotect, plus an additional
key serial number that is mapped to an encryption keyid.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl | 1 +
 arch/x86/entry/syscalls/syscall_64.tbl | 1 +
 include/linux/syscalls.h               | 2 ++
 include/uapi/asm-generic/unistd.h      | 4 +++-
 kernel/sys_ni.c                        | 2 ++
 5 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index c00019abd076..1b30cd007a6a 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -440,3 +440,4 @@
 433	i386	fspick			sys_fspick			__ia32_sys_fspick
 434	i386	pidfd_open		sys_pidfd_open			__ia32_sys_pidfd_open
 435	i386	clone3			sys_clone3			__ia32_sys_clone3
+436	i386	encrypt_mprotect	sys_encrypt_mprotect		__ia32_sys_encrypt_mprotect
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index c29976eca4a8..716d8a89159b 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -357,6 +357,7 @@
 433	common	fspick			__x64_sys_fspick
 434	common	pidfd_open		__x64_sys_pidfd_open
 435	common	clone3			__x64_sys_clone3/ptregs
+436	common	encrypt_mprotect	__x64_sys_encrypt_mprotect
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 88145da7d140..4494b1d9c85a 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -1000,6 +1000,8 @@ asmlinkage long sys_fspick(int dfd, const char __user *path, unsigned int flags)
 asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
 				       siginfo_t __user *info,
 				       unsigned int flags);
+asmlinkage long sys_encrypt_mprotect(unsigned long start, size_t len,
+				     unsigned long prot, key_serial_t serial);
 
 /*
  * Architecture-specific system calls
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 1be0e798e362..7c1cd13f6aaf 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -850,9 +850,11 @@ __SYSCALL(__NR_pidfd_open, sys_pidfd_open)
 #define __NR_clone3 435
 __SYSCALL(__NR_clone3, sys_clone3)
 #endif
+#define __NR_encrypt_mprotect 436
+__SYSCALL(__NR_encrypt_mprotect, sys_encrypt_mprotect)
 
 #undef __NR_syscalls
-#define __NR_syscalls 436
+#define __NR_syscalls 437
 
 /*
  * 32 bit systems traditionally used different
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 34b76895b81e..84c8c47cf9d6 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -349,6 +349,8 @@ COND_SYSCALL(pkey_mprotect);
 COND_SYSCALL(pkey_alloc);
 COND_SYSCALL(pkey_free);
 
+/* multi-key total memory encryption keys */
+COND_SYSCALL(encrypt_mprotect);
 
 /*
  * Architecture specific weak syscall entries.
-- 
2.21.0

