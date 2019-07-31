Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DF83C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 353B7208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="wnJQX8mA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 353B7208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED558E0026; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14BAA8E0022; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2E138E0026; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A49868E0022
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so31480795edv.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Eu+g52fZa4bEGKyIAIp4EBxePC6msthuJH3Uu+nPhTw=;
        b=JCzNIsXg0AyBw/TF30uwu/DrpVXt6PejjmMD6//FQCKz+4xk6ZB15/qF+LSUOISRNX
         tFuqHpzpn+YYiZG0UmzO2a3t05MYQkyOexJdOkxnO4Pz1Ca8yLD9wvgAMAkpJdsptREx
         SKTdw5Uml9xUt0WOAmD/26e6Cy6XqOYmlaCF2i2CAmeSo1WpnrPrKrkA1ZNjmX40oSih
         wLH8M+3i5fZhrgrEdRnxVMr/P+sURHQTwlNEdKGnIGYEXBqQojPEEBBNlofku92u0tZ9
         ddjMMPNXhOc+cGBH5Q7ORc9ZYvdaMnOu9N1K2NwWIcCCeYEg0zNJi7DcFRzVO9nQ75lw
         f12g==
X-Gm-Message-State: APjAAAVyW/4PEAR7KlPc/Ze1EaLpeeqqtVQWIIy9uB10powLjsMqPY/p
	YFfXsEJfWFmAMLUK/P4JvPXkHxfRu5bNg9OwxtW/SzT/6rk9oqRNulDTxyESVQcxQQy18bkFF7F
	FLKH2PvnMJJJxPVh/fwLA6rGu0dFCqBm6SaGepcRLwLxQlBSd6BAAo0GF43riJ20=
X-Received: by 2002:a50:9646:: with SMTP id y64mr107648944eda.111.1564586033262;
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
X-Received: by 2002:a50:9646:: with SMTP id y64mr107648827eda.111.1564586032190;
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586032; cv=none;
        d=google.com; s=arc-20160816;
        b=Wq9JmBpDLMoz8UEyj660ZGiNd+uzbgUqBl+3FFIVg39BUQb5VZ8f3UIM6YVOgzJ2jq
         R/YUaQ+6ZXiGZfpsKtorIj027q52PcQJpjLvWZOHUC/csJ/SJdP5ynbAt7MEDUITic1e
         lP5MkgDq6x8Zke9Tal/8lmgwuQrSvQaqRkv6f/GrGpVOPENae3r9K97/yTuvI96WFusi
         0Q5MDIkmgzXeL68QKW6z52We1K3+1MqWZAubOfNQA7JYYcnDto9A3NFDSyyks10y6Bir
         ntkjv1gTZWhHtYo9/3lOdT2U23N+p8ybYGD023Y2YNk+c3+BTdxQKIWGjbqleoT0YWL8
         iopQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Eu+g52fZa4bEGKyIAIp4EBxePC6msthuJH3Uu+nPhTw=;
        b=THoyMWFb801ZvhwdF9WA9RSVWnLhWxPdB+CspdGTbpbx20Prs3B4lUC1YMu0RamMTG
         a59N/Dn94z5N2v1kfGtueD8Mp2Xv9af+HG8UwJkoCRb3t98PD6y+Hl3+qsracuen9cwM
         yC/Bd7RTDT7s2EQnOOZgHnO0zU8w121Cwc46F4if7gMyDSvxgqkMFlyuIfsX5Qc0rqX4
         ATYRwbv3ww5gvCXke0VnFI/s9aZd0F8lbXKO76fDxTCV7KjvwuhIehmGsB5BHqpjKcBy
         p9UaxiuMF3QdvX/rHO3cTvfzHhqLVF/7QYmngHq94fPBqD3xgMYMSnxd9PQgnl0OBHxk
         18zA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wnJQX8mA;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor52104106edg.10.2019.07.31.08.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wnJQX8mA;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Eu+g52fZa4bEGKyIAIp4EBxePC6msthuJH3Uu+nPhTw=;
        b=wnJQX8mAznJJYoCaujK7jTh3QOUX6PWjjuHiLLJcqeV5ss0Z+2QOjKE/V/f7i2iOiK
         nWVMBrRzOEuvD50CqQeMSrlLn2yn9nza0e9HYNf9Ci+gZHXztuPcnXQO8Dv/jueUicfh
         7x8hxn+DoCcOemE+5xb8GVrcsoOF21pEeWL359gwrBqCcOEFkYVISmg99A9v32xeC8nY
         K1fXvjaKfAQ0uf1yUKgRc0FXE0a1c8GjVdeZkh9RF4YCM+ZniD98ehoTPZKfBwPrhyWd
         vT4LGzn8l+GiV/PrV8efZhSU7sLAmcDsKabNfPrtzDTZJ+6VtoCaBOiq1M24C/XlfUJi
         ySJg==
X-Google-Smtp-Source: APXvYqxAI13PpDAJZQellLR+hBXyuxC6IRUxmch2g01/3TCjBtlaolRAKh1msonh8wE/v8SwQy/t/w==
X-Received: by 2002:a50:addc:: with SMTP id b28mr108191573edd.174.1564586031854;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id l2sm16613746edn.59.2019.07.31.08.13.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 7A1691030BB; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 20/59] x86/mm: Handle encrypted memory in page_to_virt() and __pa()
Date: Wed, 31 Jul 2019 18:07:34 +0300
Message-Id: <20190731150813.26289-21-kirill.shutemov@linux.intel.com>
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

Per-KeyID direct mappings require changes into how we find the right
virtual address for a page and virt-to-phys address translations.

page_to_virt() definition overwrites default macros provided by
<linux/mm.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/page.h    | 3 +++
 arch/x86/include/asm/page_64.h | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 39af59487d5f..aff30554f38e 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -72,6 +72,9 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
 extern bool __virt_addr_valid(unsigned long kaddr);
 #define virt_addr_valid(kaddr)	__virt_addr_valid((unsigned long) (kaddr))
 
+#define page_to_virt(x) \
+	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
+
 #endif	/* __ASSEMBLY__ */
 
 #include <asm-generic/memory_model.h>
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index f57fc3cc2246..a4f394e3471d 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -24,7 +24,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
 	/* use the carry flag to determine if x was < __START_KERNEL_map */
 	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
 
-	return x;
+	return x & direct_mapping_mask;
 }
 
 #ifdef CONFIG_DEBUG_VIRTUAL
-- 
2.21.0

