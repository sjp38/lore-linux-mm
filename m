Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F48C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55CB8214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SKFOea9c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55CB8214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E149B8E0193; Mon, 11 Feb 2019 18:28:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC6578E0189; Mon, 11 Feb 2019 18:28:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8C1E8E0193; Mon, 11 Feb 2019 18:28:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 723748E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:13 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m7so232801wrn.15
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ENlTYT6F8yKSgZtSKFAMRVhy2HT+kX2kAlJukSMyeJE=;
        b=dWFAfUmAo2LCjve6yPzec1Vmpzr34ixnUIXdeKg9jHmhezpBYAmM8lKcbysX2wIa17
         EzkKSBn/0bdTSR9ISK4Op4b+JMYSxhnnI0dpgsFt68Cv2iljAxNKwl92PDuNChJJjwIx
         E1ZK8KnRw8mCLFVNKSkR6hPpN+q7pE8Rwj4Z4MGE+mEl6lwMB1byoqv1Hu/zHFUL5ONN
         E4oZttI5ygjhw0/nbP9hhgK72FVizt3NKv527n2OvZ1UXu7mlBtVuJWsK2un4Wf2bkSz
         TXatX7qxAgCx82tWZxrVN6bC8uLmd8hvsOEGdHEZ3FR3ZmSaGFTqNKr7q7k/ITl/moI8
         QP2w==
X-Gm-Message-State: AHQUAuaZL8duVJNdX7Xu/fxtWp/f8797MsFxQ57urfIlJ/5tgLicR1nV
	wT0t4metIRVP3mjg5MA21La78b1mdY53DOM0Ns99SXJLTyo36/eHuGTzVr8ixd3m5ShZe7nbOeZ
	0P4jYoGYzvR6W8XDifaOkO5NapfhiBwGHwKtA2JhNKAcrctu7jkgRJot6JvYu/xV7sD6UPsQoh0
	a27OKxZ7HyUlMofof9daKV3p3gNhlJ4ioxPwqiAwe3MNuu2ioRyPAlKqzUhBVgvv2ZkHoNemaHz
	/odAMYNjKyV/BxWyVa0/6LgM8IP57FmDs65UDWfERuwx+HDnAKRsJgyWUNhP/2AKp/vFkGyEw0/
	GwRKV5jRqcVptenYyH7LU3COl3e/DS3enpFgBc83tr0dll9GHGstohiyUqgti7L1bNHJYiEnOGd
	Z
X-Received: by 2002:adf:e8c7:: with SMTP id k7mr508841wrn.298.1549927692967;
        Mon, 11 Feb 2019 15:28:12 -0800 (PST)
X-Received: by 2002:adf:e8c7:: with SMTP id k7mr508780wrn.298.1549927691730;
        Mon, 11 Feb 2019 15:28:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927691; cv=none;
        d=google.com; s=arc-20160816;
        b=cqC9Icn8OfcmkheSDiuJzKtMXfPw0w+pVewpydI5lnF+zcFGIgK7X8OHnXU6oBVS+q
         5zLpZUpVd3A4y1o3bGXx5JocwHiGpfkC2uwQNPvnEwYUuFFcCYMj7I3O8sBEyIZ0zACb
         H/p1dGzaGqsNxXtgQSle1HNu9AL4ANMHoQ2r9zuuEuHOgx+PabldCMs5nyydwp9FcnRs
         OQ9hrOgn1fjV5RSZdHguaisaHF/PB878I1jJtA6v4uZYM/Y5MPTA2PCF9NXJITxmM3kg
         PWmxLIYh6IvtXy8sRtXJMx/0ZvKDFeb/rE17piGxSU+PRcW0ei+GGhw+g/RGxspyqqYs
         kHqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ENlTYT6F8yKSgZtSKFAMRVhy2HT+kX2kAlJukSMyeJE=;
        b=zSwXms8ocBZBUjsdCWPD/IdGTn2NlLniFfDC50Q8Po7YjqJGtAFi9mxSimb57Oa3/l
         J/scPs8IsE39qH1hqQH/8wN0dB9tGT6JQkvvF4I6z9W9HYGspF9pTUQnklcBevi5VKGS
         y8f+em18Ovj6hF1B1KCvkaWDWVsXQfFzePceRhIxPI6EcajsOj9MMWaNos+uHAfcyKxe
         BMhOx99J5Iym04gVnPsVF/7sSuFwRuke/4icISd2noLjO2ctklfaugL5+BJnUG2jFXsI
         SfcDeBfDAtjC7zYhKk+w0F04QlOsIpv64VK7VxmlLNKrKF71MaV7KXXbufiHszrT/f9n
         caKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SKFOea9c;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12sor148503wru.51.2019.02.11.15.28.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:11 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SKFOea9c;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ENlTYT6F8yKSgZtSKFAMRVhy2HT+kX2kAlJukSMyeJE=;
        b=SKFOea9clX8kUXjGvLOkAz78zIlXk2l9cAAdszRgpu1WF9+EGlYZ09jCNchdkbmaC2
         8XMzc6EJ4es6RG4yfh8iz6ilF2S8pczy501Lmx3sA+5GTPr5jyKxupxht3iJJYNzHPRS
         dO1Oa2gDPDloNIEL1xoGnm/CWJGTqTk1SNhdetFi8dolnrUHFwi/G35FNwjA4uv5Gq6P
         lQIguAmqnvp87zrCaSOSlTQeiVXRq6JEBjr/N+0tXSKavkX6Ny/HsOH/xnab0RoGwCxf
         2KKeYRqX32cxYQVHhTMaY3YMwATRdRiYfiIA4uI0CuPSdMythsBD+LWEu2/dIFo1YPUL
         MQUg==
X-Google-Smtp-Source: AHgI3Ib9SM/GU3OSZIUw9Ef85LumnojTRalWrCht9QSJZfsd1LMbft46iDmaDh0LxziZQABUjeSKgA==
X-Received: by 2002:adf:e290:: with SMTP id v16mr532903wri.100.1549927691315;
        Mon, 11 Feb 2019 15:28:11 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:10 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 02/12] __wr_after_init: x86_64: memset_user()
Date: Tue, 12 Feb 2019 01:27:39 +0200
Message-Id: <afc5b052d43606a3d53e674fb2e36abbf984c516.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

x86_64 specific version of memset() for user space, memset_user()

In the __wr_after_init scenario, write-rare variables have:
- a primary read-only mapping in kernel memory space
- an alternate, writable mapping, implemented as user-space mapping

The write rare implementation expects the arch code to privide a
memset_user() function, which is currently missing.

clear_user() is the base for memset_user()

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/x86/include/asm/uaccess_64.h |  6 ++++
 arch/x86/lib/usercopy_64.c        | 51 +++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index a9d637bc301d..f194bfce4866 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -213,4 +213,10 @@ copy_user_handle_tail(char *to, char *from, unsigned len);
 unsigned long
 mcsafe_handle_tail(char *to, char *from, unsigned len);
 
+unsigned long __must_check
+memset_user(void __user *mem, int c, unsigned long len);
+
+unsigned long __must_check
+__memset_user(void __user *mem, int c, unsigned long len);
+
 #endif /* _ASM_X86_UACCESS_64_H */
diff --git a/arch/x86/lib/usercopy_64.c b/arch/x86/lib/usercopy_64.c
index ee42bb0cbeb3..e61963585354 100644
--- a/arch/x86/lib/usercopy_64.c
+++ b/arch/x86/lib/usercopy_64.c
@@ -9,6 +9,57 @@
 #include <linux/uaccess.h>
 #include <linux/highmem.h>
 
+/*
+ * Memset Userspace
+ */
+
+unsigned long __memset_user(void __user *addr, int c, unsigned long size)
+{
+	long __d0;
+	unsigned long  pattern = 0x0101010101010101UL * (0xFFUL & c);
+
+	might_fault();
+	/* no memory constraint: gcc doesn't know about this memory */
+	stac();
+	asm volatile(
+		"	movq %[pattern], %%rdx\n"
+		"	testq  %[size8],%[size8]\n"
+		"	jz     4f\n"
+		"0:	mov %%rdx,(%[dst])\n"
+		"	addq   $8,%[dst]\n"
+		"	decl %%ecx ; jnz   0b\n"
+		"4:	movq  %[size1],%%rcx\n"
+		"	testl %%ecx,%%ecx\n"
+		"	jz     2f\n"
+		"1:	movb   %%dl,(%[dst])\n"
+		"	incq   %[dst]\n"
+		"	decl %%ecx ; jnz  1b\n"
+		"2:\n"
+		".section .fixup,\"ax\"\n"
+		"3:	lea 0(%[size1],%[size8],8),%[size8]\n"
+		"	jmp 2b\n"
+		".previous\n"
+		_ASM_EXTABLE_UA(0b, 3b)
+		_ASM_EXTABLE_UA(1b, 2b)
+		: [size8] "=&c"(size), [dst] "=&D" (__d0)
+		: [size1] "r" (size & 7), "[size8]" (size / 8),
+		  "[dst]" (addr), [pattern] "r" (pattern)
+		: "rdx");
+
+	clac();
+	return size;
+}
+EXPORT_SYMBOL(__memset_user);
+
+unsigned long memset_user(void __user *to, int c, unsigned long n)
+{
+	if (access_ok(to, n))
+		return __memset_user(to, c, n);
+	return n;
+}
+EXPORT_SYMBOL(memset_user);
+
+
 /*
  * Zero Userspace
  */
-- 
2.19.1

