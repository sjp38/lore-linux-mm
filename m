Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68951C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 284C02192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UdfnkLw0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 284C02192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 109C68E0006; Fri, 15 Feb 2019 13:14:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 096CB8E0004; Fri, 15 Feb 2019 13:14:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9B0C8E0006; Fri, 15 Feb 2019 13:14:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id C92858E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:35 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id f8so6354956ybj.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m8WChnDGiJjl3dG7Qy7BcuERcz0zJgVAywmHmi4mw/w=;
        b=Acn3/Ed3KciUjkyorlgjPObx5T6Vpw+R7hj2JAXxjmsQxthgpmdxmUHDT7tz5tyO0m
         uy4lvUExgmovvfm+fScumzRHREoSrBgXnew9Aue8R9s4LGRosX6jYwhygl598kD0cjzc
         lmlLEZBBBpdpHn4kyjUthkdnLajJ4LADUOCOsBNuk5zKXuz+9HSMybN9x1H8U50XOEue
         ev+9wmCAph5vfnrhQPIWcVLQpt9Sq4dMdlHlxL8RbADKGP1GQ+pKYnjOtTgZe69r00RN
         etT2lMuBT1Edw9jRav7Ap5vTmw4z0q5EQKYe9jvqQuyqJs8droLEImp8RHAMs7rJf8Tu
         gPfg==
X-Gm-Message-State: AHQUAuZCmcaQY+zNkAxzhzwHKGxmO4hmIKjtjMvE3/mzPtt6fWvFw5sU
	zLtHeTMS5hjtFjLQXA+IaxmgONP+3inQPVRpiZOzJNcVLWhOqkY9kLRtWPQYktw52iNIdrMrVUk
	OhJDa5gUTQjVKleVp5Rb/WWA5V8MTlOT1YKEQAhFBZ06KbHtJjH8nD+k0a+BX59+7ulb/IURnSZ
	AoP4EF/my11lILcB4AwRt9+zlVn9sJU3ig4i2k79fGoQx6O8RIQn5OEujim1IovufKiz2gCfiFa
	ltYrbX+TtP2Za7ZJkpFpvHI6ovTn28nksdGbapCg2oMgScj3WEuaubcxLTAIKVlS657KQ0OzAx4
	6MM8WTlQlHKiNBnGF3QH+tNCdYekLRoq+oO8HfXvoQl/N3t9+ACjaAKjfz3Pv9aM3onflTc/oVw
	h
X-Received: by 2002:a81:5149:: with SMTP id f70mr8949013ywb.289.1550254475583;
        Fri, 15 Feb 2019 10:14:35 -0800 (PST)
X-Received: by 2002:a81:5149:: with SMTP id f70mr8948970ywb.289.1550254474967;
        Fri, 15 Feb 2019 10:14:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254474; cv=none;
        d=google.com; s=arc-20160816;
        b=ICQlcLNPdcyz9YLkOx8WYqXauCx5rCa79vXAKs+4/ErlGejYtCv+9Lam25hRtJD087
         MSpe5J2LnOWwXA2BcHNqJiRrR4LRLaPnhWt5hDK4nUjVR4Q8lJ0OM6DTUlZ81o2GSUSW
         HyNYle3S7AXigqMR2LVpkN1ZEA5N6aO45ImHlS5ucmgimHfA4mxWRi9h+cd5h49e4at6
         j7EiGmMdcNWyEdGiE5aq/bCTxucjp8tyAbSCuh4h99lxpX7gbEXygask7sJD4leRHlN5
         uBLZG8l73jWjPNWZYMHHJuOGWjZp5p5gNVpqzUTSRvP2tGzBu7HA3XQ3aAqKG8tGDIpg
         WzPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=m8WChnDGiJjl3dG7Qy7BcuERcz0zJgVAywmHmi4mw/w=;
        b=nE78g2oSvZUoWP0KRxEbX52KZhCB4Rn6AApXdMjkeVxuQ8K/ctTAoGOgJJtDgdTZUL
         jF3aDOMXrxz/3SvRVgWxt8yiGMmLhOV04i6gi0QPcGpn/7rLzDm8qM7ZE0oigH7G4y1U
         BNUA5RLQOUZnRIxAUNC9h+MZ6SU7OOFVofRxlOUUJTe18f+0Q2904NSf8MM9RRnBAJsV
         RgSTEprZ+/CKY3Wi2AIPlK9iCZz6H8BHpN+8zevxiFRfa6r3d3EntnHLWBnx/ejJQKEb
         qJ79cARV/vVQTLuXJiHYMwZPhs9p7rBYotQn9hw7AzpEdp0RDSsA8BHzpHPb+xFQoNi2
         KpjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UdfnkLw0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4sor3213703ybk.74.2019.02.15.10.14.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:34 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UdfnkLw0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=m8WChnDGiJjl3dG7Qy7BcuERcz0zJgVAywmHmi4mw/w=;
        b=UdfnkLw0LmmTMvDdh9ElM17TqIoS3oWEjsSyoG4o6RGsaPK+fs4daWXmy0W/V7D+78
         Ob2Pc5U21jjOaaMkxoMxu9tYDRhLSY2CL/sI5SGMTfBDcQdRvqtWJ1c9dngW43CxCbTv
         9p4H2xQVSXhBxNYvad1mhG4sR3iDigfmHjGeDfRaTU+7XjGsyeFxL22FLqvWeI/UsRbR
         PTdCQwKwdVXH+yJAh1ngZAjeqZ2nUBqtDoA+jtJ5gStQMocaU9AuCbQLZYLint5d9dxj
         S9J7e7kCePwD2WfXXOsu+GBqZ9GNU0PIVhs0jDdsSLfjoGX15iGR18dpmrWWhqj3O5UO
         DL0Q==
X-Google-Smtp-Source: AHgI3IZ8yDwTc7PxyKzJo3tl350n3p72QNy9yMJQXMoHx1G4LbQACYtj2tYCy+gNRFU1vjZ6WO77cw==
X-Received: by 2002:a25:b287:: with SMTP id k7mr2048404ybj.9.1550254474721;
        Fri, 15 Feb 2019 10:14:34 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id m127sm2369379ywf.68.2019.02.15.10.14.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 3/6] mm: memcontrol: replace node summing with memcg_page_state()
Date: Fri, 15 Feb 2019 13:14:22 -0500
Message-Id: <20190215181425.32624-4-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215181425.32624-1-hannes@cmpxchg.org>
References: <20190215181425.32624-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of adding up the node counters, use memcg_page_state() to get
the memcg state directly. This is a bit cheaper and more stream-lined.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a04177f25758..4d573f4e1759 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -739,10 +739,13 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	unsigned long nr = 0;
-	int nid;
+	enum lru_list lru;
 
-	for_each_node_state(nid, N_MEMORY)
-		nr += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+	}
 	return nr;
 }
 
-- 
2.20.1

