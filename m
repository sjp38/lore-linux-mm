Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2925CC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D41B7217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:45:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D41B7217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 744BD6B0003; Wed, 17 Jul 2019 13:45:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F42F6B0007; Wed, 17 Jul 2019 13:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 609718E0001; Wed, 17 Jul 2019 13:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8066B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:45:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so12408312pld.15
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Jn1Fpw8LCDAidOyVuaihNufCQWVTMDDvASOIBvdl2fI=;
        b=bl7HnpnfQ3amU7JNGRBo3tkGpNHUBl0AOuZCyMZY0Tzn2fNb+IlSadfRimwlcH7dIF
         nSlnWFx7E9FkZefKiS+rI71IBX27ZFi6y8uAvMFWXqLs3GjgQjdo3Gj/I/wKk3ZXiE4H
         H/a2ldiOB1g3l0H4OlPQAzrnTIf3f55s86zLzdThCO9QQqgjGyHf28+ne3R4IySyILGm
         gS7/X+n9KHQsAk1RqCZqVucEe0MzCtFGKRg6vnnGp8lZ/4++WPzcVytQEQ7tFYtNDIUG
         IZqC78TZ1Plng2Io/4/suUj/xA8TjcBut5rqxthebAz7LIFvZ4NpPKzt9Fnr3XqNvZbO
         DkYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUUdjfEtyN59xQNQIJ+bf3eevXe1Ia17yaddIQ0Yen+9G2GXK2W
	aprZFJNBEu49MPWQO3Libg8sI/AoIDIpmnZwQI8MJB6Bew6b55H42pXZBBAiHUZm/fsq0WTdAoR
	kFG24hb6jESTa8ZSFmGivTPxagwq9/WtV3NaZhiaQe5Z/znGLFZRc/7nlBh/i6754Wg==
X-Received: by 2002:a63:1d0e:: with SMTP id d14mr42499950pgd.324.1563385537732;
        Wed, 17 Jul 2019 10:45:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3517HjQSBbFVoxLTIcIyX9wAEtLlekIC1hrTWEXlmy7W1nj1OeAAzO55U3XUBnwltsW+s
X-Received: by 2002:a63:1d0e:: with SMTP id d14mr42499874pgd.324.1563385536828;
        Wed, 17 Jul 2019 10:45:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563385536; cv=none;
        d=google.com; s=arc-20160816;
        b=lmS5zLlndcg6z7aeiFaRvUGa5EQYWtUP0aQ7FLuZwVklP8/frmACt3soCTIpFIFyk1
         7wY3ios7KbZ8nf8qZBNAFGwSJVZ77dABX7Tk4DvBmGTN+T7DODrHqhDho+ShtZXeQYNZ
         HiDOLLA7LGG/e1BfBEcZs3scii9EToFh2nXFRNp3x5FWwn1CCMimE+E9UqBXh8tYRhmD
         r4QtEXPkuofdqPQDilaYq5DpsNPRcumXH5wiYbfNlc1liDpv2HA77SWa0m4gfWrr+/Ys
         qHOrkSP0/OrkTFIC1gSG8Oa1RdqMZjMKiIhsuSy2bJpxSOGneBsTIYnKS+0z0/qgL5hT
         XUEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Jn1Fpw8LCDAidOyVuaihNufCQWVTMDDvASOIBvdl2fI=;
        b=sOQbUaAx1pRXoiLo/dgFuMiyPKm0qt4Rf3hLiPiv6vzrUs1UpTfJBD3wHybQ+ZZUkg
         LlI/V+kgZmTL7xqfRzfeD7WAaG0ISapWho18xm8qVcn2o9od28U3bcBOg/+SOprgZq4x
         /+An8L5m/bi9NhDcR1ylC75Zm5g3CFWZiJb5GnIFSs+iUJ8k+QN+JbxNKYR49QknTS9J
         Abrr8U7sPX5vRzHv1eyYrMk5ZZ4zUl+x0SicSUNz5HRQWITkfgybJxekqTJSdD8IXcIk
         C2gjyKnWoB4GZBrynLNRKPlljtAxY44Lz34P9+nnArXNAkHxVAb+Z/uJEovh/1teZ5Fg
         lReA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t2si22263880pgp.343.2019.07.17.10.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 10:45:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TX8wp0U_1563385527;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8wp0U_1563385527)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 01:45:33 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: shakeelb@google.com,
	vdavydov.dev@gmail.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	ktkhai@virtuozzo.com,
	guro@fb.com,
	hughd@google.com,
	cai@lca.pw,
	kirill.shutemov@linux.intel.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: vmscan: check if mem cgroup is disabled or not before calling memcg slab shrinker
Date: Thu, 18 Jul 2019 01:45:26 +0800
Message-Id: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Shakeel Butt reported premature oom on kernel with
"cgroup_disable=memory" since mem_cgroup_is_root() returns false even
though memcg is actually NULL.  The drop_caches is also broken.

It is because commit aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab()
calls in shrink_node()") removed the !memcg check before
!mem_cgroup_is_root().  And, surprisingly root memcg is allocated even
though memory cgroup is disabled by kernel boot parameter.

Add mem_cgroup_disabled() check to make reclaimer work as expected.

Fixes: aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab() calls in shrink_node()")
Reported-by: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org  4.19+
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/vmscan.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f8e3dcd..c10dc02 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -684,7 +684,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	unsigned long ret, freed = 0;
 	struct shrinker *shrinker;
 
-	if (!mem_cgroup_is_root(memcg))
+	/*
+	 * The root memcg might be allocated even though memcg is disabled
+	 * via "cgroup_disable=memory" boot parameter.  This could make
+	 * mem_cgroup_is_root() return false, then just run memcg slab
+	 * shrink, but skip global shrink.  This may result in premature
+	 * oom.
+	 */
+	if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
 		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
 
 	if (!down_read_trylock(&shrinker_rwsem))
-- 
1.8.3.1

