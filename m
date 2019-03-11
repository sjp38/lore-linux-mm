Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8E1BC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 635E82183F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RfbepiC/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 635E82183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F18A8E0008; Mon, 11 Mar 2019 15:59:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A3BB8E0002; Mon, 11 Mar 2019 15:59:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFCFA8E0008; Mon, 11 Mar 2019 15:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C31DE8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:59:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o24so20559pgh.5
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:59:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ESX7IdAvz42ngmldNYkizdOTV6gLyVtiW1vpfgoqT4Q=;
        b=AJ21TMs0hdLzY+xqTo0jj/SWwEFIhVYGCQy2EgwZS7kup5kKNElgSGkf7UeC+FaYTc
         a7f9nt/kpC62thtblBUXhO8IkbEXQHwKMs4rBHI8lc5YQOfmhQD3qLSUhAmJCFShE1bi
         w7c/XGG+rqFa++IFhcKDOvAgJBT8HGDW4TO5s9vW/dbYbEaUMSCHX0dY9aN75J80wl9U
         tlRcsgKo/L/9pPOOq3/vm/sviH1SyBz2PpGjMrkE1bjFUZZKrpPCXI4fh+ELwI5gX+Z1
         Eoisz5B2hS802Od8D+88AouP5+xYRoG/PrjA4+E7omx801nNw61z17Es+DnBniBdCehI
         rvEw==
X-Gm-Message-State: APjAAAUfEogdPyn1vM9zgL+Op72d/4oazRiP7s1SPZjcoDC0VLyociRL
	C55RHI8POg8XUdswWjuOBVm7xxHqkamid6e3gYI9ePATR6Z+MpTzVZegh0utTiDfn95Tzh4NuP5
	KVuo9oavSoYD80VtWRY624LcmSY9x0T8mTIsPbNRqbI8WHqpBLs5nyWGd7rOfZ/mszA==
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr35697511plb.192.1552334343499;
        Mon, 11 Mar 2019 12:59:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzspgy2YdxsN7cpH48W4pigeQn+FoajY8BFDPgJpwDkAI22u3ozqoKGHX5BJCKtl1ARkPkM
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr35697477plb.192.1552334342821;
        Mon, 11 Mar 2019 12:59:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334342; cv=none;
        d=google.com; s=arc-20160816;
        b=Q0jBfaEUKaDLJZWkZZLoNznAHGrtbKr6rB+uenLWQdkaL9Zw+cUElEZrtOSBr+X6rX
         bEcuzRDGTowlP6Qn9TagGpdlxgvLNWub7Nk5mvZdcja1+CLIcXXs/xNBCraZRZoKLsM4
         YtFj5Cy10EB6vrlBjDtBokRQKiqxTNM+Sd1LOKJ8ZN14fAoJeofL6ni0U1lP5iQvxggO
         v7+W7pX5Chv72VAiPUNOQspOcfMxAXLQGIQyVvubiWva42jel/6hCcpkalYrkueA941C
         DPkeZKriymLCLjVFtFAgeHr1KrJGMUp592lcZATGP+5Y6b0jfSERxFOpJNAvUkFVTEiW
         PYAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ESX7IdAvz42ngmldNYkizdOTV6gLyVtiW1vpfgoqT4Q=;
        b=dWctMEVLFNv5KglcuK3LtTrT3LhnlGdu2BIXuaGpCfMd6oyBsa6NalrcALgoMcH0Ar
         nzgVmwuXWn4WqFNwVBw/gsdkCMqLrgjYiY14B5fWhqFIlHCmAuA/J4QqrmhqkaBzNAhh
         C7AJZyzlgvUssMFTInNNg2LopNIwYSneAa9PNWNEgO+HUtHL5Eh4j+Kryjo2gc9UjQVJ
         Jj6TWnkvqJL/X5i2sGkBHfeBzxVEpt9UZGuU4kM2sOz++muw9oODdR64UjMQ2LPQMRf5
         hQUbAHOyLikSryHvdrwca4T7ByRxXONEbduE6pRMdcwxpFPjAxzXAEIR60Uye/4IQNR2
         ls/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="RfbepiC/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c24si5758049pgj.502.2019.03.11.12.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:59:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="RfbepiC/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CB58F214AF;
	Mon, 11 Mar 2019 19:59:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334342;
	bh=/C0Rr+QcsUvShRu52reegxtwUeDSEhvZY9MZp0cZX+E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RfbepiC/qEXAqD8WLR0jzfE5Tt10ctMQQprGIo0ulCFnGK4mKABAVP7vVYzOaW+2o
	 tUgkDxgdrGk+YjCSfo9LetfGyAHIiF7D6iRxtDUUYu2hNjxCIJl7Hu7tyqKLRm2kvQ
	 qsY1D9QjdRvEVkzuW8MxV1ci6x7bn+tWhg+L8fNA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jann Horn <jannh@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 22/27] mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs
Date: Mon, 11 Mar 2019 15:58:19 -0400
Message-Id: <20190311195824.139043-22-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195824.139043-1-sashal@kernel.org>
References: <20190311195824.139043-1-sashal@kernel.org>
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
index a2f365f40433..40075c1946b3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4325,11 +4325,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
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
 
@@ -4345,10 +4345,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
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

