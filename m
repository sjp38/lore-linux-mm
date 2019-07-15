Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31A5BC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9C5320665
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:32:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=znu.io header.i=@znu.io header.b="WHnkpWYr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="uFlZFby4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C5320665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=znu.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11B8B6B0003; Mon, 15 Jul 2019 06:32:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC756B0006; Mon, 15 Jul 2019 06:32:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED5AF6B0007; Mon, 15 Jul 2019 06:32:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6686B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:32:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so13321144edt.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 03:32:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from
         :content-transfer-encoding:mime-version:subject:message-id:date:to;
        bh=/DQWAtAzrI7aDaSYC2MJMiC2D4zGrFgnxN050x2KZu0=;
        b=MwJbfUkXcH8sR9Ry1Ciuon3pUr37vg23ENc1p+vKu4PIFfkxWJoU0GD3+KrU/P7sk2
         aOAHzvsjBJUOGci+QFlyauaySBqABSNwlscUL+oSYc483mjWFqa9hTEUr4O8Ns2xZWVA
         Aaii2oLDwKd1+Oa92CopmAKW7cNsckaFWnloyQUgrHPrUlyhJYFdnUgPY4uULm9E9gSO
         WDwIjKQzKHSJWijuYbe1SUePmuHBAPqYlal3DzJDXi1gSIQziWdaEXXX2T0osoNzv5Zd
         8DfeeNb++yQreQ9k88thvT7SxNdigcdim9l3iFCQeJp5cuZ75KTnfenNt4gMNjQFNNpz
         ngcw==
X-Gm-Message-State: APjAAAUPOBRpnKoKZgqbPrDqzT6jcmMWyHz10ixwH/UgzDHbm4jvsn84
	nk8cMGspD6ul2QERa0lCwJP0bHRbOtbzM7Bpo+5gznQ8CzwOjIzZTj2+Bp4ASBDlzZn1AxCZ4NE
	9MM5S21oug5ikPZ1/+rc6mTbI0V++VKb/4YWrM1YaobNoy92yxl6USN8ZJyiYXV1PVA==
X-Received: by 2002:a50:976d:: with SMTP id d42mr22298667edb.77.1563186760993;
        Mon, 15 Jul 2019 03:32:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlP2Gf5QF8ZBg3LfiQsgnnpSEv0el2q5AG+t8hvotbdSn7901oW0+Dh7GPT26H+jXhGGDO
X-Received: by 2002:a50:976d:: with SMTP id d42mr22298557edb.77.1563186759763;
        Mon, 15 Jul 2019 03:32:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563186759; cv=none;
        d=google.com; s=arc-20160816;
        b=IQa2pmV7qOPj5XmlNQxNQD0bUdEfxAY1RLyuII0Vj5VmevPj4qxs9GAKWz3V4grucW
         YJ6WrvSMxfaOezjvvx8iFw8UW3E+MwLaYR3gLFijz9Ua1y/GIBT7vZCmXVewG4Y+LgzU
         XehH9QxDOrkK1xdkrmtYSHWdinkZgbdozTQfC/bnYoPtpPnB9nGquk695MG5kv6MzDhS
         N8UF9o3S2aRZZqlAVQxjjl1VrITMk7muSzBnSai4kMtxpyqg3Stc8oQ7EmWojkTMwskF
         cRBidfM9AOlXMDp9X8JrLNaaD3Zg6Ja9iIRDoF4bdJ1h7y957J3qnn5KdZ1p7LN9zzmC
         H1BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:date:message-id:subject:mime-version:content-transfer-encoding
         :from:dkim-signature:dkim-signature;
        bh=/DQWAtAzrI7aDaSYC2MJMiC2D4zGrFgnxN050x2KZu0=;
        b=h2ylUmh3idogydkGBTrBnyvRy2p4GfYW+yWaPeWk4U/jhXUY9BEN14SP90n9ZQiSir
         Ds89HmrVU+xdRGixSubN0TIwk5BgSRvrsKWnd3xaV6ck7suWrNnH7WPvO8tib0TNontC
         EobapA7jNw6LZ8zXBwZtkKFcDC5XREgLrnzeK89r4sFy0oLZSKbFlE4zcDJA7ipRa80g
         aVHQ8+HcpO89aYhG40a8ih3RIMnDiWcQKjs7paHV3WQTcJrzv7W46d8dRlSCAFo+rVRt
         va1bRvNFIi7h/ega1Yti6ePBEBIr7gRGUMm5KkfP0f4NQEanHIBxeYn4SXZE+/6phSP8
         V5sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@znu.io header.s=fm3 header.b=WHnkpWYr;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=uFlZFby4;
       spf=pass (google.com: domain of dave@znu.io designates 64.147.123.21 as permitted sender) smtp.mailfrom=dave@znu.io
Received: from wout5-smtp.messagingengine.com (wout5-smtp.messagingengine.com. [64.147.123.21])
        by mx.google.com with ESMTPS id x58si10289028eda.238.2019.07.15.03.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 03:32:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave@znu.io designates 64.147.123.21 as permitted sender) client-ip=64.147.123.21;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@znu.io header.s=fm3 header.b=WHnkpWYr;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=uFlZFby4;
       spf=pass (google.com: domain of dave@znu.io designates 64.147.123.21 as permitted sender) smtp.mailfrom=dave@znu.io
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.west.internal (Postfix) with ESMTP id B8FB6614
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:32:37 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute4.internal (MEProxy); Mon, 15 Jul 2019 06:32:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=znu.io; h=from
	:content-type:content-transfer-encoding:mime-version:subject
	:message-id:date:to; s=fm3; bh=/DQWAtAzrI7aDaSYC2MJMiC2D4zGrFgnx
	N050x2KZu0=; b=WHnkpWYrnrj31tmq2vghKsLAQKeM+3RChHMqxp5CDxfzHQV4V
	x3XPzTO7W/0VBdAIUfG1rbFlLVdjVt490v5e7uftGxyOKwFF9yPSI+6leYzNRlQh
	j4rF3hz6SEiDSyaov3w+QEAaV5T2RPtbMz8Gd8KPyL3YtIPie+RAeOYVwmLCuC7q
	BBbZGwI+T9ruTBmussPsBxO3LCKSu3YHua2ioYmUAnkgjK5P7jaTfXBZY0KN2Oq0
	wICfvkWBu+k6Yvn6EeILtmI2z1OnTzZLM4e7QOUqMm/f3iHzEoTf9HPGrH60UYHt
	YMxzpX4bYyr2dW5SiP9wcxruo8L3QHfAVe4rw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=content-transfer-encoding:content-type
	:date:from:message-id:mime-version:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=/DQWAt
	AzrI7aDaSYC2MJMiC2D4zGrFgnxN050x2KZu0=; b=uFlZFby4B/mfN9BQsV9+T8
	jR+9oDrZeGpEEYroXLffPhNssLYw5iMRwbmVwP+cUV0FA4qkt8KAElOASZafraxT
	NmEX29wSVO7Lpj+xUEIL3yD4i9Ut86fxAlsdIXw9zQuQ2M+jFxgvFap5Fjq75I4U
	8qTP3SrMsRz3Q9UzEA0MLgs+TXweIYcpAYGQRdbufTeKQfszChwpTfCvW07I0gL3
	tkD+RyBIfLEwfQzclb1vMZQ8O18vAV0aVh/aM0Fc24OACxGO0eN6E0S7MdgmaHj8
	MElww0/7L2+tCIG4+EaV9pexGmTq02h3/6pQMIMMuoGiSCYZh66pUxag7y4JTRtQ
	==
X-ME-Sender: <xms:RVYsXcyx2W2pQj340sHBxIFQELT099OuazvFcSHuc1VrJNp-cuK32w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrheekgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecunecujfgurhephfgtgfgguffkfffvofesthhqmhdthh
    dtvdenucfhrhhomhepffgrvhhiugcukggrrhiihigtkhhiuceouggrvhgvseiinhhurdhi
    oheqnecukfhppeehrdekkedrudeiuddrheelnecurfgrrhgrmhepmhgrihhlfhhrohhmpe
    gurghvvgesiihnuhdrihhonecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:RVYsXQuyHz3870XI1l1Keeuy9bGquuQq9SmX8K3FzFTc0O-XOpaybQ>
    <xmx:RVYsXfCsn_UwWqZTsGhI7VFuSf2G3IAdDHfhhCOfMkQyEWuugNmaIg>
    <xmx:RVYsXSEpaA8exmN4vgpejB-YAyDDGtNi-LGDP_IDBr1D8CWaV_Hf-Q>
    <xmx:RVYsXd-oJLm_bHT_yKFnTFZY9kgvIc1tBDxzh0Luqn29F3PdyvvOEw>
Received: from [192.168.100.145] (net-5-88-161-59.cust.vodafonedsl.it [5.88.161.59])
	by mail.messagingengine.com (Postfix) with ESMTPA id BFEA080062
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:32:36 -0400 (EDT)
From: David Zarzycki <dave@znu.io>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Transparent Huge pages hanging on 5.1.x/5.2.0 kernels?
Message-Id: <E70C35A9-A757-4507-BAB1-D831A5746BBF@znu.io>
Date: Mon, 15 Jul 2019 12:32:34 +0200
To: linux-mm@kvack.org
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

In the last few weeks, one of my build boxes started hanging at the end =
of a build with a zombie ld.lld process stuck in the kernel:

[97199.634549] CPU: 14 PID: 72214 Comm: ld.lld Kdump: loaded Not tainted =
5.2.0-1.fc31.x86_64 #1
[97199.634550] Hardware name: Supermicro SYS-5038K-i-NF9/K1SPE, BIOS =
1.0b 04/13/2017
[97199.634551] RIP: 0010:compact_zone+0x4d0/0xce0
[97199.634553] Code: 41 c6 47 78 01 e9 52 fc ff ff 4c 89 f7 48 89 ea 4c =
89 e6 e8 22 8e 02 00 49 89 c6 e9 d7 fd ff ff 8b 4c 24 10 4c 89 e2 4c 89 =
ee <4c> 89 ff e8 e8 e0 ff ff 49 89 c4 48 85 c0 0f 84 bd fe ff ff 45 8b
[97199.634555] RSP: 0018:ffffac6a53c879c0 EFLAGS: 00000202
[97199.634557] RAX: 0000000000000001 RBX: 000000000619f200 RCX: =
000000000000000c
[97199.634558] RDX: 000000000619f000 RSI: 000000000619ee20 RDI: =
ffff95f77ffc8330
[97199.634559] RBP: ffff95fb7ffd4d00 R08: 0000000000000007 R09: =
000000000619f000
[97199.634561] R10: 0000000000000000 R11: 0000000000000003 R12: =
000000000619f000
[97199.634562] R13: 000000000619ee20 R14: fffffb58467b8000 R15: =
ffffac6a53c87a90
[97199.634563] FS:  00007ffff10fd700(0000) GS:ffff95f5fb780000(0000) =
knlGS:0000000000000000
[97199.634566] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[97199.634567] CR2: 00007fff08001378 CR3: 00000054737f6000 CR4: =
00000000001406e0
[97199.634568] Call Trace:
[97199.634569]  compact_zone_order+0xde/0x140
[97199.634570]  try_to_compact_pages+0xcc/0x2a0
[97199.634570]  __alloc_pages_direct_compact+0x8c/0x170
[97199.634571]  __alloc_pages_slowpath+0x248/0xdf0
[97199.634572]  ? get_vtime_delta+0x13/0xe0
[97199.634573]  ? finish_task_switch+0x12f/0x2a0
[97199.634574]  __alloc_pages_nodemask+0x2f2/0x340
[97199.634575]  do_huge_pmd_anonymous_page+0x130/0x910
[97199.634576]  __handle_mm_fault+0xfd7/0x1ac0
[97199.634577]  handle_mm_fault+0xc4/0x1f0
[97199.634577]  do_user_addr_fault+0x1f6/0x450
[97199.634578]  do_page_fault+0x33/0x120
[97199.634579]  ? page_fault+0x8/0x30
[97199.634580]  page_fault+0x1e/0x30

This bug seems to go away if I comment out the following lines from my =
boot script:

# echo always > /sys/kernel/mm/transparent_hugepage/enabled
# echo always > /sys/kernel/mm/transparent_hugepage/defrag

What can I do to debug this further?

Dave

