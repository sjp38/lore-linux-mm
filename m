Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4014C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DE9120840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="npNbQ9ug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DE9120840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5CBC8E0004; Thu,  7 Mar 2019 13:53:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0C3D8E0002; Thu,  7 Mar 2019 13:53:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFCB18E0004; Thu,  7 Mar 2019 13:53:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A71928E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:53:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p5so16226232qtp.3
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:53:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=p/uycB6wwfQ9mpJ/cDj3nrD1aSO5NRmGJ7t1JhstDM8=;
        b=VxW4VTbKvQjYJcmj52zeO8txIhcaNQ187MGKya9AWOG6cg6ZYTR1d4GFZGbv1xL1cc
         s5hK4iNK3TybgKDdCU1RAadQTAr/zI+SvM1u8JA2gY2D9ikW2eK03IVCawwyrrI/xXPB
         vg8RbDOude5E9pteG4nfcqO+i7nS6JxGwG9G2d+P8rp1axWP30aiVt2Ei5PbkzFhw/HM
         x8sx8or+VzojvBnPECjk8JRsFdKGng1hWtFteY58pdvVzKM8GMK/zUBuEG60DjIoq1Dq
         gxLFCG2gyQw4wgDnuJhcZFGhfWCAmjRt7ioQpxfDRmiQCt7XqLy7EnXxoyTeIlCg6RrM
         9JZA==
X-Gm-Message-State: APjAAAV6Q9URr19XaUk3yZIKONcTexuj98dMjHepcHEChRtts712sktw
	sdmHWXSZWYgd2ej9HeQu4ihHIB7uIElxfMECaozcvQj/Kba4KxLcIT2WyGorHVJlPw0Ii4kOr3m
	hW8VsuyQ9Rioec1L1UTNDBBP41BdPjGZ6WNFBrpg2eyDm7GaE0Kqch4bkfg8M5zxiQBwxck2xkm
	CmOmqU7KOBzQlxhySkFU6CmeTVOgaO5gTBDF+qNrjNmNeInc1VPFlIdbmVMstfrZRKVtEeaNeVn
	W8VD4jjyofePIO/W5Cr7in/VYdh3LDaIrAIQFqNGbtc+4r986RS2AtxLEVMKbSsIkL6v5lvMajG
	/B10O5/VLeIZMkTYgNp7zEcQPzwa0wzkHKt54RGXG8+gO81tBqxfdWECA2Wds1+jnj4iWVXvIZG
	9
X-Received: by 2002:aed:3eac:: with SMTP id n41mr11014530qtf.362.1551984794401;
        Thu, 07 Mar 2019 10:53:14 -0800 (PST)
X-Received: by 2002:aed:3eac:: with SMTP id n41mr11014478qtf.362.1551984793528;
        Thu, 07 Mar 2019 10:53:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551984793; cv=none;
        d=google.com; s=arc-20160816;
        b=B1H/6m5LV/3OaR9dmJg+tZfEyLUQzvawCiLJZYzuMH02xt03WV1Wgxe0gEF+QX711e
         bW2+F91MuFljCMeHg0uv5mx71+cxJxb9Yz2Pel9AURLiFAcgwacZSc+h8XpwlWBYGeFJ
         Uy3JjGAygPgbpEatady8slnHWksyVzzUlCEVTh5tbl1FElUzQN3sn8xjV3S0tncWTDIj
         7a0KLT1G5H2PXXxi1FoAL8O+wU4M5BOhq3dmJ19A2N6HQM2pCPAyZZqu/okpcGyycM/p
         BdycBS6LDU1vdkzsU0K7X+xYqNYMtU6nxkOKT/51hWgNZTribHURpt98IfQqmZediS/u
         qesA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=p/uycB6wwfQ9mpJ/cDj3nrD1aSO5NRmGJ7t1JhstDM8=;
        b=mOg/wbtBWCX96+23eUrAuu133E6O13u/G8W4mLnMS2SDC17lBOBXN00Z1pAZucsbV9
         h1HSqErmWqS9PiEv8K4Xx1jlQ7wHMlNxZgIggdH+ux3tdP0o4LFuFOM5A6KoBn+rnMn/
         JI/i6aucDB9JkXVYcYitjZBR6AQo4rfDgfqH5jYaTzj4AfAE03pjUFDKr2hx+4aqOYlD
         ZR6TDictEI3g7zYsH3apED8Jme+w0b/RTxR8SPTeq4nMuUdqleItSfiQnxqqUVSfW2jv
         dVZ+Gp8/z+xcgI2TRNiYWorzcEtV36VxZci5fKTvM+Mp0UvgtN+N64U+427kbB2RtzF6
         dQnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=npNbQ9ug;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor6913208qtr.23.2019.03.07.10.53.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:53:13 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=npNbQ9ug;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=p/uycB6wwfQ9mpJ/cDj3nrD1aSO5NRmGJ7t1JhstDM8=;
        b=npNbQ9ugg6BqXhBShFoxcI+GsIl/fQL1QQiivFdQuXTzcRUGxcFBOnos1rPrqOcUGZ
         LpkY8q7OeZ3u/jLDGFI/8r0tIdwcF5zyhjcZWU+ryrwQKbz64WJoswuqcgOs4CUHTFtC
         dwnK7AXsVkVipwWteXZBUzl6ojcGHfXjpr4nYNV5oBbRYe3jcn+xMH0IaqALsvmJnuCa
         RvKS76TIqHjNR9CkiOP9V9iNNQXcV4niHNxVQq3vwmCDvpWLMtTat1aI0+ysmKUVfypQ
         qcBWRpQgKdyhCZRIQ9G2JzzIhI41U5fnxDzBOllsFQ+1lAhsX4OucCWzjXwQmHK607we
         v4tQ==
X-Google-Smtp-Source: APXvYqzGLcM4sdL4fQMyRvzu7ZEKQ3Jrxk7x05or0Uat2bPqh6vF/YVXkc6OhqMJ9BzxmD4BoExgEg==
X-Received: by 2002:ac8:22d1:: with SMTP id g17mr11423320qta.30.1551984793227;
        Thu, 07 Mar 2019 10:53:13 -0800 (PST)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id x6sm2514892qtr.9.2019.03.07.10.53.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:53:12 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com,
	glider@google.com,
	dvyukov@google.com,
	andreyknvl@google.com,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] kasan: fix variable 'tag' set but not used warning
Date: Thu,  7 Mar 2019 13:52:44 -0500
Message-Id: <20190307185244.54648-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002319, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

set_tag() compiles away when CONFIG_KASAN_SW_TAGS=n, so make
arch_kasan_set_tag() a static inline function to fix warnings below.

mm/kasan/common.c: In function '__kasan_kmalloc':
mm/kasan/common.c:475:5: warning: variable 'tag' set but not used
[-Wunused-but-set-variable]
  u8 tag;
     ^~~

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/kasan/kasan.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 3e0c11f7d7a1..3ce956efa0cb 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -163,7 +163,10 @@ static inline u8 random_tag(void)
 #endif
 
 #ifndef arch_kasan_set_tag
-#define arch_kasan_set_tag(addr, tag)	((void *)(addr))
+static inline const void *arch_kasan_set_tag(const void *addr, u8 tag)
+{
+	return addr;
+}
 #endif
 #ifndef arch_kasan_reset_tag
 #define arch_kasan_reset_tag(addr)	((void *)(addr))
-- 
2.17.2 (Apple Git-113)

