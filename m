Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4153EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD7D52084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mTY6Adzl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD7D52084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92B996B0276; Wed,  3 Apr 2019 00:23:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DC186B0277; Wed,  3 Apr 2019 00:23:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5DF6B0278; Wed,  3 Apr 2019 00:23:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE3D6B0276
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:23:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g7so13544181qkb.7
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:23:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=B8+D4dqa1BX+6QU8onGZrdHDeV/bBw1xA9Qf7WlA766fW2OULQXpl+p/EEfMDGE1QX
         Pqua13g2MiJQ6j8JI5+W/H4KKqRAi1fGjp8o1uThw1Hk98BvMBAjk1tY7+K4Nb2ONpo/
         583iGCBGhBAD/FrCupuWg23xf7qMljgOEoLWBrhsycypZsGZxdiMDNh/6YyxWwMYORPS
         XdA8nwqgWcBcTs0vHnNKNCl26jFbMYI228zK7yl854fNwn+dUOhp4LltjfPVaJg1pcZz
         jZIsO4ky7is82GpFHjotqdOlCvRDgjEGhZUmOee0qJLKidm0My8AGr5pybatH4/Stpat
         4H/A==
X-Gm-Message-State: APjAAAXB1Fqu6OjUMH/WbyJ8G3X6oIvaGsHDHLzK2pZ/rer1Gi8Prqsh
	L/PmfBnjSM2OvusjbfES5eNQyf7+Ucm1s+dhUDL2c5eUMIHkW0DgQiShSYxtEROC054uEQ1250V
	Iz02op2vZ8vHnyMWMvbE50IZgeDZNDotdj8twW9SjhjcwvdWqY00inhiL7jVNAZg=
X-Received: by 2002:a05:620a:14b4:: with SMTP id x20mr45357811qkj.202.1554265403115;
        Tue, 02 Apr 2019 21:23:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPQCjT2t3f2KMGBVFNCCOuZeKsMx1u4QWopDE5p4OLLryPyjiTQyOpslIjBQRU+Zt+h+c0
X-Received: by 2002:a05:620a:14b4:: with SMTP id x20mr45357772qkj.202.1554265402186;
        Tue, 02 Apr 2019 21:23:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265402; cv=none;
        d=google.com; s=arc-20160816;
        b=fn0cWP7/tqUG0Me6McaeUbrFswssJwTclcAxUDd5hmkF2HiEwVRa+r3H6Gg9jU3gkE
         n7CcEYGBkyhDsMeaeWRKlEC3tdzUmXOq/u7mGp1VKPE3g/V3vXAU1mFShc6XgXflHJEL
         KVWUzKTR81bPCCnBGWSI90J63ufaxE8az1HkwjMtadov2suAX+H5vqqY0URmIH5+ud1e
         Qz6ItP79Y9CKeGIwc1MVJ9Apkn24DVpjvSFPWUFKSipV8LUb5VvRndjDbIPc3koNiomx
         jM16GyuwCyPEAa0r0ypiwHIxwPKSjHQc50Ds/blry7O8UMB2ZANizOWw7wEcYYDUPN3q
         eY0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=xkZj7+Zc12qTR1LxmT2emSgfOBEoKNwnGy1x8etDYX5O8GE3NLqRCKvBgMeJ21Mm+2
         6vM4Vu3/5DIUNf5GeYM1hHRDPjhftvCktfWnKrzEF+8maq8JQfxEvIn/89hGQMWyabyf
         9L077AyEs/9mqZAInXYLa1B/oqeaG1fVfxttOyJFfBrFaymP9bl7GR1G3HKaQFFu6k9n
         owvBtbNP6aX9zLzvVHfvoSwiWsELjt1w12ssD9B/RDgXuM6Xy7VEAIj0wLqPzwS46A63
         2cbBckvodOF1AIvEampORKW81ZqltcHTTFC/YicEOqEf/Eqjh1CupeYz0hky4f5jfJyD
         uXjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mTY6Adzl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id k12si8807886qth.145.2019.04.02.21.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:23:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mTY6Adzl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D808121F01;
	Wed,  3 Apr 2019 00:23:21 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:23:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=; b=mTY6Adzl
	61j/HX4/u8pVRmeDhbPrC5pgYVGektr0Ftsd0SvT2OiwWBG1APy9EJGh9fp48NnB
	EkghxIwUbm2vc5eGdfY6Ri7B1WZ7dFE83Q8KjoMLauPYrqMiBsUm7PfnTkFi1GJ7
	AMMY5EutgtgXsI8Nvo/RteIagRpivu78gCb49FFY6+o+kHO1NKoRklIllmfpv7kv
	SmuTEtJ/ShiCV989LSfZZTOhLMZ4ZXsflOqw1ZbkGS2U53evb8jOl/5M8KsC23VZ
	L9h53+Lc1hmENNQehrHIUgnv+MsJH0r7Z+r+aKzB9oSnGpEq2VNsYTck9ArRnnLM
	jI2WmSnybJjAnw==
X-ME-Sender: <xms:OTWkXHGylsvalQWAMl5izWKjp4SQsxX7i8zbv0Gt1Pi54edrArVyDA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeeg
X-ME-Proxy: <xmx:OTWkXAptUlOecLp18o9rOj3H6Qc0RMCCM_Vc8n-CxnNusPQhx7hVAw>
    <xmx:OTWkXL5yRsgWF8ZOUGBuBDSEmatk0_8KTrJBx0tyMb9XR1oLjdY58Q>
    <xmx:OTWkXG4u0fTnZFapaXlc1smb9_kzGNJGS_gGQGox0sYu1dr21mdkhQ>
    <xmx:OTWkXP85nocoI_hqxskrB9-fo-G2-eq8L-wtCB-AM1GemyZa1r1eQg>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5D044100E5;
	Wed,  3 Apr 2019 00:23:14 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 05/14] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Wed,  3 Apr 2019 15:21:18 +1100
Message-Id: <20190403042127.18755-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190403042127.18755-1-tobin@kernel.org>
References: <20190403042127.18755-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add output line for NUMA remote node defrag ratio.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index cbfc56c44c2f..d2c22f9ee2d8 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -377,6 +378,10 @@ static void slab_numa(struct slabinfo *s, int mode)
 	if (skip_zero && !s->slabs)
 		return;
 
+	if (mode) {
+		printf("\nNUMA remote node defrag ratio: %3d\n",
+		       s->remote_node_defrag_ratio);
+	}
 	if (!line) {
 		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
@@ -1272,6 +1277,8 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

