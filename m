Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A49A2C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473B92146E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="V/Y3w93P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473B92146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38EC6B0272; Wed,  3 Apr 2019 00:23:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C12346B0274; Wed,  3 Apr 2019 00:23:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8F86B0275; Wed,  3 Apr 2019 00:23:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE346B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:23:00 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id v18so15706383qtk.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:23:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=LueBaAUI1iE6FSybqpbGnejtYEdauhGZARUzXb2j6OoTGJ5+P6poKaWG1FgIjNy+5t
         DJQAImHV2kHEgJyZm9IGMsZ6E29BMwm+Br6eRpvCVvJuZLpludW/owPq+egVfm5Goqc9
         TOdGmZndOdwsSCulaX19JwzlE6Q8HszH3EAK8VyIiN5KzTm1hRVFh5EAh5sUxH+kXJLp
         ExIm1Y/WC3jdbc2/1ua78yJHSLc9B7CacUA45fO2lCb/MKQF7PokHFtH+U/y52hn4Amm
         PTcOWwecV1UkoamojKozIl1SSSLZbIS/GE1I1fJTn835EiGo0TgunjuDCNoHY2IF/n9w
         Ow/A==
X-Gm-Message-State: APjAAAUqjoqUglO5NCvznIRA1WBFmEUYPGb55bdi4qReJnPxCfMLMwBI
	Q5jmc8A70GMVKsxTcsiwOqwTzhL17d833XAKzvBNmedsus6GiyeTI1k1L4vCARwGDPlzHSdiI/U
	Y0lcCIVFf/YE7hVDlOBbKsXfTf81zPNqxB1NBiWPrCqct/Q4b/rch0r7rCdTTF48=
X-Received: by 2002:a0c:e587:: with SMTP id t7mr37965219qvm.114.1554265380319;
        Tue, 02 Apr 2019 21:23:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoPrXPc1LRgN/bxCcXBhvShRz0TvCdJn+K5iARaPh1LfsG9lcJGtaJeo2rRuqR6I00BhPv
X-Received: by 2002:a0c:e587:: with SMTP id t7mr37965175qvm.114.1554265379057;
        Tue, 02 Apr 2019 21:22:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265379; cv=none;
        d=google.com; s=arc-20160816;
        b=tjK8ROP8lzXRgPDs/8JG0vtu1+qBo0nvnmr38g1NJKsF0J5oR4ysOyoW+xBTAmZLXt
         r/tvz1XyvsJiwhr//uLXOz3r1oMVNiYaGlaM5RVSHhC5n0Iy3UH275lZDbwPQuut9H4y
         Ds0JLWaUCcTmEB2qys8BBoOFCPB4HhLbIXcdOHCFOG/uDxHCaxLktjimYb6JJ+mV719g
         5K/S82ZvBz6Y7XyC6ZskFh5oCQ2GzGkgOUTH9QDZ5pvxrwYrSZpG3ej7UFDDaS9/wgTu
         sWliAiBGxOJTQmEz+/f5xTYW/graA6lNwr/bjTehbgd9LPW4fjzadsldyxnARwhjDTZY
         NU1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=Av8ReY6h+lNYDEdG+wqljtjaDHy3bcaMkdmyfuQHZerfAm+kSEdOVMsb9R88Kcf11q
         pjeBHw3hhFVdWb2kga++cKbdjR+E0uzcsU4+m4ebpWTvj6FE69i7EQdf23mZzUCV8nu0
         EYkHehj48GkimcRhhrFuOGTFjp2UYRJpy5JmWskyZmAfK8CGajL1bHPt9h9Pg1uPgW/0
         5r/diwWPmdRlfG3/kPPXXBAyxKBzmWoHSCqwzK6EV8SKeSZLnddSbRNL96sDk9x1wkxz
         sTN26FQkzGGb2pFZ2OadjAdjiPHfj/hVKSlXMiLu/giyQdsg9tvs3PPw2u5e0lTkQSXh
         s2Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="V/Y3w93P";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id i12si2734380qtr.73.2019.04.02.21.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:22:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="V/Y3w93P";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id AE48921B24;
	Wed,  3 Apr 2019 00:22:58 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:22:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=; b=V/Y3w93P
	eDWWJ0zDKkgrTdnG9yUUrsY+karzjq+Fn9idovC3n7/bivCQ7R1bsVM2c5YGscG8
	sR2mhr+En1765Mq5xj+9KQKGLCVvAOGhwa15dx6UudoCxQHsXMVVuFZP9u8Ur/Cg
	LN7WzigSvztiJ4vcOGkHnTyf2WFc8d0DGepG8WyyPxmN5Eiz2pPVh3dFmdbibVL6
	6oapkwkiWiJzBt64IaSFbbr/wyJFPg2DqNMe9yE09bSc+nUCgRO8E5Bjq2kCcaIf
	H+CSus/Gw9OONyrpzMtxWCC6If1SeD25wsJ7SFu0lZzXvl6aAmSE7Jqb3XQAGmdN
	zUjMb6akz8gRCw==
X-ME-Sender: <xms:IjWkXMZrz0012enT9vsIhX3oX5XzbuQuaLvS4PH2VlEDag1fYiyeZA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedu
X-ME-Proxy: <xmx:IjWkXI0ZnDx3MLVwPYPvaN9LCFHaMpAoPXYDXQr0dCsxMl6a6z_OtA>
    <xmx:IjWkXCXHHQZ27KafH2DTennDlK2TvI83TiT_abenRFB1PaON4UdGgQ>
    <xmx:IjWkXDv9EyKJzE8s1Wtb2R6mvilqEVA2kPMj4RBEGRcMURniv5OxSA>
    <xmx:IjWkXIQqHnQYCIalwKV6mxwIY5hUW_37YM9Bw8U5IwrBOoJo9ionoQ>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id D33C210380;
	Wed,  3 Apr 2019 00:22:51 -0400 (EDT)
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
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 02/14] tools/vm/slabinfo: Add support for -C and -M options
Date: Wed,  3 Apr 2019 15:21:15 +1100
Message-Id: <20190403042127.18755-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190403042127.18755-1-tobin@kernel.org>
References: <20190403042127.18755-1-tobin@kernel.org>
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

Co-developed-by: Christoph Lameter <cl@linux.com>
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

