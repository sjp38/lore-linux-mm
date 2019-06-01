Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D19BEC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D7502569E
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IjPEdmaa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7502569E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 411E96B026D; Sat,  1 Jun 2019 09:17:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 399916B026E; Sat,  1 Jun 2019 09:17:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25FE46B026F; Sat,  1 Jun 2019 09:17:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB9346B026D
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e20so6543453pgm.16
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZBk5VgSkaQoCa1V1C97UfQBCcOPIp9dtMyMx8qLDux4=;
        b=YAv2QrvIKqer78QGf0BQeRm1qLotNCLO6SKAproPnEcaMFhSg575Qrl9lMmFGMRYTT
         /c6/Ojn/S1zs0cNImbjR2MmVyfDdXxar2bH2qJR/CfU43kZgNyoqkwSRFcukrfYmT0D2
         qdUqwMqE/0k4d+B03XIqGFavL9+2DrubHOQ9mXH5d2IF00nMutBvetocOEY0ZSjpqCF7
         3tSfGZB6ud3QNNHg9veCBZmyWMCxgulO8aEvTziYBr8aQ8A2vidTAHvzvjDX9sVxSm7e
         Ej73UuXHXJtQ/uasdI0whU1lFgqt6eljTvUnOvZLmtVPoBbvyqiFTGYgACrkOfNYGAbn
         f/8w==
X-Gm-Message-State: APjAAAXCoH88mj1dPJhV1x3npjXHkY9mFhUkWCaoX6o+nRO3jtdVcEQT
	kDqWETKHboGhMpIUdd73nme+ck36OWceuT1EoNN6xyo0cSFOw2l1cGD7Bh6YVWqX5lWhoKQSnZw
	GF1TSiCoTTMX2bXcPCaNu1QLLGLMHXPtbqIDUz5WlirQSksdikKa7+YchrqhXsq9v4Q==
X-Received: by 2002:a17:90a:5d09:: with SMTP id s9mr15679759pji.120.1559395070576;
        Sat, 01 Jun 2019 06:17:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpWCWWTTOrFz+StxR+VSFNNHvcYgaiz/FCnHPiFJupBUd40NTPNIan8v96msDp+meeQvAw
X-Received: by 2002:a17:90a:5d09:: with SMTP id s9mr15679682pji.120.1559395069962;
        Sat, 01 Jun 2019 06:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395069; cv=none;
        d=google.com; s=arc-20160816;
        b=WecZNTnYsRvuEq1T2Y/oOk6JF5r93yGqZoR9/J17rOrn0jHdQ8n4pQcKzXM2JH/VhN
         GNmNy80PfzDW6XIJ2clUNOsRjX7Bc4+I1HDeN1aMfkkiXXtS99S6Xc196mCTmIKM1N7f
         vENLXm5jHF1q5oKyUb7bbrHZXyTKcbCanX6qHVIL+Os8Mk7IMy45PJmSo93cTeiAzYlx
         FZPoTsak36DsCoIMXGlQAWLRrormr9GzTCC1fdT4o6qEOuaESrxdnPULSx6mIXw9pbLK
         7du7Ml1Nr8LOw7rz3CedN08iQzmmAwlMoa0zL53TkcCYBYEtT94x7n0nIE7PAyBr+EGo
         98bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZBk5VgSkaQoCa1V1C97UfQBCcOPIp9dtMyMx8qLDux4=;
        b=TIXi61+M0yhIsmFDWBPvz2TtK3VbvG1Z1e6AlFyaKjaiD5oGaFMCcPmaM+OruAqdnx
         bZKr0klwieL2F7Cdwr0IrsobMyhWRzNi7lqeQGQh22zINGZilm8ZW7aNJYj8uS+uH5Au
         yIAjhV3KbHjMROln3RmhHS0xGbOrDjgOvAjzOrUsDJjTilgY3YwUBtIzknRqm42crhjA
         y0WusOkqTkJ5WdzzOqq9K02VNuii/PnHgVm8JJacHYRhJQQ9qbfVr5fGIouZ9ATBXxkG
         HCPHCLSF77qC9sAGBfCuIVM/QJEj/EM65CWHwU5umxU/KthZ1qLO8/HCMMfaGUz3/IoC
         ItPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IjPEdmaa;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l35si10856846plb.276.2019.06.01.06.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IjPEdmaa;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6B6F72569E;
	Sat,  1 Jun 2019 13:17:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395069;
	bh=ozNdxPZMMldBMxTx2148v/sOELintvbGZMBdO0YDIDM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IjPEdmaa5DkhPP6Ft/n3WzZ2irB/YgpdkR0LsbJUdkFf9GCkba/ySjwblc+IVaAjE
	 6Utdw7cEjtKDG8LZKdw1/XQ9JLhddWAFjqiyWSi8lQlZKpXokzFRRMNzA3qpEBFG02
	 dXsE9NY8n3FpBd0Tb6df8Tev0/5vl6F89LQ19Zz4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 018/186] mm/memory_hotplug.c: fix the wrong usage of N_HIGH_MEMORY
Date: Sat,  1 Jun 2019 09:13:54 -0400
Message-Id: <20190601131653.24205-18-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Baoquan He <bhe@redhat.com>

[ Upstream commit d3ba3ae19751e476b0840a0c9a673a5766fa3219 ]

In node_states_check_changes_online(), N_HIGH_MEMORY is used to substitute
ZONE_HIGHMEM directly.  This is not right.  N_HIGH_MEMORY is to mark the
memory state of node.  Here zone index is checked, which should be
compared with 'ZONE_HIGHMEM' accordingly.

Replace it with ZONE_HIGHMEM.

This is a code cleanup - no known runtime effects.

Link: http://lkml.kernel.org/r/20190320080732.14933-1-bhe@redhat.com
Fixes: 8efe33f40f3e ("mm/memory_hotplug.c: simplify node_states_check_changes_online")
Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 28587f2901090..547e48addced1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -700,7 +700,7 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
 		arg->status_change_nid_normal = nid;
 #ifdef CONFIG_HIGHMEM
-	if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
+	if (zone_idx(zone) <= ZONE_HIGHMEM && !node_state(nid, N_HIGH_MEMORY))
 		arg->status_change_nid_high = nid;
 #endif
 }
-- 
2.20.1

