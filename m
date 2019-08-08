Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23FFDC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5E562186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:20:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5E562186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A0986B0007; Thu,  8 Aug 2019 02:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 853EE6B0008; Thu,  8 Aug 2019 02:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 740856B000A; Thu,  8 Aug 2019 02:20:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AADA6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:20:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so57581113eds.14
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:20:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LklZI+jjNy9P/Vf1oDAlKWfBdOZ3w4ODTtcULXIYH+w=;
        b=Ort5jjXsPP4zW9exHzbDeYgE3Gh5oisY0x+gpqe6n4lia6oPwCnkFNJNzz3cdyotzt
         gkH21Ct/3AEv5x3Um6vcDDWi40JwbgPnf56HcH1WkcKNBDNnf0SCcQdMu0B/gnXsPY3n
         vtEq0iIhD+RTvtpSXJHZHteFWGjBKiJ4udMqHn/pcDTe3MCpRzhXuaHsiEY0WagvawE3
         6sFUr65olvygBn1EviDDjzu2ZeRXnO5yaRCFMPSK28cNKtXI98LmV3MIMI9TP88nfFh/
         XW4EfJiTuuitktZ0ht1gnp0bov5b6nvkV4dZjDpd0qDEDHO6ULEAIx1oLV3oWPHRAQHH
         dhZw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVxINgwbMRo1UpuIsy+efSZQQ/I/Lv2NbbAmFxAaLwkKFx/Wpaa
	yc+YkkMBeEZgJw6yOxDfT2N/vtbeUMBfV6YMv5Jzm0E/7b5mXrYWO4wX3/V857coiysNX7IstUx
	r/18Rx1czEJTwNtXFr3E25QZACWTmmT/098vApMOoO+A4YT19ovOvdHkEVm74LMs=
X-Received: by 2002:a17:906:7013:: with SMTP id n19mr11819621ejj.65.1565245219762;
        Wed, 07 Aug 2019 23:20:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyimpdztY7bSTArR+mzeIO2+bItD68qfYW9osJpimOHZO66DtjELgjjOPfZGax/yJxtqfFb
X-Received: by 2002:a17:906:7013:: with SMTP id n19mr11819567ejj.65.1565245218928;
        Wed, 07 Aug 2019 23:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245218; cv=none;
        d=google.com; s=arc-20160816;
        b=KhdXEbC5Bvss21HqJYU3dSocSqza05KKEzjka1qyF0ImQR9RXeEtn26D7IrGfoobqy
         RTAUstmrBc4ONIxjrwqJBsnzkl0nRUTY9AFce5X/ZNICk0gXNu+IwCVrkVBzuWZbpBOA
         5vp1Py2F/DxgaujDm5JPT2Hm4QIAa6jUk1VpOp5i5CB84DpNhVPPPJd0GtsA4b+txXUb
         W75x3RoFVM93tatPiTKbsDwf8HxkqDfHdKHRBlF7Z5ReTGSOG+S9v3TEnC/dRBhzXAFW
         PH2MZhznB/3esbjoB88uVdsYZ1z3lp41ZctokYGV1lTZMtIER9qHT7ITYwkKuhtpk/vL
         x16A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LklZI+jjNy9P/Vf1oDAlKWfBdOZ3w4ODTtcULXIYH+w=;
        b=YXe1vm2Y3pnOFWti8cKPUxCHOQ8ymJvNp0Do8QRqa/aI54Gw+5sVfn4ULPxY/uBcRf
         kzol3pXD09nyhbUUg+VSp6qe6xrZN9CgDItRVREm6LRDppz7EuDFQWVWNok2ZdqmUoM6
         diIuAsDHGCRIRHRy/jQLj58ZQnWfyXLS3u/BMo345vY0sGkmk7aC8grdIMM831jjYEGA
         vuq1wDaVO6ostA711kUM0uaLPq/+hisGLJVqEi4lfuPPGPqsBNQmuzXsTe42uwp6e9Hw
         QVXsK9Xt21ca8gOo1jU4K3l4ue6q36XkKu4M0gCazJLNrhLNeV1kaHB2G0cVaWPLJdbe
         +mXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id g10si30715191ejj.256.2019.08.07.23.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:20:18 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 50D2420008;
	Thu,  8 Aug 2019 06:20:14 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 02/14] arm64: Make use of is_compat_task instead of hardcoding this test
Date: Thu,  8 Aug 2019 02:17:44 -0400
Message-Id: <20190808061756.19712-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each architecture has its own way to determine if a task is a compat task,
by using is_compat_task in arch_mmap_rnd, it allows more genericity and
then it prepares its moving to mm/.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm64/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index b050641b5139..bb0140afed66 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -43,7 +43,7 @@ unsigned long arch_mmap_rnd(void)
 	unsigned long rnd;
 
 #ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
+	if (is_compat_task())
 		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
 	else
 #endif
-- 
2.20.1

