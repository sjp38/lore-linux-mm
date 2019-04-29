Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 429D5C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E622B217D4
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="SoX99Cnl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E622B217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B9866B0005; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45C9D6B000A; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AC5C6B0007; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D83FF6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:27:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f7so7915360pgi.20
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:27:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WtBjYoAHkWUE+EmE+Dj18Yw6Y6txgDPtaMz1TSW2Pbs=;
        b=HKYKP9tcManyjnGMurY7y5Hdh2V4QPty5Zx75fOg9d4sirkZvRQ7XwOx9vSj9NQFh4
         FKmamfmQmXIiB7ze3F4jL2vjsW+ToR+qg7/Ff2pUtwbdm8Rh2Npv8W3FnRk53WUmpear
         T2CT2D5hARKKsk/iiatc7EwqnpVri5Bw9Hyu9JY2E+3OB+m1tAczTBbuhKYS5aJuH3Nd
         iTPl0sWrgMBFnUttxdgOz8Cu3YoWoG2f04+YLubqf0zy8GNcphihxn1wbSEZ5RKHLzoL
         b2lTcIjJ3Dek6mMGoL1pkiGbuIdkam5EVZBbAeYqCEWyzBWs9xSJ2jXt+DSE6Cn1CKaD
         zWpA==
X-Gm-Message-State: APjAAAV+oUCvvvdnDT0vab+7qHxdiPulOlW/6JKP/P18WFAthzkeB2+w
	+xv/aQ9S/Iqra0z9nugX25NoFpLcPxhWd6Kv0rBSQqsxm8WZiPqKM+7h6l97UeszA8C4w5yySUj
	OqOxfPLBQWfhYI3f/O8DKgCOwthUvPd9Vh8S7/10e0crZ1KlQXSlRGsNnvPPW1+ABHg==
X-Received: by 2002:a65:62cc:: with SMTP id m12mr62227224pgv.118.1556573278529;
        Mon, 29 Apr 2019 14:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTXxjMtaRoDvl+bIG1L6AGoejdc5ePK5Im1y1y6zn1CApZCygWf8kMO3I02IPbCefWdCk2
X-Received: by 2002:a65:62cc:: with SMTP id m12mr62227166pgv.118.1556573277487;
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573277; cv=none;
        d=google.com; s=arc-20160816;
        b=wJp9fGfyy/AhbAWsxMvQMiXh2EoqUtfi2mn5whk03GLqjJDutH0mv26t1E8+Y4VvPl
         BBTrzwRnJWajK+/UzJ/QF2clcBb61XSqnlAXSaA9dtTZF42L9SZhY0SFKqbo6oLAUHuv
         M+GmWEz4PzA2MfsKq6lCndv2jhRWAyUEieEtRQ7yBN90bbIrAYAaVSmhCOJmvH+HdGTG
         5awPR/DtNu+9v1qcdBPTyPbUILa9XS3EuO2vkm7HvogRI2Mwao4Wwz+ZWaDRg4x7wKAp
         OW3gHAmOZ5fW937EHmmaeqDpjWkDNc31877urLZ9F7hwXzFMBfWWLguJeJjkl4LKQKKY
         g0WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=WtBjYoAHkWUE+EmE+Dj18Yw6Y6txgDPtaMz1TSW2Pbs=;
        b=MJKAVnMUvOkfgQH50k6r1syK/J70KANHSiUV6zDtBD4NyyWjLXZbe6xlsaJu1Lbp7H
         v7KGTu/AJTEsmDUrk3nobrqxmSiSPtYipJsFA3bb1rOMmgyrsaqo/0CrttrUmp9yyyjj
         iRgVomupJb15rT0xghHi5mM6DN8cmeho+2bAr/ArARUHN6d1Yrx1q8apTcIWOldazH9u
         8tZ3KFdWv8XTwLQlnQ/2NRbz8s2J724Uw0FEQI8QjBQrFn1h/J/gAP3UrjVSEEjaisSB
         Jk22xCC5ILlbaIUOg15PiLCo/IDnv6EI7B88TZm0f86XgOCaFQElYak+V1nlPmgcuzq3
         fPUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=SoX99Cnl;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id r77si23694774pgr.140.2019.04.29.14.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=SoX99Cnl;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556573277; x=1588109277;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=674EX0iIftC/tP47ciQ2WAq8p0Blf4MJzfJ6YEpD/54=;
  b=SoX99CnlFJJo//c6xX5H9Fq38DDQIb7J/HoC/6JUdTiVqNGG2hceKu03
   hhlN7f6hkPQM5qIRCRxNWv6iLSYCEqfCD8ZYOnz0Yb+XCLcC/bqhI8+Vd
   mH4ba4RNoGLfPgjgNxL+8//hLFL5tUIV0RjG4rrJqhyNy2PJ0o9JSP68x
   FMngX31hz6VlY2yaWCs6Eo+b6za83fmcjbSJfMin1qO+g3UjOLW/AgBBf
   4W9jlDUdyOMN60s1d9dw9n53aeO9M821ObzHIURj0AZ5Iwc3AT3ptsIR+
   jcGw3s/qAE64nPYKNWuAwfFnPZTFOjCnBw2LWRRRKdPCUgJZUMfwujJ5p
   A==;
X-IronPort-AV: E=Sophos;i="5.60,411,1549900800"; 
   d="scan'208";a="112062158"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 05:27:56 +0800
IronPort-SDR: J3gFcUmKdarFeX2k6ifsZkQ6Xz6oqPSs421Fpnskj5D1L/UTXvv+5PPUE9QJg139BmcrVrbpnJ
 gREpSO4ylOu+9iC0aFcCeSL2Bat7KODMCb9GLKi1YW+XENdo2LAgilm+rM0AMa0xkk75P+M/no
 5taP05xhc+HBbJtbCPxT8M1WFz59khJ8iwb3vFEKVWYxW7hS/ZXFPC5hj6b5VgbMGuY02Pqt3j
 X4afvUtvdUpmkPzEhMeC3v9qTCH4k1Ne64ILPAGFJcWqIgIL5PNZvEcs0S9NGv/K6/yb140rVV
 bhByHuzMQnpd5H9a4CbV5MuT
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 14:04:18 -0700
IronPort-SDR: YKuQOaUGXWtvH6yMxnbX+5T8aKt+xMu1UOys2MqMN9CNGPcNGH4YnoS70RHEai/+/Dum58K/mC
 XFPRVsEpiOt3g5p92g5To6ydWIgV9ypo/MTkjzd06pojtdh+/P/oQUeywSO6jT8onKm5pitIXw
 aaM1FvzE3F8rjP1lzuGf9XKPsK0Q6nceqmHgrOGZaUT7EtHOCWqLPwyq+uZipCVjFTbwv1zRtJ
 cQeDkzSR2TxSz7tEs88qTe1xk1rgl6YPggLJ9AGDzG5yhhpSIJRqxGR/ImMmzo3mU1rODfO2sq
 RXU=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip02.wdc.com with ESMTP; 29 Apr 2019 14:27:56 -0700
From: Atish Patra <atish.patra@wdc.com>
To: linux-kernel@vger.kernel.org
Cc: Atish Patra <atish.patra@wdc.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>,
	Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>,
	Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)),
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v3 2/3] RISC-V: Enable TLBFLUSH counters for debug kernel.
Date: Mon, 29 Apr 2019 14:27:49 -0700
Message-Id: <20190429212750.26165-3-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429212750.26165-1-atish.patra@wdc.com>
References: <20190429212750.26165-1-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The TLB flush counters under vmstat seems to be very helpful while
debugging TLB flush performance in RISC-V.

Add the Kconfig option only for debug kernels.

Signed-off-by: Atish Patra <atish.patra@wdc.com>
---
 arch/riscv/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index eb56c82d8aa1..c1ee876d1e7f 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -49,6 +49,7 @@ config RISCV
 	select GENERIC_IRQ_MULTI_HANDLER
 	select ARCH_HAS_PTE_SPECIAL
 	select HAVE_EBPF_JIT if 64BIT
+	select HAVE_ARCH_DEBUG_TLBFLUSH if DEBUG_KERNEL
 
 config MMU
 	def_bool y
-- 
2.21.0

