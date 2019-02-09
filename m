Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3608AC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 04:41:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C69AC20869
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 04:41:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Uyx8KnH0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C69AC20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 476EF8E00AF; Fri,  8 Feb 2019 23:41:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44CC78E00AD; Fri,  8 Feb 2019 23:41:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33D088E00AF; Fri,  8 Feb 2019 23:41:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 085978E00AD
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 23:41:52 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m37so5931937qte.10
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 20:41:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=USeCh6j0FsmLopx2MZxpLbxv8BeR2zl+0L2tQUmFxuY=;
        b=f5p9l1f5jjaTcCTQIHw90BJSbjDttfmTB8OhqdekX5h0MnLr2xsXaZ0/s2I7ls1RdP
         C0QSoHvWtlu4eyHdC8h7FtkqwMXT9YYu9iRhlvsY0PsujxKp0QgTW8W3RomVB8teIubx
         KbWW2QTvblEG/V3dlk7kkrbkRZDRKJq/FNsfHYC59486Q/EPky+Yvf0ZPhjXuleEAiBa
         ZQQmSDBDPKhpNlOnajbiOnjzB5waqf0nETAi2wpRRdwmxPDgR8MVl/08RXiu6HFUBt2n
         IDutQXmqw1UPnFqUFmz9EGu0Y0GEfsvLvJkyy7kg+LkV9/ZF/wMFyK40IHdHvUOTFztf
         IlLw==
X-Gm-Message-State: AHQUAub6uHqA57BanGEgeAxGkhGQSDoFbp2tHO+6Bird110Til7DvLs9
	zshiBJM0GlzZFPwXhE5dT0D4YtfyuC/sFKrjUPrZvgmMmM5hqtSD6Wfv63dHKjELgcYViSeAjUq
	hLHKg2GvFjRycLe/snl/h4tamhJuOiWwpJShvrU5volRQ48ETox8FQ2PhXzB60SZAQOj61FA7K5
	sOXOWViIDiTsuEX6EaGxpEklVF5LiaRL1No7tOoldYDVWe3rgMz8mF04UErJ/eotJhSf9KdelY/
	nWqdmpKzJu9BII7hguBTvfeLbvW1C5/4F3QxGg/WFjvoqxDivge5ExYFFUwbKeF/Z4I0ORyu2QV
	d73zUdPHMfl8tUuxO6waRm4MWtaGems1s6PTUVlUa/JYUmoo14b2SBW4u0L0hkkFjOhtoSH80Os
	s
X-Received: by 2002:ac8:3f0f:: with SMTP id c15mr8714218qtk.142.1549687311725;
        Fri, 08 Feb 2019 20:41:51 -0800 (PST)
X-Received: by 2002:ac8:3f0f:: with SMTP id c15mr8714176qtk.142.1549687310428;
        Fri, 08 Feb 2019 20:41:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549687310; cv=none;
        d=google.com; s=arc-20160816;
        b=tKlSECEJE5amwMDy1tT2C+ZBzyg35XxzzFhbVGfAP+1fmehDVeUnlkC5b4cZmWa/L3
         lYd97XQeN7MLIi6Novq9xXLqHESTGpuYtUXYk1/9nN1oNcRX3Mw1RUgv4nBQi7zFIRSL
         NCeJoSMp8RdrION09Or3LTLABhsTmT5SZNDh/L1Kky83xIIq544/xnC1qUk65VkQvqdT
         H8uu7o+bx/ZV/6WONF5oV6S+oPYCx6f1w/YhOdbUDXJwQWwg78aFsOiVYmJDI6WaUkPK
         XHbkmunvbmWGCyt0Pzcc1dNV6LRttP1XYYbNwIbrpuZfg9ijK1JFHtxwm5+2/Z656PY5
         E6YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=USeCh6j0FsmLopx2MZxpLbxv8BeR2zl+0L2tQUmFxuY=;
        b=MSCkY8f4NQFE1UJa+b3Qi7iUrSPJBz9/IngnJiWx3w3rTaUc4ejMLWikAx5ZnXJuc8
         NItXAuTqM5iScyZXRVQXDZeLU8cio8Zq4auAwejlZbeDPbr1njZg/PVE1WHZjqgDTb0J
         YyYcVU2VxeKMcT70wuf8q+cCX9iQh80bWvNSpz+5XKj1IbGDJjs0tl0NKSlySWJQf4fc
         LuA7O5Qa5hw1p/D5mgAXP1BoyFhezg12+I1slthI7MoTNbr/UYXbwD9uoUYfcWyV0Hco
         g6WIK6mJSi5wvwpERGtwFrGm+D69J1h8jWHTT4IWIcTOokUHpcimvTPjjbNQ6RoNvVDP
         oDKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Uyx8KnH0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p32sor4430106qvf.2.2019.02.08.20.41.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 20:41:50 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Uyx8KnH0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=USeCh6j0FsmLopx2MZxpLbxv8BeR2zl+0L2tQUmFxuY=;
        b=Uyx8KnH013ecHNcSjOImmFRrRi/e+kAFqBooYZeje3twAyxLmL8LfEDM1IT4kSf8u2
         /YVdKthWzIS7yxtK5i10pc3c+/5W1oZREDNFnJzz3qHwnAAuzQ/9Fn7R+AzJ7DsKELoB
         m4thanJUTuMXhg/zzwfh7v1TvnaXJ4c1Fp/JJtfTdJTCNutO/mb7n+M8hXaIOgIjE7EO
         hO8lI6qO3hRrBRh66iNwU764tW7W6d+To7SFZP8aSSmy53Ae1AwsoxDSwgr4z3nAxAsI
         bnQ90YffdslRz0Ljzh+QhPXYf3GAWNOtcjAAQG3FWLkTpejmlb837JdmpRdwvGoGv0BR
         8y1w==
X-Google-Smtp-Source: AHgI3IYzSMi38GNhzPEP+51nPuIlZiOKRKouOQIjBm3cBD5rK5Ii5RCR2yrpxd835hPI04jUPpyrtA==
X-Received: by 2002:a0c:8aa1:: with SMTP id 30mr3182502qvv.1.1549687309536;
        Fri, 08 Feb 2019 20:41:49 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id r24sm5147743qtr.2.2019.02.08.20.41.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 20:41:48 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com
Cc: andreyknvl@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slub: fix SLAB_CONSISTENCY_CHECKS + KASAN_SW_TAGS
Date: Fri,  8 Feb 2019 23:41:28 -0500
Message-Id: <20190209044128.3290-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enabling SLUB_DEBUG's SLAB_CONSISTENCY_CHECKS with KASAN_SW_TAGS
triggers endless false positives during boot below due to
check_valid_pointer() checks tagged pointers which have no addresses
that is valid within slab pages.

[    0.000000] BUG radix_tree_node (Tainted: G    B            ): Freelist Pointer check fails
[    0.000000] -----------------------------------------------------------------------------
[    0.000000]
[    0.000000] INFO: Slab 0x(____ptrval____) objects=69 used=69 fp=0x          (null) flags=0x7ffffffc000200
[    0.000000] INFO: Object 0x(____ptrval____) @offset=15060037153926966016 fp=0x(____ptrval____)
[    0.000000]
[    0.000000] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 18 6b 06 00 08 80 ff d0  .........k......
[    0.000000] Object (____ptrval____): 18 6b 06 00 08 80 ff d0 00 00 00 00 00 00 00 00  .k..............
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object (____ptrval____): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Redzone (____ptrval____): bb bb bb bb bb bb bb bb                          ........
[    0.000000] Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B             5.0.0-rc5+ #18
[    0.000000] Call trace:
[    0.000000]  dump_backtrace+0x0/0x450
[    0.000000]  show_stack+0x20/0x2c
[    0.000000]  __dump_stack+0x20/0x28
[    0.000000]  dump_stack+0xa0/0xfc
[    0.000000]  print_trailer+0x1bc/0x1d0
[    0.000000]  object_err+0x40/0x50
[    0.000000]  alloc_debug_processing+0xf0/0x19c
[    0.000000]  ___slab_alloc+0x554/0x704
[    0.000000]  kmem_cache_alloc+0x2f8/0x440
[    0.000000]  radix_tree_node_alloc+0x90/0x2fc
[    0.000000]  idr_get_free+0x1e8/0x6d0
[    0.000000]  idr_alloc_u32+0x11c/0x2a4
[    0.000000]  idr_alloc+0x74/0xe0
[    0.000000]  worker_pool_assign_id+0x5c/0xbc
[    0.000000]  workqueue_init_early+0x49c/0xd50
[    0.000000]  start_kernel+0x52c/0xac4
[    0.000000] FIX radix_tree_node: Marking all objects used
[    0.000000]

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..075ebc529788 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -507,6 +507,7 @@ static inline int check_valid_pointer(struct kmem_cache *s,
 		return 1;
 
 	base = page_address(page);
+	object = kasan_reset_tag(object);
 	object = restore_red_left(s, object);
 	if (object < base || object >= base + page->objects * s->size ||
 		(object - base) % s->size) {
-- 
2.17.2 (Apple Git-113)

