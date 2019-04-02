Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A9D8C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19EAD2084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="71NZ5cRe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19EAD2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B53386B0275; Tue,  2 Apr 2019 19:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05226B0276; Tue,  2 Apr 2019 19:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CC9D6B0277; Tue,  2 Apr 2019 19:06:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 797806B0275
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x12so15087014qtk.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aP7x6ocNpn524UbFJtnYWiwqT9lY5T2tQUUdBKmIxoY=;
        b=sxOCA9rPxMp/p3TINGGVAT2TVYNqzfOUVgLaCTfwZ4HpSiHn+0mHWHhwZ3I1wVdnB8
         AOr5ZfKKOt4ngVDn8kySKSn4/gijEMnOqLgnr67P31vvRRW+bcQsbz3VqtdMQr+8RIe0
         kLdawBYXqVld61ffjK45k59K+IVVztJR2DBu9UFUBMbvsdAFzsh7DhAHsI6jVRaYLduC
         urvVOumIl+5HunRGutR2aMUW+o5F8XBd5K4LZ5s6JtlDSArxL6im1/iQfFsN7qn82A2a
         foFv0/hbDJ0ZozcaPjq1CDOHSTiGkXR659yd65wZ9W+8r5UI9+4bXH5wFhsbCDgt09fQ
         gutg==
X-Gm-Message-State: APjAAAWDiAKyyblHI000g7yw/M4mhmQ0NujWFubgZoiqesND902zp2c6
	TO3Rxj0tC875Bj3vhGlUbUQ+xbnZz3FLyaK9skh/whhViuwQ30+aw25XbYCZEOrOAWeAiBZyqid
	+EdqhOWmCgetKFDuilEMqdr5p0hJ23ugmp81E48t/3rhcYWe5HD1uqCrMbLeaIr8=
X-Received: by 2002:a0c:f989:: with SMTP id t9mr4975658qvn.74.1554246403252;
        Tue, 02 Apr 2019 16:06:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyzJgwEtYEhtAtpw/8ti2vl5Pzw8Dgkj+tU29VTY2qP1rmvQx3ibkvARzxaXIeLrxnfkkh
X-Received: by 2002:a0c:f989:: with SMTP id t9mr4975600qvn.74.1554246402215;
        Tue, 02 Apr 2019 16:06:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246402; cv=none;
        d=google.com; s=arc-20160816;
        b=e3RRFIJidPOoabAZFjk0eLtR5UudEzXSx6m5MShleZ/LwVvPJS4wjxESRchsMBx5aV
         tmje55gsBKIjd34QOeKcb0gEs1FhTfWl7TH3c5k/VgtPcIbhpu3DqVBdjjloPOn5IIHe
         rWv0JhBCP5FYOadlpzIHvKrNbJPALFz7j3/PFvMxWTHKMHEXT4oFDe9Sl5lfojQ1hnnY
         0WHjvVkw52lbpHDt9ZOHoFSnalO7y9xhSCVqiz9kJpaxPgJV9nZI48SDLWLBLWzjDLSS
         ZkxBkvitLfscIyvevtJlsYoQ1BMzMgBq0xLkPveA2EqtjaVg1wNOb++5CSKoPi4w9Zjz
         Gwiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aP7x6ocNpn524UbFJtnYWiwqT9lY5T2tQUUdBKmIxoY=;
        b=boxSwX619gMfi+FIv9L9L7hsUCwK32SWDfL/0B+5q7udIRC93tOyIQQ0vvsQmVQqOO
         EFbEfoycEgC8Oppr3NbCHVF6FKEa12BU4BqlBh3EhkxUb5Sh7UsaEs0hEGa8WRwE0buu
         4POoH/UtRHbzR7A6SxUW6AEpOn94Dx32HVeY8aZyqiFONTo60Dt1T/Cq1sbyobi+VTvy
         XUPACeDIihtc05XmSZh3Yi/rv+e9TV2iO/45B3s1EOGSa3SU89cum/RePcFReG7VbRUF
         BP+Ort7K54V/c4XzsJOOQKpRQv3b9E5S3oU0Hl3ZmuvFPALoMtcCpm6sB1kYWHR37Yc4
         gPWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=71NZ5cRe;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id y14si891269qvc.45.2019.04.02.16.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=71NZ5cRe;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id EA72921EF6;
	Tue,  2 Apr 2019 19:06:41 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aP7x6ocNpn524UbFJtnYWiwqT9lY5T2tQUUdBKmIxoY=; b=71NZ5cRe
	Vb88xdu4aAjbR8bx2wu26shp1R2vRoM4i8wn+wPH20gLrjy7KshCT6ZPLixtNDE7
	yVF43B9/0IbyoKtRKEgOOFboAhAWWqBKbNRn5rVvXgOJAKWgQ5hJDVsRQ8H7Sy2Q
	tMu4GH/iXlDLr0kEdQZOtHcC+a4fe78PO4K3sMCil2TSiQpt1bqGQxjy3te6RdcJ
	20AJ+oTGJ4ytiSxCMKKXQD2BhKA7W5JtkA8mzakt7f3AQKnF3BUqIlNjgP1tS0lQ
	m3sCkcxyEh6W0Kx1n2p0d2Gtg6sZ5wurgp2i3xsDSkUC5JWey739YqIasW2xGPEm
	wpQX8IZ+EwSqtg==
X-ME-Sender: <xms:AeujXOoYp2i9Y3gcTfR8YMt_Mvrao_4NQ1IW_RPsE6EAr8XEAJypVg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeef
X-ME-Proxy: <xmx:AeujXNamtfmVZiGB2pSIPcsMHGb_GkP_vomkyf0stuGxSZ1-5yT_yQ>
    <xmx:AeujXPVrtHbrzKhXSiWqwYpOKoeGF_mRaWfysqkPFeUpwufqa8pvKA>
    <xmx:AeujXO-LtK3gcyaiec1BbA-d-9qYEKNW57GVFBLYa4SnwbflqAmGHQ>
    <xmx:AeujXPrHbp5QaAG9_9M3t4taoI8iN5nCPplYSrSoXivBDeSY8IkTtw>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 67C081031A;
	Tue,  2 Apr 2019 19:06:38 -0400 (EDT)
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
Subject: [PATCH v5 4/7] slub: Add comments to endif pre-processor macros
Date: Wed,  3 Apr 2019 10:05:42 +1100
Message-Id: <20190402230545.2929-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
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

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..8fbba4ff6c67 100644
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
@@ -3848,7 +3848,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
-#endif
+#endif	/* CONFIG_NUMA */
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
@@ -4066,7 +4066,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
-#endif
+#endif	/* CONFIG_MEMCG */
 
 static int slab_mem_going_offline_callback(void *arg)
 {
@@ -4699,7 +4699,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 		len += sprintf(buf, "No data\n");
 	return len;
 }
-#endif
+#endif	/* CONFIG_SLUB_DEBUG */
 
 #ifdef SLUB_RESILIENCY_TEST
 static void __init resiliency_test(void)
@@ -4759,7 +4759,7 @@ static void __init resiliency_test(void)
 #ifdef CONFIG_SYSFS
 static void resiliency_test(void) {};
 #endif
-#endif
+#endif	/* SLUB_RESILIENCY_TEST */
 
 #ifdef CONFIG_SYSFS
 enum slab_stat_type {
@@ -5416,7 +5416,7 @@ STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
 STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
 STAT_ATTR(CPU_PARTIAL_DRAIN, cpu_partial_drain);
-#endif
+#endif	/* CONFIG_SLUB_STATS */
 
 static struct attribute *slab_attrs[] = {
 	&slab_size_attr.attr,
@@ -5617,7 +5617,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 
 	if (buffer)
 		free_page((unsigned long)buffer);
-#endif
+#endif	/* CONFIG_MEMCG */
 }
 
 static void kmem_cache_release(struct kobject *k)
-- 
2.21.0

