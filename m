Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCECBC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:27:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 908C42133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:27:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ehqEcPmd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 908C42133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FE1B6B0005; Wed, 10 Apr 2019 23:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AB6B6B0006; Wed, 10 Apr 2019 23:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09E046B0007; Wed, 10 Apr 2019 23:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB4636B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:27:03 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so3884568qkb.12
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:27:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=/apWTUDfLE14eiwDE8NHXqEFW8ik9G3/ldVR45xOjqM=;
        b=b/E7QaoULSDrX/pTEiVtSbzE0K3uLT1VhPXnjWYsxY+jSl5lgRFlTSvwb5BgpMORWZ
         veQb52BVVDbSGE+zq6ltL3IvdvTaxLr/qPOvfuZvrBOlsAYJht6dHE6vFfnOP6TYAIvP
         iBnloLI3oPczWqDehKuqzIi31P25SPJkomOoJJfGffP7rs1sU6E+6cYwBmeQTd/ZtyWu
         pu/AKM38sLNNO7IcbMFKjy+YEZhWvF9SyDoAQz5QXfHGfPS1Wudrtl4a0Jwe5dp1Uk87
         b8TPMe81MheG4dTWmGwpCk3et/hslhaD4+S/aaTFKqYiVz+rV3uolWiU9+7C6YIrBYMy
         xvVQ==
X-Gm-Message-State: APjAAAXk7nuzCLcKZPfkgBaT3CB9VCIY+7EdJmG/iX9Wql0lUBtRgRqc
	uffacVtPvQUNRSrO3tnlWT/tKzWtmadZW1BOdgk/5um0pJjYWI40/hidSu7QQLqoK2xKQyW95Sl
	Kd+NV53hM4lBD3qshWFaQ6+gO6e8smYsRC36u8uxGQQZCPVjly7MCwqXuMgNP+E7dWQ==
X-Received: by 2002:a0c:d03d:: with SMTP id u58mr38939884qvg.16.1554953223612;
        Wed, 10 Apr 2019 20:27:03 -0700 (PDT)
X-Received: by 2002:a0c:d03d:: with SMTP id u58mr38939840qvg.16.1554953222575;
        Wed, 10 Apr 2019 20:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554953222; cv=none;
        d=google.com; s=arc-20160816;
        b=NaOOrJFaFvFBcF5HJqSXnmmGF2Pv6FNMHalsgFgHfEc6fTsPGXaWMWviWiz31p+weP
         uP3cI3yRutsQnP3nc8SjBs7zq7HLsLBBqVEnos4dKeMDA/XkL7wIHbCGK3AW2XKSHefg
         ZDOv8fi1EqPvz3LPN9K9ScIqx8gO6rpqtriQ8jwbcM7GwLOL3HAXOCu1RaUKD60QIDH+
         GbBvayR1OcV9Ksxp50xmnUE5Erp1+tJcp9GJBLmJaG6pzHMuzGYYeHKVO/4BuOepr2Gp
         hyS80o9WB9q7JhxRNBtdHOY8WYa9arnN7/TKk72fjtC/qjk3wT0RvAMa2jNaVJ4mGiZJ
         2SuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=/apWTUDfLE14eiwDE8NHXqEFW8ik9G3/ldVR45xOjqM=;
        b=zN/6rmRwrnBqC3JSpSehUn47OyQpTcmIgsbgHNEmUvnMqshlkWcCeNNwyCrqokySVy
         l0jozVCxReWGJumT7R77zpCWM8CQDUyzWKyHXJrz0xlLjD1qv28pmlyzkUXAalGrwYrX
         Sn9AhpQuHbdgJFh6Q/NTpOeX7kB4HGatNARfVb2iJxD6a4hYLNj7iR18MSnC+AjmqlNE
         61B2ykUOH8S4rmn6imogzIF0ZNK9oi/UQQWoBoR2TAR4T4LI9qREF8o4QMAj5Hx7U4fE
         S550qQWE3u/d67s1X53C2GRMm/gIgiffh7ZFJAryXg7ulsiJO5S7vni4zkb2aKEC0qRy
         Tg7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ehqEcPmd;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor51743891qto.38.2019.04.10.20.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 20:27:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ehqEcPmd;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=/apWTUDfLE14eiwDE8NHXqEFW8ik9G3/ldVR45xOjqM=;
        b=ehqEcPmdEw/fasU+S3bHYOoDj6Bp/wjHEQbKzeZq0TnchS3/O9jW9fbqEpFuiuxOa2
         XHmKwdN7NftxEHFUeQVes21mTseJ4mH4YP3WFLbyQl2GON2pS57574KYEgbhFSpsxWCJ
         hm3EBL4iSDbFaQAUmsjrzywM+ylpxuqVjQmisD8qRH2uI1HgL15lvVbl7h0S9r0K7olj
         gLecOPnJvFKFtehdAPw/pI5nQguQrbc6k/NEsn2dsfWyvsF4abHGdM7oezcR0gfUPphm
         KW74NiUHSPLbpWgE22ClJi8PIjGmO04YvuBdQQz/JAiWioxpEGYwcVPCtohT+NBbOVbD
         1VvA==
X-Google-Smtp-Source: APXvYqxVJ7tRUPThUH+2r8lt5p44t/U32Pk0aH2RDMvZhVaD7ENk1+3Z7JYaTQSZ0j3TDg0ysNSAQA==
X-Received: by 2002:ac8:2f98:: with SMTP id l24mr39368172qta.261.1554953222242;
        Wed, 10 Apr 2019 20:27:02 -0700 (PDT)
Received: from ovpn-120-242.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id a47sm26484490qtb.79.2019.04.10.20.27.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:27:01 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: fix an infinite loop in leaks_show()
Date: Wed, 10 Apr 2019 23:26:35 -0400
Message-Id: <20190411032635.10325-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"cat /proc/slab_allocators" could hang forever on SMP machines with
kmemleak or object debugging enabled due to other CPUs running do_drain()
will keep making kmemleak_object or debug_objects_cache dirty and unable
to escape the first loop in leaks_show(),

do {
	set_store_user_clean(cachep);
	drain_cpu_caches(cachep);
	...

} while (!is_store_user_clean(cachep));

For example,

do_drain
  slabs_destroy
    slab_destroy
      kmem_cache_free
        __cache_free
          ___cache_free
            kmemleak_free_recursive
              delete_object_full
                __delete_object
                  put_object
                    free_object_rcu
                      kmem_cache_free
                        cache_free_debugcheck --> dirty kmemleak_object

One approach is to check cachep->name and skip both kmemleak_object and
debug_objects_cache in leaks_show(). The other is to set
store_user_clean after drain_cpu_caches() which leaves a small window
between drain_cpu_caches() and set_store_user_clean() where per-CPU
caches could be dirty again lead to slightly wrong information has been
stored but could also speed up things significantly which sounds like a
good compromise. For example,

 # cat /proc/slab_allocators
 0m42.778s # 1st approach
 0m0.737s  # 2nd approach

Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9142ee992493..3e1b7ff0360c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4328,8 +4328,12 @@ static int leaks_show(struct seq_file *m, void *p)
 	 * whole processing.
 	 */
 	do {
-		set_store_user_clean(cachep);
 		drain_cpu_caches(cachep);
+		/*
+		 * drain_cpu_caches() could always make kmemleak_object and
+		 * debug_objects_cache dirty, so reset afterwards.
+		 */
+		set_store_user_clean(cachep);
 
 		x[1] = 0;
 
-- 
2.17.2 (Apple Git-113)

