Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C546EC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 859E5206BB
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 859E5206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 236F28E00A0; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E4FB8E0038; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AD038E00A0; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A26738E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:40:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so3207767ede.19
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:40:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aDvrgZgqyB2GQtMjh4VtH5ecdHk0OysmftWgol7M3xg=;
        b=EbkQtarb1sOb8mYGnaFmjEZzkMwQHxbmMXpDQaqPjOK9x032l7Zjl+8Ntcb0pZ5TLk
         cPKiDdxY0ZKo4N7kQsIcgE/eXsr7ejuoC23XA3GBmETihU0n0rguo3zbiEevmpop/G/2
         6sGrald+VOzcaRKCUjmf63G7YQ1EB48kw4Uh5RnTe42QqOyOczu/pF4Nahps4zOC2QoP
         BaaTJAVq3KFPhAztnAYH8fBkciqcgJYxj8+Peyr6zfpDYaUzQXbAsKySoKhYXMWmj8Fn
         1foE95hv04xLehAtcHRMiU/8twekWpOSEKfzdCB9g0VcpVkoef94ok1cuKQg3SBt797O
         4ILA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: AJcUukcoypvQLgKIT5rIYBOZfCHjxjD3vBG1ZKgaCT4vXwPKLp6K/aT2
	hcm1Lu26hrLFsUdFWdsp3wvGHdiHpBBQlQQZauk/3cEuSCbXmVkGzNRdMKD1DR2Q4ySKGikosS/
	qnDXRBjp/Rl/67xwj/3Ib+raFAcYN6wMZbgdnW2RdCBDtcWR0pWVR+c7KgIALTUk4Hw==
X-Received: by 2002:a17:906:c288:: with SMTP id r8-v6mr6015099ejz.9.1547052039093;
        Wed, 09 Jan 2019 08:40:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4qfYDFRuvuAdvV8QpLJETHu4/njNIKqimTQSSr8tvwTuWIsh35SkN1dgCyrGkX13LRyOaG
X-Received: by 2002:a17:906:c288:: with SMTP id r8-v6mr6015031ejz.9.1547052037657;
        Wed, 09 Jan 2019 08:40:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547052037; cv=none;
        d=google.com; s=arc-20160816;
        b=wmVzY5f1ANpY4+BJiE+thEpBOA2PrmSqKvAqj3fUwnidl/md2+dx/EVxvSFuDM+Ilm
         y9l6d32pICrbZM7pm84iLQ+z41dY3WV/MwspqLYuxlDOp/hn/ry0phQuDLsb8GCP1yao
         nrsKQFbomU/WUKbWXZiFi7fnZ6qK9p1XKdITIkEQFdUrUUMnlojTSNu4YpQ36aJSqLUg
         +9OE4i8+tWO9menDuYh8yWzARybkBLumP3EQrBtEeaJciiJe5WMEby29AeP/tlJuBfE6
         Qm7Xz5Lhg7mPQp5GxuhdAtQ/S99k1Ft1TCNkLOLDERNfbuzYsgrsjxVjjdT4Kg9QUN+d
         oCWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=aDvrgZgqyB2GQtMjh4VtH5ecdHk0OysmftWgol7M3xg=;
        b=R8djFws/cenCLiN3Vv/Y+OyLjhKTzDccBhImQiOVKmw07IdJr7ceQVKK0cAoW7tm5H
         Si/u5lCtxUnpVOnw1S7BKXhhGjRZiHpwiz+8QeF+J76kUQ/ITvlrImoWUE6XCXQjMR7g
         LOm5Ebnvz4WmzqRPcNIkcUKP2XSU3xJuT44rWQNuv94LnaoA4bSYuLW0WGT8qZB1GklZ
         g3208G/XcpfoDcb94Rwbvn/WcSljaDbevN+bIU16buHNkFh3VtX0DkrCt7IsOSwDbi69
         rGKo2RuFBtHkDxJ8zJnCU4wKp19H3cZQt2n0tJU4N+X8aIvJzjCMjGQVZAWzfC32OaaN
         f7yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13si1551064edr.264.2019.01.09.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:40:37 -0800 (PST)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 500A7AF74;
	Wed,  9 Jan 2019 16:40:37 +0000 (UTC)
From: Roman Penyaev <rpenyaev@suse.de>
To: 
Cc: Roman Penyaev <rpenyaev@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH 02/15] mm/vmalloc: move common logic from  __vmalloc_area_node to a separate func
Date: Wed,  9 Jan 2019 17:40:12 +0100
Message-Id: <20190109164025.24554-3-rpenyaev@suse.de>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190109164025.24554-1-rpenyaev@suse.de>
References: <20190109164025.24554-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190109164012.W_SEPq7Qqz64jbp9fYgoW-EoFFYDmsgUGo3elclHq1o@z>

This one moves logic related to pages array creation to a separate
function, which will be used by vrealloc() call as well, which
implementation will follow.

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 36 +++++++++++++++++++++++++++++-------
 1 file changed, 29 insertions(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4851b4a67f55..ad6cd807f6db 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1662,21 +1662,26 @@ EXPORT_SYMBOL(vmap);
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller);
-static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
-				 pgprot_t prot, int node)
+
+static int alloc_vm_area_array(struct vm_struct *area, gfp_t gfp_mask, int node)
 {
+	unsigned int nr_pages, array_size;
 	struct page **pages;
-	unsigned int nr_pages, array_size, i;
+
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
-	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
 	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
 					0 :
 					__GFP_HIGHMEM;
 
+	if (WARN_ON(area->pages))
+		return -EINVAL;
+
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
+	if (!nr_pages)
+		return -EINVAL;
+
 	array_size = (nr_pages * sizeof(struct page *));
 
-	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
 		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
@@ -1684,8 +1689,25 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
 	}
+	if (!pages)
+		return -ENOMEM;
+
+	area->nr_pages = nr_pages;
 	area->pages = pages;
-	if (!area->pages) {
+
+	return 0;
+}
+
+static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
+				 pgprot_t prot, int node)
+{
+	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
+	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
+					0 :
+					__GFP_HIGHMEM;
+	unsigned int i;
+
+	if (alloc_vm_area_array(area, gfp_mask, node)) {
 		remove_vm_area(area->addr);
 		kfree(area);
 		return NULL;
@@ -1709,7 +1731,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
-	if (map_vm_area(area, prot, pages))
+	if (map_vm_area(area, prot, area->pages))
 		goto fail;
 	return area->addr;
 
-- 
2.19.1

