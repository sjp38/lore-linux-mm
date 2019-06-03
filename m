Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 467F9C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F24A2272F3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="IoSRBbnW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F24A2272F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A234C6B026E; Mon,  3 Jun 2019 00:29:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3F56B0276; Mon,  3 Jun 2019 00:29:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C3E36B0277; Mon,  3 Jun 2019 00:29:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E56D6B026E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:29:03 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h198so13784781qke.1
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:29:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ewjgpKzrSyNZxS5aNItsJCiFiD2mCvE5h0lTeGrIDUo=;
        b=CT6oh2n5Mtz0YKGx5T1nhXeBE/aPVOnmTcc2lfH/S93JISjl8dUdUC+4cayQcl1uXc
         cc+lb9qs5iLGWxAnaSBrlsOfvzWIN/VBGd6vWofsVL+diUHRR17fRnNs1zHLJAWeocAc
         AsGjl1hxTavXgtWVauKrVdi8GZ1vUbbaax47rqy0nxbnxQ6mxW7Iq1964r/pdJYi2Emg
         RagYyhEQ+ML2PJN8h+5QjgIk7Te3vROGAUejls4qk25rpxxBHKXwdOvhxhSZW9AWB3d8
         ETIdqiCH3FObwrYuAEuN4lEM4TsrNJevkUS6N8IE3xa4ABbQ3NOpou8OCBIiYs2DH44/
         50CA==
X-Gm-Message-State: APjAAAVqpVyghYrpvrYxbTBevIoCE7AkPkfYFQZf435XMwgqN+qUglP8
	M9UhruU9C442Wk7ddEfEKGJwFc0UVRVfX+jAYsRSRRWlMqKaHhyG2pMY5TwkCd4Pj/TZA9Olxmc
	umgfZ0wdUEXmhdEg+EiDqjSBXW15tnMRd/rNQeAjAGtjCauBXzGI5HUuAZtsn/s0=
X-Received: by 2002:aed:3145:: with SMTP id 63mr21077381qtg.184.1559536143226;
        Sun, 02 Jun 2019 21:29:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLXV+YZ140LvJuhSyOLQckLxqosJEiPybOM32rNv2PERJxdhOa4RQtMARvndnARVj6CLEZ
X-Received: by 2002:aed:3145:: with SMTP id 63mr21077343qtg.184.1559536142267;
        Sun, 02 Jun 2019 21:29:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536142; cv=none;
        d=google.com; s=arc-20160816;
        b=WAm7yTIVA3qe1Uv6fx8zkKBktCAFOrT6ZxcV4THULwUJoz4bqed0WCsmInYyYND1IT
         +AleWDBffOEjJRulIXu+1jPxOSgMEIMcIF3RqBP2JT3pu0Ip7XST+T2ALSA6rxWJ4lgc
         qlUlYglgtksO4+yTTkwO1uve5wChkGDV5A2QDPFUZMWulMZN5Zgc7k/bIo9CCKzLqlgo
         eY7bmbOj3sRPLfcaWkBlrncwi1WWvzJkJ4nRKMPM1wubhU2NQsHoUgkfr12pNaYoYhg7
         tz0HCQbjUqxx/u/kzvNA+VXkdC2jQsyo0qDQZ8kBmmJN//vgGZ2RYXR4al3OdgUgNsQA
         WoOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ewjgpKzrSyNZxS5aNItsJCiFiD2mCvE5h0lTeGrIDUo=;
        b=ZPQ1nCaruIaMFq2eR6gW+4MMPVxuhesmPntBnfSXzeR73384khXXoxJM8I0DXhGmuS
         zGdWtusiQqlWlFGQreeofUp5z8P/FYNd0bmUMkza5nHVnUyXJhYTMqgyYwHuXbYuHYvT
         eSjbiY+PTCLKVSUPRoV5hskhMxGi46PiSazEnm7cEY4UWuDwqpXJcbTgA8wfbGFrpToC
         2CGG8+QLhfQbItZoTTDBI4zwxAtsRzmVpFJtCJvk9v1CRfLibrtN+gLqGItNvsXlNvG6
         s2m9SF9rIO5+kzFUNbAaa6uyMvpdlvxbLAEIosG7K3E/n0kdgqp81/0iXK65ecyqvuFX
         1BOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IoSRBbnW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id o22si4594605qve.85.2019.06.02.21.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:29:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IoSRBbnW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 07BB11283;
	Mon,  3 Jun 2019 00:29:02 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:29:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=ewjgpKzrSyNZxS5aNItsJCiFiD2mCvE5h0lTeGrIDUo=; b=IoSRBbnW
	/MnkcmJqrNT5voVVHOF2HDm78r1ptlGnuLEAhtfByiYSAth7lBKRIFJHKGbONqmn
	n9UVthqyetkgCvsrj+7pkvH5MtmmzIiVs/c6jiLK7RxL/bbJUimKk3+O3szcTSRs
	vJIDHxqClhud2LL51vDDgg1FxOW68cw7tuSVnPX1iNMx24Ty5KeGH0+yAf0WrDBj
	socy5DCMQ7OE/FlOncvhs//KTN3ZJ5D1eoMOa9UGvVTkWNrQQx0IVoJ7tE8LCIud
	otq3mwQLk3BSy21ZvUTVfHv46iDriY2AepKcuL+2jT2Yu5mWCqSoEc4NY5EEUZyS
	IiYkQRy0xjTc3g==
X-ME-Sender: <xms:DaL0XNqx8Jd-XU-pkYuBd8vi9YcGoiJtH7JYmShfbeHw3LYdvhocbw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:DaL0XLTMXu_myirZJLnoa4L66T3Q6n3jM_UADurIL0AwHiM7i8oGLw>
    <xmx:DaL0XEpXGYDwOQWfc3NEfy_TXiaLtQznK_SMF_LcyLQ9FQ-B0MlJrQ>
    <xmx:DaL0XGy_3VbUMO_8C9GkpN7MZ-GI6V4dZj1LvJEpHY5Sv6TXNdnFGQ>
    <xmx:DaL0XLAFNMrlWEo8sfJXnnXQNn79inSmvfm97CjL5Hg18Y17ih9oXw>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id DCC0B80066;
	Mon,  3 Jun 2019 00:28:54 -0400 (EDT)
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
Subject: [PATCH 12/15] dcache: Provide a dentry constructor
Date: Mon,  3 Jun 2019 14:26:34 +1000
Message-Id: <20190603042637.2018-13-tobin@kernel.org>
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

In order to support object migration on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

Provide a dentry constructor.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index c435398f2c81..867d97a86940 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1603,6 +1603,16 @@ void d_invalidate(struct dentry *dentry)
 }
 EXPORT_SYMBOL(d_invalidate);
 
+static void dcache_ctor(void *p)
+{
+	struct dentry *dentry = p;
+
+	/* Mimic lockref_mark_dead() */
+	dentry->d_lockref.count = -128;
+
+	spin_lock_init(&dentry->d_lock);
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
@@ -1658,7 +1668,6 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 
 	dentry->d_lockref.count = 1;
 	dentry->d_flags = 0;
-	spin_lock_init(&dentry->d_lock);
 	seqcount_init(&dentry->d_seq);
 	dentry->d_inode = NULL;
 	dentry->d_parent = dentry;
@@ -3096,14 +3105,17 @@ static void __init dcache_init_early(void)
 
 static void __init dcache_init(void)
 {
-	/*
-	 * A constructor could be added for stable state like the lists,
-	 * but it is probably not worth it because of the cache nature
-	 * of the dcache.
-	 */
-	dentry_cache = KMEM_CACHE_USERCOPY(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
-		d_iname);
+	slab_flags_t flags =
+		SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | SLAB_MEM_SPREAD | SLAB_ACCOUNT;
+
+	dentry_cache =
+		kmem_cache_create_usercopy("dentry",
+					   sizeof(struct dentry),
+					   __alignof__(struct dentry),
+					   flags,
+					   offsetof(struct dentry, d_iname),
+					   sizeof_field(struct dentry, d_iname),
+					   dcache_ctor);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
-- 
2.21.0

