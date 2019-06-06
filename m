Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFC8DC28EB2
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84F3520868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jg3GgoVm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84F3520868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01FC66B0269; Thu,  6 Jun 2019 06:15:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F13C56B026A; Thu,  6 Jun 2019 06:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB4946B026C; Thu,  6 Jun 2019 06:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A34C76B0269
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:15:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l4so1530261pff.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:15:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=8+IwF0335QNXDHgSaRi4xr3Z8UVNirnqsUP9wOtPXKs=;
        b=mfvSw1n+IlhWC+e7cpdap0Zwwu472eFIwhAbz1BgJMhMSZBABIjhA/wua009rFLeJy
         BzkL0Jnqtj0y/6MK3rOLExM83eTfys3sjN7LE2WvveCrkq/2W1tR8RRol18yl4nQzDPL
         dH24lCJEVYFLHDzY3QibTVPK06JwZO6ibJoFyM41ymJPpUbwNiMIrDxmzAnYlVJCvKQL
         0f+hotcfEPk9k4ij8r6YUSDDesG39Wy3h7uCz/2cRgBz8R7CJURIg8otXib1FFd8Me4R
         FU1I8rg72uItVda+/F6LgnFT+LSXWgmBH1tiSns7BvFT2U7LL/slj2I7BJ7KE2mMPS2u
         M3IA==
X-Gm-Message-State: APjAAAU4t54+BvRuWZqr6adIAvKV8ZEdVXYUGONoitivjL7xPF575xed
	xsl6vqINzZMxRjieYX4SK+oPl6LyOLz5pPfpmtUVuU1XanxE5+6doY0XONwnZO4nDkk41sYXzS9
	6Iy6kEUYK+an5xYJ8EM3L7yK+homdtO7rQY/UAPivFkb9G9UgeUiaI+fUreQDGVISvw==
X-Received: by 2002:a62:6844:: with SMTP id d65mr52706642pfc.175.1559816123118;
        Thu, 06 Jun 2019 03:15:23 -0700 (PDT)
X-Received: by 2002:a62:6844:: with SMTP id d65mr52706559pfc.175.1559816122057;
        Thu, 06 Jun 2019 03:15:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559816122; cv=none;
        d=google.com; s=arc-20160816;
        b=QxbO7fT+g7PhE2Ex94+YCo5sJurxzqDGMBv4nXPi+OAC1GkRPnxtJ+a91AWqFNpmE9
         WaHCcdhw6qym2xKJvKrSlqF02eCy7EDEOx4nBSnhGEOfsJw4wLFyGOMk5gH1HPjmEOIc
         tIhYKZGG9DszLaAbF8qT5KY/lqPb0zhpJb6gBJC4e9F1rf5Ux4VutmvW9v8gcVN3VncC
         Y3GZkgA4Nz9uwNCJmNIouCXZfqoaJ22GYO4tvbbATQ1bCEk9xmjGh5pIFnRVi/afhnJo
         RzbctiaitikJua/SDawPFMQ88fcB1RjzT9fyMlbstwuF1fTlYH2cFDOzCKy34fQcgtqp
         PiaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=8+IwF0335QNXDHgSaRi4xr3Z8UVNirnqsUP9wOtPXKs=;
        b=ddEvN/Ru0w9tckFcovRDacqKoRqLKk9w5IZXuxVObEwG4HiqAzLnfAPMWuz9x3Iigb
         ecSXcrLKx81urKERlKQlS5NkPksnAIOpLuQjFemQE+nJ62skMIKAlVPDYIwbNX+SpGqG
         AHJ7epMvq8hHhThtAd/94BH8PHmaHrlQo3dX0sKUoTyTZPFRnFIdUHujGy4Tw7gWGEsH
         ELJTBqzvHfGVcB/IAuC+m1QJHHnvSf/2AE4pruwSP1DNsx3XV+AZ1h9EAqpux3hsDFsJ
         WVXy0PL88zn9xD4DQJ2Z4VBtRnE0ANnQnLZJtSVQLF9FZ9ai0kLuWVR+kGxVl3+q6hlh
         1GXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jg3GgoVm;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor1552099pjn.27.2019.06.06.03.15.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 03:15:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jg3GgoVm;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=8+IwF0335QNXDHgSaRi4xr3Z8UVNirnqsUP9wOtPXKs=;
        b=jg3GgoVmCY/bC92MYCfLgi6NuTGRDm/487IydZ68+fijsLV0d8QxsKpi3gevxG9MKv
         CStbLX6GcKQhMDuDtfH2TO6FMGyratyZUUmu1DDva5BTYrq8x2y9NwVtMKQL73uAMWb9
         LZTVLPDSvrwDNly8FTs5U5LwOomGuOWQGaRAV0rXqIp1lbhDWLSAbs9/X0F3ZK4jyhYv
         w/BtCr89WltsywNUQu/KINBbhTtoHYQC/+5ymTZzu90d/5xhoSH4GhK0D7UbetwEhSjh
         kpNL2h1jmFzmo0NG6xoztwVGzFHhJRgQXkAyotG4Y7PRE9fQiVzVYYVALkY2IG8/7wOv
         vXGg==
X-Google-Smtp-Source: APXvYqzG3+8/LzV9uQ9G3bjFjX0YqT5YWawQvI2XSVm68YYd7+NjikxYEiHsmbZD7zjSF9YXSvPNuA==
X-Received: by 2002:a17:90a:364b:: with SMTP id s69mr52048168pjb.15.1559816121658;
        Thu, 06 Jun 2019 03:15:21 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id z68sm1895829pfb.37.2019.06.06.03.15.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 03:15:21 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	linux.bhar@gmail.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v4 2/3] mm/vmscan: change return type of shrink_node() to void
Date: Thu,  6 Jun 2019 18:14:39 +0800
Message-Id: <1559816080-26405-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As the return value of shrink_node() isn't used by any callsites,
we'd better change the return type of shrink_node() from static inline
to void.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84dcb65..281bfa9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2687,7 +2687,7 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 		(memcg && memcg_congested(pgdat, memcg));
 }
 
-static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
+static void shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
@@ -2857,8 +2857,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	 */
 	if (reclaimable)
 		pgdat->kswapd_failures = 0;
-
-	return reclaimable;
 }
 
 /*
-- 
1.8.3.1

