Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D993C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A9A821773
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A9A821773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36A376B000C; Fri,  9 Aug 2019 08:57:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9556B000D; Fri,  9 Aug 2019 08:57:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A63F6B000E; Fri,  9 Aug 2019 08:57:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCABE6B000C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:57:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x1so85576206qkn.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:57:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rCBTggVDR/vexQzmfUI07D4bXf04XmrVsz5pXgYzCyc=;
        b=Wa6reoVr+HfZopyfZWLELHYnbXRSlrv7H2hHXulEJR92L+41e46IoLe+efYxUHfuUM
         zoaoBAZpVampP2cE4T2HCedpocyBx2WBs6SfERrIEV1nlNpue4v06g+rVjZUKPpWUurP
         O5n57+HRwmg3IWRbGlcx9rCO+qGUQpitigSMi9K2abDV0v5DvKo5+9pngvdr4e2LlfLk
         ZltnzogjcMoeAcSH/hvQGkSR9XVewZRxeXpiHsotJ6qiQIHzUkVSHqdz+PB5b5+gwBWX
         kI2k2e6VlSEQOwwQ0N4lO8Gk1Lc4Zwzt/uZtk25luR4Aqncrcs+YUKoqDV1qT8Zv/NAj
         R7/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTqfVcmLafl7dWKXpoT8gNlUoUGhGQQiNXJGOrTXPdQg3J0ov9
	RKoiKcK2aBo93NdF5+XkoiQxZsTMnQRWMlZe/+Xk+sASPBAist/JoIKy1V/dgy/X+gtgy3BswiD
	bJfT2aOqv7G8K9Kg//XLq+Ob6ydl5yi9SJn7UpAtwfgWDZN1RkEo/HknEBuknLLA8hg==
X-Received: by 2002:ae9:c313:: with SMTP id n19mr5888047qkg.324.1565355463711;
        Fri, 09 Aug 2019 05:57:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4FtWwxsJetJovRy13K456OBWH6HI4aYxVnxlQPHaGticlzpLwj7qmvLcKg+931sbhOofK
X-Received: by 2002:ae9:c313:: with SMTP id n19mr5888023qkg.324.1565355463231;
        Fri, 09 Aug 2019 05:57:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565355463; cv=none;
        d=google.com; s=arc-20160816;
        b=yoA0+wLTuS9m96S6/MTZwMaSEWrQNmkUVDsi35tFZwK3EzRsHnHqxXzzGBEeYAYlDG
         Ut3QiAmwvn4BbrXorCfmqlUsciHxTVIvcWKxfvm62VBQN4fG6QjRluQsWCImm9sSs7Ml
         L89aCGIuMq1g/O1XwqoCpOpY9HW+qL59dgt+fpvO5ZESOEfx8hX9OWzjXUFy3P+ZkCFw
         2pV2aaBHt6zq1nj+CK94eN30Yw5QDGM0eBjv15cns796OR6ddpYWjfIv98lfeZk7e1wl
         5EkpdLHzBYzzjHcnveO4yyDNL4UUOLNgavhHM2cRtcupgL63TuLmBVntN0jT2sjo2P4s
         gYLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=rCBTggVDR/vexQzmfUI07D4bXf04XmrVsz5pXgYzCyc=;
        b=Jwhvz/pWVhNEdvg8G60feyvxnTGGC3JYMfOSgm7/AmEijFO5BgeEBZ30c90Da67iHL
         MsrsgC6Js+Fa9jvJ/T06+qzSFg4EkZi4qJKhJCpFa1y83FrKzvCOrZnuh5fBrTRs/YrU
         LnifxtW+CHAVHOUCaz3vvQ6nJZiBbpkFzBXZNbFhRhKGB+6iVpX+3zOw1pa6v0vqKMVV
         WAL29J88is12svDJ66myYPTtIAAiin1Q5VUQt1Qh7nhiySVlEc/rK6wJuuob/vP9EPDL
         tHfev67kprr9E1/ZN8V6/jD2wMJVJGd9WVZdN/uYxO8UP61kcKZnjKNGFLfFm8td2HNw
         Xr8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si6158252qkk.268.2019.08.09.05.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:57:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7BAD965F37;
	Fri,  9 Aug 2019 12:57:42 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CFFFA5D6A0;
	Fri,  9 Aug 2019 12:57:40 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v1 4/4] mm/memory_hotplug: online_pages cannot be 0 in online_pages()
Date: Fri,  9 Aug 2019 14:57:01 +0200
Message-Id: <20190809125701.3316-5-david@redhat.com>
In-Reply-To: <20190809125701.3316-1-david@redhat.com>
References: <20190809125701.3316-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 09 Aug 2019 12:57:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_system_ram_range() will fail with -EINVAL in case
online_pages_range() was never called (== no resource applicable in the
range). Otherwise, we will always call online_pages_range() with
nr_pages > 0 and, therefore, have online_pages > 0.

Remove that special handling.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 87f85597a19e..07e72fe17495 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
 		online_pages_range);
 	if (ret) {
+		/* not a single memory resource was applicable */
 		if (need_zonelists_rebuild)
 			zone_pcp_reset(zone);
 		goto failed_addition;
@@ -867,27 +868,22 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	shuffle_zone(zone);
 
-	if (onlined_pages) {
-		node_states_set_node(nid, &arg);
-		if (need_zonelists_rebuild)
-			build_all_zonelists(NULL);
-		else
-			zone_pcp_update(zone);
-	}
+	node_states_set_node(nid, &arg);
+	if (need_zonelists_rebuild)
+		build_all_zonelists(NULL);
+	else
+		zone_pcp_update(zone);
 
 	init_per_zone_wmark_min();
 
-	if (onlined_pages) {
-		kswapd_run(nid);
-		kcompactd_run(nid);
-	}
+	kswapd_run(nid);
+	kcompactd_run(nid);
 
 	vm_total_pages = nr_free_pagecache_pages();
 
 	writeback_set_ratelimit();
 
-	if (onlined_pages)
-		memory_notify(MEM_ONLINE, &arg);
+	memory_notify(MEM_ONLINE, &arg);
 	mem_hotplug_done();
 	return 0;
 
-- 
2.21.0

