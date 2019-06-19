Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23673C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7E022166E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:25:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="g1it1Ete"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7E022166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7356E6B0003; Wed, 19 Jun 2019 19:25:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5568E0002; Wed, 19 Jun 2019 19:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FAAD8E0001; Wed, 19 Jun 2019 19:25:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC596B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:25:25 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b188so1125167ywb.10
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=2Xe5CNu50mksX/zEQQqGlLiWQgOuxvE/hS5GIpxigKA=;
        b=MIU2nBxEbvbQE7m4o2FmsnvN17ZxJIq4HFB4hk8HehWbJrvdvegcrgfs5yxwKhuFyb
         RLsRwDx/3jiMUrNWBrYQQ+HVsH3mmcomurn2Fb7lr94s0gYWbQCRbifV+BQTUANfEkGx
         qq2gbBcNU57FCNddtpxaQC5ypc+xHR2Ajgr10yH/iBtDUvWELTwQH2dBChMR/Cw27BfL
         zj+LqGbyvpoVTY66bIxs08MCrymP6LZ2SId95HbDmrO3XTHdY/FveeDMhpLCWiZ0FLLL
         X7YbBgnZZMEopNeZcF1oMsYRXoXe5ofxrsKI6WbvSNcDCsmM13aXXP7nr7rU11u8RSei
         UkMA==
X-Gm-Message-State: APjAAAU224BFXY7O8v5WktSbIOW5ROI3ZWCf/KO9R0Q/Yez2BOCqdoFn
	Atb3lWrgH0Z0vnpmsKEcSOPFRkLtssutF8omrG1x1zcMGVy/Tot+6mc9TKGGAMGJWXSQj4hz9hB
	TRGEwYKPbW16iI7u56rAOqGW085mi4XqmnyeMUQ61QGnN6ZAI5CX1hCFBYa5cdGhLcg==
X-Received: by 2002:a0d:e84b:: with SMTP id r72mr28444182ywe.22.1560986724935;
        Wed, 19 Jun 2019 16:25:24 -0700 (PDT)
X-Received: by 2002:a0d:e84b:: with SMTP id r72mr28444167ywe.22.1560986724315;
        Wed, 19 Jun 2019 16:25:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560986724; cv=none;
        d=google.com; s=arc-20160816;
        b=Krpl0LXlBJgpY6xC4aqrxpYnzvUWr0v3AGiY2qfB1utc1AGAXnKNErQ+DkXXpj2Sup
         Iu0ZsIncQJoOCD+xca3cDV2N9Kvdq11S7qQpNIFdL1Vq2ReAkuVtcKyvtNSnQQTyJd8L
         qtw/1V71QyGBk338YqNX4Gb7Ca84jah+SLdBDltsrZUIGIZbAV9FCbSKxd4JnIowgBY1
         Z+MBITz7+EHa0LHSA3msWOA5sP31t60s6N2gWDggpJjIM7P/2gvbwdKltoGfVTcA/D/t
         BtPzla4DLhuuauH7x643P10f2gkJ1l/h/LeXfMZ/wq3UeM/3nwhbccQ8zGaP7mAkb2Ph
         qWrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=2Xe5CNu50mksX/zEQQqGlLiWQgOuxvE/hS5GIpxigKA=;
        b=b1LXukqB6hQNxqccfePqugagV/ELDhInar07Mpl2ounlSdqHEWWbKb85H4mQZI7Aiz
         JqB3MYapXQmDdAjZaDplRqj/Ycd309F+Kqs8k+yQx/59jHAKsWexfugFfYLwukQ+0XTq
         KKi9zVYYxRedDPCH4TR8FStZBpGkBE69MIWl/wH/pVNE3mpa6L5PFoS/+FTVQrFzVihl
         cAfOTW7EAJc/DBpzEm+oBV29Hwdu3kBHKhYE/WALaNW/7/dPFCELs5x4WQPnJHXLDbF/
         iGRFZXa5MFtnAX31Q3DnBNk0tsZhwYPPyc/cG1d2ORU48kVgEzBPrY7Dcvn+V/YIwpo/
         b4ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g1it1Ete;
       spf=pass (google.com: domain of 3y8qkxqgkcayyngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y8QKXQgKCAYyngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a64sor10647733ywb.168.2019.06.19.16.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 16:25:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3y8qkxqgkcayyngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g1it1Ete;
       spf=pass (google.com: domain of 3y8qkxqgkcayyngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y8QKXQgKCAYyngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=2Xe5CNu50mksX/zEQQqGlLiWQgOuxvE/hS5GIpxigKA=;
        b=g1it1EteZ/NGeK69zsjfHOTg9qZMabcBis5hFjOrlB2l+EFid2XH43a/H1Q98WQaN4
         EuaSsBaTPlqXmMYUHUth9G/bMVvlH6pFOoOKmzO5ypBeVy38P7a0Es8xFNAKHTRaabbw
         8raai+S+rVgHmvNm9WwaNFbh3CDbHzBDR0yc8D2i20C+AGY93ETkj7ecEaSTfenjJLSd
         fcu2WQVp0NMDR3iKV/rnrn6v8WivwS78j6PGG20RxN0RiXWs5GoTqxJGDi9W1+QRi9g4
         d0z67gIh/nncaGZD0tfYFyUqwU/UD9ePElOit5dKhGB4YOjiUpRTPlAbsW+SCWdDRbSB
         Q3KA==
X-Google-Smtp-Source: APXvYqx0Ajd3n7T85uM4Bzn0REZs50Wj6xVympn1t8+jBERmV3VKWhN1SE1iCxw29OAeOkbSedQJqpGRdieoww==
X-Received: by 2002:a0d:c485:: with SMTP id g127mr43382535ywd.405.1560986723899;
 Wed, 19 Jun 2019 16:25:23 -0700 (PDT)
Date: Wed, 19 Jun 2019 16:25:14 -0700
Message-Id: <20190619232514.58994-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] slub: Don't panic for memcg kmem cache creation failure
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently for CONFIG_SLUB, if a memcg kmem cache creation is failed and
the corresponding root kmem cache has SLAB_PANIC flag, the kernel will
be crashed. This is unnecessary as the kernel can handle the creation
failures of memcg kmem caches. Additionally CONFIG_SLAB does not
implement this behavior. So, to keep the behavior consistent between
SLAB and SLUB, removing the panic for memcg kmem cache creation
failures. The root kmem cache creation failure for SLAB_PANIC correctly
panics for both SLAB and SLUB.

Reported-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/slub.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 6a5174b51cd6..84c6508e360d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3640,10 +3640,6 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 
 	free_kmem_cache_nodes(s);
 error:
-	if (flags & SLAB_PANIC)
-		panic("Cannot create slab %s size=%u realsize=%u order=%u offset=%u flags=%lx\n",
-		      s->name, s->size, s->size,
-		      oo_order(s->oo), s->offset, (unsigned long)flags);
 	return -EINVAL;
 }
 
-- 
2.22.0.410.gd8fdbe21b5-goog

