Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED8D8C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E3D20878
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kFld8fwp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E3D20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B2B6B000A; Thu, 25 Apr 2019 22:27:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20A6D6B000C; Thu, 25 Apr 2019 22:27:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2206B000D; Thu, 25 Apr 2019 22:27:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E25BC6B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:27:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f20so1675201qtf.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:27:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U8DAYh6kKcmZLs62Z24hf1Yov5/xwP/SyAoz3HiKdRQ=;
        b=HedzMLBH1uUCTnlYK3u6r6dKbEOkHxzRu+Fm0dIiJlYcutBqdWVTm/CRnhxCZ9izNC
         YEJ+7OXojv7P6wTqa9qxMtJL7jB+BDeGzc2avUAyC3iY+OsYparxrqobg5ZhUM1ZWCDf
         wWs7XeRyNfmN7MW5w3QgnSPKkzEHx36wNMzpCswA7kyrIXwoh/WKv4sVPTnf8BXheKJc
         F6ygXOwZ1QNBX+Yie5ZoGprlrnI6PCckzlaG3UFD9cB0TeqrSw/YkzvH2FCeO7kYN/+s
         lpaAQpwssIqCv8a20r/n1Nsfjr0zqTPrf5cduWLSKWJZ5nPomo3VKIpzfGFvKx19EeJ3
         mYoQ==
X-Gm-Message-State: APjAAAXIBWtDYmVtHD2ZGUZ8BavKtIJM5SHiB6ZNfZrau05Zwy0u3Cae
	X2EjKyLeyccPPv53IxKdNJthsJ9kiYoYSoy+MOey1ZbL7YsJ1wzCXcnkMp3c/y/vKaq8iD9jMKg
	kKosvizfwt1wb547XaRqKYvsE4nKXKzsqhrWAispTOiEZUpkvbG5RuJZp16P4GBE=
X-Received: by 2002:a37:8fc3:: with SMTP id r186mr33957754qkd.102.1556245661696;
        Thu, 25 Apr 2019 19:27:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwg9goui3j5xp/PKw42qYwB7G47VZ9awF4+G9aoL13kTS4sJ2Fd1uROc0h3B9IPLHosJj3Z
X-Received: by 2002:a37:8fc3:: with SMTP id r186mr33957699qkd.102.1556245660392;
        Thu, 25 Apr 2019 19:27:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556245660; cv=none;
        d=google.com; s=arc-20160816;
        b=wTPDgee+bHniiG/PaU/P99SgbfNKpC+nuUFe3P0QV+kZgsxESmlXCrkf8uTTiTGk5q
         TiGrrRINoatWilJ796TH0AbD0C5hPQYYAnVkicNXBIibWqiFw0xkhJab1JanNWFW19BM
         RWk0xP19qiO7rG/Tq7u71GTvnLdGiCD1azgBZOsIZDUJkN0fDuk5dtvVnP7mSeDoT1mn
         uUN7hiX1Jodref2VcKQQwY8easydjcUgCuy5TH4w189QW7TtOaspmWqLFyLJV45pmuKm
         drJGk8uLZgXUGiaCkD1f6lzOxX5rLv+tyZ6Wh7e/5se09tXwjkOIOMVFYGrjE+YkH+Qr
         +LDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=U8DAYh6kKcmZLs62Z24hf1Yov5/xwP/SyAoz3HiKdRQ=;
        b=Fi0duHXV5R2j+gai0O12Pm7L/Zigw+8nXei33ysV9Yi1mDf53e6rReSRx2CDkKxSSN
         USOluZkHcKOlS2OW10azaHT/+RMC+1olffa1co5az1jf2PfOLgrTkRNWgWtcGouUWxPY
         Ye9j2Anp2wrMWk+PEXbqIAgu87ftPvyxaKSeXwoYAM2BiWXOZdbwbxuXbIrcXJBOplTX
         RIgaw2S8OYNCtxu+KsjnEM480bF7OHClWMTqAQ8XMezXrMKKPPKdGEn9oTPhb5QuMwa3
         9gbp+b5eQ62nMcGMNDLeuZy+7BuApxR2GQPqDyfl4/xG923iBbQJBPToCEMTpryKzpIv
         AWJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kFld8fwp;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id x52si3908206qtb.297.2019.04.25.19.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:27:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kFld8fwp;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 25647CF14;
	Thu, 25 Apr 2019 22:27:40 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Thu, 25 Apr 2019 22:27:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=U8DAYh6kKcmZLs62Z24hf1Yov5/xwP/SyAoz3HiKdRQ=; b=kFld8fwp
	rxzL8gfIGZm/CBp7C83dBBFHEi/PmjGVz507ngjQMOb4MD+DTc1Q/Y7ELtkaE4LA
	XADpf1vw8+flbXwPL73uRfr4e3Pwg+S/fX82Cm3Nuu5inaI80LLhaHJ5kEP56VHj
	YisxlLXZfcia0qtoq5RuSRQ1QSkuO+W+tDsTJMF3T71CgJutzsX2cqt50hO3qF24
	auMlBW4TEePdc8dj4MMgKoASjbsRnRHGfZFp8FMebISzhdkLmRiOCK8SEuLQV5wN
	xvOTQSInBiU15oVGCGgVZd2B5jD+YNPANqnOxqpa1lu3m+WdMgmr0zSoVKMShfgl
	07ORxrfp9CY2dw==
X-ME-Sender: <xms:m2zCXMyFt9vXKM3AJsDjT-ToDpveAV_5nVK6HZOUMQ_9rW3vNIJyMw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheehgdehlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrudehledrvddutdenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:m2zCXKon2k2xaDVmH3jJyeJM5l4ki4yCpW2BV_zpOoVhgEEYpRIFLA>
    <xmx:m2zCXJ4gF74U3Uc2zHjiK_KyS8YYcvS41Qzl24GPBw7T_D0BS7tUEg>
    <xmx:m2zCXEiSbhrDDpTc6D_Uoir5-A7hpRB_x_KsYYszAsVSBUS9K1fu2A>
    <xmx:nGzCXBhWwNaiVWqfSkWGTUrvWCoNMTRG1u7DwX0boG64Yg5-2afM2Q>
Received: from eros.localdomain (124-169-159-210.dyn.iinet.net.au [124.169.159.210])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9D1F7103CF;
	Thu, 25 Apr 2019 22:27:34 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Pekka Enberg <penberg@iki.fi>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] tools/vm/slabinfo: Add option to sort by partial slabs
Date: Fri, 26 Apr 2019 12:26:21 +1000
Message-Id: <20190426022622.4089-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190426022622.4089-1-tobin@kernel.org>
References: <20190426022622.4089-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We would like to get a better view of the level of fragmentation within
the SLUB allocator.  Total number of partial slabs is an indicator of
fragmentation.

Add a command line option (-P | --partial) to sort the slab list by
total number of partial slabs.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 3f3a2db65794..469ff6157986 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -111,7 +111,7 @@ static void fatal(const char *x, ...)
 static void usage(void)
 {
 	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-aABDefhilLnorsStTUvXz1] [N=K] [-dafzput] [slab-regexp]\n"
+		"slabinfo [-aABDefhilLnoPrsStTUvXz1] [N=K] [-dafzput] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-B|--Bytes             Show size in bytes\n"
@@ -125,6 +125,7 @@ static void usage(void)
 		"-n|--numa              Show NUMA information\n"
 		"-N|--lines=K           Show the first K slabs\n"
 		"-o|--ops               Show kmem_cache_ops\n"
+		"-P|--partial		Sort by number of partial slabs\n"
 		"-r|--report            Detailed report on single slabs\n"
 		"-s|--shrink            Shrink slabs\n"
 		"-S|--Size              Sort by size\n"
@@ -1361,6 +1362,7 @@ struct option opts[] = {
 	{ "numa", no_argument, NULL, 'n' },
 	{ "lines", required_argument, NULL, 'N'},
 	{ "ops", no_argument, NULL, 'o' },
+	{ "partial", no_argument, NULL, 'p'},
 	{ "report", no_argument, NULL, 'r' },
 	{ "shrink", no_argument, NULL, 's' },
 	{ "Size", no_argument, NULL, 'S'},
@@ -1382,7 +1384,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aABd::DefhilLnN:orsStTUvXz1",
+	while ((c = getopt_long(argc, argv, "aABd::DefhilLnN:oPrsStTUvXz1",
 						opts, NULL)) != -1)
 		switch (c) {
 		case 'a':
@@ -1436,6 +1438,9 @@ int main(int argc, char *argv[])
 		case 'r':
 			show_report = 1;
 			break;
+		case 'P':
+			sort_partial = 1;
+			break;
 		case 's':
 			shrink = 1;
 			break;
-- 
2.21.0

