Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B0EDC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFC5F2343B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="D50zJ+/7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFC5F2343B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 973646B000D; Fri, 30 Aug 2019 19:04:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FBF36B000E; Fri, 30 Aug 2019 19:04:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812D16B0010; Fri, 30 Aug 2019 19:04:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0135.hostedemail.com [216.40.44.135])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD0F6B000D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:46 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 15EAD181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:46 +0000 (UTC)
X-FDA: 75880625772.12.dress82_29943eabde663
X-HE-Tag: dress82_29943eabde663
X-Filterd-Recvd-Size: 2412
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:45 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5F16123697;
	Fri, 30 Aug 2019 23:04:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206284;
	bh=a37g0eP2XAZbu1KkdNxknxGq8kdrXBvTIl3LceIVzJk=;
	h=Date:From:To:Subject:From;
	b=D50zJ+/7TJiChRwSBFsyggfPRHNBiWXozCS9CKsfryFxfXtBrLJpp8zFoOkoBuiiU
	 brXgdRijMDSj4J3mucymVK/vK+v6T3N8rsaHi5DZW/NDZjPuSmfiT5/BNP3iRBljgI
	 21aT/zLDBedp+gc4RKNHRxEpsjrXbRfuS9efSo/Y=
Date: Fri, 30 Aug 2019 16:04:43 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, gustavo@embeddedor.com,
 henrywolfeburns@gmail.com, linux-mm@kvack.org,
 mm-commits@vger.kernel.org, shakeelb@google.com,
 torvalds@linux-foundation.org, vitalywool@gmail.com
Subject:  [patch 4/7] mm/z3fold.c: fix lock/unlock imbalance in
 z3fold_page_isolate
Message-ID: <20190830230443.qFvaKz7QH%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: mm/z3fold.c: fix lock/unlock imbalance in z3fold_page_isolate

Fix lock/unlock imbalance by unlocking *zhdr* before return.

Addresses Coverity ID 1452811 ("Missing unlock")

Link: http://lkml.kernel.org/r/20190826030634.GA4379@embeddedor
Fixes: d776aaa9895e ("mm/z3fold.c: fix race between migration and destruction")
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Henry Burns <henrywolfeburns@gmail.com>
Cc: Vitaly Wool <vitalywool@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/z3fold.c |    1 +
 1 file changed, 1 insertion(+)

--- a/mm/z3fold.c~mm-z3foldc-fix-lock-unlock-imbalance-in-z3fold_page_isolate
+++ a/mm/z3fold.c
@@ -1406,6 +1406,7 @@ static bool z3fold_page_isolate(struct p
 				 * should freak out.
 				 */
 				WARN(1, "Z3fold is experiencing kref problems\n");
+				z3fold_page_unlock(zhdr);
 				return false;
 			}
 			z3fold_page_unlock(zhdr);
_

