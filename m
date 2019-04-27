Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34E00C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 23:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFD59206A3
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 23:41:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gAwdxj7a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFD59206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22F806B0003; Sat, 27 Apr 2019 19:41:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E0046B0006; Sat, 27 Apr 2019 19:41:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F5656B0007; Sat, 27 Apr 2019 19:41:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E891F6B0003
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 19:41:02 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t63so6133562qkh.0
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 16:41:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=jmuzgn2qTwOZmaWMMrvylpYaoQfaw7rrRV6d+SYFgtc=;
        b=hFbbpsxpUZibydqGHRZAVw0RoCB2ZmgakGC0MAOj2OsgpBzoPCrfGAkK73/zuGdpDX
         GUxT5WMmir8DPahx3nEo4FE7zIoxna4Tr93WrIoGga4sOTSXCba2AP169knF30xEUbnq
         7+kjie2FYU4hU0Qsl6J+0LQ1pWfjr2BX3aY4PhQmRnbVex0F0/UEqFjKe49Y/mLh/qzR
         m/NnhnSOCV3pOlYX5eyGbEvt1a4XA8bFDnU9MhGpGyytzdVE28HdyB+bn/FnVu0jJzWL
         /au+smZPOqrYEbN7hHj2rCT9u86kA8FMZQLm1l0RUYyCpxRnHjRHwVbKk/rRPUu93D/r
         GFKg==
X-Gm-Message-State: APjAAAUQS+TqT363RjEWrohqkqUUd/FuLFDDC/AbSVwDnBfpNyj1+lG7
	79Xvmwf7ilyq6Ijg4d1Jg5OAtKD6yHxMBiA0F8fRr4gFscXLdb71PzrrT1Q09Q85XAWY7Mf8h23
	MZZvRMXXsbdqO7o9LMzx+EX9JQyf/DjR5OtXZKHnEkqF22cLZmyPQjEm6OHY7ulo=
X-Received: by 2002:ae9:c005:: with SMTP id u5mr30256693qkk.179.1556408462692;
        Sat, 27 Apr 2019 16:41:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb7SEVAggKDMQF7x9HKcuGL/XZDJc3MNDIVddDsTwa8G7cz64lqNZe4eq5Ek60kByt28UQ
X-Received: by 2002:ae9:c005:: with SMTP id u5mr30256663qkk.179.1556408461818;
        Sat, 27 Apr 2019 16:41:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556408461; cv=none;
        d=google.com; s=arc-20160816;
        b=yaOjzxFH7mvJEac2FwydcUkBFu6XCw+EGslYmO6IeWobc3qSVBhYnNYTRel1Zo++10
         Xm8yKmRU70m7tPs/Q+bpvbtMY1pJ0JYRIx2BWjFW9Z6vu67WXFf3slk+wdk5kZHF/7f8
         Pw44TyrtsGZP9QYF5ov5aBuR/cpVtcKWkolO0huzHc5a3LcQ1fLh7Yjc90A7nZemGqcI
         J0Sn+DUtD/j5Ju/QVQfrhxurJyRKkqg8UspkrNpDbpsSjf2/s06RCK7QcFJjHFgnSS6s
         kIptuRZCeuy/7KsG+Y3is4lAk3V0/wYYrhkWqf36Uq2+/D5DeaxiWaDPCqhpf4hgbuTp
         C6tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=jmuzgn2qTwOZmaWMMrvylpYaoQfaw7rrRV6d+SYFgtc=;
        b=mqWyWG2ZeEsuOXJM6GhH9TlJO900DE9MtDF2dFgc2578sOFm/ZfaYeMj+5Gz7fYWWO
         x4FoNkPxxOxMAxR6WyLs1/uBwdY0yQAyNjJezF0zo10EIRiWYWkfgA3GEB0tjJ2A3q7k
         s5wjTYvkAgyiCEeGH3FfejYp2BXNKnHEdPTU6h+joshGG6IUeZlyvR7HrNOEzYaU+t3c
         2+UuxnZ6O+eQ/soDc06UsJ1yFxr5OCiWo0quUcT9J02+KzSfjU+tS4VVuX5Fiomh03lO
         Ph2DiZT39cpR9Hd2aBCCCza0T35/W3oDvLJXP3ZygA6rdvTqykav4uxGt1nEOJMgNLd8
         pweQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gAwdxj7a;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.27 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id u26si10915424qvf.79.2019.04.27.16.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Apr 2019 16:41:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.27 as permitted sender) client-ip=66.111.4.27;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gAwdxj7a;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.27 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6B94E21448;
	Sat, 27 Apr 2019 19:41:01 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sat, 27 Apr 2019 19:41:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=jmuzgn2qTwOZmaWMM
	rvylpYaoQfaw7rrRV6d+SYFgtc=; b=gAwdxj7a4OFG119tyqRF80dXmpgeZjX/X
	D+xqe9Iptje2ETPSOVUowRM4r2BvmHZcZMx0sFENa2FdCDc3d1TUxdpzlGbk88U+
	Ys1wwttMZFyPMJuCF/7ZB+pdpNEnSr3q70vOJFVOiDlgfgB3V6rMzM2NCKNjkGE7
	0GfSJEel3NlT1/YWfmv3fawsSvxXxJUj83hFsXWVTVunK3sK7RgQrzxJVyqiFK+e
	pyU9oXdfRj9ChbyADD2HDCmfPutFKud4aaEHX5/TsZ9vp45DkBKZ0L1c0JYYy4vR
	2NsbiyVZZkhOHtW3kP8kPYX+KN4vWdSs65t0ue0U9K/e6fch0ZPVA==
X-ME-Sender: <xms:i-jEXAnJmXQS6YMqUPH4uKDrzI5UGrVowPzFL53b6ARv7z4fDuuPYQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheelgddviecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkphepud
    dukedrvdduuddrvddttddrudeileenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:i-jEXOU2zxEVfXxz2eHnGnrG8Ez6IycrxObWyH0AT3RZMxkga0lt8w>
    <xmx:i-jEXKJcxo-XpIWftArJGCByMwRIuYXdbb9AtLMYAadYLzgNSbcQuw>
    <xmx:i-jEXGuQgjLP7dpiv_3zvCTWfDPD-IhQtjzbR2QM4A2ru_bos4NCxw>
    <xmx:jejEXMbb-lgbwv7rPYjNTsg4MYV-7WWl7tpH68fN3Fp6J3DlBSD3Cw>
Received: from eros.localdomain (ppp118-211-200-169.bras1.syd2.internode.on.net [118.211.200.169])
	by mail.messagingengine.com (Postfix) with ESMTPA id AE348E4176;
	Sat, 27 Apr 2019 19:40:56 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: Fix kobject memleak in SLUB
Date: Sun, 28 Apr 2019 09:40:00 +1000
Message-Id: <20190427234000.32749-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently error return from kobject_init_and_add() is not followed by a
call to kobject_put().  This means there is a memory leak.

Add call to kobject_put() in error path of kobject_init_and_add().

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..84a9d6c06c27 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5756,8 +5756,10 @@ static int sysfs_slab_add(struct kmem_cache *s)
 
 	s->kobj.kset = kset;
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
-	if (err)
+	if (err) {
+		kobject_put(&s->kobj);
 		goto out;
+	}
 
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
 	if (err)
-- 
2.21.0

