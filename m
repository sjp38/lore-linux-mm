Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCCBBC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75B8D27225
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="W7fL1H8A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75B8D27225
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234F66B0270; Mon,  3 Jun 2019 00:28:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E50D6B0271; Mon,  3 Jun 2019 00:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D40C6B0272; Mon,  3 Jun 2019 00:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E04676B0270
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:28:11 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so13725594qkj.10
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:28:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=A2xUm/c1QMOPSqZ7s8invRNgw1dO9YvZCU++wFciDxknLwnnri447S0fAgd0UN/XzL
         iho+84Qerf3EebB5h6vumKF+jQ3ZQsaXrWXPigXrAP6pERpkzmaYpfyObl03ugehq2OY
         aD/A565xaRL2X5/pAn7OeNRQU0oPkeTTGVFJ1sxVjqGl6xlKTpIdH/DtO91AZ7kzWG9X
         bv6V0qUPTX3gikWHk2bIkrVqSPBeT5jlFY9sJ1d1qZjJ8My5tz4UUODtP7YehMqkpKn8
         mN2ItEJWsO6MbEw2z4BzV+9blpAiXmJXdUapWuCTApWzJCHvg0uWoqo9vJuKUHN1UdAW
         UtDQ==
X-Gm-Message-State: APjAAAVb+BEGFPD5eWJv6hzbaFcdBnLvezWYJQGZ2tsw8aqXeZRnD8sC
	IgTIupbmtoxFyCD5oZlzaq73l1hjDz4Suv4ZgMuONcx+F2xtfgD3ieG+yJmECz8KLkjbtHhXc5H
	ioQ3gTDqOgKYt3Ird/m+ZesrKjV1cJ4jzEYqmIEteBXo/cBHDo0GkYn1sp6mgOLc=
X-Received: by 2002:ae9:f10b:: with SMTP id k11mr19526113qkg.238.1559536091694;
        Sun, 02 Jun 2019 21:28:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxroNCz1irGJpVmNwQfeuFXRY8pDddV5tDDi8e/g9CQX9ldLC3uGyPtGV0Dl39DtrRCA5fm
X-Received: by 2002:ae9:f10b:: with SMTP id k11mr19526092qkg.238.1559536090899;
        Sun, 02 Jun 2019 21:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536090; cv=none;
        d=google.com; s=arc-20160816;
        b=zeClZUGEjTaogN2xhDLkJpDTPJePmJ42jIreIYbjwyyfQhBxTEQ0NVnjVZPEZc/PUd
         ghcxh0iS3+fTO5iNzHFl5hMgnRhZndSZdnnq4VlkXGe6h60xlrF1WI464x/QgnTyoauY
         fUkQ+8dYooyXCgXg5KpOFKSHWzWGVIRSyR8uQpiIPxDM5yObf9T1VWys16eFZVFNt6Nk
         4YsXdMDiJeP1lPxUEJtk61L2EZCSp1km81yYJbGoEQVAMQlxICmtEfbzXI1+YgydKA0F
         oIgNzif7Gt3wBiZJCEhne517MK7ZGepANzglqBgFYIuLdSJ0kVPVdSeAXjY9PodbV0CK
         a3+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=W45ND3tRsH08+gQGzuJ0QbV997yAX+G1KX5gmjYCxhuOAHrF0/YCjBjm9qdHgEtEc5
         nb3FzlsnNAn9+uJ8owqXlcPoEPaF12lw0islfBQ7DYlXAeL1thrjmrFkyBA4tyZatnic
         aEroIZUiIWN63K/n4r5cpSvDANooF/yjaspPlsrML0DnR27q1oS1QqmttrYX0ncZKnIB
         MGttdLMRUVjjWHz/dE+7c+ZicT30BDvO0VnD6xb5oSLgp6ArI2y9tIUa3VXE2GduK2tw
         n+m7R/LgLRG0H3haWD3TjcYhSIB/xT8XI8i+hyFekcdI36/G87cXBZ6ZLBiVt0Cy68ky
         KV5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=W7fL1H8A;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id l13si4550405qtj.64.2019.06.02.21.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:28:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=W7fL1H8A;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id A5FB8199B;
	Mon,  3 Jun 2019 00:28:10 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:28:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=; b=W7fL1H8A
	LfNFoRx+lIXkmmLAS7NFbIPAVxMml8jtELjMnYRAAQTRWlvVo6/ARYkxSziQ9YCC
	tulqD83nAZAExVG6cANgAuO4b5lFNSApeMfzM+5S4VJfghlVByJlKWLaI94eimpI
	LH19vEgir+ydq3UJ7NiGyeP2GErX9mh1pfFJ8psisUrzv0z0XiBW8my7Ys3PkcX4
	rBt4QlzOZ6UPWo2JaCaYN8CIfADTxgTeJbE7LODwiRVF2U+PHCrFVWVvSKKYG2e3
	3dPkek2wOblmPrRvAaTZvPHngGxyZhcT055s68QKl/s86utRsUbNt/GrJ2NRLEMq
	9RJ1gH49Cy+RlQ==
X-ME-Sender: <xms:2qH0XCnDo0EduU6vkUlbdCrHmMFiCvamKp6s5c3Iaj8Fvt_nahXLTg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:2qH0XOHjAS07r-CrgD-xg7gjtwN0-vgVPs_eJyLuKdsjnpX6k2v0ig>
    <xmx:2qH0XLoZoc_JAN6AWpttHiNgo0Qv0tuuKLMMjWIbS9_7Xr01JIWvsg>
    <xmx:2qH0XK4ZLDc3MFubqamy4K36NyMjMYvyFqGQDfKYGBNSIM5-gjUOSw>
    <xmx:2qH0XG_jLiOJemCCmetEnScfvTsFZdTIbcs27suh1wZ4CX99n47pjw>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id 70EDD80059;
	Mon,  3 Jun 2019 00:28:03 -0400 (EDT)
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
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/15] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Mon,  3 Jun 2019 14:26:27 +1000
Message-Id: <20190603042637.2018-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603042637.2018-1-tobin@kernel.org>
References: <20190603042637.2018-1-tobin@kernel.org>
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

