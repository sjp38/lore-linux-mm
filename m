Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EEE1C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E0B621734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E0B621734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC5666B02A3; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F046B029B; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 370F66B029E; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8CBC6B029B
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so1892301plt.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VRvO8oqMppxOnEWDEBuBzBCYC9+uFK55kDaEpE2UVds=;
        b=LaNSgB0794uWcJgI/q/MXbDiBXGIUwhZlkBsLkkjwjeN2mq9MixiQlIZIyM+HC6lFy
         MtVABEW4v9Qz4tZn7ZPgQ7jqYCBBKQRQjpYQQUaZ36XsBE17DfC5sWlHaZf4AJ6uc+1k
         sXlWURL1Vhdj/jY7zEsAD0lILl9IUd+9fLL2DukwONvwFqe2SVxqHl2JdljX1Yt3X3zO
         eSJfCJjGWdubevS0HT62XmBG+qx4xkDJGczcqjQvQzPmPpo7CmUFFT6AUkTH03oqEpdF
         hRKqTE51T+/mm+KVYHtDTNheGETPiBopMCyEUbYKXleWJ2XjrNYhF43LhjUVHsSXZ1i4
         Fhuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkcdEyyzJFznFA9mz/ZFe6KWzaLXExf/1udLVK6WjNwsN/qL3z
	kPtCkeVh8Wk3y8ryfOQuEUDuqGQD3ekSInyX4NYo1VcnutckLmjkpxDXEKWy4OcKm8IA9rQSDgz
	ZaSpdqrVeQD3uG7gBrH2PXGG9EagB/GohCO6oyh4Hi6WlOFDltlW+6hPSGRKNSNQvVg==
X-Received: by 2002:a65:62c4:: with SMTP id m4mr46915904pgv.308.1557326690541;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNbE7AElQJVofKQykoVh4ogRP4oU0Y8BnV/uFrhGYqO0tZohsG8oU7RUYoEgmfkO/F7vXS
X-Received: by 2002:a65:62c4:: with SMTP id m4mr46915775pgv.308.1557326689244;
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326689; cv=none;
        d=google.com; s=arc-20160816;
        b=xE4OKP4iM7e6s1MhOQp7RjiU6ozOeFQ3J1WnR9zS55FZhdRIB2uBVG4uEADCXGqpoq
         MTyXrBzKzBt2jQNHG9dIXyHCgQDZFeBLaOyUHUssIaQuxl6dny+3j7kWPkPWttLCtKmn
         DbbTElXMZcCgqx9HrfmpQFJMdHATnVhhS/ZSKDb0lmkZBdbTmW53/CbmroSXeEF1D43A
         GGHvHLi0IVs2GCi4pDWNMyQn62QAAGJMWVM+133R56cCxwhKJPwtuZj8pPw/HoCUW4ak
         r3qtrUELpbXIAI2OOdhbf1t8lDotgVn8U1bVz71AKVOU/Z+oZbKXANMcRB0pXTNiOIKY
         1vMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VRvO8oqMppxOnEWDEBuBzBCYC9+uFK55kDaEpE2UVds=;
        b=NDNHc3LZ+wm231uUn0Q+mmRtoqDuhslpYm1Ea11aJre20lO3LZwmr697RSelKPv6dZ
         0r1oCzsNfdxWOkZrVGMSE7GyfA32ayPGTCaYC1JOuvYXifBo/FNLpUcqKpIh9tyQhIqE
         JeO0dlXUYf+aNP/8uCoUlfByCbTqFu26oj8LveElpqNuCwR8u7OQQlhB82iQDi5QyYQe
         tvd2vN0u1yFRNRpg8rgYO1zYIbH2AQOviwmUxfpWIKqof4aVjiHl9RTq0wapRebf+fWY
         +GuOLI3Qg4UFtcKwzgJJQ9A1cZZnyZaxcV6GVS/W4LgYCz953dj/dE/ojowt190HOPn+
         yLAw==
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
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:48 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id D81CDEA8; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 43/62] syscall/x86: Wire up a system call for MKTME encryption keys
Date: Wed,  8 May 2019 17:44:03 +0300
Message-Id: <20190508144422.13171-44-kirill.shutemov@linux.intel.com>
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
index 1f9607ed087c..dbcd4c28d743 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -433,3 +433,4 @@
 425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
 426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
 427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
+428	i386	encrypt_mprotect	sys_encrypt_mprotect		__ia32_sys_encrypt_mprotect
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 92ee0b4378d4..d01bd132e9ee 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -349,6 +349,7 @@
 425	common	io_uring_setup		__x64_sys_io_uring_setup
 426	common	io_uring_enter		__x64_sys_io_uring_enter
 427	common	io_uring_register	__x64_sys_io_uring_register
+428	common	encrypt_mprotect	__x64_sys_encrypt_mprotect
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e446806a561f..38a2d7b95397 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -988,6 +988,8 @@ asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
 asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
 				       siginfo_t __user *info,
 				       unsigned int flags);
+asmlinkage long sys_encrypt_mprotect(unsigned long start, size_t len,
+				     unsigned long prot, key_serial_t serial);
 
 /*
  * Architecture-specific system calls
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index dee7292e1df6..86f942f54b1b 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -832,9 +832,11 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
 __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
 #define __NR_io_uring_register 427
 __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
+#define __NR_encrypt_mprotect 428
+__SYSCALL(__NR_encrypt_mprotect, sys_encrypt_mprotect)
 
 #undef __NR_syscalls
-#define __NR_syscalls 428
+#define __NR_syscalls 429
 
 /*
  * 32 bit systems traditionally used different
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index d21f4befaea4..80da8d9ac8b1 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -350,6 +350,8 @@ COND_SYSCALL(pkey_mprotect);
 COND_SYSCALL(pkey_alloc);
 COND_SYSCALL(pkey_free);
 
+/* multi-key total memory encryption keys */
+COND_SYSCALL(encrypt_mprotect);
 
 /*
  * Architecture specific weak syscall entries.
-- 
2.20.1

