Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0344C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69B0720870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="gFuf3Z/O";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="DrSMkMyr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69B0720870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C48788E0002; Wed, 30 Jan 2019 23:11:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1EA68E0001; Wed, 30 Jan 2019 23:11:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0F7A8E0002; Wed, 30 Jan 2019 23:11:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 852388E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:11:01 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k203so2006669qke.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:11:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:mime-version:content-transfer-encoding;
        bh=UCPkQVr58oLjGKAE0TNmYYJbUlDgbRTbB4YKF6U2JnA=;
        b=XnEN/cccHlRKCiQK/ru/War2+LA9D6d0L0M+PKITOZ1MOnZhtuZFSWk1PZBHkWsgIm
         Otb8LM2ps+UiSAvCS/QhRk0HmzHf20oWqzpB3ml4etHiNVeAcV/y86GuB2AtBIhhapPX
         uM0q+5JbVuFfx1YgRKdLiD031zqJarneJ84y17B5E6oA74Ksj+Hu5YzgK35tb59JHwiU
         qd95cXUe+Vo9wv8x7lHBU3Xc8klD4y9gWlLZL28ad/KDJg8EBiOn2DZoWIG/creXUy9T
         PDhFEhIV2nsfNaHU69atljga1enpPpbJTszv9jii1107dpMwrAACxT9M+1TTq5/EX3OW
         zPqw==
X-Gm-Message-State: AJcUuke9cX9hf9Tpr5ltZWFW5x1LG9gBibMh6eAWz9/pe68+s6yxG1aY
	hgXJQydblceRQaJVpYwDMUCJjCZdMxUEZi51KYjjdFiGMxjtCGSBwTJgnq8KzCf2uCW+whki9Vq
	SDNpaQ4zgFHY4A1leSnhxo1AFci50QQo7P0EHS/INOQb6vpgQLPVIruc2V6RBGCBvmQ==
X-Received: by 2002:ac8:4910:: with SMTP id e16mr32303101qtq.332.1548907861309;
        Wed, 30 Jan 2019 20:11:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6I7Qv2mRN9QcNRGHi10jM/VpISdMgKYbT+olqwPuTSThDuz7MdgxHEc/UVhG/0J3qRBGfK
X-Received: by 2002:ac8:4910:: with SMTP id e16mr32303078qtq.332.1548907860669;
        Wed, 30 Jan 2019 20:11:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548907860; cv=none;
        d=google.com; s=arc-20160816;
        b=f3LFi9a6aR9DzT89licEo32718+vyeIX56Ao/iD8cxXcZqLtNeD7kF6DJhpvokrAYF
         VU/WnBckqJvIoKH2ZazLI82nbxMr4ERlOvZV1S7YMQSzBdNuTD1wLwpo2DTsqqJiRAyL
         rGsaBoFqJrS01f7yXn+R8Z1aL/ypgO1GtmSDgN+hoeYJm8Kgo1HVgUZOMNGCrISfGfGj
         cvPlF3qDwQa1s0zWiQStabIpknLYGL7h3zoz83RBBGf2X4VOv9SbJH37pIVM4ZubyfJV
         rP8/xGGnLA4sqy6W5ju4iBkP2rfGCXHprgLUxnpnWtaPHkoCuJtSZ1sxHAHHYmENM9um
         bTyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature:dkim-signature;
        bh=UCPkQVr58oLjGKAE0TNmYYJbUlDgbRTbB4YKF6U2JnA=;
        b=PwxeoaWv/kn+3Nxr5L+Feg2tC8uEYeeABhBuJ2fo9vFTYyAZrPB+hmudWih+aIlUhI
         rNKaCKMptOT7S6XfYyiIGBEdLvDo/I2Bx7QUQimbeqnaD5At5tTL7Yf6na96aYnCz76a
         JQkZYd7pgAQ3HY5e2FIGnvcT9jHcmOrfmVljoyW/jjNb4xdSK1kesDRtR1cY/e7dflFN
         itBexra3OPpSwDYGET07TtWbtOULopvGsLDBpe7qrWFasLxv33gqs13LLBp4hKf4rAME
         Zzx2EX2Wq65ug+p0iwi8faUqEzu16vS/Nyl3xU5iH3wVNBh8gXETQH7ervs9L7XevCC8
         PfIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="gFuf3Z/O";
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=DrSMkMyr;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id q45si2005893qte.344.2019.01.30.20.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:11:00 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="gFuf3Z/O";
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=DrSMkMyr;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 208EF22585;
	Wed, 30 Jan 2019 23:11:00 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 30 Jan 2019 23:11:00 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=from
	:to:cc:subject:date:message-id:mime-version
	:content-transfer-encoding; s=fm2; bh=UCPkQVr58oLjGKAE0TNmYYJbUl
	DgbRTbB4YKF6U2JnA=; b=gFuf3Z/OkS09yKXYlsAL/7W5VvjtfwJx5QhImbobuV
	uucHzHst4AJBV4XxkEheCsM+jFuS/cwgYs8g5Y+NFFzTT+bNdSc4oBNzfGnM9GW7
	aUxappBvuXi9KDI0rLCuilDxwUPGhOv0gIehJUU5eYfxphS9CcnMM3Mj2nvmYCV9
	Lhzppuh2Ez5Q7xZmKZWLnFWS4norG5vCo4GBmYutma74UyWUOqGc9Sg4qeSgM/wf
	E88MKB+VhNahAa5e9T/Xk+/SLQ9KGBiww2nhD9CQhdIt54Lm4XkDJFLyCd6xlNPs
	/xeZ3Yy6OcrQSheIP0ZVIiAkNrSWrT/sC+UJFz2sMsrA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=UCPkQVr58oLjGKAE0
	TNmYYJbUlDgbRTbB4YKF6U2JnA=; b=DrSMkMyrNG5tH5JX+piTsczKXPR3huzxL
	GPxt4KA12q2BCTuQbtsJdlV9irAmS/kZqMWur/J0/6ccExCncAZI49ot22AGoNhX
	dxxzK/O6hJyTXI9HcRfl7UEGQgEuj43kNfyuSHJVsy3+/de23hFRW+Q4+Ug8R+4B
	MD/7LgySm0Ehlf0G1EaYCov4AgVKr2Oi3/cS3W+19dKqUDpT0BaakM7HTPry36KX
	C0JnS3zzjal3/kIGczDRC9hRgefDl4JEkES1kMa27yKSBIgMlpU2nXUIz/LTaFwu
	am04Mv+rTPio96KhefOhenLED65XEwVTuIvdjOyI8spQKWl5DwhZw==
X-ME-Sender: <xms:UnVSXDZEai83HuG2-YWxKjXNJ_H9q4apiM8LgwJo4dSERK8baxSmlg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeijecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduudekrd
    dvuddurddvudefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthhosghi
    nhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:UnVSXCmFmJMIA5Q9or5w2LDdZNcjMGovSRYUeSv6fRTr9U0M4X5MPw>
    <xmx:UnVSXHzROVf0f5QK0uYMTpXytrPXUholVXOUc4dq2kH2VgetZ7vqlw>
    <xmx:UnVSXIMX6qVPPhTAHzmk3JXWk0V_EPjVoZXGRciDvG-yOgBPhTHo_g>
    <xmx:VHVSXEjz5bNjAMoieimHsxDNY4KdScwjArov4wcgFiffEuWJljh_0Q>
Received: from eros.localdomain (ppp118-211-213-122.bras1.syd2.internode.on.net [118.211.213.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id DCB7910086;
	Wed, 30 Jan 2019 23:10:55 -0500 (EST)
From: "Tobin C. Harding" <me@tobin.cc>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/3] slub: Do trivial comments fixes
Date: Thu, 31 Jan 2019 15:10:00 +1100
Message-Id: <20190131041003.15772-1-me@tobin.cc>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Tobin C. Harding" <tobin@kernel.org>

Hi Christopher,

Here is a trivial patchset to wet my toes. This is my first patchset to
mm, if there are some mm specific nuances in relation to when in the dev
cycle (if ever) that minor (*cough* trivial) pathsets are acceptable
please say so

This patchset fixes comments strings in the SLUB subsystem.

As per discussion at LCA I am working on getting my head around the SLUB
allocator.  If you specifically do *not* want me to do minor clean up
while I'm reading please say so, I will not be offended.

thanks,
Tobin.


Tobin C. Harding (3):
  slub: Fix comment spelling mistake
  slub: Capitialize comment string
  slub: Use C89 comment style

 include/linux/slub_def.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.20.1

