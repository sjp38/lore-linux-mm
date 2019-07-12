Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20FD0C742B0
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:05:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E04B42064B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:05:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E04B42064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E878E012D; Fri, 12 Jul 2019 05:05:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757F48E00DB; Fri, 12 Jul 2019 05:05:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616A38E012D; Fri, 12 Jul 2019 05:05:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDAA8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:05:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s18so3980524wru.16
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:05:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=+HBe9Alwaw2a4PnmAusbor0qMLzxOZ6v3mYmR08nWEc=;
        b=knBNr8w7fAAPrjkmUQWcnlxA1paW/yVaVnNqRlKW7y3RlG2ZJQikQw9hDW2pCuEgox
         C5cqf5FmrOeitgHoKKBXLLjlldAX6ocX7axjsdn/2WOUPgduxQsuEB0yftKETvm1GPK6
         WhV6drInb/LSR39RIHvWu/qKRSWp/DRJoUdTTy+W3KH1/ryJ7e+je32FvCHuq8meOavI
         UfJjaQ2QDFZXL65I9twZT1La6k3LcpLUw1JIgi/qeIVbvdDY2JI+Gp+sdtNtuF8n1Mj5
         NaIMtBWW6YBi4kBEWDW0V1zlYcVocn7ahFFl3xfNF7RXlBrK/oRDWcSB1BTwA120ep46
         s9ew==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAWi4goLlBP4QRvfNB7wUK/2eMCdVLB5lidmC/v7PM+8UxGnj0aE
	TLQtCQ+fUg+jqtB1W2FastYAEK1JE8fIZRgcalSpN7fsprIbqurj6lkz/GaKuYRRQQ2hcCkmL9d
	9uDHfHIaa3EkyWAz/xic9nwxYPyPfi+wtPc4KbvznalgK3rhLe+s5wLH57tt2Eu8=
X-Received: by 2002:a1c:630a:: with SMTP id x10mr9119708wmb.113.1562922307506;
        Fri, 12 Jul 2019 02:05:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYb/nXVhLDLmFXjMTwkA7aGgYg1HmjcYjHkibRAl6qHTIK9fUMYuNIy2/XWneCGdiNKxK5
X-Received: by 2002:a1c:630a:: with SMTP id x10mr9119638wmb.113.1562922306684;
        Fri, 12 Jul 2019 02:05:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562922306; cv=none;
        d=google.com; s=arc-20160816;
        b=Loce2inTvAt6yeemIE29rEWRRMtP963eNb/VCY8rCnegyOP86Fellq3M5kcwMj0FVZ
         lX6GrtvLfUnQd5JEYGVmma7LZsL6YJ2Te297Fqzt+oI7ArkP4n2Ag3wPwC5NlLBLvN4B
         OLssesfybcKzAD3S/uImNj7n+MycXDjvoeF/v49M7Vvh1T8ux29Kd0BQ54nhaRJAPiXj
         KE5aJkXDO0SVzy2AjQV2LV1/rsETgnYqRcBxw4e5yys1zA8RIRxB7CMFyyXPkM85CYMB
         W/McGiSdi986p8KoqCoThfO4C6JqgWmYND+9/fQh+c02cLP12ozVSKlh8CKNtXCHgKaz
         OIeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=+HBe9Alwaw2a4PnmAusbor0qMLzxOZ6v3mYmR08nWEc=;
        b=e3Zkzm2UpP+N+U44Wx4AsIsOghIAJeowYALNjbBVIAcn9syO78QObfS6pqF1DA33D/
         TVhMUCgrZ/KCyWRCwOwfQTrGKHAmN4d25dzV17zZgtjv0dk7eQ23Gmrta8JQDfWznzJa
         8guD3XUSmVAK1RZPAiRErNFLKultbdstdq73a2zGY0orGAkMXwR7aQL4r0Qgsehhu2cZ
         iObd+8tzMrJ6oVSbWlgZs0LC3XBNQqOg8dvlSSdirYmKLp//vk106Ho5aPjEEeeYXxRq
         j1Yofwzy68Pge8dn0cY2pJ849fKmAEJVMoxn+6/A2xpF383b6/A+B0Gp4vbCgJnCECQy
         H1cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id k14si8159190wrv.303.2019.07.12.02.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 02:05:06 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.126.133;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue009 [212.227.15.129]) with ESMTPA (Nemesis) id
 1MV6G6-1hwH5Z2EoY-00SB3h; Fri, 12 Jul 2019 11:04:59 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	clang-built-linux@googlegroups.com
Subject: [PATCH] slab: work around clang bug #42570
Date: Fri, 12 Jul 2019 11:04:39 +0200
Message-Id: <20190712090455.266021-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:Ny01W1sDzoQkytMwytJIIrYFKJMAp43dk5NNDspRvnOllp9EkZr
 VuzyTUNjSse8EsEyCqr7kc40Ba4ziU5ZJeO+1M9SBaOgjKuIZikTFUdKqTjhsp1dC0hMyAb
 pzT0cscZoUzBS9aQuvnFE7VnM1CNm1uE1TfgnnqFyCIqm3ZduBeyRgSaa+3GiB+97zyK7Fg
 Vq+dXYbjGqocQuWH5gCnQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:FRhumaWfoBg=:uF2ZId5iyFd22A6N4mOrDZ
 DtmIL69RcbPhxVSvodv4SUhsYV3+yTK/vCQrNs/qghahhIl06Oaaj1oGMBTiXb1ZEJ0kvWka/
 sKHJbkSki3UoNonkKIXFm6kJbKDjygapYoW0EpCAJQ7ysWmxe2LOwY5SeEOr18TmoogwlUW7w
 RWOiJpzdMDSPkR9+1kD5+ouGToWbg07Sh+iVwcqcvBLDRIFuY0Lr6K3WfrDh9+igLUXmNr9Dq
 +uoq6gYSfqg6ZQr1Ta+90TtUt9blY4SiRiiHiBz4uU6cw4VFzSa35XjGdq6LdAHaoA6zNigPQ
 ehN3T8Bwk+7/ZwQFIx8X6EJXFRMVpz36YVZwn208Q+krl8PTa17VZDTpRmxz4I6XyaHEcd7tw
 XNjGA21LQmrxeNMfuOTYT59cD6THL8xnGL4zEuVG5mn0+zotPWlKWihBZWGGp/zCQQDeMuqmg
 mH6GfOwLdOsSOQHM/7q1NYMkDcCLJvbKCqICmPvX12LY5VeJXgbjSbUlkr4D+aCIARFWGN4bu
 2/uYYtvJ8MkKxNyV0wjTIg0X5VtdPvj34xCu404qgrfovh86PGxQeY5y6lSi3G4kic5Rgz3tv
 4OlnfYOM+WO34ViWN+LZnpgELAknvuzOgatnlXyoQaf1ho4dY8cyqujhqcHuJeoiio9WKRjEU
 ZsSHw0gqQmRAi5jhR7aDBJr2ye0/ArzAZ+LEuIW1OOWycpVPns/zzcQh5FBLSnsM9+WagkJsQ
 RO479U51Z4FBGauyIZAB2MKq45G9BqYlZQN9eQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Clang gets rather confused about two variables in the same special
section when one of them is not initialized, leading to an assembler
warning later:

/tmp/slab_common-18f869.s: Assembler messages:
/tmp/slab_common-18f869.s:7526: Warning: ignoring changed section attributes for .data..ro_after_init

Adding an initialization to kmalloc_caches is rather silly here
but does avoid the issue.

Link: https://bugs.llvm.org/show_bug.cgi?id=42570
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
We might decide to wait until this is fixed in clang, but
so far all versions targetting x86 seem to be affected.
---
 mm/slab_common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6c49dbb3769e..807490fe217a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1028,7 +1028,8 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 }
 
 struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init =
+{ /* initialization for https://bugs.llvm.org/show_bug.cgi?id=42570 */ };
 EXPORT_SYMBOL(kmalloc_caches);
 
 /*
-- 
2.20.0

