Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEF50C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9908D21734
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9908D21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44CF6B0007; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA7F96B000A; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 920336B0008; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3643F6B000A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so1057323edd.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:15:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XKweMPqkN+ZOr5KVD4JMmVpTifSSsIXkDsQZVM5g5zY=;
        b=X4XDhRJGoGepd1uC/vZ2+J7yp1s5ncFX+w8jB+HVAM4IRRFThqwaeb22qrY5YoWD5I
         jaEkH7gCOZJorc8H8RjMBhdmp/7GgJ4/vX+szLKOpQyci4bKKkMcCfqZSEdFce8IUiY9
         bfJ4FbsGLeP5fz9PDegr7lnMG1/Qftc2ywAgMLCEhh3/McpwgBLMTwyuWHxgnY2nWUVI
         GsApGhKKQVLby7XdAyloQr/p1aJEGbmV+/8k5PMTsy3YRpbz6R8KpBVBBcQlcHaodCQp
         Xm1jRGTkIZcTysCPDJmzkqdebtZiRgHzfF0wlvexJrIx88t5yrlEs0IciresHsLO7rDi
         y/yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV3RK5yDrdhRFW2Fux/Za64Hm20Tq3h3/9zsoQ7O2AbFBSr/H36
	sQwP7YqnUB8aq0OliY7HLQl+x33RJIsmMeikcMYYlLLBF0TjftezCv2cZTMtG7Uiuxzftc1CwSq
	1fqb7dDb4PV4lTGb6Xl1JlCfCFAGIAF4uD4zsJ7mKvfAGqe+29QThMTQNT4C7OSKWoQ==
X-Received: by 2002:a50:9485:: with SMTP id s5mr3022297eda.223.1554369345740;
        Thu, 04 Apr 2019 02:15:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLRZ6Tuu24+5Lddvlm+FU5t3H5Oie5QgM2fe+TGUf55jF0HaBPEIU6lo5anaBxUQIpxjiQ
X-Received: by 2002:a50:9485:: with SMTP id s5mr3022210eda.223.1554369344123;
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554369344; cv=none;
        d=google.com; s=arc-20160816;
        b=F8PLAGcw7WLkQQMiAqvIZhACswCqrDmWtnDHgi1J84D+tRluWxb0mneNseokSX7W3P
         MPhubY3BTcep5kjxMs0pLclNe+g9OjSmuZ8doiX+HrGf+vhYsFdy/LY1xYGKuBvwv/OS
         P657VFGYyIpOAAjQSm4Um95tJxF4Ike+AC8AE80OJ8Ybym/ovFicECLHFcGotP0Pl98p
         ZCaQ+4tY9nxPa9HXOYdY3ScTePyzexoZbmQm07JbiQzl5QS5GzaqSCzv6apporMQO8Gs
         UbmwWgR8DaG3wtTATV0yx5P1S4sCHxhT9yTRL73UGvGeNElGmvGoDwH1Alcd6Tb2KiOX
         G6lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XKweMPqkN+ZOr5KVD4JMmVpTifSSsIXkDsQZVM5g5zY=;
        b=hL01gxNxANj0NOrCzGRfE7KyO6pJmN7arQ0holV+icM9ee809YbC+4VWAl+PhoRnp8
         yKNsj0PoOgVCp9205hEXk8XikqAtRyBwWmw+1piLgaMJeZRctUZ1nSwLtwWG5Ho2dvFY
         PPXBQjVJZKpV+DIgon6DK4nj1dhTUoBiRO8Tn1lf9uRvEoCzwp1UNGXiM49n5HZDqcsS
         Ykd0/NdmhXtO90AgfX9OTkQr8hYYjRcwZjw2GhGDPS8Whl5IR2VmL5XQyr+wU9I9cSvJ
         TpbK5oblOkdK//Pg6Cy4YXDf2TiuVFEsKIxyE1jMoLfg+sibQAdE1wSGMWCfhyOSYj2P
         wZEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d56si1284362eda.12.2019.04.04.02.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4A327AD0A;
	Thu,  4 Apr 2019 09:15:43 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/2] mm, slub: introduce static key for slub_debug
Date: Thu,  4 Apr 2019 11:15:30 +0200
Message-Id: <20190404091531.9815-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190404091531.9815-1-vbabka@suse.cz>
References: <20190404091531.9815-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One advantage of CONFIG_SLUB_DEBUG is that a generic distro kernel can be built
with it, but it's inactive until enabled on boot or at runtime, without
rebuilding the kernel. With a static key, we can minimize the overhead of
checking whether slub_debug is enabled, as we do for e.g. page_owner.

For now and for simplicity, the static key stays enabled for the whole uptime
once activated for any cache, although some per-cache debugging options can be
also disabled at runtime. This can be improved if there's interest.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slub.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..398e53e16e2e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -115,10 +115,21 @@
  * 			the fast path and disables lockless freelists.
  */
 
+#ifdef CONFIG_SLUB_DEBUG
+#ifdef CONFIG_SLUB_DEBUG_ON
+DEFINE_STATIC_KEY_TRUE(slub_debug_enabled);
+#else
+DEFINE_STATIC_KEY_FALSE(slub_debug_enabled);
+#endif
+#endif
+
 static inline int kmem_cache_debug(struct kmem_cache *s)
 {
 #ifdef CONFIG_SLUB_DEBUG
-	return unlikely(s->flags & SLAB_DEBUG_FLAGS);
+	if (static_branch_unlikely(&slub_debug_enabled))
+		return s->flags & SLAB_DEBUG_FLAGS;
+	else
+		return 0;
 #else
 	return 0;
 #endif
@@ -1287,6 +1298,9 @@ static int __init setup_slub_debug(char *str)
 	if (*str == ',')
 		slub_debug_slabs = str + 1;
 out:
+	if (slub_debug)
+		static_branch_enable(&slub_debug_enabled);
+
 	return 1;
 }
 
@@ -5193,6 +5207,7 @@ static ssize_t red_zone_store(struct kmem_cache *s,
 	s->flags &= ~SLAB_RED_ZONE;
 	if (buf[0] == '1') {
 		s->flags |= SLAB_RED_ZONE;
+		static_branch_enable(&slub_debug_enabled);
 	}
 	calculate_sizes(s, -1);
 	return length;
@@ -5213,6 +5228,7 @@ static ssize_t poison_store(struct kmem_cache *s,
 	s->flags &= ~SLAB_POISON;
 	if (buf[0] == '1') {
 		s->flags |= SLAB_POISON;
+		static_branch_enable(&slub_debug_enabled);
 	}
 	calculate_sizes(s, -1);
 	return length;
@@ -5234,6 +5250,7 @@ static ssize_t store_user_store(struct kmem_cache *s,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_STORE_USER;
+		static_branch_enable(&slub_debug_enabled);
 	}
 	calculate_sizes(s, -1);
 	return length;
-- 
2.21.0

