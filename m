Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F3AEC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0582A206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Ta6tCXtz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0582A206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ACED8E0004; Sun, 10 Mar 2019 21:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85C008E0002; Sun, 10 Mar 2019 21:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723E68E0004; Sun, 10 Mar 2019 21:08:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 436F08E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:08:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k5so3915707qte.0
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:08:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QUZeS3AdF7WqBwpmb1Jq8fZixl26ADp8ngeUBW86i+4=;
        b=DeyDa783I+g9MvTEHB7qB4joQ+E9K2t8G6mic6WDk4ILxbgIt6X5iAD+B7/vmPL+DL
         vvyBwHtB5wJCcv7Yi9/WVBJ0nx/lDlep7798zGFPdqOeO/kaAI5ElKd1g9QHGeoDzWeb
         cPlBVIY9bQ5ymka9mQgkSzG3dOMN1zU++AirrlF4n2ST+q8MWZJExUhyqdhLC3eXrdlu
         IG+PUwjAZUpHxmPc5rVjanFmN7NajBoFF+othsFuHZk0zvJozE40B+1+hJ0yIPlkwVlL
         ZIzr1FwbkY0irbdY4yBRYyknfNp1hEzZbsTycLXoj7OU0bOu7AqlVvhhQztgbZLEGgff
         bv0g==
X-Gm-Message-State: APjAAAXLvWe+8Y2+jQ5htS5bYZDN5v6Qr7o4FIfcp3nz4VLsxRG9bYU+
	A8rMNlDqOxinSPQUmbm9e3TS2mM/m5TpopPhx20dYCZmJMMAzNloggSJhfMzZg3X/iIGEggaFoG
	bdqqZwoSGjgDiexTtiee5l7DnstfBJWVtB/i3rSLAI7ErT4zqu13qHjW9XwyzR9o=
X-Received: by 2002:a37:f50e:: with SMTP id l14mr9945040qkk.332.1552266503053;
        Sun, 10 Mar 2019 18:08:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7MJalp0HVE/b93k9Zr+7WNNwqiXDIhllOXOI49HR2ZFuMk+yinlCnJOWOAtLoHF2fMVT9
X-Received: by 2002:a37:f50e:: with SMTP id l14mr9944982qkk.332.1552266501495;
        Sun, 10 Mar 2019 18:08:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552266501; cv=none;
        d=google.com; s=arc-20160816;
        b=n2wMpJ8yn/K1DapATnpTJLugQAMg/Bg9Ifqpyu8AGMgeHd2oiXcaarHTeq3sjnhFA9
         JN1yGsKSbwIbC5JUSiYtfNwyEdGyZqiStdaNDIvxkJHr7zKdgXqYE6ROsCEaN8apgTSJ
         IQ4aqjntjDfcDI/2CeLA3aJ06QZvd7PBsnw5MLDSvpn71pHFtRTzE2lf0dNiikM5SnhK
         k0rolabwGjf1ysrlOF/7q9r+Fs572R89rAo4aJ1P8OGYX6KB15k/7+gq1tKorWYWT78K
         K+M4lP+n/QU4/te0Ecq68PTl0Fp8FWWju1wfRMSoEXgOoM63/IB2JEk1unamzHEKbo38
         5tog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QUZeS3AdF7WqBwpmb1Jq8fZixl26ADp8ngeUBW86i+4=;
        b=j7m/+lGZhTSGM2oDWDF08ChsnQZrIe8r/sYO9jpZcJvz8kQbiPBwAu6zy14R1VPV0p
         IV2FUxm8YqMTf2IE13ZKMPpnq1qn0R1+ytOOxwdCbCvwWUOUdnBAddnHie7LVnPnRGTM
         cUTePivkmbwCDOx7DMqu1m+YyZqc7/2SX8oyu5cdl2LPqmcHU8I/tHQBXLUpEdyETIpa
         k8wRQI6PR91nZJS/uuWODAlCQQLs4YQ0uvlQ4x+zJGxLs5ko711TEF1RRROMU5vDreRg
         IHVrwmWPdjascw6481MElATqEFiqnYGCk/22GKJVhvPMjm0moGvcX8NdrCugEg3aBZb3
         rnTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Ta6tCXtz;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id y1si2456307qvf.173.2019.03.10.18.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:08:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Ta6tCXtz;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2C15321FF6;
	Sun, 10 Mar 2019 21:08:21 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 10 Mar 2019 21:08:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=QUZeS3AdF7WqBwpmb1Jq8fZixl26ADp8ngeUBW86i+4=; b=Ta6tCXtz
	r3RhP4SFqbhg4a3c+OS689bI80hIKiLYJwaoiAjsSQIXm9naHzcOx3B7Impypx8Y
	JiKu/At6rhrB1zQj7Ru5moy/mE661MJWeuwdn+tP7ypQ5/VuFwvkRdiO0ol0ugB0
	K851BEjTSRYA2zeezA8lJ/dSE4dK1Elct7HCPHYFjfMjGP81j33UmcUYDuGuO/UI
	wW4TrLfENTDEqvAvUUVc2PdgM7J1Gw1MKVkN/ZGXmrr9f+3tyUrhzGKZoZhp1FL3
	3Pq0cMWoCcsvir6V2mm0pS54Osd1SPWm2axS51y0iTNQsCaFQPA+XOK77nrJQH5u
	gY4xIZjbNpA7AQ==
X-ME-Sender: <xms:BLWFXGKpS6HSH-A9W0pPtNyx7rOiyE6GIn4nNYwmTyyNqM6-D3TiSg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeftdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:BLWFXCYg4mouj7_0rjZWUi4D32v-syv7HLEdTSzL8LgKkz7NI30JpQ>
    <xmx:BLWFXBvB3ANCE1ltaoLLVdFkhpeJb3dGqc8h8KXwSkoFFQCbVJbVZQ>
    <xmx:BLWFXPuDX3ja6Ofel46eAVDV9lIDd7sNw9A347kNpo_3ZdKaxWR6FQ>
    <xmx:BbWFXHa9KP6K6YCFhiwzDknu5aBqChJZHjb0plD7b6wSzVjgAoDlqQ>
Received: from eros.localdomain (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id D00F010335;
	Sun, 10 Mar 2019 21:08:17 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/4] slub: Add comments to endif pre-processor macros
Date: Mon, 11 Mar 2019 12:07:41 +1100
Message-Id: <20190311010744.5862-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190311010744.5862-1-tobin@kernel.org>
References: <20190311010744.5862-1-tobin@kernel.org>
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

