Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72727C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:56:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40CBD2182B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:56:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40CBD2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D00AA8E0003; Wed, 26 Jun 2019 12:56:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB2E48E0002; Wed, 26 Jun 2019 12:56:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BED9A8E0003; Wed, 26 Jun 2019 12:56:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A47EF8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:56:49 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 5so3305942qki.2
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:56:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=9UtuahWtAhbxhjZ73YxEJ0x/8bfQk01yoJgsV0MQRL8=;
        b=ZDpTNCVBypkia6Jlp12AtaYLRRfMDghg0IXifSsO48wGvs7Pvn6qNsNcC/T8dXsExS
         /GnVuAenmXEH1HQNw6Wh9JEa+Rq1Gx1D/yOYTnSnZoOGV9iSyXA/YYoLb+IdeQvZxanr
         4RKRDaQKybs86QMyG7gxTvRms55VNQkQx1V0St6amYEO6rA0+/Io9nSy/xYpr2eREuep
         b13AuNvGni8cMWX601G1cv6wmspSDiEpBklDpzPDDHuC7KgbWCq5Jk54I7I1MV/gQ/pK
         3O5iRh0L+b4f//ERCMrcG6rJ9vW1yw2gBQMscRv+HxE48Ac85nTbpjzSt5YTpZ8CGd0D
         sdKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUDRgWSuFz1bOQrMBvNRAUqjOfq5YjgFTwhGejOFcF3qzNT4Eao
	u9cbpkk4Uf08Pk6VA/NBD3mb23tiNGjneI/DCLs83SiMwcrO2aKi5/PK4BNqanXCeXf4zO0/nNn
	refXtXb58Rr4wYE7CQ4Wr1CJp9wLffYhj5OK0aNkyi5cpJ1rXd/pyscjwZup25kj2LA==
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr4223953qvh.225.1561568209426;
        Wed, 26 Jun 2019 09:56:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4TH6+siDKA5Os3flALhhaTX1pFkUNSUhskX9/u5UxcLX0/zeR4gNbMIFMtbvssreICUM1
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr4223915qvh.225.1561568208871;
        Wed, 26 Jun 2019 09:56:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561568208; cv=none;
        d=google.com; s=arc-20160816;
        b=m7acdDEL5fZQUulKeimXKK+E1crY3QVxTTwe9C6knOrYFuTT8dkR7XL5QuYWizAVqF
         MxsdrUySq0dFKbqBc23SLOrQIuYXpDBQ/RdNPJLXjbT6voSNJzqU5xQ2kabrmnD9sICl
         n8G6VzjBERIX3GCz2aSCOJeMkoPGb/Ig2vv3RLhstxMLKv9sukMuDiRDxBdmZ0XkJ0cq
         YKrWCRYC51pmjWjW+mDf96zLAUjr5amQrUUk/xvqudVUT7J1I28WYWdwan/A+js3ievX
         iUM4FV8V9YhOAevYN+qm/H8XLsr9DDoAAopiFXUPLnR6D0eA69kuimdYOs240TUoz+qO
         eMIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=9UtuahWtAhbxhjZ73YxEJ0x/8bfQk01yoJgsV0MQRL8=;
        b=u4W8GxG0vv6kIN6SicTipciCyI0CKRdErCSf8qfUedbTzaj//rbhhOzYumyaOvAvne
         1mWvstNVC1zzUWe+D5lvR7kHqVjMBxJ5oy2wNkNqeYIyxILnCEBZlTcOH3Agzk2+x5D4
         fIq4I/WjbdcN3FmeIRDOFP3uh8X0j8eCzjQJtn3l76Lj+ip1HrnXMX0eOnvZaY+uFvVW
         jjsBA98sWk9Fhx9W9LQDrg9zB3o2clJGpZI8oO/4LV8vEr59C75rQExs22VbyzGTag9/
         OqDoDHQ6t3wICt6WcF65ZPpviSRYIXQ8B3ABqYFh/CF7uQiHU6GWGTGolMQPLCiI5exf
         1tzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si12325888qka.90.2019.06.26.09.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 09:56:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 286DE83F3C;
	Wed, 26 Jun 2019 16:56:33 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C46A119C5B;
	Wed, 26 Jun 2019 16:56:29 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH] memcg: Add kmem.slabinfo to v2 for debugging purpose
Date: Wed, 26 Jun 2019 12:56:14 -0400
Message-Id: <20190626165614.18586-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 26 Jun 2019 16:56:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With memory cgroup v1, there is a kmem.slabinfo file that can be
used to view what slabs are allocated to the memory cgroup. There
is currently no such equivalent in memory cgroup v2. This file can
be useful for debugging purpose.

This patch adds an equivalent kmem.slabinfo to v2 with the caveat that
this file will only show up as ".__DEBUG__.memory.kmem.slabinfo" when the
"cgroup_debug" parameter is specified in the kernel boot command line.
This is to avoid cluttering the cgroup v2 interface with files that
are seldom used by end users.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/memcontrol.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..236554a23f8f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5812,6 +5812,22 @@ static struct cftype memory_files[] = {
 		.seq_show = memory_oom_group_show,
 		.write = memory_oom_group_write,
 	},
+#ifdef CONFIG_MEMCG_KMEM
+	{
+		/*
+		 * This file is for debugging purpose only and will show
+		 * up as ".__DEBUG__.memory.kmem.slabinfo" when the
+		 * "cgroup_debug" parameter is specified in the kernel
+		 * boot command line.
+		 */
+		.name = "kmem.slabinfo",
+		.flags = CFTYPE_NOT_ON_ROOT | CFTYPE_DEBUG,
+		.seq_start = memcg_slab_start,
+		.seq_next = memcg_slab_next,
+		.seq_stop = memcg_slab_stop,
+		.seq_show = memcg_slab_show,
+	},
+#endif
 	{ }	/* terminate */
 };
 
-- 
2.18.1

