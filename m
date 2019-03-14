Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 880EEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 388CC2087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="m9UUtS1G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 388CC2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C23F78E0007; Thu, 14 Mar 2019 01:32:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BACCA8E0001; Thu, 14 Mar 2019 01:32:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4CE98E0007; Thu, 14 Mar 2019 01:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 781258E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:24 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p40so4278293qtb.10
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nG4agUcLr3gug1FP86NJDoqRG2ICgfrBSTTX0F15CjU=;
        b=cn/kQvFcGSqLfQwWh13aGbhQDA3RfdTxGaa0OTn11haMmjiHMjbcJE3Fs0jrPBkT1h
         qd4HQ/RaZkzq04R4DuOT9Fn5TKBQpiLft+n1z7rusEBHrBhEXpNNhmBXj/UpD1w5gQn8
         UNBh+KI0bztxU+aDtb9DRIq3VezgPH+qBl+8xBXphVrIUuq5cHpYnqLZoPgd+8pL0Mlo
         22i8LWk/PPMvXplIFiUWpFvkC59RrXinXjjzWcl5cKIBxBm5xX0Wew3nVtqMWTvi5nkq
         BIHDeEsacVeAFmLJLPgzQ8rsWlOLjwZHgwdoELwrqbWcdGcgag2G+n+XU3KGp/UNm8/s
         dgUA==
X-Gm-Message-State: APjAAAUL/3PoBA5iMNnLbIZ0x2g59+RJaKhG0GWpvzV8E+VaH5PVHOSb
	gKjSXycDJ3qSZXCV4R0ufzsV6cn8egv9hP8Bkxa7DK3nOKg0pALYeAcqce5DYFHoWbp+h3hTU4I
	2UTD4niaSlVaHy54bYfidEzdlJWkZw6pnB0J318q0Bw/37S/xvZPS5C88PSyAenM=
X-Received: by 2002:a0c:d121:: with SMTP id a30mr38706087qvh.0.1552541544280;
        Wed, 13 Mar 2019 22:32:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwChOW4ZNEhDYiyjdVIjwe2spIZUxIlWs2Chjs83LwGRSkaX0Bl/Dh+uUlbXWUy9UNwcxIl
X-Received: by 2002:a0c:d121:: with SMTP id a30mr38706045qvh.0.1552541543070;
        Wed, 13 Mar 2019 22:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541543; cv=none;
        d=google.com; s=arc-20160816;
        b=z4DXTrVdMu00L5xEuQzOSfS7jhjx/dwKcmDPg1d3fvfwbi2zUNdqoqJBdVo7E6M1Sj
         IqEhADuI0B4v1Ck7T3JJsTaI79o2j+OjavIPUON3QEI2jDYIZxOwjetYklSOTGIbz+e9
         Pc1o2VXwqHePxOIeP/Vd2OrgEn3FZQ8gpDh2+fA5rWkCbeu0PV20sVTfhkCOT1rT7tZ4
         +2Ei1Bj21l8StTHZVRv/gYuTtGSaJVwOLMPZIC8fkVVOTGAwN/rjTj1EAdRmP+rZjXb3
         ZVqRZkpyccPYqCXbx4qILPXYAL/XMUsRn/QVWI8bXjbMx0WHE3kjUpnO3Ezr93yd6WWf
         AUQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nG4agUcLr3gug1FP86NJDoqRG2ICgfrBSTTX0F15CjU=;
        b=pcIq+DTVwI/TTxI9X8ukzHZBtt7xKg6wJ6/npIAAQmDceRdAjLZXKF7j7ggp6VOKfz
         ck+c+yW8vm75Gq79ruIrC/qMqq20YQxYkIxmfzoBBVzdjD6ADaeRsIgT/2LNjS0D87gy
         k9pxvP9Mfl/7hy8XU1NqHFHaNeynxO9rtdR5OWf5gLcOqqJ+Hc0UY4tak79GVbrNrOug
         8l3h9Ma94tS8IxZfWFuLg3aRQVn+Qe7xKlzhNg/LPDjGiSi9fWlIQsLie+R1ddt/maON
         xnGJLXmP1dJGyYe34AJLvmXvbNqZ2enPDWqzgueHQPlfJZXZuU8oUqlL2I0+2MY2gZDf
         P2QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=m9UUtS1G;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id c10si3807900qvo.164.2019.03.13.22.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=m9UUtS1G;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 33514211D3;
	Thu, 14 Mar 2019 01:32:22 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=nG4agUcLr3gug1FP86NJDoqRG2ICgfrBSTTX0F15CjU=; b=m9UUtS1G
	40FHBT/D9O6JXELA1BCp6O4Sluhh7mUEhII+Ba5sMV5CBy+n9/REazHlR5r1hcTl
	fQuwdgisFb6XgDVU4O7WaugvbfvdGUBlIPlw7utDbAmqcDe/ZpiImtHci4EqqV0E
	vParUzUOU4cnnep2FaTm0LAQ+tje32yLG9CIa44pUI/zwyXErnPsogmqRg4nAoFu
	as37G4O3gF8YkGOQ0wMJLYk9M29oSBUVMMvLie6Pxxpc4SOuUAboTMo7XxYwLhVA
	kgW+f/GN1meV20+I1YgD+KGxEYhiVyLwFFs8NhtyfNyFxNSzZbmcum9h1WzjcGBY
	M9aPyGrppSPzqw==
X-ME-Sender: <xms:ZueJXJIMLsNCiBGM5xsLniOfD3pfeyL1jjH0oKjgbE6daitqYK2Pwg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeef
X-ME-Proxy: <xmx:ZueJXFkcHfIPkUM_SC8RDcUaBXQav2ruNclyJOVpPE0F5kCOShvdtQ>
    <xmx:ZueJXIlKu2i8gWmXoPCb7Od3rLZvfyBoaw-tguOID9vmrzqgrhOkhg>
    <xmx:ZueJXApCFbg3NGsuO9sL4QgXgl0GUP0--a_xobU7310DxI_NzHCpjg>
    <xmx:ZueJXEXZwlnUXg2E7ewRuELprjmfMU4k5TdMdgmfGDIVBcaOxTdpXw>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id D4004E408B;
	Thu, 14 Mar 2019 01:32:17 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 4/7] slub: Add comments to endif pre-processor macros
Date: Thu, 14 Mar 2019 16:31:32 +1100
Message-Id: <20190314053135.1541-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190314053135.1541-1-tobin@kernel.org>
References: <20190314053135.1541-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SLUB allocator makes heavy use of ifdef/endif pre-processor macros.
The pairing of these statements is at times hard to follow e.g. if the
pair are further than a screen apart or if there are nested pairs.  We
can reduce cognitive load by adding a comment to the endif statement of
form

       #ifdef CONFIG_FOO
       ...
       #endif /* CONFIG_FOO */

Add comments to endif pre-processor macros if ifdef/endif pair is not
immediately apparent.

Reviewed-by: Roman Gushchin <guro@fb.com>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1b08fbcb7e61..b282e22885cd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1951,7 +1951,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 			}
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
-#endif
+#endif	/* CONFIG_NUMA */
 	return NULL;
 }
 
@@ -2249,7 +2249,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
-#endif
+#endif	/* CONFIG_SLUB_CPU_PARTIAL */
 }
 
 /*
@@ -2308,7 +2308,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		local_irq_restore(flags);
 	}
 	preempt_enable();
-#endif
+#endif	/* CONFIG_SLUB_CPU_PARTIAL */
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -2813,7 +2813,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
-#endif
+#endif	/* CONFIG_NUMA */
 
 /*
  * Slow path handling. This may still be called frequently since objects
@@ -3845,7 +3845,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
-#endif
+#endif	/* CONFIG_NUMA */
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
@@ -4063,7 +4063,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
-#endif
+#endif	/* CONFIG_MEMCG */
 
 static int slab_mem_going_offline_callback(void *arg)
 {
@@ -4696,7 +4696,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 		len += sprintf(buf, "No data\n");
 	return len;
 }
-#endif
+#endif	/* CONFIG_SLUB_DEBUG */
 
 #ifdef SLUB_RESILIENCY_TEST
 static void __init resiliency_test(void)
@@ -4756,7 +4756,7 @@ static void __init resiliency_test(void)
 #ifdef CONFIG_SYSFS
 static void resiliency_test(void) {};
 #endif
-#endif
+#endif	/* SLUB_RESILIENCY_TEST */
 
 #ifdef CONFIG_SYSFS
 enum slab_stat_type {
@@ -5413,7 +5413,7 @@ STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
 STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
 STAT_ATTR(CPU_PARTIAL_DRAIN, cpu_partial_drain);
-#endif
+#endif	/* CONFIG_SLUB_STATS */
 
 static struct attribute *slab_attrs[] = {
 	&slab_size_attr.attr,
@@ -5614,7 +5614,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 
 	if (buffer)
 		free_page((unsigned long)buffer);
-#endif
+#endif	/* CONFIG_MEMCG */
 }
 
 static void kmem_cache_release(struct kobject *k)
-- 
2.21.0

