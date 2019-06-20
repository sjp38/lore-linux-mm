Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80FF8C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B4DA20B1F
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B4DA20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D39C66B0005; Thu, 20 Jun 2019 01:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9A08E0002; Thu, 20 Jun 2019 01:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C00878E0001; Thu, 20 Jun 2019 01:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 745986B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:08:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so2578831edr.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SHkC1mZg2rp08rzAypemwkUbAlcN9ysauQkDyXk9YVg=;
        b=Ejgwr/VlByjms82+69sXB2nR2qPip5W3YbiaXb9bhzD5wT0P7oiuRRd4bgbLglbgvP
         dRUDTBfQAsEemeTXO9c5PDtUtEeGzVmE1xqOFpWlM/BVBJyHPoGFmecyw3yUhh8JBfjC
         Y3WQLs8HSIYKAR5oKfyplCKEmpPM4YK256X51oIMwid8z0K+hgYUjE+bzzK6y/GHJ9tZ
         ndVRf/4p7j62WPOFiquYW37cxzobF91F+ld4FksalrC29Q1kKLtqttV94MxJ2u/TtkiO
         H/h4ZAvXs0XHGLZXSYsZw1W/2Uy5KzHWcAPcpZYSGUqebhpNSV7rAw1KnrbZHoIOR87J
         2szA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWgkUpIo+YhSe+iPkwbYBWdbfBUubWW0zq+ONEz3UVoRLSaWq/6
	nidbyfsCcvE4lRT1fcxKjNw9Ab2b1YpxcMpw93LpsKHvLeqfJWMJFOD/3NPzXhWUnrlxoO2lhla
	1JpNX7QslIShbGMr9OF9GaG6XD5e55rKnBD2JycYrXBZhVWRlTJKjpNEi93zokSo=
X-Received: by 2002:a17:906:1181:: with SMTP id n1mr78563041eja.177.1561007323984;
        Wed, 19 Jun 2019 22:08:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3beSdzdWr8RBBRU3pjVr7aHnM0jAi+VWDDFM8iarQmqAvFbYInex+zBgpwdSNxcNH4Mdo
X-Received: by 2002:a17:906:1181:: with SMTP id n1mr78563019eja.177.1561007323222;
        Wed, 19 Jun 2019 22:08:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007323; cv=none;
        d=google.com; s=arc-20160816;
        b=BkWSPSHuS2gdmpqP93EkZRyQ5GVbrA19Idahw2CKy71XPAeQGIWGvnMg3P6WubB50t
         Rx6Y6lY2iEW2RXjRriS2vyV7EdZWwdTlNQGa8c0MZ0GZ94UNCFTdAPG/yMrDLgpDOIU8
         SnSYdqRE7y+QrK6jYKjdGN80lSoU3F5qTSyx/VM0NU8AgIWOMCGs7ycOfI6iVI0Q5+fF
         yL/mKN9gCnvIEkwBEHKUKsDRkLuTuYVILR7zzriFkE3nM25TjEdHjt4hKPKAg5gvhTcU
         W/jONH6l2XijrYtGCdfe01qzXjVvvSLl/0UnKdKkqjTFEpCx33EZybgeZmSvRNKxN4Ji
         H1ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SHkC1mZg2rp08rzAypemwkUbAlcN9ysauQkDyXk9YVg=;
        b=0XDI05OjG9K3rzz7GjWGcw3ps+jOD8KKFyQcjLdJMMN9y72F7H+eoULcRUOngVrw98
         /vxNSG3NrEcK8RMPU5SjgbKXhnLf8JBwbJQS+12U6lFlYvFesM99MJQrA9ycZ2S11dxd
         REE6eEWIkFI5dHreRFgJbXr0Ed/Syy4KT1DZJ5XRiZWRU7gDuzvANB3UHNEA0e+ilq4d
         9SSro+UK1OovyF/kRrVXOMrlW1zVEZ51mIgOuFTD6rnn/5wW8u2nHlW1vMtZaDj3NjST
         y7wxX2hUMkXKu1vH3COZG8DwraE7OjWGnwF3z6GghTcSKSZb2BBWNZqtfmev8unxlzg9
         NcfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id v4si6990278eja.213.2019.06.19.22.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:08:43 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 08AE424000A;
	Thu, 20 Jun 2019 05:08:33 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 4/8] x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
Date: Thu, 20 Jun 2019 01:03:24 -0400
Message-Id: <20190620050328.8942-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of mmap failure in top-down mode, there is no need to go through
the whole address space again for the bottom-up fallback: the goal of this
fallback is to find, as a last resort, space between the top-down mmap base
and the stack, which is the only place not covered by the top-down mmap.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/x86/mm/hugetlbpage.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index fab095362c50..4b90339aef50 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -106,11 +106,12 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 {
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
+	unsigned long mmap_base = get_mmap_base(0);
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = get_mmap_base(0);
+	info.high_limit = mmap_base;
 
 	/*
 	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
@@ -132,7 +133,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mmap_base;
 		info.high_limit = TASK_SIZE_LOW;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

