Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D154FC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86A642084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="FpWx+tFi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A642084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AC4A6B026A; Fri, 12 Apr 2019 11:15:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CD06B026B; Fri, 12 Apr 2019 11:15:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1066B026C; Fri, 12 Apr 2019 11:15:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35C6A6B026A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:15:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k13so8973507qtc.23
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:15:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Os4Omut1si9dZUtk8xlS/9PlA4SUJZFOM37ndbDq3oI=;
        b=dD70gIWm1OBBV99+lCO9Sl1dV3mJQiB69+DDt0Er8gqHO9MVPaa/JpoA103gzHwwDD
         C/8hiUlAFAXdI0xWieMpakKAhlied4e73mrQjPVWhW7zDh4KcZzPUcj3Z0vOQrMK+UGp
         l8o/udXBmtvbz4pqXgANydZn6RwrG6pXdqL9lZo4uYLX7xXahtrqRAtpY96xYkYz1qfw
         LFT7n7Ny9HD9JgQXjQt9Mx5FaA/eridJquED/tFvU3w5XupEVecn1yM6pdSmo8LrBSMF
         TSdYvkaITsJUtyprW5Ynx7p8U9u/zHr+o7l5DUZ1sYHO97as+f47rBSVN8RcWYPnbdvI
         +OdQ==
X-Gm-Message-State: APjAAAWZn8MMnBmyhbdRPa2+G0ygGFOevk2ch1RW+yFi4uaYYOGsIzIx
	wXur0cA/XDyxO6KWRPr8WuRAoRouKcH76xJ22Icn+jlPjRBaQPFS0yvGw6HGzISZWXfK1+VPybc
	/61JEUMyak810Vuy+yJ1dnEna2MR3+NgnOaPUgDvRKB3YU5/8FC9IbOQz9xHrm9e8oQ==
X-Received: by 2002:a0c:ba0f:: with SMTP id w15mr46923083qvf.20.1555082123898;
        Fri, 12 Apr 2019 08:15:23 -0700 (PDT)
X-Received: by 2002:a0c:ba0f:: with SMTP id w15mr46922979qvf.20.1555082122728;
        Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082122; cv=none;
        d=google.com; s=arc-20160816;
        b=D+OlfOxdafoC6jocXUtq0Gdsk/ZkHbqTf9KKywzPh+X1Vt/esiCW/OdhLvaou7/UUG
         tdIroJ66VY2ktctLLEHfuu0tHLkB+zeSR/+POI3oI3Xu1IswW8HOkp4zvJY+5LJA8Nb1
         2N2r+K9IDVI4j87cdsPHlRK7E1Cl7WNRciFtfIivy9rj+7uAtXCdpYvwtNTDL451uZ3B
         78hwzSd9s5So3cDZVqGVBCnc/OMKJqiALYLjPIYQhZtatgpwwb+Gpkeq/s/Wni9Mqi8n
         8kluPMWQaGjjSkDUPnQampv5NbP6erQBvX0A0xVDwwvemWI0zpyIKu/50tDbVolSl8PV
         WcUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Os4Omut1si9dZUtk8xlS/9PlA4SUJZFOM37ndbDq3oI=;
        b=v6DvshjhoG/5f8O0LkAU4X2EojIb44A0YawP6RpnwXBVUD2pI6b14qlzwYHPfQ1Zem
         gSZQZyCSMpjBrlnvC+HfF/ETSGPWnU6dXrr5A0AgV7qglHlWZTHPROqFI6B43lQEf6e1
         Ru6NBCr5mss/oO8do+kDDUCg378cWLcvCCMMxnu5fdtKoBZNn1oY9ECZNSwZKan2mQyH
         HU2/OnhpFWrpiWpmatHbsNYhoYTnbIKf4t4Ud4toiLBYaXiWJFKbs0+QyEtGH8kJajwp
         cQnCf6imfeQrtd4jO1CYlkGpYuCkK4Y1SKHbp9xCEqvcLoIV64wK0qHL784RvDVF1edr
         PT8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FpWx+tFi;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o56sor41702310qvc.71.2019.04.12.08.15.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FpWx+tFi;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Os4Omut1si9dZUtk8xlS/9PlA4SUJZFOM37ndbDq3oI=;
        b=FpWx+tFikqrZdAqHy8DuhFwSzGznleXRgjxZNDwl8fFECEghu5j8q1+uwliecftUar
         L0qovs/uw2w7CgfnMoQx78Dk2YOOBJoP4QTDOWlGJbl0O6GIUQ59VmwlLyyT2oHnuPB9
         8hmvZJ247fTWRB9ZF+7KVq8xvyJanOTGCHhUTW0AmBAPBRC57t2u1Dj8wD9npYit59ja
         SWtjvgC6wCEuHSXwHDt8NxymIdh+HFjimb6yjHjLjhhk9NO03kJFznmagrp8qtPf2wJn
         CBD2GaKz8nvXzLO0rYOHzvsSx3udCXhFRsoJhxmSHMjI/slxgUGy30JqhrRYaSYZtXU6
         8JdQ==
X-Google-Smtp-Source: APXvYqzVDhpq/REyjk2jbBHCrlfGWJ514qWQfxe7lwASD2ybrledPl2eTVl5f7Jl8CXIIUISZgnShw==
X-Received: by 2002:a0c:92d5:: with SMTP id c21mr48389189qvc.215.1555082122539;
        Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id m189sm25217643qkf.2.2019.04.12.08.15.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 08:15:21 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 4/4] mm: memcontrol: fix NUMA round-robin reclaim at intermediate level
Date: Fri, 12 Apr 2019 11:15:07 -0400
Message-Id: <20190412151507.2769-5-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190412151507.2769-1-hannes@cmpxchg.org>
References: <20190412151507.2769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a cgroup is reclaimed on behalf of a configured limit, reclaim
needs to round-robin through all NUMA nodes that hold pages of the
memcg in question. However, when assembling the mask of candidate NUMA
nodes, the code only consults the *local* cgroup LRU counters, not the
recursive counters for the entire subtree. Cgroup limits are
frequently configured against intermediate cgroups that do not have
memory on their own LRUs. In this case, the node mask will always come
up empty and reclaim falls back to scanning only the current node.

If a cgroup subtree has some memory on one node but the processes are
bound to another node afterwards, the limit reclaim will never age or
reclaim that memory anymore.

To fix this, use the recursive LRU counts for a cgroup subtree to
determine which nodes hold memory of that cgroup.

The code has been broken like this forever, so it doesn't seem to be a
problem in practice. I just noticed it while reviewing the way the LRU
counters are used in general.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2eb2d4ef9b34..2535e54e7989 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1512,13 +1512,13 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 {
 	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
 
-	if (lruvec_page_state_local(lruvec, NR_INACTIVE_FILE) ||
-	    lruvec_page_state_local(lruvec, NR_ACTIVE_FILE))
+	if (lruvec_page_state(lruvec, NR_INACTIVE_FILE) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (lruvec_page_state_local(lruvec, NR_INACTIVE_ANON) ||
-	    lruvec_page_state_local(lruvec, NR_ACTIVE_ANON))
+	if (lruvec_page_state(lruvec, NR_INACTIVE_ANON) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_ANON))
 		return true;
 	return false;
 
-- 
2.21.0

