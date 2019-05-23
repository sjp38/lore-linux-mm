Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07065C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1E302133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:20:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="N8/Quhbf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1E302133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 540726B02A3; Thu, 23 May 2019 15:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1D26B02A4; Thu, 23 May 2019 15:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DFC16B02A5; Thu, 23 May 2019 15:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0585C6B02A3
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:20:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w14so4116346plp.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:20:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=CUPIV9x05Ws8OFWxr6c7ccpmnkQnmvfxX07vpw07Tuw=;
        b=iXuh9JJlhSiKG/FUhu5PIc35nIpbTB+BVAGGradJetHnYFkLog2mnV3ggMBHUIc1/K
         8XffRB8Rumem79uVJ1mJvnezPg/eW2nvEJGtnE3aCm7m7ALM3Inw9prxm7bcOIdsXCqv
         pR0sKqY5cjFy8j+e0n0fxo3bEerw5kRkd0GInJyGMSNI6Q1+0QX9ACDB7r0VzkFKTPtR
         +8iCFAT+3ym8bBx1piVG3bb0IpzzrobrMXG+t1+Bi3PL/gzyLqKecWDDyH7FVhjITRpO
         EMKlIlB+WXjzsGqx2119XS1nTbXU912DD+XOEGh7Y73Qca5rriB0O1WhBmpEAdSsotAc
         96NA==
X-Gm-Message-State: APjAAAWu1Qn/8ssvy6im6NW+hHduk2NgV1ow3WQuKQ7OF3HUgv5BzBX6
	1dnGZo+iDWjcPRM2bUwvbgBPiCtzYnESUwPnstHEeoAz68C5ecnGOzQRi6Bu6vOGljnUZsDvmo7
	m7iFDIANsoag2ZLBWCsVuDVLK0nFxWlAToQyiU8JjQgE4/o9QzIP3aEwLfSMXWLbAqg==
X-Received: by 2002:a63:1650:: with SMTP id 16mr6450575pgw.164.1558639256600;
        Thu, 23 May 2019 12:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzP/e1j6GZB7GY0Fnjd0T7zeM/q+kUgzsKHul78chEgWUvIiUVynyA1mFWtM6MeRIwxB3OM
X-Received: by 2002:a63:1650:: with SMTP id 16mr6450505pgw.164.1558639255953;
        Thu, 23 May 2019 12:20:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558639255; cv=none;
        d=google.com; s=arc-20160816;
        b=AompUgQQHxps/wVxCPc1wjAbskHrwdzm+4e9IzpGnvN0d5IT/sulXL0JexMW5JB49i
         RbVQPL1+93Aqq4SBWM3pcJ37zkvCgnH8GVRBLjkDVuY1Z31+ow092RE1E9JJG+IkVL6T
         WHiHC68086hZLXWXjKiF3b96ZIkOESd2PRKmtrJ7mjlH77lgrg4txsPjOSams+EW458e
         pfpb+27WV7P01TD9qMo4C8JY6P92vpB2m01sa7fWjrf04J+SnZyj/i1mBSAClk23LGGv
         3mjB6lgUeE2d5MiEFY/Zg8v7Glp+y+zvT3wIJ/NAvPolmVPkmwL2xAPcpne9vtuarjg0
         aE/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=CUPIV9x05Ws8OFWxr6c7ccpmnkQnmvfxX07vpw07Tuw=;
        b=Hpv2fEvAb5qSlaOAnZWqP/fdpSuoLyjM4TERyjTYuwIO/NFurOevvnZuzoGGxs1M7Z
         FlwV5bSJFEXEF6EMrHW0Pn+uq2Y7Tax2A261OmJtg8P3aUWvAzeA/IFF+b5UeNjpeqtM
         qh+IOSlgTRfIn/Mz5yOodmyQHRCRaubUUgo9RmF8qxBaRDlqg03KaoF9C9jRH8jZ3ZHo
         A3sS/ZSuUPAhcduQmJhLogbfc2OmDQGHAZyA+C+c/kNGsO8lfPC10h55ccXmp6b8Scxf
         tsWephqdqDdUnoztS6IkZSzjcpRGNXR3+s4qNk2jHMg+jT27sONxDJpxtVvZb53XWxQh
         bx1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="N8/Quhbf";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 7si590292pll.99.2019.05.23.12.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 12:20:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="N8/Quhbf";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 20645217D9;
	Thu, 23 May 2019 19:20:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558639255;
	bh=mbmgRkQiwuLf6DbY/gT5XIYsFmE75IZy8W8zEZ8AzcQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=N8/QuhbfUjEN3xFo+w0+EqEx4WdSOaTvugtvpQT6QX8PIKvuh/jMUmT1GqZS7YuH9
	 iWl0ckoQ7lPj/ZovPP2GjJCpDyrUkQbeZ38KZb4W+boZZOsTklVg7AxegxOEPjzgFe
	 Sj1JEyMESuadIm0I0zAV11KQp207xTX5PamOWC4o=
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org,
	Ira Weiny <ira.weiny@intel.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-mm@kvack.org,
	Ingo Molnar <mingo@kernel.org>,
	Justin Forbes <jmforbes@linuxtx.org>
Subject: [PATCH 5.0 019/139] mm/gup: Remove the write parameter from gup_fast_permitted()
Date: Thu, 23 May 2019 21:05:07 +0200
Message-Id: <20190523181723.124661314@linuxfoundation.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523181720.120897565@linuxfoundation.org>
References: <20190523181720.120897565@linuxfoundation.org>
User-Agent: quilt/0.66
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

commit ad8cfb9c42ef83ecf4079bc7d77e6557648e952b upstream.

The 'write' parameter is unused in gup_fast_permitted() so remove it.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20190210223424.13934-1-ira.weiny@intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/pgtable_64.h |    3 +--
 mm/gup.c                          |    6 +++---
 2 files changed, 4 insertions(+), 5 deletions(-)

--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,8 +259,7 @@ extern void init_extra_mapping_uc(unsign
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages,
-		int write)
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1811,7 +1811,7 @@ static void gup_pgd_range(unsigned long
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
+bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
@@ -1853,7 +1853,7 @@ int __get_user_pages_fast(unsigned long
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write, pages, &nr);
 		local_irq_restore(flags);
@@ -1895,7 +1895,7 @@ int get_user_pages_fast(unsigned long st
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, write, pages, &nr);
 		local_irq_enable();


