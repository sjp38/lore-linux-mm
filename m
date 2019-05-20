Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29941C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4CDA2081C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GbbDnSgm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4CDA2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 730BB6B000D; Mon, 20 May 2019 01:41:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E08E6B000E; Mon, 20 May 2019 01:41:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D04A6B0010; Mon, 20 May 2019 01:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFDC6B000D
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:41:55 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c48so13233296qta.19
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:41:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=eXHm4W/drsal867H3zIYC52YFAlL4avr+ytjs+XJiivHmUOPnfA1x09vWSqO87gbXl
         folk0bsK7GrppNu+GqD4bd55QVBDpFFaJ7XRa15M7RIBnJmYcwrz+ZQlc7Qe3VeUngu/
         uqOFyhSzjf8cF+UO5/oCdA8Mb7+RFdUZtaMw3mmdeMY3TDwVHkmxFXrgAVRFO/qtKVy2
         d8fvV0gNInnbtL4OuMd+koYrH9/MI1R1BXX/ChGcp0vawSnwQDGihXu6P860HO2uF8v6
         CATFt4wFCC1ye8nj6CrIxvicvkXxWOO8kGEOOmlVCzhtRtTKmmr3sNhZQ1kqmivVlLFQ
         92Pg==
X-Gm-Message-State: APjAAAVzmfvgBvmGYINammrje7YHlpZKGrsVvsZuKLY8NMoci5i7rrtl
	sKtih71Pqe1YyvCgHL27tnS2WnwxWF8OvCpc17bMhSZ8HUkniwHytipo5gB4ZlCsRSgs1b3LrNY
	nZWZwuAzypICizSSfTbVhe4F4Kgec+ilaJDLJCK1W7zP71bQaYAeXWH6/ifMEtmQ=
X-Received: by 2002:ac8:198f:: with SMTP id u15mr62500907qtj.153.1558330914955;
        Sun, 19 May 2019 22:41:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAdzbmNppiuSE250qfH5caUJN41q9Pjg72Aa+UjT7uRokzzYPebEFgH32xInOzaeK9vjJH
X-Received: by 2002:ac8:198f:: with SMTP id u15mr62500866qtj.153.1558330914112;
        Sun, 19 May 2019 22:41:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330914; cv=none;
        d=google.com; s=arc-20160816;
        b=mrR0CYUCZ63GlSvg8NxP24gFvlSKU5fATYsG7R31G0uuBl3rTCBYxi7oHlENfP8uGw
         Ii8ingkaMFGfIV/QEIjpNJrT2sKwcQbdc+CwTJhAANnB1r5ZlxYK0eHT6NSn9t8AWfBT
         099vBQQnhBg/3jl6xAooRfUbpMtTGdCSFoYw4NMZ2HPvAWvO1h31ZTSC4DGzexFqaMVz
         pQB7wb/WNMg/gB0/AMp4UC4WDz+IxQiNEJ1db328/jtPQRdLmaxa1v+lZE4HkGpNLG9e
         qxLrPy1YU2h01tQq6xbGVA2/s0d3Mdy89rVZlTZ0kdCsb96MT6mf70f6e/G4cio26bNv
         7uNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=fFytD07fj8O2jrTJlG2tnlu3G8XFttJPbIQ/bPJE+wxhz6Hp/plX5xx+GUt6x3Wzp/
         ZKmWUoIU4zLNz0mDSAJRpmgqdVFv8bcx+Hft5oLehzE+SabZ6Oum1qUErVUqmTplPJj+
         B2Jtj6tjm7Be1BzR3pHQcxBquWGYlvAhc1WWCSGjPoKSh7CFljb7IkUGJ7FEM1Besk+A
         ZlqXY16817u40pjzvdx8oqu5gLqjSZlM/U1SzSw2oGDc4LoG7GDbmbaWKo9hRsmjXTUx
         klTguE5BqWHeq1x6o3CWj56KDzFSKbLp5A7TlP4ufajJGHNrzaV4I9EK41VM0GOufmMh
         k1jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=GbbDnSgm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id e12si592470qve.129.2019.05.19.22.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:41:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=GbbDnSgm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id CCF6846EF;
	Mon, 20 May 2019 01:41:53 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:41:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=; b=GbbDnSgm
	0kVZe8RNuEifClhviafSdIf6NVtk0GruV6Fn/MjenuqiXRGGoet1W8RyBsiTx2eJ
	KR2P/iazreJakJr9AVkSEzJA0WPSgdvAmKi0o6iNQjaVP0OlKwwfmIovSTbN0Yro
	HzUflNj+0yAYXx+hM1zie5xJ4bIc/Sn2+b7Hdl3qbH21xyoLdoPTB5JnAUyINPjw
	l7Iw5+ueEUGVCwHQ5nIJarApG0QFmrgTDpzjo+8+cypGNr6l8XmroCDGtVYwVDGQ
	gQLh5ZclTVb8T/VRLhmSSPQRWUKHrambSidQjQoY5/7RG7+bOd3EQSUQdSuzeOXc
	lJN1JwWphP9kJw==
X-ME-Sender: <xms:IT7iXHvkZzZJ73Oh9-8Z9lr9XbloaLxSyeWNikULZTiEvr9cADKr3g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgephe
X-ME-Proxy: <xmx:IT7iXIt_iJeH1nYZeRk0ixxheLrYAYbiuUgTEWgEtjttKETfUtXBZQ>
    <xmx:IT7iXDrjB8CwR9rQNT6_bjXJr3AHTq2oCm7HlQn31mPtntzTfxO9Bg>
    <xmx:IT7iXKHAZ9GnJXF5JWy4NEVuQPRXhv2OgNBHuAWwZXHLPcBpw9vfbw>
    <xmx:IT7iXGuT5BhNNhBLBCeK__Yc45ySr4EC0Zh8WoWJ8IAZyeW4HnxV6Q>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id AEB008005B;
	Mon, 20 May 2019 01:41:46 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 06/16] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Mon, 20 May 2019 15:40:07 +1000
Message-Id: <20190520054017.32299-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
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

