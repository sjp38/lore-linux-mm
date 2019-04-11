Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7302C10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AB2920674
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="M1ZFmbQB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AB2920674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2762B6B000E; Wed, 10 Apr 2019 21:36:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 226A96B0010; Wed, 10 Apr 2019 21:36:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 114FA6B0266; Wed, 10 Apr 2019 21:36:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57006B000E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:29 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o34so4132193qte.5
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=FDt+Hyutgv6iWSWJcUA47BQeTgzfgDqaxIkjZBOgaMBswLb7rcdOKmn4OsQGBYbXns
         sDPsxaSs5LRRxBSeDyn58Kjl8+qVLdw/tDQbmFbtkw5rBlyUzipoEDH0MufIqqnnvQE+
         jtgzr9ci39AW0lLodTbv6Id4Hh5lb/Ovn99XTVh3qwYh+8ZgPEw7AQNLOgTo1rnKUnho
         7BxG7Fznndz80oMVNP4eHKIXRVCOp/xh7Hj+IC6AdQqwuw36Abzo4AYHo3tkJFm/91Hi
         aSdo4O5AcroAC09mU+rN3skAUavyqAOadXR8NB5BqvMMCVliXAgC88UylF7hpiFAcNF8
         JKDw==
X-Gm-Message-State: APjAAAWBNlMcez1gAqlbvZEUPuOnjHxyccactqTxffG3kXsjwQfGO1y8
	f1J73QOyiDPfV08AyqMkPiBtN79Tl/d8BLEl/6v9q8GHFyvh8GjaLNuI40hjIzOl5Qdx8fJCWnT
	pRxeAJ2jqxCKDT9SkVPy9J2d1Bvevh7fStxrZqV+7VWirMdqlTY04M31sR7bAIhg=
X-Received: by 2002:a37:4a83:: with SMTP id x125mr37951258qka.146.1554946589684;
        Wed, 10 Apr 2019 18:36:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhwikyaeAhAcu7XgW3T2B+prxD946Sheefm0cKJ6/oM88sbnd621fSqPkRjF60fL3OqNQ3
X-Received: by 2002:a37:4a83:: with SMTP id x125mr37951215qka.146.1554946588706;
        Wed, 10 Apr 2019 18:36:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946588; cv=none;
        d=google.com; s=arc-20160816;
        b=J0fgm6LzidZuYGaU/YfCHJcT0iqzVcjuCQG/SVBdzrblOKFPluE++WA75GeMYRAjBu
         X/DuW+kJsMAp3eedY9alUO+TjNVxM2PrLbYu05/KKfsOj4pyV3DZd0ook0mK28xyxTlK
         svRgrkumaG0Ta/fGdH5o1UkrBNk8DxcDLTHxSmkS4ycddQyVj4J1zg7HG4Vw0EYGcVSP
         3ncXW//Vxp/ODfGdIsbpV3HzUOY0U+gRVIqg8RJB1wiUwupNPc2nD7mJm1pPADLUy9IG
         ci8FDJLTCNqG0s3Vs7FLI/WwQU76juH1Y8D8zsVSPYVbxQFbz64WbzCyxGUATfCiGENu
         cvRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=Epmvvkf8Knvk51CP0nPytHG31oQ+nuCmQSFFACuSljcHo1VEFrqxXkdSi8u4CfPbVq
         EYvWD3iE9B58O5ITiIJH7613VtUonQmvp4i3PDvBhuv9jcp4+XvKMv2xFvXP3foswxv/
         rV22m7TeLLzYtd6ijr6Yt58VUhArlhYaX46XoMyAw5SFwmkwBmS5iyBGoKMIVOpa8I9C
         V7JeP7bkAs4wtY++FxO/HAZG8mQzl0pDy4MIJspg/exk45t3Mqa17GhL859tlrcDo5HH
         APVMUXx9KiG3gFBAmmPD/VNPUnqgmCUaLY8vMejcL36M7DJE7i1I7OCq+YGRGr8PNnQP
         qurQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=M1ZFmbQB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id z7si7795541qtc.358.2019.04.10.18.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=M1ZFmbQB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 6BF279E0B;
	Wed, 10 Apr 2019 21:36:28 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=; b=M1ZFmbQB
	l8VrI8YC1Yy3XLxmknffwzRwR9dHjgdPqNw7SW5dlaNS06jhwH4zNzXuVthx2fUL
	NRDYLjer9oO4NVBKj4CkR4392zAiHiB1CSqeQpyjzd9xALYEAEjBq08LklQU16WP
	YVjqcAE4ZlQsnnzyOLQJMwApnu7pH2ksZ0cu+xL4LhCexZqq4bfzysRBfXQj8rpk
	sPfdeeDiUQ913PZtQ2LjOjPwFjvBO6QbwLUllIaWdGqo44RTK3xDmmI1SN8c+SvS
	L5QNg82eT5O4X12af8V/lR5bfVDL37byQhJATJbiTNFxdMQVrVlN1m/+Z4iXP4If
	RGXmXe7atGnwYA==
X-ME-Sender: <xms:HJquXMKT8uhJq3BBk5lrurL-MsSovBKQDM2154cbIy7lJgAyUKryUA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:HJquXNGzGc9wrmZaTpOq6pjbMuYKLBSTyyhEMtpTiL7nwaEUTT47kg>
    <xmx:HJquXNBb2CYjqMGh00XZ4u0VHgKiH7WnM8KskqZYHSiIT7WIOn87iQ>
    <xmx:HJquXH3B3Z2scJ-2amYHQ3DfLU0sR842_HJ6eWIHzqu34qifbeLbMA>
    <xmx:HJquXNuI0zNE_noLq1BZvCfUftpY5z54KXMZ8-PIY_Hwupo_jcbJgw>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9067EE408B;
	Wed, 10 Apr 2019 21:36:20 -0400 (EDT)
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
Subject: [RFC PATCH v3 06/15] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Thu, 11 Apr 2019 11:34:32 +1000
Message-Id: <20190411013441.5415-7-tobin@kernel.org>
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

Add output for the newly added defrag_used_ratio sysfs knob.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index d2c22f9ee2d8..ef4ff93df4cc 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int defrag_used_ratio;
 	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
@@ -549,6 +550,8 @@ static void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->movable)
+		printf("** Defragmentation at %d%%\n", s->defrag_used_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -1279,6 +1282,7 @@ static void read_slab_dir(void)
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			slab->remote_node_defrag_ratio =
 					get_obj("remote_node_defrag_ratio");
+			slab->defrag_used_ratio = get_obj("defrag_used_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

