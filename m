Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BEE2C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12185214AE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a0WVV8Kk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12185214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADCF18E0004; Mon, 11 Mar 2019 15:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8C9B8E0002; Mon, 11 Mar 2019 15:59:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97D398E0004; Mon, 11 Mar 2019 15:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 589AE8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:59:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so35171pgu.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:59:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EUuj2VgVnXDPuYpq4H9aIttMM8iEI6Y+lDt9Lz9PsgQ=;
        b=k9WHesUJaGAJ2p5i/u77DIbW4cgfez88rJxlrKwutIhwM8fRvCV0ogIJi5ulbm8Ij/
         w/+icpSyQVYAFgMIHwjuxQs9PfgjKO8nTyBRaaDOj+NcptiQonZxH219dtajQ0iowROY
         68J+T6pOXPgU00REjtCf/ZpBUS+2ZhQ+GQBxi4X7TZtcSSwr5xcHnshOwCSoGY3Oq4dZ
         WZ7d0nVfEILr9yEYiuN3VfxUHpJ8TEK0Oku9uytt/81n7FlYAtzIxHcVGlFh1rokW8Ep
         hi1K/ce9iLSZgONqVFzf03JuqjKIxFvoP0f91tYhhNoxt3SQH+gLmT/vDaEbByHclZLV
         A5xw==
X-Gm-Message-State: APjAAAXvr/ePWQLkd6r4rzmncuWgpRQft/ES13VMbElFJ1NMf578FSLw
	uFi3l2Xm/YiYrfmJnPD2PwXZrb6Ncp3Xy6l31x+nv2sS69ozluV2LJnD5QOLQqMrUO3hYfNifbu
	5Wos9A2WWy/dIJG+Kys9PazeXLo1h9RFp2IR6QR8d6n1/EsbX6BknYolH7UNKekU4jA==
X-Received: by 2002:a17:902:bf41:: with SMTP id u1mr19385092pls.230.1552334372064;
        Mon, 11 Mar 2019 12:59:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0LP3Loe/0WHsuMxeX8uncSUkHwYLG7OZ0WVjkQVVvExprDvQ4BahTs2HOi15dlsIRti07
X-Received: by 2002:a17:902:bf41:: with SMTP id u1mr19385045pls.230.1552334371290;
        Mon, 11 Mar 2019 12:59:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334371; cv=none;
        d=google.com; s=arc-20160816;
        b=WEZ5vuH2RF+eJP6l0+c71mTB9V3N+xwH9DnlAKcQjusaF8teMGwqLkvxpL/MoNkXaR
         EyBZ8JBvMiyGgxYBiBx/mT06Jik53wsoJezZz0EJNN/buDhpgS1Cr5mKDzj7KEihoapt
         Ko6tKKbNFH+oS9jt/BbFxRTpgQowaN5fWSeQleDDziGlca8Il356bELjp7is1vxwASRn
         9k+TUaNzXsM1N7y59KPouFwoSwjIYhRUDZ6ieab/P4ctxkyzNvnYz2c77M20ySx4HC40
         TLGC4jbwZ64ZmpzzgeJTTqtEmD6+nnTuWBs8+oDFoCB/+pTt+0H+QA0WlHPsu7keFvDp
         eR7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EUuj2VgVnXDPuYpq4H9aIttMM8iEI6Y+lDt9Lz9PsgQ=;
        b=yHQebmUeNZIfcXjpgXW20sEZ8mtnY26kftkue89u3pqmfpIWqUE0We+j74gP2DSseQ
         Zk0s86wjCAPIQAzSnm9ryrcaqAjI5F4qeqOgJbXbr6scQu3RfeNRMGfcIJ0bscAXESR3
         3z9y7t9JXT+8sW+AObf+0uDxSJqHQKZp2Jh7fMTmEFUru/kdHrojSWHRdza9/b9xsWgJ
         vhO9e8glEa3J2x82xrUOiImlCyq/loiMt6tJGL2Ce5DYjCs++A5tKsesZdllqcm1dEEt
         B2xDsNZURxLEuVskhuA8Gfm9xaz6+1VTrE21mVXjrtX2lwvM79V6qWK3qiM+LRF8rBqy
         IjdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a0WVV8Kk;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r124si6316847pfr.252.2019.03.11.12.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:59:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a0WVV8Kk;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4DAB42087C;
	Mon, 11 Mar 2019 19:59:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334371;
	bh=XvHTynYYjho/ocuBvOKjHCIiHUp4C0UmYEyfVhjekqQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=a0WVV8KkyLxpevI5Rv79g6hVw5Rtd4PjgspX93GV3IhuC6lPNevqhqElKfRtfH6mn
	 NKRKkY4h14hGdC8g6biGYF/EMBAqq0c31pd8f78+AokwQrMlM3GxWTFVrObD0gf0Ri
	 XRQzMVjRekkCHVZdTiXBMeznPkqg308/7ryslmDw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jann Horn <jannh@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 09/12] mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs
Date: Mon, 11 Mar 2019 15:59:09 -0400
Message-Id: <20190311195912.139410-9-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195912.139410-1-sashal@kernel.org>
References: <20190311195912.139410-1-sashal@kernel.org>
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
index 3af727d95c17..05f141e39ac1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3955,11 +3955,11 @@ void *__alloc_page_frag(struct page_frag_cache *nc,
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
 
@@ -3975,10 +3975,10 @@ void *__alloc_page_frag(struct page_frag_cache *nc,
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

