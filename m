Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87DB9C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:45:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CCD42171F
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:45:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SqzGa+39"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CCD42171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD846B000A; Mon, 20 May 2019 17:45:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D36BC6B000C; Mon, 20 May 2019 17:45:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD7CF6B000D; Mon, 20 May 2019 17:45:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 801F16B000A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:45:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bg6so9889408plb.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:45:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YUHf7q9iXWCEikBJqRLDYPHkxe+K1g9F0jzW6WB16Gw=;
        b=nNEPATOfRYwBMOZ2YIjyHIB7mQSWVWE14ZnJt12snvR5Jeh1k9lIlTom/qhRRJBejD
         kFmNgM53uF7WxTKxAJjY8dpzxGD+TPB82VDqEQd8krSJWrxsEMR87ddDVM8nrJvHJN1H
         D0DCzjXyoPkGVfSEJIIjP6Wy0bZxRmToSksEH2g/pCSU1zJl4WUps0sNUM9LBiFdrnMF
         qNxJr2Ha3dyV1v3Qf0dGJUvygvM8bgxhNqV87KPpLYhsDMjGAblJ3IFryHw+KacB3p0a
         n9ij2QeOTrjP2p+rL2DjJcquBKo3jrVphh44kF9MgDDXCZyyScc0nqfGVOJ9rKpxzC86
         dpPQ==
X-Gm-Message-State: APjAAAXqdzUwZyE0uA2OddV77VvxKFcjMigWNdw8873spEElexhbJwMp
	PVMTeB5XOTzGs9K07CVe0GsfyBajTgp7n7fk7WUvAt8wm78lwqUmIBrKQG3RjdPJd/94MeGzJz2
	J1XbrdIGVOcnkPgsbGP2Hx5JpXlI6NzFdQE3fyH+wdYmgQeeoNe2Ewx+OA6do5iBrPQ==
X-Received: by 2002:a63:3ece:: with SMTP id l197mr39870830pga.268.1558388729106;
        Mon, 20 May 2019 14:45:29 -0700 (PDT)
X-Received: by 2002:a63:3ece:: with SMTP id l197mr39870792pga.268.1558388728501;
        Mon, 20 May 2019 14:45:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388728; cv=none;
        d=google.com; s=arc-20160816;
        b=akGSMFF1CeRXeT2tEIQg21nDzscgSu4dAmdRInQUbk2E9jO6a2On0MyBuKokpx04cy
         uC+TvHyuTcgw3BLjE+dynGXiLUdkdYCqdISPDqHNqTIFZnN1vtAxiwf3Yp5SNMAlZzXC
         M4Bk8IXFWcNvxGURwn3z93emz1AB7ZI2/U3oBqXMBZqYpUOEksWF/buyv6pTKv8w7/m6
         fYNgpa8ETikLlOkrGVH93EVnx7izSrpTpHADMXNfQt96l3ubfCUfNM1FLsyE+ng+EU35
         9zEdYuk005jWZM7RO5NjEnsRvMjbhhm30EvoOmGvsWI7elFJl4ijwy6yUehxAMzINfwc
         ptkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YUHf7q9iXWCEikBJqRLDYPHkxe+K1g9F0jzW6WB16Gw=;
        b=cOyZKDKJPMJ3MnXyrydqv5Zm93amllYRPw6rLcSdc98oGZPM2XeUwFpbPORl6gq2NK
         vfauu27sziIIsJTKx7lgAiJi0XObTuiu1XQPbPqyt3DRoocv0M1E1UOTTCyP+x8pDW0s
         cF7ja6hju6/mmAILNo4jHO5nu5Ix1/OObvvIXxGfSDIzLCUiWLzVy+7P1d8EDXo1VKOx
         C3cYH/+15juvipqtVTKipji728f5Utfc5LGT4xApOXZNAYpPjl0PK6x8d5MCNH9yW5Hx
         4vI74Nrlpc5btj7P1hcmip1KJJDADNdcivH6WsQIh3cQjaV6Lf34lqGhD9wtsz14LiH4
         qHTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SqzGa+39;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor14914975pgv.0.2019.05.20.14.45.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:45:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SqzGa+39;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YUHf7q9iXWCEikBJqRLDYPHkxe+K1g9F0jzW6WB16Gw=;
        b=SqzGa+39RXJrEiK/aoV7RYVpMOaf6+ADD2GKSHjU5EM9Ck0hSAnWM8ba4z4W+qf3yW
         h5WCMgI9wyUBhVx7XvvC2hBF+aqmsrvvAM9tp/XVqYg9PfsayruOhj7Ef2Ar9EfT8Y9/
         GDU5QBHSyO9SMMRWu0IcsnnuCMUPLv0WRWae8=
X-Google-Smtp-Source: APXvYqyAn4JGhQApOJaJtFSbuuE0hhasC10/gDCL+x2kZA0QSCoJ0zh1W4xStnAS0gUMwwQVOJ7gkA==
X-Received: by 2002:a63:2248:: with SMTP id t8mr34282895pgm.358.1558388728012;
        Mon, 20 May 2019 14:45:28 -0700 (PDT)
Received: from drinkcat2.tpe.corp.google.com ([2401:fa00:1:b:d8b7:33af:adcb:b648])
        by smtp.gmail.com with ESMTPSA id d186sm27681331pfd.183.2019.05.20.14.45.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:45:27 -0700 (PDT)
From: Nicolas Boichat <drinkcat@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
	Nicolas Boichat <drinkcat@chromium.org>,
	Michal Hocko <mhocko@suse.com>,
	Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-mm@kvack.org,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] mm/failslab: By default, do not fail allocations with direct reclaim only
Date: Tue, 21 May 2019 05:45:14 +0800
Message-Id: <20190520214514.81360-1-drinkcat@chromium.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When failslab was originally written, the intention of the
"ignore-gfp-wait" flag default value ("N") was to fail
GFP_ATOMIC allocations. Those were defined as (__GFP_HIGH),
and the code would test for __GFP_WAIT (0x10u).

However, since then, __GFP_WAIT was replaced by __GFP_RECLAIM
(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM), and GFP_ATOMIC is
now defined as (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM).

This means that when the flag is false, almost no allocation
ever fails (as even GFP_ATOMIC allocations contain
___GFP_KSWAPD_RECLAIM).

Restore the original intent of the code, by ignoring calls
that directly reclaim only (__GFP_DIRECT_RECLAIM), and thus,
failing GFP_ATOMIC calls again by default.

Fixes: 71baba4b92dc1fa1 ("mm, page_alloc: rename __GFP_WAIT to __GFP_RECLAIM")
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/failslab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/failslab.c b/mm/failslab.c
index ec5aad211c5be97..f92fed91ac2360a 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -23,7 +23,8 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 	if (gfpflags & __GFP_NOFAIL)
 		return false;
 
-	if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
+	if (failslab.ignore_gfp_reclaim &&
+			(gfpflags & __GFP_DIRECT_RECLAIM))
 		return false;
 
 	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
-- 
2.21.0.1020.gf2820cf01a-goog

