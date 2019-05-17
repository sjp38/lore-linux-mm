Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B97D2C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 11:42:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68BED2089E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 11:42:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68BED2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7506B0005; Fri, 17 May 2019 07:42:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B77016B0006; Fri, 17 May 2019 07:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8E4C6B0007; Fri, 17 May 2019 07:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDBD6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 07:42:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r5so10232469edd.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 04:42:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1MSGMYa7Pgl5jEklXI4z+mlq/ex7QoqUEhMVw2Uee6o=;
        b=QI5MWlT+Na0/lnqHUnoTAgMgStkO0ZBsIeB4m26KazhSMNAIKUGX922BNF/LS1cKC/
         90wxqBt1a7W9XiSrR89oKhjAer9uFK8Hbwd8ob3rDsnWJ39L2WFtkePA7HAtd6Y/JrkA
         wXUf31X/xV4LReLBpvTI5t31pvsskPZEezwjKsBnHOUVN4s+epnOJMQUPk5zAz8HZ7Rn
         0rifLd07NnY+A+UKw/R7zeIKIemuVkaQH/liSqDCzxi8gDGLm+T5DVj7jVqomtYhxxR9
         bymzIB5napUahO3BYcs+OlKtR19PQ5hDiq287rO47MHDcnDjxkNLmve6GdAgTyuPybYw
         uOSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Gm-Message-State: APjAAAV7935SXX8Sy+t4qhVPhOYqPrst3025g3uMFaXXn3V9kJgBpZtD
	5+FMkDGfUbIDw9xDL10xV1k7OTiO1OBwg8nNS1BgKvfdpclwZn2FRdTliUic1tiTbVj5Q1zrnvl
	IUVtu82MqyxS8he/03u2EWR2Ox/6wdxR1K3MtXrqRcDL8gTs1sR1G+jV4kGiOgCODew==
X-Received: by 2002:a50:9858:: with SMTP id h24mr9199419edb.147.1558093327826;
        Fri, 17 May 2019 04:42:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1d9JCzesRxG9f5bQ/Z2yUpOdmwVTPmeJ/zdI16Oy0u/2vPHX+20HPCxiXq3wGDM/oYRF/
X-Received: by 2002:a50:9858:: with SMTP id h24mr9199338edb.147.1558093326857;
        Fri, 17 May 2019 04:42:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558093326; cv=none;
        d=google.com; s=arc-20160816;
        b=M0pwdoNKWC2nnWpSd2uPeo7TeIbLlrT7yOfTfYsCGcr7OQLx21zn5aSi0FAPSCvRX3
         s5NzZdKgfNrXeOOZEUFh09vCYuzOCGy+/REloFfbHV8IoZCskSbQJc51Ls6nmbhy4INY
         a4q7R1iatdCF4ECjV+pq7uCKVGqMfh/UFP5JOE6anbafieNFLp+V+fIT1ehfPiNzhgou
         dFDlFH2875et6E3fDtvi5LnaCJa1TbGdSdCjPcNEp2LoUoJ/AI3cn6oYfOCbsMNB4esB
         7QmiXGAjs7jPIaVj7FC6LD28rfli2qNJXze3q10T1fMF9387OAHJXAUHpo7wkSqJ/N5o
         CUoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1MSGMYa7Pgl5jEklXI4z+mlq/ex7QoqUEhMVw2Uee6o=;
        b=fZTepfoSym6v4owAnZYge5RGjBm+/FKT5B20qdRnhO96LVZBqTAFp+vnV88gyx/Mic
         J47RnVkaDJMowXj8mePuPelfsS9T4tgQ+YGyF/POno5WEIARGZc5js0vl958/D7Lidfd
         wpacMvOsTqKtqVRRoNNkpg066e8lm+Swj9ItKRWLyXwNQZZ0KHIlww+HOvtcx9HvSOMR
         LK3HDn7VbirPVCMQEYJdS3WjFkvR0zHFUDmGbI97kvCAORkMxit/hi9yrOHyDEskovB3
         hBAgeOFpM1WAgSjNGBQPBv4eQ9NmwY44gjA9GuEYZ8l03caXoViRlPKp0ROHkiqh1gI9
         2QeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3si2693867ejb.94.2019.05.17.04.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 04:42:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A5610AECD;
	Fri, 17 May 2019 11:42:05 +0000 (UTC)
From: Jiri Slaby <jslaby@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH v2] memcg: make it work on sparse non-0-node systems
Date: Fri, 17 May 2019 13:42:04 +0200
Message-Id: <20190517114204.6330-1-jslaby@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190517080044.tnwhbeyxcccsymgf@esperanza>
References: <20190517080044.tnwhbeyxcccsymgf@esperanza>
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

So fix this by avoiding checks on node 0. Remember the memcg-awareness
by a bool flag in struct list_lru.

[v2] use the idea proposed by Vladimir -- the bool flag.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <cgroups@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 include/linux/list_lru.h | 1 +
 mm/list_lru.c            | 8 +++-----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index aa5efd9351eb..d5ceb2839a2d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -54,6 +54,7 @@ struct list_lru {
 #ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
 	int			shrinker_id;
+	bool			memcg_aware;
 #endif
 };
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0730bf8ff39f..d3b538146efd 100644
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
+	return lru->memcg_aware;
 }
 
 static inline struct list_lru_one *
@@ -451,6 +447,8 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 {
 	int i;
 
+	lru->memcg_aware = memcg_aware;
+
 	if (!memcg_aware)
 		return 0;
 
-- 
2.21.0

