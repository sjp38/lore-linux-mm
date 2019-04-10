Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B65BDC10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 10:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BC712133D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 10:15:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BC712133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BF3D6B0277; Wed, 10 Apr 2019 06:15:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 045376B0278; Wed, 10 Apr 2019 06:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4F6D6B0279; Wed, 10 Apr 2019 06:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF17A6B0277
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 06:15:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g7so1534186qkb.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=NlFuMUS94v2NpXZV1dscR6EYhD7U+tt6O7E/YGeBZFI=;
        b=kyQZOhu7CctKwWcn79vI+3r+gEFI9hWbMSDZGFw+wP2/Ut1+ZyFNHonJSS8z726CGj
         i8Djqt3RyMFq7XPz5hTMNkVjzGwkMvjE5Vhby52QqBm43YdzAPtqB3daKVeoCCHSf7l3
         iS05Yts9hBbcsdroN/cS5fcg53hbfZtEpQWkmXda9tuUJ+ujetG5ySeEMnnjdce0YxXl
         nD8j17hCcIvo27k9TygiSaQVtz7Ww7ER22FKqcLLh1O+L9qY7cYoM/h33xAZkM8jXOzU
         UG+WAbEGPqA04d0QEkCGravYRXITtnq+e3zEyLul/yv/Mw+CKk/DPi2sJtvEWOPZzYUs
         mNIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUx0LS3XH5OGglGv8IgYdVjq493dqY17lL3aknH8/miT4twoACQ
	IOJbDr4RvEu6MbxIreTy44DU6qfdz+FzI9ZQddBRdZXJ8+NzaeJONI6dtKFfNWcbaLeMXl/idn0
	cXB9ppWJHVLQ3a+UEO/fLfZwRsLStLUf46N2OTRHQMSmEqtg4JYyMuIm4wq7m5SmSYQ==
X-Received: by 2002:a0c:9666:: with SMTP id 35mr34172042qvy.30.1554891300532;
        Wed, 10 Apr 2019 03:15:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxYscZGVUm4AJ6dOzogYyns97Ku8p4tgxlbE5FDNAHB/5lP2PSVRktirQxKXnz7pMbAXY/
X-Received: by 2002:a0c:9666:: with SMTP id 35mr34171982qvy.30.1554891299599;
        Wed, 10 Apr 2019 03:14:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554891299; cv=none;
        d=google.com; s=arc-20160816;
        b=Xcbw8tPH9DiWCTirkt2yv4CFBbT2p73tC6VTIULflvbA9sJsRKDazqD0J2bFbccNk6
         T63t1OeDKJ6U+dJvc8mULPXsClLq0m2rhUU5J7FXeJlUAofDXTqn/p5TFhMuiCvWpj7e
         T6KvyruuNcB3rVkFujlVWfr/DrmoUax4zq8VKDaA4kFrDqxm+tFAHYrs5tW4ZttP7eoj
         44iXQpBwwMMkEavI9JQd47X1Y2XU/WI+SIE+3dhXEs5FoODNZPBYYBrzi3mZebGafy8D
         S5oJk/JCSPJGiQnECO+47jm+bfLN54KPHmS760uj7wIxgpYog4Q54gB4isapverhgeXP
         d+AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=NlFuMUS94v2NpXZV1dscR6EYhD7U+tt6O7E/YGeBZFI=;
        b=GWc3rjR4d1+z58fSiThrFzBS/1jIQ2nyuVstlWp/kXI2T+PUHGu9TzhHo4st7oKKrt
         GELgkLApjYxj6klgnQ+L4FQEv7R96SxC+fg76Xnn33h7ro8eys4tXo0F5jgZTZjzw8DY
         0exDL/o20Wtzl2E4ns2FmjCwt733ShltzW6jo8y0TWJSYMRxykeyIQ4ybO1BgzIuz2Ye
         7j8PzwtryX2kwdh+IU4ep0uwHUNlLSYHrE1eRVEXp7dYyAHtfYal59qEZN+7k0412vJs
         UauAy12aGLyo1K9h8GIjt3hlCK8KrqKT6FiCmRQsQuonb6GHJwn4aNz5fxBBR8bV10vN
         7GCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i13si2561908qta.371.2019.04.10.03.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 03:14:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A3C4EC01089C;
	Wed, 10 Apr 2019 10:14:58 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.36])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 55B5917F4C;
	Wed, 10 Apr 2019 10:14:56 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] mm/memory_hotplug: Drop memory device reference after find_memory_block()
Date: Wed, 10 Apr 2019 12:14:55 +0200
Message-Id: <20190410101455.17338-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 10 Apr 2019 10:14:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While current node handling is probably terribly broken for memory block
devices that span several nodes (only possible when added during boot,
and something like that should be blocked completely), properly put the
device reference we obtained via find_memory_block() to get the nid.

Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5eb4a4c7c21b..328878b6799d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	mem = find_memory_block(__pfn_to_section(pfn));
 	nid = mem->nid;
+	put_device(&mem->dev);
 
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
-- 
2.20.1

