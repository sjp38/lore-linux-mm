Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4ABAC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6804A217D7
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kQ0Cxmjl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6804A217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B3806B000C; Wed, 10 Apr 2019 21:36:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 162D86B000D; Wed, 10 Apr 2019 21:36:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 051B66B000E; Wed, 10 Apr 2019 21:36:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBFC26B000C
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:21 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id p26so4074940qtq.21
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=OIxmTm8xZgvG60KTDwsTJTNdDttQtUMs47cFCOLCJZ9/KxcBNrRR6fNFoW5cfP0beh
         brJPqpLnvon/XTCGJhxIIrnWHjpTsBk6zjGjL7rYN8pf7bMRUZ/gVy6VwqEr3Kfioyc/
         npOUe0O3Hj2abP21/9voIUR7Rz7Q+LBrpU3cEMnk3b2us1TzCwf4WQgoFw8VaSZdH7Lp
         2W9bpeNc6UEYNXeVC3p5uSinOAfdgIm5npxXIwROz7u/UPyRuK3/8fHUoGVac/1YzHQa
         rUYUqDS59y63UU9ZS9ySA32KCqUn7JlIhaIP3HTE4phtKksvv9V6QOaPm1v+NormQTjs
         efXg==
X-Gm-Message-State: APjAAAVTfQBNpC3r9z2azuefP1BDF+gKAGOuda6M8TcAqga9nIu4YUJp
	TdFxF/ibj5h42qCrXAppDGjt3lJKxXay0TsFJqVEclkIBf5ZAGnV1WBIEJENm/8ik4VQXLAoXZ3
	VJ67rUvE28WlF/RhVz2kIPhwZuLANpaQ92GR0kWH4N4kc/vHiqBNmQ4nM1LGqknE=
X-Received: by 2002:a37:de04:: with SMTP id h4mr36074895qkj.196.1554946581677;
        Wed, 10 Apr 2019 18:36:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfqZLvrxrX23qosoNtZ2RNwoCa8WJ0ccyjrNTs4sBB9Hftr939iNlcOKIVNDkh/6tREZQo
X-Received: by 2002:a37:de04:: with SMTP id h4mr36074857qkj.196.1554946580770;
        Wed, 10 Apr 2019 18:36:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946580; cv=none;
        d=google.com; s=arc-20160816;
        b=rYCw/bsmLGUiRpO45Mm29fUXOrysMf64MnchgeeQpqUEg5OKJuS9x4KV2C6VsQUdBu
         lTMVZpX8PxEPkb0SdqTZnopzOUDjTZJgAlKvCAhB98PnEVk5idIRZSLOcb/TbOAA8Rmo
         DOb6gF92BnQlyoKstR1UMPha2GKlBO/Up0AgyUu26UGoYzxg/CdUiZj3xgq1DUmo8Xzx
         eqSl6m5xYp7ISeCIvT/hAjvtQKx37/8HqeLDFt28UZnRr0uEtzAxgPmRRd9fd3Gq17Nc
         2ol/laJRjIVB3OWD4HsgUcS7jJuXYvJQjHn3e1AKtGl9jkh3gwg/c68BEZcnnQvEnQDw
         e1Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=gMsJNAo+EwSxobDwHafVcIPNPZoP+YaCjZCXX9gftPuADa30YTKqqVeVfbRk8TOxcs
         /zD3Tl/q99whePNdXDPwzx45SLLlTE8ypHjgaXIdgMWwpEWFGPgG6flVEU9DO4mzV+UO
         XRRn4VHORlS/JzEjDtgMzMIU9wDSDmAzH6iMjaeaE4N3vjlcMDFGh/iJpSwLTr3E12w9
         dXWNMoz/Tlqu56Phz4sgp1A7DTaggO0Q0nLRPRA8qUSAX+oBmBFX5X+MsNwMA+aOwezT
         DxBz64Tmxsh4RPwsQhLdm45k4tO5rJvDNn4vgdZ5w4XxU/2i4y1e8yW4GkOHnoh3FkbE
         jJDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kQ0Cxmjl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id s23si4223807qth.295.2019.04.10.18.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kQ0Cxmjl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 831E790FB;
	Wed, 10 Apr 2019 21:36:20 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=; b=kQ0Cxmjl
	8dTQUILa8oACPG3p/uaxtPdNLrSjSP9SADowD78lfTBlKP7pQmJk81YwuUa49ZWx
	bKQygMv52av1sGOfF8wlUmnbxuEehULvsyH5F+9/pQk7XRWHvXkfIBSB5iJB03hN
	jml//5oo1S8TQhTyfixv7Lwf3HHUe4oZhtr8t0+nN3bnHwU1Na5pmkqAnLhwRcFd
	Y/vHgeyh/Zn5ExRDWdMNh1I9naRLHGqyQZAEkxD25Ee7QuK/4QCa2CHXhArK4L1L
	JKpmwsNcMy0XjODVdV4hxqLXwnLenCOFbm1Bi3j9o8LyM1FMtw1IASJ0oRXVb9T5
	DYcZtRyp4yeFUg==
X-ME-Sender: <xms:FJquXHLwDksAUVZfQZutN9E_FjVPWvsEsQobq1Tcky7WhkZo2l665Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:FJquXCT-mVnuvsUej0R3G_CCrmy0LDGHmWblwcs14cHiyulns9JJtw>
    <xmx:FJquXCEK8PHeNQ2-W63kwf4t6eawKwe097L6TwP0OYIzDPENL730HA>
    <xmx:FJquXKHgGV5H57rpkO7VxrN9hcekfSI9mShRanbxo9t8wk5i6uOq_g>
    <xmx:FJquXFaAS86MOIA2oD2s8X89YXgM9oX3mUCSnEpUfNrLMVDM9TFSwg>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 90EA1E4210;
	Wed, 10 Apr 2019 21:36:12 -0400 (EDT)
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
Subject: [RFC PATCH v3 05/15] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Thu, 11 Apr 2019 11:34:31 +1000
Message-Id: <20190411013441.5415-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add output line for NUMA remote node defrag ratio.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index cbfc56c44c2f..d2c22f9ee2d8 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -377,6 +378,10 @@ static void slab_numa(struct slabinfo *s, int mode)
 	if (skip_zero && !s->slabs)
 		return;
 
+	if (mode) {
+		printf("\nNUMA remote node defrag ratio: %3d\n",
+		       s->remote_node_defrag_ratio);
+	}
 	if (!line) {
 		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
@@ -1272,6 +1277,8 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

