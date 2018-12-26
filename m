Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EBBEC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 185D2218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 185D2218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7557A8E0011; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 890708E0014; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276788E0015; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D08A8E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f9so15242490pgs.13
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=nOmb6v+nXizyBHW4WE4KtqyuH+NWX1h+e022jm/zANE=;
        b=JTKCEzfzxYEbxwU+gDZwyVlSmcwgsHuxG/v9TXK9bC+rywh74Jf22CZPLU4XEksKZx
         VdaiG+QS+VHxcrnP5ensPC1cnjM7OJjqv/pI7kmJ1kjVKmE3Bgr/q+ugjae/qRxx0Gzh
         8RNJtIEs3kqIBVUykNn3e0xFvigTNmxTJ7hJHjEpFhg4rXSWUe4sqXdimFEaaG6hN4Y6
         hl5ves6CThAktk86sWNWRUNOOgUJaR2b5PMFLuCdEmb5nG9AA4BOqTSGrqNuI2ALjpWA
         1H/K+G4A2QvG2MIvPxo9UlZrpxizsoSFxa/KsS3EfFZWc/y6rq21P9tQJIvcbHDKTLsW
         Hc4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfvID5AiPkkJxOFp/w/R9cUU9fZznHs5nTDAb93yZb21S08JyJI
	eOmVRJax+6I92KuldJOqSJ/mganSJFU18hVR3uwYmQ1v8PVX02eVi1I9JqoyeThlLf+e8gefA+E
	abxShRr/FDfynbkKcU53YOYQ9PswuOrTuqXwhqufaxaphteMi5IQXU+zSG1yBwrL0ZA==
X-Received: by 2002:a63:1c61:: with SMTP id c33mr18519270pgm.354.1545831427816;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN56kcypRc7Jo8+yRCU7wkc/n3cvMDNdtcUZIa1l8Wwvo8mWhkDQ6Ad6c1hx+mt0qZoM3Xce
X-Received: by 2002:a63:1c61:: with SMTP id c33mr18519232pgm.354.1545831427338;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=tH/Y5qSzxcmFz9IAoB8WTFcDKo9fyIr51QMhGZqFhlFI1kAVd9+oHF6Yi9wV156Du9
         djhPGCL+Lyfd6xhVb5tPF5mxJzlWiltmyKM6ebIVbGLkexpSjqYN3CXWeZcghpr5OViS
         EEbjSewyAOE5FhvrzCsPBOEVb9e0eTZYVSKIbx8ISvZwcsQdeAEWNCZLWXFAygwuwU3U
         caFLtLmoO3dAWD5oHmjtaU+vnoHOyjYkZ/SOsC/TaynUIVbMd5rgdDxGxLUIORFFeau1
         GxjzRFVy20Aw4Igk+QczYkXp6U7Edgp1cvgQiS+U9YtuWvA6PnHv+BfqbBrNmM2Ypr9N
         uKTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=nOmb6v+nXizyBHW4WE4KtqyuH+NWX1h+e022jm/zANE=;
        b=DG+Hi5cw1CMRbbwJ6VVaS8/PdAZyBSbOWQd0omH1TtVTE7OhFjxEf4+9IrPoVcgzfc
         g6Do4hjxuz4HFOGBehRl5QgFteJXVV1qri+FT5Urqpp8g8jHdMeZfPMc88jpqZ3eXt8b
         cEDo6eBbfw7qu2mY0hV4WpedFGXxAa1beCd1YlfHE58/RvepDf4AQsWrD7WIYdlvuBX9
         6UXZU2bTJdO7MqJIf8tgbenwEBacQTwEQLJi44r+9U/C28jSFfmsH2Zw2INXt1DpK/2H
         94BTOfLjE7Jm1DX0wwcclbP+YghoJl/POGRCKc9j90/CjNBwBVy0PKkgHQ9OAMfOhVH4
         XVmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358941"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Ot-GK; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.828074959@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Jingqi Liu <jingqi.liu@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 13/21] x86/pgtable: dont check PMD accessed bit
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0006-pgtable-don-t-check-the-page-accessed-bit.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131459.A4apcHnJbJU_stcC81AlIfsJP5ImLGWlyeR8Bf4NmEw@z>

From: Jingqi Liu <jingqi.liu@intel.com>

ept-idle will clear PMD accessed bit to speedup PTE scan -- if the bit
remains unset in the next scan, all the 512 PTEs can be skipped.

So don't complain on !_PAGE_ACCESSED in pmd_bad().

Note that clearing PMD accessed bit has its own cost, the optimization
may only be worthwhile for
- large idle area
- sparsely populated area

Signed-off-by: Jingqi Liu <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/pgtable.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/include/asm/pgtable.h	2018-12-23 19:50:50.917902600 +0800
+++ linux/arch/x86/include/asm/pgtable.h	2018-12-23 19:50:50.913902605 +0800
@@ -821,7 +821,8 @@ static inline pte_t *pte_offset_kernel(p
 
 static inline int pmd_bad(pmd_t pmd)
 {
-	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
+	return (pmd_flags(pmd) & ~(_PAGE_USER | _PAGE_ACCESSED)) !=
+					(_KERNPG_TABLE & ~_PAGE_ACCESSED);
 }
 
 static inline unsigned long pages_to_mb(unsigned long npg)


