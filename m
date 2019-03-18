Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48859C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E730E20872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KOAmRspW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E730E20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945DB6B000D; Sun, 17 Mar 2019 20:03:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A21D6B000E; Sun, 17 Mar 2019 20:03:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 791A86B0010; Sun, 17 Mar 2019 20:03:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6166B000D
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w134so13311371qka.6
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=;
        b=Y4sWNjiQ6/YPhGdRbiq2WYTantuYYpvbQ7iUOggZ2AG/0jRLX61TXkXwfPzgpRPPoG
         lMlM/31+p5B6GgLTf5NNpssId115TEnV65JO3I9qJZR5D99IrZ3fuUr8rL27Ytj/cILj
         VEn5MpVptZ9lP5A5Lpy5YhMdiFcWEtQj/l41q8/W4/CTGYNM2KFseShJFQ9n5UtitYWb
         y0U796fcbo6VCI+35alJy3zWyBCzrGbivb4h2dESkYk4QrIiOQOiBGXNRFLyjfD97viA
         cwfA8yAHZQp7BsFtrAm88vBs667OVe/kySVmM4Z7vv+J/9Jw2bDJbn7gxugCzirRPU0L
         3Rzw==
X-Gm-Message-State: APjAAAWcRmTHhOA3B7OkHrHSkz5sSgBNNqrDTVjHjEPCW8T+tw0FEcn9
	gee2IDEtSmktDe3ZqSraMdoerjrR7k59Z8KTXyiZlldzmACIqKHoX9LZaSw76cRiTfZifmyQbvE
	EtqjM9Tqy7o/VRghySSrVOrXM3AZOxeIOxfSlspIVerynOfCuKV29LltThssl+uk=
X-Received: by 2002:a37:a14:: with SMTP id 20mr489050qkk.265.1552867434095;
        Sun, 17 Mar 2019 17:03:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDhXFjA6dIqDzcAxP3ErwuZ7Zdueyg8uLkGPD1gXyHHbWiDztSnChqkmGDPJ/wpbHepXfI
X-Received: by 2002:a37:a14:: with SMTP id 20mr489008qkk.265.1552867433155;
        Sun, 17 Mar 2019 17:03:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867433; cv=none;
        d=google.com; s=arc-20160816;
        b=iEnOytBJ4bcffd5c4Tmwxm9+VcA3cqSb89nkyrJcjAH2kahQCJd69gyz+iiD0joBkn
         JohAEiXt44PLoCqgX00yK5UWqftqaNa2f0tvofhcqnSAxTvJ9WMZFrdzH3kdCdfVfAuQ
         FDjvWV6jDkyPBcXk0+Wtf1/AY/kgvd+JSr28KiZknjDlBHVndYnLVQuYnXEJ7ADAQ5fk
         Czew0y5wtkCObhkVx4oL37wdcJxZL45kwN9RL0XCe4WfvtsWUi/v9qHV7M6NU+cLIoF/
         njVt/S/R6uy83kJji2Ux4pTo5fgQ7HwqvNQjr+ShsD52EE+7VTcU7OHBmQE/1pCNUUpD
         a+wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=;
        b=N8rUH3/P5NB7vrXRFnTs87fNlPr/Xa5MHZBJGxEbObbOW1q5itj3hRbgnr+tnDhNSs
         fenwdIFXtQGYFTStvUm7bIz+Ly361WIcp+KepzbORkoFpuQu83kU4jN9ObiKzD7B6gLd
         PW3mN1mKOgEw31oYm2cmeqNgHex7AKoiJv48NatPzBTe7FGdDw5C03d7mQWwSZB9m3se
         lLlX+0vj8+ju/X9yfQ4m1pfiqStrymlwSn1E1k32gjIExCI8QVRgEU8OUv1uXesDrbsD
         CcaRX6MVbaI6Im8hpoG9JgxypZGuBF5Bz/lTHuwqmHa5QXXTNva3SaMjX+t+KJ/5fa8a
         5iAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=KOAmRspW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id q70si3941399qka.246.2019.03.17.17.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=KOAmRspW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D72E2210A8;
	Sun, 17 Mar 2019 20:03:52 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=; b=KOAmRspW
	zBQVWYQ7vICgKRiQqNhAMtncIDQke6ig3Hz+sdddxUlCSTlcQT1rCLx5IszqwTh7
	JebvNswcv0GRgndUA3DVZVYb84T+t/L2RHTx+BGPq+Hydz1wdannzgYxtSLOSQJ0
	hwp/WX4SJWXnGVtZnVFeVJxsoEHjYOH8WnLLcm4vqnRCSzg2BFzJiU5D5WaPjqwv
	QNezb8UZvFW2/fvKBcqWtiuUOkm1Zu0XqKTAVALxQYKfBYmpseslQb6wMpaeSAAs
	Y59viX8Gu+BcUOaar/P+dMz5U3L1T5bzMsEvdWPDKkpj9HEeFzMMqoLmp5Oi12Qk
	q4QxuDgpnAzhqQ==
X-ME-Sender: <xms:aOCOXIXGvKZG3G-RbHqHN8nBpLKDwPqsvEyrGhwu2jLjgD85evxSXw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepie
X-ME-Proxy: <xmx:aOCOXA36fJJx7e90odDYP9HIN0QWUFw-YLuyfuFIpXqZsltBtilWbw>
    <xmx:aOCOXHYShTMv6GNSSXvbkyutxBMU5Z9ZVZXDL5HeQSrCYSFXh2qTRQ>
    <xmx:aOCOXLrpBeY-uqgrwaqgcPSTVSuEIzjvqA3avHlPWubb-u5ls6kgaA>
    <xmx:aOCOXHw4MVrmOtdaJtn_tlSWzXbeYCU4HcsdLd05aKKvc0qSpombCw>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id 70051E4684;
	Sun, 17 Mar 2019 20:03:49 -0400 (EDT)
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
Subject: [PATCH v4 7/7] mm: Remove stale comment from page struct
Date: Mon, 18 Mar 2019 11:02:34 +1100
Message-Id: <20190318000234.22049-8-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318000234.22049-1-tobin@kernel.org>
References: <20190318000234.22049-1-tobin@kernel.org>
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

