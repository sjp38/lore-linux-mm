Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E989C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 394F020C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="EapzB6nV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 394F020C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC84A8E0022; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 988518E002A; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F0A98E0028; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 132648E0029
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so42642186edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Qu4eqa88cl7hA3fQdb28KWqV5w4hCLiKuLbYR7iJuDE=;
        b=sA+EbHXj4owAMxLGYxcqAbi3WSBX/I4Ya4WAZJ2Yrnr+01Hbut1j9oHi542/zDqPjS
         L60B1w2uY/w/n/yG4B9awfPlrNmK+y3RnFqu1T1adRRwh/dIusj1IabNNNqr8vRaPs+k
         h/r6jJ38Jmt33ffegoR/BQJLHCjkNlh3rFOXdxEwjKN0TmstMA26t0N1EyhTjdEW/Epg
         tnNB2929UBgxqsCJDGPOXiBFxYgZRAWMpiJQEKyetyEbwDJdNPOaFUN+t4zjyFQQKqf4
         PysBqNKcaeBYTV4Fd+ITj/hCKBW+PKzPeA76h3WQeVapCY3O+ARTAIZe22PFOC5s7quf
         XtqQ==
X-Gm-Message-State: APjAAAUAd72ZFMLhWKSinRPvzrfNMIadcfXlf3tjI0vAoPclJVXnFbqT
	cGD6jU5EBilSnGTtVnv7zwrnG86UN0BLVJIB9Xz4delxoT2JR0nSZMFQ4ftemrDLRMgszoRZNmt
	sf7Y65l0yy7RtgFAc8y/FX++GXVw7CyoP7jMQAvLE1M1DocFTjyIqV/wKI/BbKzE=
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr91677079ejr.310.1564586035640;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr91676981ejr.310.1564586034414;
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586034; cv=none;
        d=google.com; s=arc-20160816;
        b=H2yAgZQVolyR5ewfE1gJTyuWfJb16OFKvkRBA1LYkbXY4iZvs+ifrVIuBaPr8NMHYE
         go2H7X2QkKZfZk9MbBjZ5fEKR51RgsIxUkY7yKD4ozHN969HnUQpcIYxyYzm94S74gQt
         FxwUPkFGp1S+f+CMwTh66ehA/5XU+WKYX/HOAslhP9GckSv8uqYnI7QmLsPU+pKGPTMC
         wTzvhx15bTDZVmLPdpHQRzVpri4LLqQdmJToUlKSbFawsgotBIGjiuLHQNQs4n+yZ6YC
         aYS4V0bXSlfHhSk7ikevtKVipfhtSqH79XjAWb0c8jYz8SqdNVyV6Er7NOTJk+4XAxXl
         fPCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Qu4eqa88cl7hA3fQdb28KWqV5w4hCLiKuLbYR7iJuDE=;
        b=VTKl2sEzoDu1W/CiCZf6ZiTLu7v3VD5HsQMgrOMXF/F0BhJyG8rEFYCg+JzdtvXl8q
         OGRRMi9brhJpy8XsDo8QwK1f1ggv75fdhblxjkOo0KHF7HqHec5qOth8C24XTZj0hXpb
         Dxns4VPmf9e2kJcc7irUFN3Sj42vxLfex24vzUXiC/6I2AJNyuuz0lWxUzHXwWdfJ76N
         s0NJVOrmYhKk7kXB8p04mXf2VY68sSVyTveq8k5EqcXL9/Bh37xdmvOQTbb4gigB+6E1
         wArFsJI45rygmWvXYdQyrAaCadoxkEC7NXXAbqHuUgxcEbKbAPZfc6Y3WHEe30ygugSS
         KCzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=EapzB6nV;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e25sor52257906edb.8.2019.07.31.08.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=EapzB6nV;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Qu4eqa88cl7hA3fQdb28KWqV5w4hCLiKuLbYR7iJuDE=;
        b=EapzB6nV2zuG3XXqORhtOg865rDFWXiiuUO8FpJLb/h1WDao3VpOzWeFDmaFbxm/XL
         47TBQ8nUUTf9qkmZiYlrYuMBsFG5TIn6RKRtGHhdoEi679Dd/WD/MF4HtnmQP59r+ZVS
         lWZPfIfuMFEgQo4Y3mbUEU6Vw4ZKVnL+c9FxScjZKMpMrPiR+cuZijKKGYKRXfElKJqa
         Xlf/ibW3jXNNJBvLlFTHpGgT5lOrKP+W2Zir2emFXNHQgTL1ugZEAXaNqYvDXjvvf1sY
         eVxqaYVdOcCPAQPOF9hrrzA0BOHPgcYf40DmCzESR4BUuRMyXnjNV9lnjdj/b1tOOPp+
         BzBA==
X-Google-Smtp-Source: APXvYqx2zTJL6YB+Gc6tZHir/y3NwypWB6AAdiaRHKrntm3SVSrSWzIlrCWGYk+WyVgbmkUaGcUHkg==
X-Received: by 2002:a50:acc6:: with SMTP id x64mr110288029edc.100.1564586034088;
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id oe21sm11729742ejb.44.2019.07.31.08.13.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 172081045FF; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 41/59] mm: Generalize the mprotect implementation to support extensions
Date: Wed, 31 Jul 2019 18:07:55 +0300
Message-Id: <20190731150813.26289-42-kirill.shutemov@linux.intel.com>
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

Today mprotect is implemented to support legacy mprotect behavior
plus an extension for memory protection keys. Make it more generic
so that it can support additional extensions in the future.

This is done is preparation for adding a new system call for memory
encyption keys. The intent is that the new encrypted mprotect will be
another extension to legacy mprotect.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 82d7b194a918..4d55725228e3 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -35,6 +35,8 @@
 
 #include "internal.h"
 
+#define NO_KEY	-1
+
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
@@ -453,9 +455,9 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 }
 
 /*
- * pkey==-1 when doing a legacy mprotect()
+ * When pkey==NO_KEY we get legacy mprotect behavior here.
  */
-static int do_mprotect_pkey(unsigned long start, size_t len,
+static int do_mprotect_ext(unsigned long start, size_t len,
 		unsigned long prot, int pkey)
 {
 	unsigned long nstart, end, tmp, reqprot;
@@ -579,7 +581,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_pkey(start, len, prot, -1);
+	return do_mprotect_ext(start, len, prot, NO_KEY);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -587,7 +589,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_pkey(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
-- 
2.21.0

