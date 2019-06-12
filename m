Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 172A5C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B50AB215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:10:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="fUzZrGvA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50AB215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52F1A6B000D; Wed, 12 Jun 2019 13:10:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B9376B000E; Wed, 12 Jun 2019 13:10:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 359756B0010; Wed, 12 Jun 2019 13:10:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9CA6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:10:06 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id d139so957673vsc.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RGV2nXv0tDBodUuIHbEss/S4uQOCZyMq1lOqu82Edzk=;
        b=ZWspTScoHIlbTavXpmF/8LDpokQqyVRG4ZAd690CSwywXBpZASmRpe0bsCYOkis4pj
         ea71fUnni4ZoRehdM1PBePTV3OAhj2DkreMSkaDRnkBD3OLPOAsHxQTlOLq9IDb0LGaQ
         CsD+k7G5sWt/Rsi3apJj0/FPm3WYtYWor0E7oRWCQgsHXwS0iLEnDUtgIxPd3RE4izyD
         flk95mMBrHKoUNplukgs3/cytEy5mQ6aNNOSb6KZD9CZGssEwhtpNQXnDp3IuHL9cHmL
         oMWBiflWtha0RvN7PqtB4RsGsQLfKXnOelsf9Rz6aUg9cfryt/6zkh15HYLBA2FjKnV9
         mc0g==
X-Gm-Message-State: APjAAAU9B1vsa1oop7JUg+M8h3pbxrSRgKAXPEa/1J/h7c9/nqztWVSp
	L8+FpcTN7ASZDPdOoBGTD4XdiHyneNJVABrNiKFIq1WOghtyxj1dONEv7ggSn29pJsADgcC+NpU
	tRZqWrP/060aln4FQwrK4nBurtN4s4qdqUw6VUCvxNkQ2mT4K2VlBG3kevyBcMea/IQ==
X-Received: by 2002:a67:1605:: with SMTP id 5mr30245967vsw.26.1560359405706;
        Wed, 12 Jun 2019 10:10:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNE++qx9JHr2xl4F6a60Ga69Uiegj4W3KGOg5T3b3FrpTGmcWTqVn5xVwq8hG7GOrdXNdt
X-Received: by 2002:a67:1605:: with SMTP id 5mr30245896vsw.26.1560359405117;
        Wed, 12 Jun 2019 10:10:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359405; cv=none;
        d=google.com; s=arc-20160816;
        b=SJ6EPkLZVa35N7YGfLRnML2xpieF17n7uhkGFO80fxQ8fA+NCz2uIEkCauadxtXuqK
         QeQUXHmM/KEaaE87sLT2lCF9zx2ce+Q8bUdcvGLFfxTUbB6DqYIVpP1xTMTk9+duORJw
         qrRUq37qpNrorbIqCm5BG5L3WOHZZELfQwpcshSvrhyhQSvbC3HYWUnKvVxla3aUoCe2
         YHmREU169biLlFwlYJPMzRV19t5pQj5svsxH3evLqqFt9/sc3OBy59LkJR/afudqY74V
         YlW8FdC2ySy9ob1/wYd5KjyWStCXJJEzZfdh6cQRKeCsQ9FJnTj6P+8+Dr4h9jWHNGW4
         H/4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RGV2nXv0tDBodUuIHbEss/S4uQOCZyMq1lOqu82Edzk=;
        b=Ofpb3Oouvp/I+9sOirXYW/XHs4sA0142PUkyPKJFEj+RzvjA1iaTkzXPojKnxiJeWF
         VyDVwsQgz1XOqgYt+6/pVbjVz8ZLNJMI/FDP1wLTIP1fnrGGh4Fw/36gH+DAJL+Ko+v3
         i9mq2m0HWBUFIqZu3fIKXfuEYxjBcPE6Be2wfCukx4u6jMxSjnG4L6Oeo/xA+47ekPu1
         JxvNkD3X/01iWoSDvVX6yMPF9FKE2jLD2QriG7Go+KuV9ZvA/4RyS0OwBdi4clruQ3Mp
         IxFV4q464Ly7VCieJYY+T2vDgQNw1LoELxoyYQLYnIVAyg2auQ+tKmUvGdaA86wvxzRd
         9+Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=fUzZrGvA;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.48.154 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com. [52.95.48.154])
        by mx.google.com with ESMTPS id a22si76685vsq.180.2019.06.12.10.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:10:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.48.154 as permitted sender) client-ip=52.95.48.154;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=fUzZrGvA;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.48.154 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359405; x=1591895405;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=RGV2nXv0tDBodUuIHbEss/S4uQOCZyMq1lOqu82Edzk=;
  b=fUzZrGvA6Fc5l5xPT60CAit2NcoQyNcptxu+f3h6FWfQFqRjf3sJRRJ0
   gmOawV7Nju6Yj2heEQBGIHtzbIry6rit8cIpHHoIfE70p1qYmtzIFKNGP
   9uFAtDEaxwFh0qTKR47oggejyyGkxtYWZeOl7yXtEnE42e8bBh7HfqE6Q
   w=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="400444646"
Received: from iad6-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-1d-9ec21598.us-east-1.amazon.com) ([10.124.125.6])
  by smtp-border-fw-out-6001.iad6.amazon.com with ESMTP; 12 Jun 2019 17:10:03 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (iad7-ws-svc-lb50-vlan3.amazon.com [10.0.93.214])
	by email-inbound-relay-1d-9ec21598.us-east-1.amazon.com (Postfix) with ESMTPS id 43F06A258B;
	Wed, 12 Jun 2019 17:10:02 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CH9x1s017050;
	Wed, 12 Jun 2019 19:09:59 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CH9xNm017043;
	Wed, 12 Jun 2019 19:09:59 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
Subject: [RFC 01/10] x86/mm/kaslr: refactor to use enum indices for regions
Date: Wed, 12 Jun 2019 19:08:26 +0200
Message-Id: <20190612170834.14855-2-mhillenb@amazon.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
References: <20190612170834.14855-1-mhillenb@amazon.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The KASLR randomization code currently refers to specific regions, such
as the vmalloc area, by literal indices into an array. When adding new
regions, we have to be careful to also change all indices that may
potentially change. Avoid that risk by introducing an enum used as
indices.

Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/mm/kaslr.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 3f452ffed7e9..c455f1ffba29 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -41,6 +41,12 @@
  */
 static const unsigned long vaddr_end = CPU_ENTRY_AREA_BASE;
 
+enum {
+	PHYSMAP,
+	VMALLOC,
+	VMMEMMAP,
+};
+
 /*
  * Memory regions randomized by KASLR (except modules that use a separate logic
  * earlier during boot). The list is ordered based on virtual addresses. This
@@ -50,9 +56,9 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 0 },
-	{ &vmalloc_base, 0 },
-	{ &vmemmap_base, 1 },
+	[PHYSMAP] = { &page_offset_base, 0 },
+	[VMALLOC] = { &vmalloc_base, 0 },
+	[VMMEMMAP] = { &vmemmap_base, 1 },
 };
 
 /* Get size in bytes used by the memory region */
@@ -94,20 +100,20 @@ void __init kernel_randomize_memory(void)
 	if (!kaslr_memory_enabled())
 		return;
 
-	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
-	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
+	kaslr_regions[PHYSMAP].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+	kaslr_regions[VMALLOC].size_tb = VMALLOC_SIZE_TB;
 
 	/*
 	 * Update Physical memory mapping to available and
 	 * add padding if needed (especially for memory hotplug support).
 	 */
-	BUG_ON(kaslr_regions[0].base != &page_offset_base);
+	BUG_ON(kaslr_regions[PHYSMAP].base != &page_offset_base);
 	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
 		CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING;
 
 	/* Adapt phyiscal memory region size based on available memory */
-	if (memory_tb < kaslr_regions[0].size_tb)
-		kaslr_regions[0].size_tb = memory_tb;
+	if (memory_tb < kaslr_regions[PHYSMAP].size_tb)
+		kaslr_regions[PHYSMAP].size_tb = memory_tb;
 
 	/* Calculate entropy available between regions */
 	remain_entropy = vaddr_end - vaddr_start;
-- 
2.21.0

