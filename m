Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53574C04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04BA421734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="G/Duqu6R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04BA421734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A61BF6B026F; Mon, 29 Apr 2019 23:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12816B0270; Mon, 29 Apr 2019 23:09:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 900106B0271; Mon, 29 Apr 2019 23:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 705116B026F
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:09:21 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n39so2776291qtn.0
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:09:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=lcvJv7UGuJkFVkknd4VfvOV/45YfjtyDZP6dQPUSq5iCpWlJSahMrZD0UXHWsPYfBZ
         7bE8nHoB4h2NWzEp04TovBQULwCr9qGcWiJ7VRgxyjsHyTjwmr9A6qGanoYAXB0qpqRA
         4GB6bkRq7QzgCN5WW6cpbEvQ4lemMB3i+n41mXvz8wLYuSEFhHhs1Whoy2knKnTPmoR5
         gWgr5AvC7c3zJKny8zfvr6BeyTtktDpyXhIjQT79u22ZvGCKlbrBLCUBE/XIBY+cznqp
         PnKnCIWyQbiELp2OARBw0iumBqSeo6xig5A74vpsPFYiC3R+HCwicW+8ZKSjOU2POukI
         jgtw==
X-Gm-Message-State: APjAAAV3yFkK/nRpaQACIOlrPlkP7omFsefN9BGukhwCIi14JgKOSDsv
	F0oJCZj4nDp1f2Ry/Cr/ILEh6LPhcq7YCvEoXQzCIxym/mIASanxP4JwMBQkRBER+bFzfxv6S68
	gmpdXtKwVrKt+fgG3/x5o8lqOWbxwZrvEeRqkdFjJ+0GcmYybfSxtswlTgAsmASU=
X-Received: by 2002:a0c:a944:: with SMTP id z4mr36717760qva.119.1556593761245;
        Mon, 29 Apr 2019 20:09:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfh7k+3f36oNPDdtHO08ixPShm+jf4YPRDXoiTole08whBbP3pFS5/Mp1BXB+neCC+B7o0
X-Received: by 2002:a0c:a944:: with SMTP id z4mr36717734qva.119.1556593760417;
        Mon, 29 Apr 2019 20:09:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593760; cv=none;
        d=google.com; s=arc-20160816;
        b=PjkwwNogL9+VNRCgQXkCZ0BuYphxv37Aa4/OMfn1kRQctpZFejFIseXNRj0u/0sBnT
         HYTh1H73hSGkGdcRYw1hQLNboBQPktqGr8w9sFYp5fOCVUPPgbYZJdRKlW4k87tJcWWX
         hh2bttY1LFCPEqIXGJHfxW2oDPu5VldkqNflb88afRpPMjcmxBRHzJ/PjJNHqAJJvzuP
         xPFWgxN/DjhscqApqJHFoTRl8VZHdioxoHTjr4AXADtHKJkwVBzW5DX++ZoWp4xZjdvD
         BywT9k3EWGSYvGoT4ogKzPHbLChwS9gBX7wnCBwciUtFkkEGxr7C6MWK1BIGuXyOiooQ
         Bxvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=;
        b=1C0PRSWTmDUY5oMM97/PYi2rGxf6rgwnAtZpTB2QfkySA/uWtJnwtWpK74JjwrKUXc
         4+GnVRE9UOdBia8VjDmHnLaYCgLTUUBBVFcq0+wudTQM8bU+k/42T66YGzggDYSvQo3o
         kuhap+bDDSgi4W6g3s9mxAEC9kfGnWfGCwZmxocI9AISL2s86Fss5iNuTc6eYNuzp46g
         2VoEkl36byDlLmDyXWbBCNNO4Y+mVDcOEHfPI2aPd0y8i5MFCxk0kGbLESPG0P3PmuyX
         a/DWCDz7mxe4Bltz6qk7mUCgOohgl69X92cj6mmSzIrfwkpY85MtQ+aRbAK7yI3gucRE
         WJmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="G/Duqu6R";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id g123si1833785qkd.172.2019.04.29.20.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:09:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="G/Duqu6R";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 269D8266A;
	Mon, 29 Apr 2019 23:09:20 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:09:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rfKadsTflryLW7911DaQh925XQ0k2Bp3gi/G7eAxyJQ=; b=G/Duqu6R
	IX98r8fGsTHboSiPaGfc+oXz7F7GTHMM+xq5e9jY+x01fnRalMqbv3hYxJYD+uZp
	In3DEYyoYoQWtxbp7nwkNfxwIzekJplnUFlExEXLK+gw7KtIF585kzwLTEcCGZ++
	06i8aJw/HpRVmjOrjZ+zcRByTtIlESsm/K8avMuIcAqnKHMqEZZQepONBedgJ86m
	A7gBb+MrF+Uim8l1IKY6ZYJrysjVpKY0S1Q/GMa3HOeRPYOcXGEtHUUvCI4zAY0K
	wtxNew6HgyxMWft46wy4hw8mz0Tw8GlU5LZdVhYFzFoI9JUZYgGDk3KA0aqvocjE
	QNmgcFRnoU8vHg==
X-ME-Sender: <xms:X7zHXAWpZWfwDdTcRbonp-iw1WBmGAsE95JETzgq3DNQBIAwY8p2ag>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeeg
X-ME-Proxy: <xmx:X7zHXAb9EJfgs0IIzDk2InQleLnEpGTHFX44RSA9c2Kmdk9QpI3RLw>
    <xmx:X7zHXJ5dnerfV3It8K9-H-nx-0rwOSBI3EHpoVHRPzHSZhk54UmYEg>
    <xmx:X7zHXBzswA71xafmUYrxWnjFSPX09YhVCkksYucpAv_Ur-zrLsfAqw>
    <xmx:YLzHXNTk8x9g-EuRTTWhzsFNH42LQG0MCSp2jhvFxrvKD5TxSBpgEQ>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 77B05103CB;
	Mon, 29 Apr 2019 23:09:12 -0400 (EDT)
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
Subject: [RFC PATCH v4 05/15] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Tue, 30 Apr 2019 13:07:36 +1000
Message-Id: <20190430030746.26102-6-tobin@kernel.org>
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

