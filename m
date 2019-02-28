Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5B47C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E922084D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:18:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ZGN+GuTT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E922084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009AE8E0003; Thu, 28 Feb 2019 13:18:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFB678E0001; Thu, 28 Feb 2019 13:18:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9B08E0003; Thu, 28 Feb 2019 13:18:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3C798E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:18:53 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d13so19244876qth.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:18:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=ljQRzmSVHZ8FUWlGnEiX6dnZnYIPE+woVYSvg1vnVl8=;
        b=GD3wkNcs8XlgIRxO8qfS6rfpkaZSxut5b8NM8+hQIDTUtZy/CCSeD+57gPHjnIinvs
         UVZecN/MhVPrFI/ky6B7mjm74t7TTf0yJB1EOgcG2/nagjYhOHqzcRJxPuXJ7o78wntV
         lCsJI/bWUjySFl91c7R7P2akQX6l5I6cK9ffMadvp94kSw/hMdYeCEo+ym82K45Iuyln
         4Siq4LQq664bw/68dDz8TApQbbx7PoH9LKiL+5WStVJnU1aTm9XraOr46CpKuzOu0aSL
         vs2u1JtR2hI/wOkdu5DgDAJZTe3nynYzRek7VGJZBLQ7ZubhGWZl/gABIP6bourF0j+i
         0CGQ==
X-Gm-Message-State: APjAAAU5jdxdQliAsAlT/X8ztSzQNWTmaSMYzNbJ8XMtquy4wi+TcnXs
	C5ceZjxPhF/3Tl5jIst7iQgJm8lF5F7A4l7h8HzWQEb0l9BgcKa8uxPfRfbFcJfsV/Lqq+w+P/l
	vg+yoSmkisZX5U6LYuK/GxNvmSogIFlTLX1NQqEaCs22otnPtTYYHAv8SXN2H4vlZphqYd0dZNk
	R87l07c/rsVpzh66zzL2mArKxWWAlxVQPriU14YW4I9pJ6MD2aX2VP/GuEbWC9/KjbphxOVOm2P
	GlBXC74c+F/PuPLBt6hAcuA547BiMtzistXWNinBIS2k8bIx9jz8PlnoCfe9HXUSDIS9b6uqqJ9
	lrAqU4RLeBW3a5iSpb1dk6YV6Y71JLg86PVLF4HiKwopUPXd9yh2pzmKXWAvDDGLSg6JOLebYjF
	b
X-Received: by 2002:a05:620a:15fa:: with SMTP id p26mr682249qkm.130.1551377933443;
        Thu, 28 Feb 2019 10:18:53 -0800 (PST)
X-Received: by 2002:a05:620a:15fa:: with SMTP id p26mr682212qkm.130.1551377932743;
        Thu, 28 Feb 2019 10:18:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551377932; cv=none;
        d=google.com; s=arc-20160816;
        b=WBPxkOeqwc/vKlgR1ZliODZqu/xJkGk48GA17dBtOarzVLao+CmvOOqQxizyRqft8T
         yFDkdedBl4NhoBWKhRzqYFvdWBWzz+O4Qfv/CQF5p5G5uL/5Lr7ft+79oLUt3lMotjyE
         1T8X53wOdhEQGr6fqJQ1tEQ8PF/64r3uQXlbdmNx3YA0lXcliZnzFTIuw0PwSUSnatnc
         Bslp+FvJkQjJwQtz3uZaqLiQgQEFaW5zZTa/uQp1K4QIg+d1aOM3hgJNFCweN0zwABRy
         HOc8k6JiGqmjGIacdZaDYczhkhTsP6CamuRdq5rQf+9bv9LlYPoLieqLhuh0tB4D5dSt
         WBOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=ljQRzmSVHZ8FUWlGnEiX6dnZnYIPE+woVYSvg1vnVl8=;
        b=l0xme0c3Hl/uw87T6Ar/7N/hVXe/YLwwt2An70M36nBgdK++F9MfaQshiowC9ctChc
         robzDPVr+cSk6Wi55In9wfkGpn/w4jD01AzQrJm592qfvuC69wqLx+DHyOknZ5GBAWz4
         2lTwB9UUs1YoTCDymifxvUI9npqfrO4OKqsvinpajzLjfSMCq2I6puNEppeVrh3JxXya
         SpPIMk66cIOZMru3wXdczMw6hAo7PkZHHFxJfp9kCSn5afe2Nz9+qY5WAb1bfHPDl7go
         quJoYF+JhRhtGKefS3YoMxzQZuoXQpvj7NRhuNLXRlcUk22b9cSB6VTtLVh6Y0lFgqkk
         bUFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ZGN+GuTT;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c25sor13710415qtk.51.2019.02.28.10.18.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 10:18:52 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ZGN+GuTT;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=ljQRzmSVHZ8FUWlGnEiX6dnZnYIPE+woVYSvg1vnVl8=;
        b=ZGN+GuTTkFiYk6EBJySQlSM0ZZxVYMiH7AiaMYMR2RY1fC6K6wACV9tQpQHfjnnfR4
         mSUZhAC37d1TPzUre3jMCuXs+I6NY0hVZGIro6Wl48Oomfgd6HWZzey8AiS3kcIcUS95
         N7pyU4wct/4QOH2WuS4F+Y89l6rUdkRdgLQYPmrs9XbOGx+7aNFa0cf0O1obX6zC712Y
         vqfY4XdFz3vFC7qoTqDOGRN9oQGgtNUbWDOnjyFSbhjS0jgjIzW2O03gte+meZYdiuPC
         oNc8M7c7l9HyBlo7U53a7/Zo9CQZhK+HWNnpLUmeaBr+hiyPL5frVuSgbqT0kC/wNdhp
         PbZQ==
X-Google-Smtp-Source: APXvYqxFKSVHE9vkdmn5TB89Yj1mBAEz3pM9mtmc2n71EZavt9Z2FW3+aGEsTA2Lbo8LnzvyC7wmWw==
X-Received: by 2002:ac8:168b:: with SMTP id r11mr469269qtj.387.1551377932381;
        Thu, 28 Feb 2019 10:18:52 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id i21sm9570633qtp.73.2019.02.28.10.18.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 10:18:51 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/sparse: fix a bad comparison
Date: Thu, 28 Feb 2019 13:18:39 -0500
Message-Id: <20190228181839.86504-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

next_present_section_nr() could only return an unsigned number -1, so
just check it specifically where compilers will convert -1 to unsigned
if needed.

mm/sparse.c: In function 'sparse_init_nid':
mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is
always true [-Wtype-limits]
       ((section_nr >= 0) &&    \
                    ^~
mm/sparse.c:478:2: note: in expansion of macro
'for_each_present_section_nr'
  for_each_present_section_nr(pnum_begin, pnum) {
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is
always true [-Wtype-limits]
       ((section_nr >= 0) &&    \
                    ^~
mm/sparse.c:497:2: note: in expansion of macro
'for_each_present_section_nr'
  for_each_present_section_nr(pnum_begin, pnum) {
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/sparse.c: In function 'sparse_init':
mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is
always true [-Wtype-limits]
       ((section_nr >= 0) &&    \
                    ^~
mm/sparse.c:520:2: note: in expansion of macro
'for_each_present_section_nr'
  for_each_present_section_nr(pnum_begin + 1, pnum_end) {
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~

Fixes: c4e1be9ec113 ("mm, sparsemem: break out of loops early")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 7ea5dc6c6b19..77a0554fa5bd 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -197,7 +197,7 @@ static inline int next_present_section_nr(int section_nr)
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
-	     ((section_nr >= 0) &&				\
+	     ((section_nr != -1) &&				\
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
-- 
2.17.2 (Apple Git-113)

