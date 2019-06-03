Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BC46C46460
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 190E92724B
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="X/3bMxR6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 190E92724B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2BF6B026D; Mon,  3 Jun 2019 00:27:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA9B96B026E; Mon,  3 Jun 2019 00:27:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A726E6B026F; Mon,  3 Jun 2019 00:27:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 833DA6B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:27:50 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w184so13732407qka.15
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:27:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TF57F9Io+O0/OZ6gKFCnEeu96OOBr/TUAaoumLTsEF0=;
        b=e0pyZiKQfuHsWJx6oh/F7DKSnCcJcbfjJkhyh+K1RyHBz7ws/BL0aK4c0GEvptK82C
         EzBsZoWZ6aJdSQdC26S7eEISlFX9kWW7LRLyGY2swBFLlgQw3BdiMI1AfGkqX2WFN+Qr
         k270lA7FQgEeqpapgE4qWp+wdPIVGnMlOVLbI2HiZYG11RXec5pIzYpEy3Nw/G8eArYX
         2GbPAJYk6okl7WzmUXBoecmcEDfG0M32Ypngd56FcjrEeS59NnsJsz49bQ6kZcRj8jLY
         5wCNq7c6VxeBqq4QlAqD4cKHyd0ZR1PJQQ+AKDY31DnU19SjzvLGd/HARwhZgl0djCbo
         kXNw==
X-Gm-Message-State: APjAAAV9YBs61dT6UGE4VTolL/8Sat9RkFo/Nqc0b/B9IiydDsF0q/xb
	7KODHW3S0Iu8U8/QEpP3SagJG8OZXVhlD+YkiEEbXMWKQc7UmPc6fNdDmKE17RKIjQLeV/GI1HJ
	DVnw1Cc0btQGKRRpQQxilLd123t55OfNt8nfpOsEKQYigIUszPeJ3dL3YDa0PrqY=
X-Received: by 2002:ad4:45ab:: with SMTP id y11mr20366475qvu.137.1559536070268;
        Sun, 02 Jun 2019 21:27:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFZgTXhyrKpB6CPef14JLunfDiDEjEWAy5xxVyHiHV9vk/7ACtjycFxs9NcCruLCTM1tg4
X-Received: by 2002:ad4:45ab:: with SMTP id y11mr20366425qvu.137.1559536068956;
        Sun, 02 Jun 2019 21:27:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536068; cv=none;
        d=google.com; s=arc-20160816;
        b=We+vr7gARBoQyd7FojlkZWTfwvJu975fuhQK8QOVs4fdiAcqyzA7MBw2tl4ECTrYS6
         d/B3QPiWmUqVeKSORLBn52HWPLeJeA7jQmnjt7/8kCYYvk+esSEsISX/qP22vDTuu+fW
         93MOkqYaj/kC5tEd65izLLDdRSoR/4YB9vShzA5AgtmJO1OI5ppGAKnAITlLAYKbuVxV
         L5uaugVj3O2N5aXHhd+bAAgNXM1z891zpbM3JSVdDiY5xSWgptmzn5Mz77N7+vPcaqeL
         DlwtmgY3jgJmwgv4UtjfWhIYxnaFwBaMegIAYEaiFbirBTq1aF0G4YqOnJcnL67htRrx
         BdBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TF57F9Io+O0/OZ6gKFCnEeu96OOBr/TUAaoumLTsEF0=;
        b=l7eRV4fF+o4h2/S04ve+XIHmbksol8qPIQfF6Vjz4x9JKl17U3CaMakCLl6Dms7R/R
         boQAduLZUPtOGrMNNm2PldyaMPE0rg10tipEdyzmi5jYoakdAQDkTGI247DHSbnUJL9I
         odzIRnibHsJ6V9JjUl7ALdziUbrxqwtzwO3nJxDjaW7DBh+daWF+TrOAReiUeJbJUBEc
         QztqvYZ2Zw5vQ+QOrPziaMQNcr5U3eZBaJUzi1PKTflN/50q12rJXoJsUvd+6JVJZLsT
         ftgmd95NLOhd5bOH2HVc3yZFSFdVlkgrXBlj8T7uxf4L0dhak4gSlR78aKHpr2Z6txux
         wZew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="X/3bMxR6";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id 53si6281013qtx.195.2019.06.02.21.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:27:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="X/3bMxR6";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id B4C2A123E;
	Mon,  3 Jun 2019 00:27:48 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:27:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=TF57F9Io+O0/OZ6gKFCnEeu96OOBr/TUAaoumLTsEF0=; b=X/3bMxR6
	mB9zUnWZJzuM+Bprvs6pFmCIdoAyFvitCZBf/23ycwHUxne94eTRA+JPme/UrzN3
	XwciTBJUhW/wqk/QV/gdfq5jeav2AAMN1z3Q33gNKcCu7zSHpavA/ePKKGkxh+hd
	y3udydsyz+QrzS7ED8ZRu0q5uTNg3uB1XS+4OB65EetjPoSMC+MHqP+F0zZYMCAd
	o1xYRFrCM8xSeCJy8FLiWzbfit/TGx5HOE5TNeri2lACHTmXCr2P/MzBpi89M7KI
	iVlWWLR/pbU0NSBhnqVseiCGvtj3B1YbkJWUZqxwboo4ysHeEky8wXIuiXO4Vf9R
	1ZGXTPsqj1K5pQ==
X-ME-Sender: <xms:xKH0XMAERCeEzq0CjjY_ExdK6hzuP9Ra74cG2KiHDdmoQlBCgXJHaA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:xKH0XMfOFN1NEx3jDN0zQQ4azQRxya6CLS_q56luFsAwDT6Tdz7OxA>
    <xmx:xKH0XHJS3e5Qbf_7E8S4QPtKMev6jqtDyYod-n6GowzGpnHcznd-Cg>
    <xmx:xKH0XPdx_gZ40ItaFnuAlxyt08q4aoQ3yWUg-eJVtbvCX8E140L0Wg>
    <xmx:xKH0XAz_DA_oZkFOEe3BDpg12GiYMiwv9UmdZsJcmfBHdiXLosnHnQ>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7931F8005B;
	Mon,  3 Jun 2019 00:27:41 -0400 (EDT)
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
Subject: [PATCH 02/15] tools/vm/slabinfo: Add support for -C and -M options
Date: Mon,  3 Jun 2019 14:26:24 +1000
Message-Id: <20190603042637.2018-3-tobin@kernel.org>
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

-C lists caches that use a ctor.

-M lists caches that support object migration.

Add command line options to show caches with a constructor and caches
that are movable (i.e. have migrate function).

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 73818f1b2ef8..cbfc56c44c2f 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -33,6 +33,7 @@ struct slabinfo {
 	unsigned int hwcache_align, object_size, objs_per_slab;
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int movable, ctor;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -67,6 +68,8 @@ int show_report;
 int show_alias;
 int show_slab;
 int skip_zero = 1;
+int show_movable;
+int show_ctor;
 int show_numa;
 int show_track;
 int show_first_alias;
@@ -109,11 +112,13 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-aADefhilnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+	printf("slabinfo 4/15/2017. (c) 2007 sgi/(c) 2011 Linux Foundation/(c) 2017 Jump Trading LLC.\n\n"
+	       "slabinfo [-aACDefhilMnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-B|--Bytes             Show size in bytes\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-D|--display-active    Switch line format to activity\n"
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
@@ -121,6 +126,7 @@ static void usage(void)
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
 		"-L|--Loss              Sort by loss\n"
+		"-M|--movable           Show caches that support movable objects\n"
 		"-n|--numa              Show NUMA information\n"
 		"-N|--lines=K           Show the first K slabs\n"
 		"-o|--ops               Show kmem_cache_ops\n"
@@ -588,6 +594,12 @@ static void slabcache(struct slabinfo *s)
 	if (show_empty && s->slabs)
 		return;
 
+	if (show_ctor && !s->ctor)
+		return;
+
+	if (show_movable && !s->movable)
+		return;
+
 	if (sort_loss == 0)
 		store_size(size_str, slab_size(s));
 	else
@@ -602,6 +614,10 @@ static void slabcache(struct slabinfo *s)
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->ctor)
+		*p++ = 'C';
+	if (s->movable)
+		*p++ = 'M';
 	if (s->hwcache_align)
 		*p++ = 'A';
 	if (s->poison)
@@ -636,7 +652,8 @@ static void slabcache(struct slabinfo *s)
 		printf("%-21s %8ld %7d %15s %14s %4d %1d %3ld %3ld %s\n",
 			s->name, s->objects, s->object_size, size_str, dist_str,
 			s->objs_per_slab, s->order,
-			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->partial * 100) /
+					(s->slabs * s->objs_per_slab) : 100,
 			s->slabs ? (s->objects * s->object_size * 100) /
 				(s->slabs * (page_size << s->order)) : 100,
 			flags);
@@ -1256,6 +1273,13 @@ static void read_slab_dir(void)
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			chdir("..");
+			if (read_slab_obj(slab, "ops")) {
+				if (strstr(buffer, "ctor :"))
+					slab->ctor = 1;
+				if (strstr(buffer, "migrate :"))
+					slab->movable = 1;
+			}
+
 			if (slab->name[0] == ':')
 				alias_targets++;
 			slab++;
@@ -1332,6 +1356,8 @@ static void xtotals(void)
 }
 
 struct option opts[] = {
+	{ "ctor", no_argument, NULL, 'C' },
+	{ "movable", no_argument, NULL, 'M' },
 	{ "aliases", no_argument, NULL, 'a' },
 	{ "activity", no_argument, NULL, 'A' },
 	{ "debug", optional_argument, NULL, 'd' },
@@ -1367,7 +1393,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXBU",
+	while ((c = getopt_long(argc, argv, "aACd::Defhil1MnoprstvzTSN:LXBU",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1376,6 +1402,9 @@ int main(int argc, char *argv[])
 		case 'a':
 			show_alias = 1;
 			break;
+		case 'C':
+			show_ctor = 1;
+			break;
 		case 'A':
 			sort_active = 1;
 			break;
@@ -1399,6 +1428,9 @@ int main(int argc, char *argv[])
 		case 'i':
 			show_inverted = 1;
 			break;
+		case 'M':
+			show_movable = 1;
+			break;
 		case 'n':
 			show_numa = 1;
 			break;
-- 
2.21.0

