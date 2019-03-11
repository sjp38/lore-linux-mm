Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC821C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FF08214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="FLkLi8wp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FF08214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DF728E0005; Mon, 11 Mar 2019 15:58:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C5B8E0002; Mon, 11 Mar 2019 15:58:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3F88E0005; Mon, 11 Mar 2019 15:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCCCA8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:58:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q15so6936830pgv.22
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:58:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hpnic7XRoEoqxN2C7gTuYpQA+627IlSX88qWCjzXlJU=;
        b=FiEBCwtdmT8amHrN586bXd7Fpcb0HoDSAdBK0u+DB8ONBUJrgqEd4ilCbj+ZSw9Vyp
         1QISgk3cZPVCDFKAinDgG70jl9q4PzOaDE4Qt34bDqW/eqakOKLdzLThLuWnDuIdiK0Z
         hlR/pUkPEDQeQR61Jn27vd5d5Dub7so4QZUnIOFuF/QBKdngRxwznvHNre/GD2dp697D
         SIvQPuyn5eaYfSc4nqHIHrTc4d2SvxcLypRJZRHHUKCAxcys/mWWCj3WPhaflIACp1wN
         VUHfGbmNMIV/90cTggBonawCvkrivEdERhzVsdb3G3UdxblVuUq9+7NyXjBeWUL7kgWB
         SShA==
X-Gm-Message-State: APjAAAV5ZEZ69X0X6F4HFufrpQGqRsT8wE3b08zH75+zo1D3aVlYpabt
	iyLVJ+Z1H8kqkgD7F81b1gxQM/2nnNNTSBmy1Z5q6FN0RDbCp72S3nqP0qwZ8nV6H4hnGscAuqw
	czyy93wHp4qTuq3bKCoM1ycUokVliYf+y/Utw5sqIWagSQAIeTDKhrctzBAAYrmS0QQ==
X-Received: by 2002:a62:b2d9:: with SMTP id z86mr34939767pfl.255.1552334295466;
        Mon, 11 Mar 2019 12:58:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe3lA+iK9WyW84Vhhvuwm6Vuzz98dO0H1osbiV5WVOgLemgFFA/L+aLkKSA6eRrXA+JY6U
X-Received: by 2002:a62:b2d9:: with SMTP id z86mr34939734pfl.255.1552334294752;
        Mon, 11 Mar 2019 12:58:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334294; cv=none;
        d=google.com; s=arc-20160816;
        b=Z5ZxH0k657inzOYvR3pzc9bhkJxKw5ki/uUdaZjqsQtVooOyls01iuxQzJ+gw4wjzK
         Z/ObSP2evuc0m1yOWdvKhZ/Z6dO7kUPcHz9lh8GG7UzKQRrlblIa7rBGxgupi3wJ8pwW
         HT6DI+7FvfWcDbWXmeZ4aurtWHTR5+7E4yz84CnIdQrUrXIIlL8WQqMtEQzw4eKXC92M
         3+6ZubIya1Oy5s919EjEVYr/xwcuStbEIDtHQn3Qqcn/0TgTAho6+gr6NdW+zC352op9
         nh9i624Hv/qkUBB+hIgBDB49EZR6XZVGhEgN5hbDn/TjxkYp/se60vq9AZFE7YbUflBJ
         WM5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hpnic7XRoEoqxN2C7gTuYpQA+627IlSX88qWCjzXlJU=;
        b=DQbUwqNQeXg05sd5w907F1czB3dYM9gbiTbpKuxsefBPJwoY6lBVI8OGTDiN7a13o6
         w37uOMrU3HRjTQmux81jeoR3Lti0R/exJgqLmljvmmCQr7v1A01zQQxb0xFjYI4rqZhp
         MVuMVfNZEtw0KlH+C3iA0KrT0LvHqYmsqlfjNTRO41XDHVL94+LYyJ2vOSysExEBIu28
         RtEEPUxCDbBe9kozf3VXBDjDwvsIjN5pKJ+0fsMfpJkw/dWu9bMVlOdWJfM4MiS7uhiE
         q20S8r6CAXE0s32k9ty+7ymYHgn1zEThM2IEQBMprVyhbcu06C3eddDUPmlqXoEpzawk
         Cjaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FLkLi8wp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e8si5552103pgb.424.2019.03.11.12.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:58:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FLkLi8wp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BCE9C214AF;
	Mon, 11 Mar 2019 19:58:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334294;
	bh=yi66KY97cAF0XSIlDC5TPtGaTMBs7kCAdK71Hz+5S+g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=FLkLi8wpRxyaprOM6E5FwuyZ+oho7/efHWszerenOv34PPyrZcyIQU56SOms19GFn
	 R9ZezUnuz/XfuMcpQCY6YCrh6PklgwOeIgWZ/5Y2ZVQawrYrXKgVndUPUIrhIZgfOg
	 GTceR/rR1oVPUsYzXyktSb7AT71A7qM9TQYtGCJs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jann Horn <jannh@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 39/44] mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs
Date: Mon, 11 Mar 2019 15:56:55 -0400
Message-Id: <20190311195700.138462-39-sashal@kernel.org>
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

From: Jann Horn <jannh@google.com>

[ Upstream commit 2c2ade81741c66082f8211f0b96cf509cc4c0218 ]

The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
number of references that we might need to create in the fastpath later,
the bump-allocation fastpath only has to modify the non-atomic bias value
that tracks the number of extra references we hold instead of the atomic
refcount. The maximum number of allocations we can serve (under the
assumption that no allocation is made with size 0) is nc->size, so that's
the bias used.

However, even when all memory in the allocation has been given away, a
reference to the page is still held; and in the `offset < 0` slowpath, the
page may be reused if everyone else has dropped their references.
This means that the necessary number of references is actually
`nc->size+1`.

Luckily, from a quick grep, it looks like the only path that can call
page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
requires CAP_NET_ADMIN in the init namespace and is only intended to be
used for kernel testing and fuzzing.

To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
`offset < 0` path, below the virt_to_page() call, and then repeatedly call
writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
with a vector consisting of 15 elements containing 1 byte each.

Signed-off-by: Jann Horn <jannh@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9de1dbb9a6c..ef99971c13dd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4532,11 +4532,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size - 1);
+		page_ref_add(page, size);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		nc->offset = size;
 	}
 
@@ -4552,10 +4552,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
+		set_page_count(page, size + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		offset = size - fragsz;
 	}
 
-- 
2.19.1

