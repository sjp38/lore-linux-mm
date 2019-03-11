Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 008DFC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0936214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="U5Qd5/op"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0936214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C81A8E0004; Mon, 11 Mar 2019 15:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4752A8E0002; Mon, 11 Mar 2019 15:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 313298E0004; Mon, 11 Mar 2019 15:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E61FB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:58:07 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x17so229355pfn.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:58:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=niT63oOe/Wmp3NNLiwy71/znISgty6aQutF64IIjMnk=;
        b=T8v3LdjELxA3uLYavUREbAAN+3Y+PwyGGlCWU6Z3to4d5Mtln/RfmYLGY2wlCZz4KQ
         F76iIz8frv36LkmzLAnVn1Qwec0xZVBVcn0pBsFAx08u5zJ+elSve3frhh4+KI5ZnnIW
         CKvF4uqZQJMap2e/c8BMoC4rWxBafqN8ipd23nMtBTFbyTpzhK/BQFZ8czsO5p9EhQvr
         MVijZ/j7W8VGCPcmTG3QLYRdsbbepCgyAtxvtEs/3KeZmHAW4LBa8VlWVN5Jt7dBbMGN
         +PkQwX11lOJYsV9/yDedIFjvWUGcZgKxrJhXCI67r6Ly3+qYxEbbPi/DHlG8Nb8t9r5f
         P6qQ==
X-Gm-Message-State: APjAAAWAilMu6jlbHVlHD9X3COKNOsMkujABsEEMg+URmpkLHr+LO8Ul
	eINWlKnQ5hcMHv55sVlIpggD1EFXZdQ0qSpDmoGMHnpiJy5mS+IRPYa5KVXN0PnckXYcp2Rlz44
	v2We6WK+BcHJ+aoWA9rRZok7FE+dsu+LQZ2xY4gjLMTvVgdWI2rRp5JuoABrs/DuLWQ==
X-Received: by 2002:a63:1061:: with SMTP id 33mr31171876pgq.226.1552334287629;
        Mon, 11 Mar 2019 12:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNP9Qvk7q+RgVnWhKSf4JLbZ+BwO3zBeCH0+zhrCtdDOs1JpkawwO05zMYJABQVjx/hAzP
X-Received: by 2002:a63:1061:: with SMTP id 33mr31171838pgq.226.1552334286854;
        Mon, 11 Mar 2019 12:58:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334286; cv=none;
        d=google.com; s=arc-20160816;
        b=kQuMXAYGAD0GYz3+qTbLcEVOdDYqrfAaPfu+VHtgQYVQP8Jd85C5rM0cQbMc+f6xbJ
         iisr25W1/OnRaqcsYrLuAniBC9Bw3qeZbGA2GA92szNG6OfZzIuWT4AP6nCsUHoB2vxH
         Xln4yQyb36LFI+Ih5CFKhJe1EzhMqstFVOcPFjXEhZE4idyOjUkW2Y5wAjX09ts2RI5X
         QibiRWHIxBWcFLSzmT1SvMNxdCWnryO9cg28YYSfs0Icq9igld9nxhf71zN0xG9jDTRR
         TJDGFiqrPoRZXRPz23MyIEFSSj85PrYBDxVEpy5g0S1wtIt4b221VnKeQZ4shc2BE3j4
         gJBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=niT63oOe/Wmp3NNLiwy71/znISgty6aQutF64IIjMnk=;
        b=XRD3jPu3121EGsxlxxy59+EEH0ygmRscLBWtRqx4DYai1CVYozejcwujYrFHBNHbnE
         fn5IzXGB6K1F7WDKPNv12WPyhd3U8LNEXTHApim07907LS8vZ5BqluZncac9IpQy7oh0
         gDS2SH4lAMIddg6OHqvcbZpFtnt0R7VD/vjm3Jy9ZBckw2dku1luAsUTWYD0RVGDu3uy
         4z3oTfNwbCD6aaahRfjZX1LJhN2NEmoRj00Q+67HHyIpsmI0jZJgUoZNdydVXkuLtgaP
         6ncJbJQDopddJzip3dJy8ObeQjjzao7+gXNRRLlAwNR7LikVO3pxi3G01HtCqrCGHJhs
         9xgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="U5Qd5/op";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f18si5417768pgv.253.2019.03.11.12.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:58:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="U5Qd5/op";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6EAA82087C;
	Mon, 11 Mar 2019 19:58:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334286;
	bh=IYP+z8kciYaOnhBA5kVQRQt9GB/ssglnI/dSG0N6ObI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=U5Qd5/opXY9b7BWY704i5lTxxfHEnPLNGxB0LGOvVdiQFXiGw0+myUDSlwvOlC+Ol
	 CDflWQirGo1FLOgKBKQbkVq0lgMs9cSDQTzX76KBC9EbiHQMZFz5QtrGKtQyHKXzKx
	 DyqJOy91XFc4h+Qw8u79hpmD39I86TIvm2cxQ8UQ=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Yang Shi <yang.shi@linaro.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 35/44] Revert "mm: use early_pfn_to_nid in page_ext_init"
Date: Mon, 11 Mar 2019 15:56:51 -0400
Message-Id: <20190311195700.138462-35-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195700.138462-1-sashal@kernel.org>
References: <20190311195700.138462-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 2f1ee0913ce58efe7f18fbd518bd54c598559b89 ]

This reverts commit fe53ca54270a ("mm: use early_pfn_to_nid in
page_ext_init").

When booting a system with "page_owner=on",

start_kernel
  page_ext_init
    invoke_init_callbacks
      init_section_page_ext
        init_page_owner
          init_early_allocated_pages
            init_zones_in_node
              init_pages_in_zone
                lookup_page_ext
                  page_to_nid

The issue here is that page_to_nid() will not work since some page flags
have no node information until later in page_alloc_init_late() due to
DEFERRED_STRUCT_PAGE_INIT.  Hence, it could trigger an out-of-bounds
access with an invalid nid.

  UBSAN: Undefined behaviour in ./include/linux/mm.h:1104:50
  index 7 is out of range for type 'zone [5]'

Also, kernel will panic since flags were poisoned earlier with,

CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_NODE_NOT_IN_PAGE_FLAGS=n

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            memblock_alloc_try_nid_raw

It did not handle it well in init_pages_in_zone() which ends up calling
page_to_nid().

  page:ffffea0004200000 is uninitialized and poisoned
  raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
  raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
  page_owner info is not active (free page?)
  kernel BUG at include/linux/mm.h:990!
  RIP: 0010:init_page_owner+0x486/0x520

This means that assumptions behind commit fe53ca54270a ("mm: use
early_pfn_to_nid in page_ext_init") are incomplete.  Therefore, revert
the commit for now.  A proper way to move the page_owner initialization
to sooner is to hook into memmap initialization.

Link: http://lkml.kernel.org/r/20190115202812.75820-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 init/main.c   | 3 ++-
 mm/page_ext.c | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/init/main.c b/init/main.c
index 18f8f0140fa0..e083fac08aed 100644
--- a/init/main.c
+++ b/init/main.c
@@ -689,7 +689,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	kmemleak_init();
 	debug_objects_mem_init();
 	setup_per_cpu_pageset();
@@ -1140,6 +1139,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initialized. */
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index a9826da84ccb..4961f13b6ec1 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -398,10 +398,8 @@ void __init page_ext_init(void)
 			 * We know some arch can have a nodes layout such as
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
-			 *
-			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (early_pfn_to_nid(pfn) != nid)
+			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.19.1

