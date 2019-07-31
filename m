Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E58AAC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA5E820659
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="DnqAXhTZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA5E820659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31B8B8E0040; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27B608E003D; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A9B78E0040; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A836D8E003D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so42633298eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V4Vs01tlfRxj/hdhWvsn+MzzX7wMrP0xYcTZ6W3t7PA=;
        b=LgUjvXtzDmik6fVNp67ej2sSen09tmuSgGRn1XG0deKe7jbrKHs6XmDl3T6OEkhC9y
         SMvTu1gH+gU2uAJz27M1mUp+TuZ1cuIGH0jm/jE6hQT7O/4ewUyXqHIES4n19YcFKu/S
         GeYXqKcZdOeZ3c7HWAGRIReG92gJgUN41UkBQog4BpRSPBXf0SBQZIHsp9eDpKXzHmgU
         htnohaQ9nWJtNd3wpIX8MTHnzOwLFFECQEbK2eVG5CfKdtYvoUYcZJtS36ZeAZNCvj/Q
         anhi2qRYRR29eP16tqFyUEy+6vu/gv46XbauvXi01ncBk3DNW+OnHYRACXfrBKjil+AV
         K8wA==
X-Gm-Message-State: APjAAAW7n2c0QULPsY0oo6nnrqGKHWskytqbIwhloG4QN20zpu9uHX9e
	NdfARi7zMiKvOeX0kkIu1AUlR5hnjHiM4xHCE63TqafofZWToeYhhorsYZ0dGg/2d/nSDwmHErB
	232oFZO/BEPOedL15ADRyuVPQoUHGNvTqVJkHoVC8Zq9JFyqpvH/jmvgPFCbkfKY=
X-Received: by 2002:a50:f599:: with SMTP id u25mr110233055edm.195.1564586632267;
        Wed, 31 Jul 2019 08:23:52 -0700 (PDT)
X-Received: by 2002:a50:f599:: with SMTP id u25mr110232949edm.195.1564586631069;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586631; cv=none;
        d=google.com; s=arc-20160816;
        b=C6SOHEn8pKjjkie/uGvVuxtHe3ZyxhROvQZ0YwTzezQTlG0x64tCdDJso1G15QMwx8
         7Mms3wDAvGi8ludVhd+PgC8fCdQ2r8nNZl38NIyh2LYmt2FqJAvCG1KKgOKpZaax6kIe
         mB+07AGRsV1eoyoSMRwxhaEmVZLGe+Fxiz3AJexmO9pxZ16JoLFDzo/RIOxy4ivYIVwF
         ZxJL0ADq1BdecMByhBWzAejyMCacea31YkNbgW4ifD2uAW6ZdcT8w0weZFCeRuvocile
         URjk6DNQv1a4Zf9ap1Y/LIlu5noZMKAKRBQRUtb+e6pDWdabfFM/efJHMKmI+Zw5wY+H
         Z1Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=V4Vs01tlfRxj/hdhWvsn+MzzX7wMrP0xYcTZ6W3t7PA=;
        b=o/Do23S0nmB7nY14r7HUNXOrv0T8sXyu8WBocDZ020x5qqeOCPbbmJHaNrgc9uNOJU
         lLN3azYM7Beaq0v2s2eZXjCqPKJ0FHMHGozzsMlLQkiM+xyoxrOP2E9Zg88VfDJW78Ca
         emF0PO2eivmtAgzST7H+GPoLqSGCuOj3nCSGXmF9dR12rNdizPswJEsyC1GH3XMKuuDI
         mx/kX2OhATUt//GBq494a6W3sEJubq8BvPtAt/410eA6GKZcANixC+dv5gvgRbSG6Qug
         S9TrMVXH6S6AupciTnplpxAQHoZhZt0SqhZ/U/gzK0zJ4cBYOgC1OVyE3usCNqJe4v3e
         nqPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=DnqAXhTZ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f56sor52039292edd.11.2019.07.31.08.23.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=DnqAXhTZ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=V4Vs01tlfRxj/hdhWvsn+MzzX7wMrP0xYcTZ6W3t7PA=;
        b=DnqAXhTZp01yN6WSw/evIc0boNe52PO2BoJktJtMh2RgostVls+YOyjDU6sjdeAXpu
         pYNcxAcwMJyK9ACo0Uze5/331zleuRgZ8tdMXcyXHPouR7MjjLnzEm4vrrvRLtE8OL+z
         76Cfo0xHGEhi44+MBvlBGlpc/EOvonqmzkGktFkI44+xmuDaiqapmC1Xp/Y9zTg7OInG
         a9YhCGJldybaRAWWZ5RBIZd3ymSs+wsjDNu5AUmyHnhmm+vat7AO8LplmVvMjX0krWt7
         jQavX89FPCTjy4eg6GZ4rPAOp0XfZXIvJviPw7ZSaRn3QUgHcgBLfJ3RAn+sdl9p07vK
         IUrA==
X-Google-Smtp-Source: APXvYqzpD06BRkFUgNWq9pUNA5hd6n+ixu+p9XWwB3ULdCfnwz/4f2lQt2Iw5Gwg1+XUTttxmbAlwg==
X-Received: by 2002:a50:9116:: with SMTP id e22mr108657772eda.161.1564586630746;
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 9sm8073176ejw.63.2019.07.31.08.23.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 6C43A1048A5; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 53/59] x86: Introduce CONFIG_X86_INTEL_MKTME
Date: Wed, 31 Jul 2019 18:08:07 +0300
Message-Id: <20190731150813.26289-54-kirill.shutemov@linux.intel.com>
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

Add new config option to enabled/disable Multi-Key Total Memory
Encryption support.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f2cc88fe8ada..d8551b612f3b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1550,6 +1550,25 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
 	  If set to N, then the encryption of system memory can be
 	  activated with the mem_encrypt=on command line option.
 
+config X86_INTEL_MKTME
+	bool "Intel Multi-Key Total Memory Encryption"
+	depends on X86_64 && CPU_SUP_INTEL && !KASAN
+	select X86_MEM_ENCRYPT_COMMON
+	select PAGE_EXTENSION
+	select KEYS
+	select ACPI_HMAT
+	---help---
+	  Say yes to enable support for Multi-Key Total Memory Encryption.
+	  This requires an Intel processor that has support of the feature.
+
+	  Multikey Total Memory Encryption (MKTME) is a technology that allows
+	  transparent memory encryption in upcoming Intel platforms.
+
+	  MKTME is built on top of TME. TME allows encryption of the entirety
+	  of system memory using a single key. MKTME allows having multiple
+	  encryption domains, each having own key -- different memory pages can
+	  be encrypted with different keys.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
@@ -2220,7 +2239,7 @@ config RANDOMIZE_MEMORY
 
 config MEMORY_PHYSICAL_PADDING
 	hex "Physical memory mapping padding" if EXPERT
-	depends on RANDOMIZE_MEMORY
+	depends on RANDOMIZE_MEMORY || X86_INTEL_MKTME
 	default "0xa" if MEMORY_HOTPLUG
 	default "0x0"
 	range 0x1 0x40 if MEMORY_HOTPLUG
-- 
2.21.0

