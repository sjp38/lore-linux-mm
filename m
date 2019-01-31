Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4BA3C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2E5E218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="aBL9xFVh";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="l6jiDaD0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2E5E218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EA6A8E0004; Wed, 30 Jan 2019 23:11:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3473F8E0001; Wed, 30 Jan 2019 23:11:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262CC8E0004; Wed, 30 Jan 2019 23:11:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0FD8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:11:06 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so2195934qtk.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:11:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aC7B1MclzAxY5cAw7rCoiRc+tqKP2Rf1XdmtonaI+7U=;
        b=fk+Ouh5KaBjOTXQbiG/v7rcMw4FOuZmwo52MvdtfcgBzfw1WBzq6bR7iiiRt22mN8g
         PoxYG6nPkY6mV0Qa2ynT0YcYhLFt9CtEdBYEtckagBiHby0yfktC1N4RiF9b8tHZ5Hfy
         F5hV7kEEEYPgOjfUsZ0OEZ8+aCchnB57T2vQC5H1evg8mT9UgvJUEEl7rGQROA2N4uSR
         U0QO1+DgWhO9JBbSKNzQDdy/G7VTKysdho7TAbhz5+PkAM3+CTERlEWQ0V7qZ1aV76B7
         0jejiozAspZzNCnV2qbZDE7AJ9zuYZzfyisgdRnu5P8ypSlY6PbdiMBpTOFIwzM/DuZ7
         kgCQ==
X-Gm-Message-State: AJcUuke3wdOgUYYHsB2xjEVnETEIxAGzkZXEM+P9LJGkqeNRcj6IZ0pP
	Ittp10YwpDP68n344GIPZv4TOrss205kaZRkjwfVeBZUnaNxrp7b2/a6ethqt0miF+Ul2gW+56V
	1skn9PmGTGrC9ihqq/9DklPLR8pwyTRJsP8Zos889KfGjJbFhlgyP+2nrtXeJ4QL6pg==
X-Received: by 2002:ac8:7416:: with SMTP id p22mr32214376qtq.318.1548907866726;
        Wed, 30 Jan 2019 20:11:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6H99CzVwOSNiDBr2tOkDAdZWzVQIDCgYX5Z8oPyssaSRFsmpCRuL3VKCteIU3rI2doaJWy
X-Received: by 2002:ac8:7416:: with SMTP id p22mr32214359qtq.318.1548907866245;
        Wed, 30 Jan 2019 20:11:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548907866; cv=none;
        d=google.com; s=arc-20160816;
        b=UK5m42AbjxJ9UsZQO8tQ+Ggzmx3LaLfLTl/n5Ug23EOEicfJCwl8b67SvUPFDl0edQ
         XVPxYM9QQDlWoYVL6PXOkirrKydrJrcx8kY4yY1iyTtVvDTtjCyH1fg+Qt/7i/5oB7y2
         jyb4HNZuczWgSnZ7VkoaoTEoLNi7fMTtbyF9DvoeneyLboqNg0IxMfaVImscaSuA1L06
         3IspvsAMiAW8yJN559ZUXPqzUBFXGup2zAg5nnrnbDwkRIUwObOQtmc8EgZDLNt9TQaP
         o9zpA+wbwtlr6y2c9uebd1SuoN00NLmQgI8h1w4za87Vr3uh/k3wMYKvkEWe6fU7dJAC
         PYuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=aC7B1MclzAxY5cAw7rCoiRc+tqKP2Rf1XdmtonaI+7U=;
        b=GpzpesdEcDwN7znDCLyUqeRTYVssAoFoTKLH25ehAE+6r7T7HqztHjBbKiaLp3fGAY
         oZ8VT5b9hvFfk1vkxQB2F41uYuVxXVn/qYhcH4ZOnu96gAD/sq/LYG5vwZrtGH5u/buP
         JHXs3Q9Nch/MUs1ZwV8LNCP7reoD5hpB0lfcji325wB9JeHIdIAjEBHMFF3a9wMIsSR/
         Rk8nVuc/fhIM8fsbCYa6Hnaqm9ZivkNWTpF+tElcGFqJTzQfupz6cguk4cnpU1QNaDey
         aNEaBQWMjkkrsgGpyllOIr+PY7NLQmfskipWV96IshGhL0G52KnWkt5NxBztLV5R3/S6
         6krQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=aBL9xFVh;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=l6jiDaD0;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 38si1262006qvi.108.2019.01.30.20.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:11:06 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=aBL9xFVh;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=l6jiDaD0;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id EC38C21E8C;
	Wed, 30 Jan 2019 23:11:05 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 30 Jan 2019 23:11:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=from
	:to:cc:subject:date:message-id:in-reply-to:references
	:mime-version:content-transfer-encoding; s=fm2; bh=aC7B1MclzAxY5
	cAw7rCoiRc+tqKP2Rf1XdmtonaI+7U=; b=aBL9xFVheOpszgdbPF39BdpiKaT/r
	RQKUB3uQG12e5tDoH0yUAbt+0WN1wS8SqcQLnyiDZFqXkWQqya/nVLoG/wj0M9+q
	O3KjGlbDeq2hw0Dg7eN2wrHYgspIzw0P62BcK68aWVqozbFwBbPpbPKjwHzAVa7Q
	W7oL/Muc/Pl7An05zo8YWEWAWimb1wpgzQIVy+dRkBVPRSb8VHC7bnfB7PHKeiD+
	6jZMNzwbpCVRwp/O2ZDTUF23fYuU7GaV6r8URUtUJJRRaoAnAIgBKY5nGc0TlMD2
	p7CWEiu8vu0+3cf1/L0nXPxpyRjYIxijVb8YEDXq8UAwAvgK2us07tFxg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=aC7B1MclzAxY5cAw7rCoiRc+tqKP2Rf1XdmtonaI+7U=; b=l6jiDaD0
	F7Y9RiiCtMZqEGMNxrKY5v0tuw9uuh+Onj7mqJPo56BLO/btAu6VHJtVVFDLyPDK
	fMf6cJYyjwBkAWohm1tweSyc/oGmU1Tup6guD6IUTmQMCFrbNrppM3S7jy8ClIlG
	NqIrNpWsOXh+G4W74xnp+60x4PDHT1RyBMIMoGzsdhbu+WNBBQLOVfSrhA9nLmat
	zS9HN/pzB4VZkXB5vGVzkzdgZoymtznulSj0EEUu04srWsCwJWGcqwkfwoijYR91
	6i0NvrWlKAfkH2I/5BnYZzB7CoaAakblXh1lggJMLQ0eNrWIFSBNeuCaNkcEQfPt
	SnCvo2mQQVO99Q==
X-ME-Sender: <xms:WXVSXHO-aigguOVq1LAuoWe72ShGuBDzk6S2-sOI0Hb6hurZ2UDu9Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeijecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduud
    ekrddvuddurddvudefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthho
    sghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:WXVSXCnZdcnMomshsaQT1fJ8s7qoUwWnbdFDxH2hqoCLyk4YF9afag>
    <xmx:WXVSXBYcpr79GTs9V44RGHdaK8xfIxLsZltRnG1Oo3QxGrkRgBoJcQ>
    <xmx:WXVSXATE6Hyhg-Yu_4HB52C245qZEXvbBoi3YQ_gbfLlwyM9wJVxHw>
    <xmx:WXVSXD6jd8LqDrs1Mth-JwwhYptl3gNhtdMfWW-Ubf7bP7nrFtPmuw>
Received: from eros.localdomain (ppp118-211-213-122.bras1.syd2.internode.on.net [118.211.213.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id E89C410310;
	Wed, 30 Jan 2019 23:11:02 -0500 (EST)
From: "Tobin C. Harding" <me@tobin.cc>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] slub: Capitialize comment string
Date: Thu, 31 Jan 2019 15:10:02 +1100
Message-Id: <20190131041003.15772-3-me@tobin.cc>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190131041003.15772-1-me@tobin.cc>
References: <20190131041003.15772-1-me@tobin.cc>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Tobin C. Harding" <tobin@kernel.org>

SLUB include file has particularly clean comments, one comment string is
holding us back.

Capitialize comment string.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 201a635be846..d12d0e9300f5 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -110,7 +110,7 @@ struct kmem_cache {
 #endif
 #ifdef CONFIG_MEMCG
 	struct memcg_cache_params memcg_params;
-	/* for propagation, maximum size of a stored attr */
+	/* For propagation, maximum size of a stored attr */
 	unsigned int max_attr_size;
 #ifdef CONFIG_SYSFS
 	struct kset *memcg_kset;
-- 
2.20.1

