Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCFA6C282DA
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AE7020820
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nYNyba3e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE7020820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48A8E8E002F; Sun,  3 Feb 2019 19:57:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43ABB8E001C; Sun,  3 Feb 2019 19:57:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A2E8E002F; Sun,  3 Feb 2019 19:57:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09C528E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 19:57:54 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n39so16829024qtn.18
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 16:57:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UPtLQBBDpQY8OrRZNx58X637Zf8UbyPpXV+o1ETUk5k=;
        b=DDwGIHGdA/MvkeTbV+gsyEs7xHnQ9fQJe5cZIYQMB2oNWUSZKTzt3h13jm56SAr2rd
         m4kJGopuPapQpaHfT4BHFprx2Rk+uTZ1t14mbfkQ9/pQ2o1oiQXJN9RS5Vrec1EcF16T
         uO53WhS4xiBBs7LKGTsKdSBEjpTg9Xnr8o6prLHScQ31q8i9It5LesrBedD7VIvdEnWQ
         9ffn3qTqeVOlT8UZFnmJ7zMI4Fw0FJ7rc+CxUO26ACVZkVMmE8poKqMGI3gpyQlPPMQT
         BkqF9SjuV3oVHkYIrfnAb05DF+0Ptmf7dYXND8+eSWI4uAyTBonTKXYvTAAYGDK5JTuX
         P47w==
X-Gm-Message-State: AJcUukeveS7u1Jqnr8alowLspEsZZZrDT35hMcY9Mkl2W+uyJZhv3xWv
	mIU2DGLlYmiTsWrFz1TDId7TPOPyyHeh4+MHn96FOHQzghCJNmOgYnmM6btOqTkaJGiVdbGsJgB
	CHVJySVYinJYLv0T4LAUkOb91PcE95Y7JrX0S41/Ccy/82ogDpv1QaxGN+mIP8VU=
X-Received: by 2002:a0c:89b4:: with SMTP id 49mr46052345qvr.85.1549241873821;
        Sun, 03 Feb 2019 16:57:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6QETGQ/L5KrjfeZ1zAAG2HyErqfM6rwynpU7FCnSE5QnIilguWOx4Vb5VBsQxxavbR3kQy
X-Received: by 2002:a0c:89b4:: with SMTP id 49mr46052326qvr.85.1549241873258;
        Sun, 03 Feb 2019 16:57:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549241873; cv=none;
        d=google.com; s=arc-20160816;
        b=j2JJFhgRxz3ERe6ZapPE2nb35yX/6sQsggq+9wRtihq/byQDdh8SLdaD9myIFvRYIJ
         /11VkEPuFb3n1U/p1Vv6E0IMu4dy3HcyPYpPL75j8aAAMB9+fb/maT6BgphNqulYvmfz
         XhFSQsv9AtyWfOzvVJ+d7Z7jrasn4jj5khyiQmB106JQWjr6uFs4TmCOg3Z0n1dF03Nk
         PEcc331OjzNap1bu/a4W8bMKeF1Wz31KO/w9Ehi7EbZqdV0s/6RZXKnuxmB0Bz4Sg8BI
         9r5VXxNzNXlIye+eOAmD8a80CdMMJbQbZ9K4nTKCDS4e11aHaElhWg+8gJaXlulHAdj3
         Y/jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UPtLQBBDpQY8OrRZNx58X637Zf8UbyPpXV+o1ETUk5k=;
        b=Hf6k0Kp02z0hy1SEBjM/Wwhtxjuq8kOKhLH/hlXHHUYghRO14BXuLdbPtsnszRzKE9
         ppSecjdaZSv+lbMrWRYpuknkSClu8RiFwE12fLlC+2wcBer6Wd+Vv49WjsKRWCJu8Zb5
         R4L8gJ31zSnGphP7uKGlJg5RSHhKWOM1mdrshRPsRpBRHOD5Z9oP8Ix9m57mMGGq3Z+5
         oo9WUmbkFubAXS1KKojU48iU7n/hlHvSIHbgdmP6vfxu7LQknC/k7l0tkG37ikJfKHj/
         q37PddWB0+RJMQ4JslPJUt0MW5D3ONAaQho7OwHBHwQq19LHmL9qYxaFs/kowpDMHS+b
         kJOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=nYNyba3e;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 49si672034qts.164.2019.02.03.16.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 16:57:53 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=nYNyba3e;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0514520D0F;
	Sun,  3 Feb 2019 19:57:53 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 03 Feb 2019 19:57:53 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=UPtLQBBDpQY8OrRZNx58X637Zf8UbyPpXV+o1ETUk5k=; b=nYNyba3e
	FAlBG+Ougq0t2IIV2kUbyeYo6H5UF/zL5hGKKT9xCvczVCyzvHgQFXXKazYhwsfl
	TMfwxt6Y4rim/paoPQA/H/8SLTKi0ISG2GOo3yQgxVzNtvG/9RajdkCIZdZGdBAa
	UuHLeYmGvgrjn6srihmak+lOwdjGsKGFLQPx8F4QZ79lQ5Drd+oGGTS8xNAs5kDg
	Wt2o09UJkIFRnKrWAF0MCRAOCZZ+psL27DaI5OGhOzMp87JHJujxdNJZ1WeAct1Q
	G0t100rAZPBDQ0qqlosCwuztOfA41rfjv52wwVVLn17Cj1mpptPGu/H3uIwUsLwv
	p9yQvNRDP8eO7g==
X-ME-Sender: <xms:EI5XXG587kEdtMQ8ZpIXpaEh9f3Qvk75sQ_1idixHURPrYuZ-41zwg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkffojg
    hfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhg
    fdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppeduvddurdeggedrvddvje
    drudehjeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdho
    rhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:EI5XXJQaJEHGlrfgeAzzySV_ANE_RzgH0-xOGvrQYV6lh-FpOWYRtQ>
    <xmx:EI5XXN-Gr9TxfLZ-f7xsi97PSPesZ9sojTcJmgF1FKKDh605QAW0pQ>
    <xmx:EI5XXCpFtTVCUS2Qt6cYCUZLEEz-gnuI5oa1f991cQLDJMeaPUQZ-g>
    <xmx:EI5XXD2XcygaWH3Al5C8oVAQSnGdJabEAG5WPMPKexsEDTPkmbE_GQ>
Received: from eros.localdomain (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8719A100BA;
	Sun,  3 Feb 2019 19:57:49 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	William Kucharski <william.kucharski@oracle.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 3/3] slub: Correct grammar/punctuation in comments
Date: Mon,  4 Feb 2019 11:57:13 +1100
Message-Id: <20190204005713.9463-4-tobin@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204005713.9463-1-tobin@kernel.org>
References: <20190204005713.9463-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently there are a few minor grammatical errors in the comments.
While we are at it we can fix punctuation to be correct and uniform
also.

Correct grammar/punctuation in comments.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a3f1fc7e52a6..d2153789bd9f 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -81,12 +81,12 @@ struct kmem_cache_order_objects {
  */
 struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
-	/* Used for retriving partial slabs etc */
+	/* Used for retrieving partial slabs, etc. */
 	slab_flags_t flags;
 	unsigned long min_partial;
-	unsigned int size;	/* The size of an object including meta data */
-	unsigned int object_size;/* The size of an object without meta data */
-	unsigned int offset;	/* Free pointer offset. */
+	unsigned int size;	/* The size of an object including metadata */
+	unsigned int object_size;/* The size of an object without metadata */
+	unsigned int offset;	/* Free pointer offset */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	/* Number of per cpu partial objects to keep around */
 	unsigned int cpu_partial;
-- 
2.20.1

