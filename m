Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A72C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D7B52184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="cq6T20jd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D7B52184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EBFD8E000A; Thu, 14 Mar 2019 01:32:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 173D38E0001; Thu, 14 Mar 2019 01:32:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F30078E000A; Thu, 14 Mar 2019 01:32:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C35888E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:35 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h11so3714462qkg.18
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x7XzuZHTX79KOo0NhHz+n2DRp/2Ctmdn2rPrkfVwAcU=;
        b=WogLOVLTR8l2zIOCIA1U0s8ncR+YCDH6yg+uWu8Gw8Z+hWtzmXByf/tNC3KtKLOb0J
         AQ22yyqrsTCwtQs0xAvaU/IpClGwBY60Jppv2kHZLzHstXse/oYpZklPOw3YZufTt+pb
         ZQm2flOo2dXAKu5WwKxOQzLP8+g1Zz7e3tTsH0YCPYsxCLMpTUFDj5kmry8tQ42NKg/L
         sdempLVVbp2Wp1CWnEKIvSe0HNTQTAyWnBearEFp5odn8+4vQgtT7NlmorrdrMNM2Et8
         jN7JYsImXVGQTB34DESvlapro7tNKtbX+zxJPFW1HW1NOh4t3OvA3cWOVZpdvcVy3xiB
         pihg==
X-Gm-Message-State: APjAAAVT8d6JDUKFIbGClGOpgBdCYrZZWUPQRSGC7bE6sfW9LVU+BZ3W
	x7HcTsQy5auYKAeJgy2Rpm7qZ6vKUtRkFEYeN0JSgX5XQm8ANSDtVf0Ey0P1kuFqaRaVJJKy/v7
	M4Col4AoeHlu0izjZQL0xtkaF/F6gpa+U4ked/95WYJkDF4fqyLARJpwt1hdqB+c=
X-Received: by 2002:a0c:ac93:: with SMTP id m19mr37199509qvc.27.1552541555608;
        Wed, 13 Mar 2019 22:32:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwns+EuZTm+XUuE+WYWdN11at3XXSXpU/4rwi/6iSCgDl0p9++4FZ/lpKF4Yp/Y9Sye1DYu
X-Received: by 2002:a0c:ac93:: with SMTP id m19mr37199476qvc.27.1552541554648;
        Wed, 13 Mar 2019 22:32:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541554; cv=none;
        d=google.com; s=arc-20160816;
        b=Xu+0fn3BSFgaDcZg2F9aVWmkbBOnHxfPwWuU9a827JQkGwseB0GaEMGbH35UaQK/IW
         u8RxhB/dw+2yXxTsw3OE6Su6oSQLST2atNfEk5uC5kd8/g9EMKVVHmL78dtgnk9E1I55
         UXB2TfgQlHYAFxCNZZMEt5IFaGzeyXSqQY8OYLVfN5qT+oVmNXqVChvUkmVoFQ/fmS/Q
         aztA+6+jzKWSJZDt95kqDI23H1x3zx/uUtiC5bMo/jFJ0DoZZrc9E2v4WrVrq8HNLFEu
         MIH2P5t3GQQax3AA8kraRzl8KjME0t/lxVCWGQPgcF/QbcyYIPIGyAIFzMRgGRMe2HBw
         VV4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=x7XzuZHTX79KOo0NhHz+n2DRp/2Ctmdn2rPrkfVwAcU=;
        b=MYYl7dipBRwXhz7v8WNJHBtT4aN4i5g9gPwWpsZN/5tECjWFlnnQ0SG+DIcpaBPIGE
         W4pfXFB6Zuqnw52Nl/Q9EbC8RPmUr/FaVYsdkDkqvETxnjxprh2nyOcaZiKAZ5lyqwIA
         eGFz0t1ubxgp56TapP5tNz0mnzHw/3ImtA/GvxNlxiHhGvcvt6li4RKwnVoJ7khR00Q2
         r/x4T8i5bPo1gtv0YCJV0+TrYnlD917miquVWfbrBnhOUFQ/93C3IO+t1GyKP4JqkwsI
         THxPm9iLwFf3h5dhmQ5ugsXcpuinT3XdJyEdSAAoy9zltHsBFJos+gxwu5lO1Toiepje
         2EAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=cq6T20jd;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id n21si5967100qvc.65.2019.03.13.22.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=cq6T20jd;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 66CA3213BD;
	Thu, 14 Mar 2019 01:32:34 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=x7XzuZHTX79KOo0NhHz+n2DRp/2Ctmdn2rPrkfVwAcU=; b=cq6T20jd
	f0zndyqf3aPS2jJfgynxjjCEtdmIuaFvb3+M+X4uBLKSicfN0ZbZM0HYmeVqdLi9
	1N1WGY/WOfXTzeqzC+x25ACgo7Vrgw+4EXnJ7nzXzGznQ8/HlcT469VKBCSlNN/g
	qv2InpYONKFrKbELh35Z280dplyM9YU99RDBRq/l8j2nNWlB6RPSCilCIOIfE5iM
	wQc3AkR+UbSfjDma9HJuDedIOCx7qNQgK8qeHdUleeB52qFNd53OgYjALmpo3NUa
	0pQdW4p6KH9W02Ysj2EnZM65AbbqpllxuetXCigkwpBFygisNWeormprjdsCBq3S
	gWEETAtrSdpXdA==
X-ME-Sender: <xms:cueJXLTq0x-P9zmPDEUJWqRLBnbqsuhRpZlVVVbN9lo7V5nppyrd2Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeei
X-ME-Proxy: <xmx:cueJXJtklfuHIpJHXLLxYzz2tSeWL2DU_WansADc1QuFOVmtQ8XBJw>
    <xmx:cueJXMc1zPRFP-ktJdZn-bl6Bwx5Kmbr9w2Q5tbqhxiJHlwE6iorfg>
    <xmx:cueJXDY-9gAALsJQfx9QrnkSDKL_cmBVNVQqPDmV238y8EIfeWu2Pg>
    <xmx:cueJXDmCt_Ovc6IoAK6ZJtIX1PL6QgxC55jcwnP210Qiuf8RqwuHJg>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id BCF57E408B;
	Thu, 14 Mar 2019 01:32:30 -0400 (EDT)
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
Subject: [PATCH v3 7/7] mm: Remove stale comment from page struct
Date: Thu, 14 Mar 2019 16:31:35 +1100
Message-Id: <20190314053135.1541-8-tobin@kernel.org>
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

We now use the slab_list list_head instead of the lru list_head.  This
comment has become stale.

Remove stale comment from page struct slab_list list_head.

Reviewed-by: Roman Gushchin <guro@fb.com>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/mm_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7eade9132f02..63a34e3d7c29 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -103,7 +103,7 @@ struct page {
 		};
 		struct {	/* slab, slob and slub */
 			union {
-				struct list_head slab_list;	/* uses lru */
+				struct list_head slab_list;
 				struct {	/* Partial pages */
 					struct page *next;
 #ifdef CONFIG_64BIT
-- 
2.21.0

