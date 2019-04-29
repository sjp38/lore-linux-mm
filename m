Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50E7EC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14CC9215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:59:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14CC9215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9D5C6B0003; Mon, 29 Apr 2019 06:59:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4D846B0006; Mon, 29 Apr 2019 06:59:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3BA76B0007; Mon, 29 Apr 2019 06:59:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62ED26B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:59:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o3so4653209edr.6
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 03:59:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dWX3FWphLOghWXlk17TBdDF7RRERQ2Z6BRop46ttLq8=;
        b=GEV7NwYOd2uVaMbO++IQfTmVMKLVg3PhD8lK2D+eTL8FhnyZc5R0IPpZrojryY3ct5
         lwB2HhVR7DJxghPQ+LsCJWyBuDPqQ3jHe/xDERROc2j2seazXcX9jEFhRDFrJZDtLwoI
         WAqQppbnqIWsuBAG1oKrFeV6leUudsMv5tszPOW/eMDHP9YkbE4/erf/qGVVKoCafLhy
         aEAWGzWY7qOtus3W12QKDV69PbOMbIfGF4enOcAGa4Z9+KKlE7S2JwDxm6bjp8G5Umt9
         SnZRafaFquOmccaqsG1sChCIG+oh7Cg4qQK3M9x1rZ4nr2/LZAwsX3O6NldcFVc4ue8c
         +qsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Gm-Message-State: APjAAAULeFmqr9VMns6CEjoblcnWpcX8mafYeVHhk+fGdf4viIrz8cfq
	RqLhfLVxvIXeFTvkPAnUz7mbTFnCMd/CaHRw+yYxeTi0kwfJrPqI7Jdgxh9EWluwNCHfHuv4Veo
	NXgpQ9ijGIO1h8uW+I+2AkUh3fFDxsngstFgwlXi5xfzzW5SH3wjZDP+fOCACMBpN1Q==
X-Received: by 2002:aa7:c50e:: with SMTP id o14mr39155735edq.0.1556535582893;
        Mon, 29 Apr 2019 03:59:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhjF69Ra5WamG+OhZ1DCx7fZDc9tBPUwKfctJuWs+7IDjeyPTQt+i0j2c7enmdwZLeGAZb
X-Received: by 2002:aa7:c50e:: with SMTP id o14mr39155700edq.0.1556535582027;
        Mon, 29 Apr 2019 03:59:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556535582; cv=none;
        d=google.com; s=arc-20160816;
        b=UIbJYwLq2NghqZd7V/YVxfSL0Mg8rIevz8stCe5Gh6OMEyU9AXQqRoATrCKfyFAd8B
         I3kt9g7cfbTdqYp49CDWCq50CmwvxTHk2TnWM4CtlW1pHkC93LP7nYxqQYEdD0luX447
         0+3tvxlH8nxXzyT+qwt91pT1VUyq8SK3v2PQa79vMQ5Q8P25P5Xevj+8JVskvCZ+Vkee
         zIJmHhykemXIuyh/+mMYdPdpiICOGj6yey7xpmeuD+GEjhUT1zxmexhr6mEKmbWFmFdP
         XnVYp/zybNH5MuUGgKdqmqZPYnEf0FrOdM7ccCuNkvznc7D8lm1CcvYtBCkKZJptQVE8
         8WGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dWX3FWphLOghWXlk17TBdDF7RRERQ2Z6BRop46ttLq8=;
        b=pVwIRw1HWmFpvwJ5z7aY8efbigDtNPtOyfCIihQTcULxhm3/sgasoU31F3fzJJbURU
         BKPO+WREnvPrQe0aB54ccZCJHbUpCOquHyPn/yJkFNZDUcJetMBWXudT3jrrhejb4tLq
         YWfdJM8XseZyamPP2f6v0RkIyyAaS8sma2nysvrjx6d6k/1O0cz4gsnftatTk8U1UPQG
         2wf4tPHiagRayrIDMk0/7/U1Egs/LNadRpt+zpNaYADk6cdfbDd83r24Hr5SoiaGcVIA
         oH1QYOOslUsCGolIj//biDeKg7WryiGXImi3ZCTq41vYmCTyPNMkgNt0hEkiVh9gXkH2
         GdRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si5723108edx.407.2019.04.29.03.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 03:59:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F05BADE1;
	Mon, 29 Apr 2019 10:59:41 +0000 (UTC)
From: Jiri Slaby <jslaby@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH] memcg: make it work on sparse non-0-node systems
Date: Mon, 29 Apr 2019 12:59:39 +0200
Message-Id: <20190429105939.11962-1-jslaby@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We have a single node system with node 0 disabled:
  Scanning NUMA topology in Northbridge 24
  Number of physical nodes 2
  Skipping disabled node 0
  Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
  NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]

This causes crashes in memcg when system boots:
  BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
  #PF error: [normal kernel read fault]
...
  RIP: 0010:list_lru_add+0x94/0x170
...
  Call Trace:
   d_lru_add+0x44/0x50
   dput.part.34+0xfc/0x110
   __fput+0x108/0x230
   task_work_run+0x9f/0xc0
   exit_to_usermode_loop+0xf5/0x100

It is reproducible as far as 4.12. I did not try older kernels. You have
to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
investigated). Cannot be reproduced with systemd 234.

The system crashes because the size of lru array is never updated in
memcg_update_all_list_lrus and the reads are past the zero-sized array,
causing dereferences of random memory.

The root cause are list_lru_memcg_aware checks in the list_lru code.
The test in list_lru_memcg_aware is broken: it assumes node 0 is always
present, but it is not true on some systems as can be seen above.

So fix this by checking the first online node instead of node 0.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <cgroups@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 mm/list_lru.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0730bf8ff39f..7689910f1a91 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
 
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
-	/*
-	 * This needs node 0 to be always present, even
-	 * in the systems supporting sparse numa ids.
-	 */
-	return !!lru->node[0].memcg_lrus;
+	return !!lru->node[first_online_node].memcg_lrus;
 }
 
 static inline struct list_lru_one *
-- 
2.21.0

