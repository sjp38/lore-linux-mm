Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83402C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28EFB20811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="W6LsTVjH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28EFB20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74326B0007; Thu, 28 Mar 2019 11:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF74F6B0008; Thu, 28 Mar 2019 11:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C04E6B000A; Thu, 28 Mar 2019 11:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B20A6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:00:21 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u18so9307068wrp.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=wvpTucTNUo5TPeOa8kyd7/Y99PlFK6jfFJo0+kyHjCQ=;
        b=SV51U1t+smZyL0qOe/sLsgAdc/PquJMUBUHM5VUEHhSIfTM6F5cRLOtVuthhtU18Kb
         OZM4LAURNksUm08OGSkPXowh/CWhEPANhxvB8ozux4MGtUF3aljStOdmkfX3tj0Gx/ko
         FPh3i5MEkHIfx64sapj+X7rG8KlV6hxT5ID1VirMTEyRwUrbwGU6ACuLMmfBgNPTSc/p
         V9DSTGiLCxdkwRe9PYAzIjFACPT+gxbOL8INR1nM6jI4wkPkwsNQTs1cnkzyYz9E6oC5
         HoABe6EI9EWfnwEqCy6wStzPY7L+4XDVJbko2DaNKvE48CnTeO3jAjcrI0bamSSWcXxd
         5ttg==
X-Gm-Message-State: APjAAAViemw98I3qmxyZ4RxLzdIFqpikDU34VCICKRtTHa5km3WrvmgE
	9nOZnzVR3HJsn5B5lJ6MTW2ITTuO+Ug/bo+5yA85WvesluwyzcTfVuQwiiBvCXcAEBd9mLeQ08/
	rGUc5BEwo2bK6Q4ohs/hWtxSbc7aczkcvJnxVPaK0hDH2MwkreRZyJa709iaaeVT+Yw==
X-Received: by 2002:a7b:c00e:: with SMTP id c14mr292786wmb.110.1553785220724;
        Thu, 28 Mar 2019 08:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyycmw7/EjhNp5tqPHQpZESdgN3qR9DzAcHnBC9V7vOVx7gF5vBET29uaBszOn7IenogL5
X-Received: by 2002:a7b:c00e:: with SMTP id c14mr292710wmb.110.1553785219460;
        Thu, 28 Mar 2019 08:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785219; cv=none;
        d=google.com; s=arc-20160816;
        b=x/wYnB3C0JhAAp+WdxBFoyd9w2pVGloPlRSVRtl0kNtJJSyWzui5SYXQ9Gf2Db+9iJ
         2ooanxnRMoVc6kFIzK3VQwM7VwVkapTAM6IZXRfX54B6OoorGNJ2xrIqszZEMU/6MrYr
         +T8jVPfI4eTiivNXzN2Tu8xca6KU0mxOr2Af5cvtJOsxrjGNatX1OxXSoLvvNOs8/QR+
         GMoQlcu1TBeB9WxLz3JoY1PEPnvp4dCYllZbAMrRvKnmIfmYEz5GfQMs2yTlbMH7UM81
         Xz5yjlphEdgHZAxBD3/hVBtXgaJz+/S4ak0vzOaZaRIacjX0dyCE7RegJVuytBibjih4
         +bwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=wvpTucTNUo5TPeOa8kyd7/Y99PlFK6jfFJo0+kyHjCQ=;
        b=xSdmAS0Zq8aZQ1w2pp/VeDWZ3LhScly1jg1mnoa4jr0JI52n6GQmheHAgKnOLPOusx
         O/oMyX7+t/ZZUKDdR/zUcIJd9251X6vvJ/YtdgvwcElpZv7XSXzcRPtBUN2ct1vVuFyw
         z8pGb2I53hVtJ7IJnP5akiqpuUL0lRyizsDYSmCdaqFkjt8g2/o7W8dhke7hX8YMDlMj
         cOOvXTyBPqO7yJkA4PcC8igTpS2PVDW4GWQtNkbs09LQBPApAwUXG9viDnB61LKnarcs
         9fHiBLyth8pepCAlhyIsZS5Shru7DxkLQRw0ryGugeYIu6AyEf+JGoEiKoNSHS7cKUxG
         1UGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=W6LsTVjH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id c16si13069658wro.273.2019.03.28.08.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=W6LsTVjH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44VShx2vGFz9v2Hg;
	Thu, 28 Mar 2019 16:00:17 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=W6LsTVjH; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id K2HjoE25HR_r; Thu, 28 Mar 2019 16:00:17 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44VShx1Ktxz9v2HP;
	Thu, 28 Mar 2019 16:00:17 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553785217; bh=wvpTucTNUo5TPeOa8kyd7/Y99PlFK6jfFJo0+kyHjCQ=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=W6LsTVjHKr5KWIF4f5oiZ5nY3dlsndSmK/1nKns9QSFvcx3u4hN9TyMHgKFksONrT
	 PIMKb+LUNfx3XIbLw7WkPYA1Kwu7QFREPjkUORDikvyBukG331e2sLeGeLMtV/7cDK
	 IwtECME/Nz+/TnHnporAMm2Gkgoi9OHa98mKwwzY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 82CAD8B923;
	Thu, 28 Mar 2019 16:00:18 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id CE8y7EQb9ba3; Thu, 28 Mar 2019 16:00:18 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2EC518B91C;
	Thu, 28 Mar 2019 16:00:18 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 05E3B6FC84; Thu, 28 Mar 2019 15:00:18 +0000 (UTC)
Message-Id: <e424bf7dc36ed6598a24dd200e667cd0de9a53c1.1553785019.git.christophe.leroy@c-s.fr>
In-Reply-To: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
References: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v2 2/3] lib/string: move sysfs string functions out of
 string.c
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Thu, 28 Mar 2019 15:00:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to implement interceptors for string functions, move
higher level sysfs related string functions out of string.c

This patch creates a new file named string_sysfs.c

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 v2: restored sysfs_streq() which had been lost in the move.

 lib/Makefile       |  3 +-
 lib/string.c       | 79 ------------------------------------------------
 lib/string_sysfs.c | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 90 insertions(+), 80 deletions(-)
 create mode 100644 lib/string_sysfs.c

diff --git a/lib/Makefile b/lib/Makefile
index 3b08673e8881..30b9b0bfbba9 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -12,12 +12,13 @@ endif
 # flaky coverage that is not a function of syscall inputs. For example,
 # rbtree can be global and individual rotations don't correlate with inputs.
 KCOV_INSTRUMENT_string.o := n
+KCOV_INSTRUMENT_string_sysfs.o := n
 KCOV_INSTRUMENT_rbtree.o := n
 KCOV_INSTRUMENT_list_debug.o := n
 KCOV_INSTRUMENT_debugobjects.o := n
 KCOV_INSTRUMENT_dynamic_debug.o := n
 
-lib-y := ctype.o string.o vsprintf.o cmdline.o \
+lib-y := ctype.o string.o string_sysfs.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o xarray.o \
 	 idr.o int_sqrt.o extable.o \
 	 sha1.o chacha.o irq_regs.o argv_split.o \
diff --git a/lib/string.c b/lib/string.c
index 38e4ca08e757..f3886c5175ac 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -605,85 +605,6 @@ char *strsep(char **s, const char *ct)
 EXPORT_SYMBOL(strsep);
 #endif
 
-/**
- * sysfs_streq - return true if strings are equal, modulo trailing newline
- * @s1: one string
- * @s2: another string
- *
- * This routine returns true iff two strings are equal, treating both
- * NUL and newline-then-NUL as equivalent string terminations.  It's
- * geared for use with sysfs input strings, which generally terminate
- * with newlines but are compared against values without newlines.
- */
-bool sysfs_streq(const char *s1, const char *s2)
-{
-	while (*s1 && *s1 == *s2) {
-		s1++;
-		s2++;
-	}
-
-	if (*s1 == *s2)
-		return true;
-	if (!*s1 && *s2 == '\n' && !s2[1])
-		return true;
-	if (*s1 == '\n' && !s1[1] && !*s2)
-		return true;
-	return false;
-}
-EXPORT_SYMBOL(sysfs_streq);
-
-/**
- * match_string - matches given string in an array
- * @array:	array of strings
- * @n:		number of strings in the array or -1 for NULL terminated arrays
- * @string:	string to match with
- *
- * Return:
- * index of a @string in the @array if matches, or %-EINVAL otherwise.
- */
-int match_string(const char * const *array, size_t n, const char *string)
-{
-	int index;
-	const char *item;
-
-	for (index = 0; index < n; index++) {
-		item = array[index];
-		if (!item)
-			break;
-		if (!strcmp(item, string))
-			return index;
-	}
-
-	return -EINVAL;
-}
-EXPORT_SYMBOL(match_string);
-
-/**
- * __sysfs_match_string - matches given string in an array
- * @array: array of strings
- * @n: number of strings in the array or -1 for NULL terminated arrays
- * @str: string to match with
- *
- * Returns index of @str in the @array or -EINVAL, just like match_string().
- * Uses sysfs_streq instead of strcmp for matching.
- */
-int __sysfs_match_string(const char * const *array, size_t n, const char *str)
-{
-	const char *item;
-	int index;
-
-	for (index = 0; index < n; index++) {
-		item = array[index];
-		if (!item)
-			break;
-		if (sysfs_streq(item, str))
-			return index;
-	}
-
-	return -EINVAL;
-}
-EXPORT_SYMBOL(__sysfs_match_string);
-
 #ifndef __HAVE_ARCH_MEMSET
 /**
  * memset - Fill a region of memory with the given value
diff --git a/lib/string_sysfs.c b/lib/string_sysfs.c
new file mode 100644
index 000000000000..6c6bae70e6f7
--- /dev/null
+++ b/lib/string_sysfs.c
@@ -0,0 +1,88 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * stupid library routines for sysfs
+ *
+ */
+
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/string.h>
+
+/**
+ * sysfs_streq - return true if strings are equal, modulo trailing newline
+ * @s1: one string
+ * @s2: another string
+ *
+ * This routine returns true iff two strings are equal, treating both
+ * NUL and newline-then-NUL as equivalent string terminations.  It's
+ * geared for use with sysfs input strings, which generally terminate
+ * with newlines but are compared against values without newlines.
+ */
+bool sysfs_streq(const char *s1, const char *s2)
+{
+	while (*s1 && *s1 == *s2) {
+		s1++;
+		s2++;
+	}
+
+	if (*s1 == *s2)
+		return true;
+	if (!*s1 && *s2 == '\n' && !s2[1])
+		return true;
+	if (*s1 == '\n' && !s1[1] && !*s2)
+		return true;
+	return false;
+}
+EXPORT_SYMBOL(sysfs_streq);
+
+/**
+ * match_string - matches given string in an array
+ * @array:	array of strings
+ * @n:		number of strings in the array or -1 for NULL terminated arrays
+ * @string:	string to match with
+ *
+ * Return:
+ * index of a @string in the @array if matches, or %-EINVAL otherwise.
+ */
+int match_string(const char * const *array, size_t n, const char *string)
+{
+	int index;
+	const char *item;
+
+	for (index = 0; index < n; index++) {
+		item = array[index];
+		if (!item)
+			break;
+		if (!strcmp(item, string))
+			return index;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(match_string);
+
+/**
+ * __sysfs_match_string - matches given string in an array
+ * @array: array of strings
+ * @n: number of strings in the array or -1 for NULL terminated arrays
+ * @str: string to match with
+ *
+ * Returns index of @str in the @array or -EINVAL, just like match_string().
+ * Uses sysfs_streq instead of strcmp for matching.
+ */
+int __sysfs_match_string(const char * const *array, size_t n, const char *str)
+{
+	const char *item;
+	int index;
+
+	for (index = 0; index < n; index++) {
+		item = array[index];
+		if (!item)
+			break;
+		if (sysfs_streq(item, str))
+			return index;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(__sysfs_match_string);
-- 
2.13.3

