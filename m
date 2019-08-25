Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 274CCC3A59E
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD0AC2190F
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZlulVT9Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD0AC2190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F7596B04F9; Sat, 24 Aug 2019 20:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A74E6B04FB; Sat, 24 Aug 2019 20:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E50B6B04FC; Sat, 24 Aug 2019 20:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA6F6B04F9
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:46 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EC4E2824CA26
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:45 +0000 (UTC)
X-FDA: 75859130130.05.mass81_46ab5a7ae232d
X-HE-Tag: mass81_46ab5a7ae232d
X-Filterd-Recvd-Size: 3210
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:45 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 55839206E0;
	Sun, 25 Aug 2019 00:54:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694484;
	bh=L2S2GGnciDnwlnmsfC/b9WeIfalDn4jL2tsJvrWBT2o=;
	h=Date:From:To:Subject:From;
	b=ZlulVT9QkC1VhYqJ8u8+nxxp00qAMhXD2GYAnYjfQPSe65KDXsAkUUN1g9jnPgv92
	 Q2DgEYPCtR68irbFtQ0S2lYSl1pql4pI9Y+joYFpSO9SUQTnrTAbpTGN0aAPMHpKsA
	 RB8WUL+qJwowEa0M7nV4kprv77fAx87FN/elR7Ow=
Date: Sat, 24 Aug 2019 17:54:43 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, cai@lca.pw, linux-mm@kvack.org,
 linux@roeck-us.net, mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 torvalds@linux-foundation.org
Subject:  [patch 03/11] parisc: fix compilation errrors
Message-ID: <20190825005443.DjMnGU4bk%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>
Subject: parisc: fix compilation errrors

Commit 0cfaee2af3a0 ("include/asm-generic/5level-fixup.h: fix variable
'p4d' set but not used") converted a few functions from macros to static
inline, which causes parisc to complain,

In file included from ./include/asm-generic/4level-fixup.h:38:0,
                 from ./arch/parisc/include/asm/pgtable.h:5,
                 from ./arch/parisc/include/asm/io.h:6,
                 from ./include/linux/io.h:13,
                 from sound/core/memory.c:9:
./include/asm-generic/5level-fixup.h:14:18: error: unknown type name
'pgd_t'; did you mean 'pid_t'?
 #define p4d_t    pgd_t
                  ^
./include/asm-generic/5level-fixup.h:24:28: note: in expansion of macro
'p4d_t'
 static inline int p4d_none(p4d_t p4d)
                            ^~~~~

It is because "4level-fixup.h" is included before "asm/page.h" where
"pgd_t" is defined.

Link: http://lkml.kernel.org/r/20190815205305.1382-1-cai@lca.pw
Fixes: 0cfaee2af3a0 ("include/asm-generic/5level-fixup.h: fix variable 'p4d' set but not used")
Signed-off-by: Qian Cai <cai@lca.pw>
Reported-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/parisc/include/asm/pgtable.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/arch/parisc/include/asm/pgtable.h~parisc-fix-compilation-errrors
+++ a/arch/parisc/include/asm/pgtable.h
@@ -2,6 +2,7 @@
 #ifndef _PARISC_PGTABLE_H
 #define _PARISC_PGTABLE_H
 
+#include <asm/page.h>
 #include <asm-generic/4level-fixup.h>
 
 #include <asm/fixmap.h>
@@ -98,8 +99,6 @@ static inline void purge_tlb_entries(str
 
 #endif /* !__ASSEMBLY__ */
 
-#include <asm/page.h>
-
 #define pte_ERROR(e) \
 	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, pte_val(e))
 #define pmd_ERROR(e) \
_

