Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68FBAC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25B7520818
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:32:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="DOaXH4tV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25B7520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6ECA8E00E0; Mon, 11 Feb 2019 07:32:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1E188E00DD; Mon, 11 Feb 2019 07:32:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A34168E00E0; Mon, 11 Feb 2019 07:32:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76E1C8E00DD
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:32:44 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so12597308qte.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:32:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=B2ouR+Ang/LItZ96PM06UJ1jkDO7ifCmte1uKNl4m9I=;
        b=sLZiarbuHGBi/KmMs4zgvpKr8JO/iInO4ZZMngTJuwvYuvI++Nspe9Xup6r331mKDx
         SIohmf6LtamgSBDQNH7Yi2pdyn4zmcTSlNrryzWeJn/MXia9KtEduDAJrmN65YBQNe7g
         g+KIPkPYoCq5C86RQC8i/QHsf0tXzX7RKQsLuxtMHlo6WvPlaSuyyB/reeTCNDimKNHy
         eGV3BSJMWj5/15VGoY7w6Pm1MUEIK49vH5hGvANsTZ5Mup2mBJkdk0hrvwO12ui4CZFb
         jFgPiTEIJGOZlJa6UzUSASpRraWoCNzISZnY5eRDm8kH5P090ogsMWX9e+JgPO54V+4O
         YJYQ==
X-Gm-Message-State: AHQUAuacMTGt1hPRC5JDJl7gla3Z/9ogszSSNoNkRvu1FCdDrkdqNCTi
	tOFUsPywjNZKjsgKiMfTotexZz2eLhBuFU6D7y99CnB/m9ZxC7lNQaFLCo3haPqNqrzRtJRVVL9
	m1MDCusoqTbDYeTD3RM02vMwHFi1gXE1QMPTA0vWHl1YVMvI8JH/RCR5n+f43C7K7BwrG1piU+4
	SrpJOmQyrVwpVyrGVn5R/suQO+aeFJJ6jyGW2Jbv5X4GcIta5mFMDJkg+M/u4DZXLzydmqeBS9G
	wLvwWTdR7GN3++CuO9x8+jG4poi9xVFN6Ewyq5UvXnDMbU/urDgB8srSksvpwGiwmEgnL7uwy+5
	mQmcnsBr3uF7T5vjLWvJUXCWj1jE7SRvsoRhaIklXb0kNB8I9uwD+HEoFeJFwN4JZLSROe/hXsn
	b
X-Received: by 2002:a37:4d47:: with SMTP id a68mr24875734qkb.349.1549888364150;
        Mon, 11 Feb 2019 04:32:44 -0800 (PST)
X-Received: by 2002:a37:4d47:: with SMTP id a68mr24875705qkb.349.1549888363618;
        Mon, 11 Feb 2019 04:32:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549888363; cv=none;
        d=google.com; s=arc-20160816;
        b=EC4ao+toD+kuhvcwkTtFA7TOyvVp9ROY95AeLfa5VbYBBAjJGl1nNQ641b7HA8DTI/
         zI87C75hQowz34R7B3BFuSnFnaHL7qrPfid/wmGlyTZBwneXfctp/57leHDTusyGH+bV
         AWZUX7AScJQEARg8/gZzUc35k7nacxEATf9xa382lvRwB9hm7u6Cg2w85hLzqJ5cvJuW
         6Zf45RDf7L0RZaKeGkRdRNKI5XB7to1gUSiraQYgNpFRB6O8Qnf7D41GA3F2zBrmaZdg
         wK+Vgi3qE7ZXFLqMNn+5murOc+BVf2ge+7Ih+eH+nmOjZAzOsI4h6xaJH6WOrUvdLlTu
         ltuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=B2ouR+Ang/LItZ96PM06UJ1jkDO7ifCmte1uKNl4m9I=;
        b=gfrAAr0rNdZ2FrE7VAq3ZUZIldrpPevzTt4y8yeGehBzJl6iw65OF3Ge//SZMsUAND
         0RBclqbC88ab4CVEkJvlSNpG1t1IKT2pdrP75ILLEzdPXfGUWttjLcfgZktOOABSqEPn
         Z85nuRUe/NORFmVSGvhr2CTVKp7OrSn+2+uUGkc3/rPyX/uDu3fflir94C1Tr9apbRZv
         BgmwXgJ+Ph8Qf3gLh2uIa2ZwRMDlkXKxq5xwBNb2lF+I8vB3fGD/G5Ugvaa6bTiXigl4
         r6x1s015fYAHfohLIG6k8Blri3twvPSjtkgwIqi8YXwhxJ1qPFh6rIlmPnhPdldl+Bzu
         sbew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=DOaXH4tV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor11312703qve.9.2019.02.11.04.32.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 04:32:43 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=DOaXH4tV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=B2ouR+Ang/LItZ96PM06UJ1jkDO7ifCmte1uKNl4m9I=;
        b=DOaXH4tV21cFMhS2mNjs93TTzRjlPcp6GZc1CMQpstAl5juxcg/1cjuESUfksfEHgn
         G4S9Bt5bOsfRdiABthYNSGVPYfsN/boEz1HhcDHYnY5PvIyvfvouH7XxSO4z+xUzVQmd
         J7RGbKOKuwCfRAHs72OaP/kGWwixvPuOPl+10olToEi8hLtH3Trjj83pEdhDJ2X7XJfd
         loq8Js20flsGzcr+x0tlRpyIK+4HzBmLNtOrb/heJ3tAl2FUJvXSXNAmiqqiIana0YHw
         wr8QAn+4etl5LYRdb57khbJhfYReZ9//WzlWCh9vR68Joz3Wsrhf+d262NcEd/EQOUaL
         NLbg==
X-Google-Smtp-Source: AHgI3IbvcpJ8B5DrC2p58gNY0AExMmGTOFsI9dp4XE+ccMuoyiaUgF3QtJJ0xmiuI3Bf9otjzRsTsg==
X-Received: by 2002:a0c:8425:: with SMTP id l34mr26545005qva.101.1549888362886;
        Mon, 11 Feb 2019 04:32:42 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id i33sm6236445qti.74.2019.02.11.04.32.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 04:32:42 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com
Cc: labbott@fedoraproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slub: remove an unused addr argument
Date: Mon, 11 Feb 2019 07:32:14 -0500
Message-Id: <20190211123214.35592-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"addr" function argument is not used in alloc_consistency_checks() at
all, so remove it.

Fixes: becfda68abca ("slub: convert SLAB_DEBUG_FREE to SLAB_CONSISTENCY_CHECKS")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 075ebc529788..4a61959e1887 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1077,8 +1077,7 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 }
 
 static inline int alloc_consistency_checks(struct kmem_cache *s,
-					struct page *page,
-					void *object, unsigned long addr)
+					struct page *page, void *object)
 {
 	if (!check_slab(s, page))
 		return 0;
@@ -1099,7 +1098,7 @@ static noinline int alloc_debug_processing(struct kmem_cache *s,
 					void *object, unsigned long addr)
 {
 	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
-		if (!alloc_consistency_checks(s, page, object, addr))
+		if (!alloc_consistency_checks(s, page, object))
 			goto bad;
 	}
 
-- 
2.17.2 (Apple Git-113)

