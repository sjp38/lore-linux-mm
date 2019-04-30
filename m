Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8B73C04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:08:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D3DC216FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:08:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="j6+4FHAE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D3DC216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0030A6B0010; Mon, 29 Apr 2019 23:08:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF4FF6B0266; Mon, 29 Apr 2019 23:08:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBF0B6B0269; Mon, 29 Apr 2019 23:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC28B6B0010
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:08:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s70so10745304qka.1
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:08:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=l4H1Vio9dCuLy+Akq/ieMy4MKL2rJ+5UoWzC5WfdsEJvSDlnXbUYgI++e9rR0/Ufqw
         SzZ/8WNy0/CVfpaHCGkxh/biyTczlN3+G1Jk/U+aFZ/L7jCRBWsL0cqBXTgQ98dUBW1j
         iy584GAKreOFjSyDXYWilA0T/HnB9uuDYBG/4ueVnCMjbLc82P6qLlmb69BxGxdgXjza
         fzj5sHaLO+Z290BWHdyXIjcQYgtUqWOVIEktb89cv0Qx+moyjc1YpK9Mi/BFsmySqNPk
         AoMO2XO4d+d8w3+K+jEkkm1Iu0GmRq/keBsfyMlwUPNtKgp0wNX+oWnjIbWMOOS0fMDI
         5lUg==
X-Gm-Message-State: APjAAAWHzcE5g3nAjrppMJlXioYQ7rpt37pBGO78xflM9XP/lUIcig+8
	OvkEbf4usFlHaXL/FrGH+SjUVlNL0TEHQ5tQKjmjb3FzoytJJBK1H2lgBm/dxKpNISRwQlc2Wax
	Y/iD4TNev6Vq+Bs7299nq32yNN/U/r+TkPwgWY+F3ow6XAZRIW/tpxcwHjTg1XTE=
X-Received: by 2002:ac8:3868:: with SMTP id r37mr37307332qtb.199.1556593736482;
        Mon, 29 Apr 2019 20:08:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4GLr9KDwaDihb781/M03Glr/pEg/NC+Mrj6OzmwBP7ur9qGjmTe26+PZdsiCpxq6jfEe8
X-Received: by 2002:ac8:3868:: with SMTP id r37mr37307289qtb.199.1556593735216;
        Mon, 29 Apr 2019 20:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593735; cv=none;
        d=google.com; s=arc-20160816;
        b=Ar0kEACWq4Ln5IRt+4B9cy5exCbh5CXRR0jDWSzFIzyVbuA2+alMmk4WwW0NNnTNvP
         1AMthFnDCoicRm0lf8RCXGVSd1TMeUpUxMpm5BiybnHNJSG/zDq5KFglZgfZA1IpLhO5
         mThUx2om3vP9i/G8UQcGq5/rB3dKSZTaD00OppvlExyp5bLyCnghUaxwyfEBF7spBdyo
         Foa1NcBrHCZ68ecCLMERahvNI17xjvyY7LrLO7lUBxlJ6Sgohh38nvVMI5sB1QHZmxxD
         GHY25nd4gppYeqGTLkEMLs9umlbH6tRhH7UgcuXXHafYHLVbrrPRAsjuaFlQXgKjvhfb
         0tmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=EQpZXh3N2/aMYwa+lEPqNBhKvmjTiix9nXayxK6E1s1GXsQ/9aGSA1XwRMUt+9uyKr
         71zkWwzRgJXyocH62BkBS2k0W73k5wWPm2LnYZ+1puYP1/cpJQptIJ2IZuJSkuSKQpqf
         KWM6Cs7XLvbUzEr1TYyIZ7i4A+5EcRQS0ErIm1f46egV2Ea5iTjssFz5+EVoYzo1VuZ1
         y9jJOwBrA6VdCwj89XsIv1KRuXhzwTMefocthIvqlCYE8BnKINLLM6MhpdcEL0KHW5ee
         yShKyV7oIOX71L6t5XOgH2qacMzsbyrWukJ66IOSJ2VUvyHqhUEI6xX91c5fIYeA38sB
         aTHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=j6+4FHAE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id p27si8572266qvc.166.2019.04.29.20.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:08:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=j6+4FHAE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id EB66B5286;
	Mon, 29 Apr 2019 23:08:54 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:08:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=; b=j6+4FHAE
	FVM8Li58NZcWW6HLlE9bl9fVj9deVbeq+Jxjc8W0HH4/aQ6y4q8QepnkNhVe78pi
	/biDsaZbgcybTFU/OokAdYlEJiQ3BjySDRQjwsyDtEHzv3wZAFeqVoVqqFxiyrZw
	Fh0VSQXbrxiHBNEP02LAzOWkJWkulDgZ/Xg6sKV9S5ZLrf5h9ZfZcrZzLKJfcfFk
	guHwnmPVbrN3d96RTt3m6egGtUUq06Fmb9ypLapjBnRxm2tN9U6kaFAtNqf6qnPp
	ND1JWNDcqiGim5drGe0p40+254w9D8NgPXf7K+jIjDYecXZskVwftSTcrVoy1Xeb
	Vcl8ZCFCMSEmjw==
X-ME-Sender: <xms:RrzHXAPEBhCpNjCXwNt0jBW2aqTaJsu1NQb5QmOEilZ9atFLj-nR_g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:RrzHXB5G8MLDJ25Nk39dCyJQGv8lb2DXgPQyQGb5pupr1u1FuawfDQ>
    <xmx:RrzHXGRF_ZQ-jDvN86MxcCg8fs88aswTX2E77CFHgvteghdNY1m2hg>
    <xmx:RrzHXOBnLKsBdFFAEHczuCctWFVyd3ZL3YjnMVDfCx5wSFwpse0T4A>
    <xmx:RrzHXA54wqxBOUYVI-Nae-eFnohIcFmOvxSMZniT_iRY8CO50KcmzQ>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2CB2D103C8;
	Mon, 29 Apr 2019 23:08:46 -0400 (EDT)
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 02/15] tools/vm/slabinfo: Add support for -C and -M options
Date: Tue, 30 Apr 2019 13:07:33 +1000
Message-Id: <20190430030746.26102-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
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

