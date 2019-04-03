Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD847C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CE38206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="A2qei93U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CE38206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FB006B0275; Wed,  3 Apr 2019 00:24:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AB5E6B027E; Wed,  3 Apr 2019 00:24:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2739B6B027F; Wed,  3 Apr 2019 00:24:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 094BE6B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:24:24 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f196so13644635qke.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:24:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bbV+w3gF2LYD1FivN0kmZexmR5wyxe6wR2gkjGxFRYI=;
        b=iuhwCeLcFSW1+bHBvoIRPw2fy+ZKtJ7rEA2a7Ehg8fR44VtkyCVeIyNPWS9L5AYmVf
         xfApj8zrTNZABrug8v/zt3hdTH2LiGcsldy4Bf5KUvnB9QyniY7+t7N/SLcC42L5URUJ
         Be3Iwrt1BbjRCJyMeMDFTursTL23gc4v69OlI91jg5q850ieoUACezsqj2Nb+B4v/yM4
         0VwO6cDe6hKpYSGjM1ttEMPIkeco6WNBeu42HYgVbJhoN1Tl930WEX6uqPuvckZcHML1
         MyDQx4olbFq6x46903TQT6ZvQStmEGnu8gHVeOfdNbhqYvbYWoADj/KuCFdV+A8OtlBN
         I1hQ==
X-Gm-Message-State: APjAAAX1p/jcaAi7rAFyIetJVvYsy0uBTeGiruj3XqVjqWy6z5qk7Ssc
	GdPfaQxwPR3BT+1JsG59cZaW+rZn21F0VoQoTko+X0GSVaqeIYMyvPSHPnC9av+axeir29+sZ/n
	YD5l4vZ93a9caUxlj1TPf4A+j3E5Y7vuzJpNDDsdTeo97j6R3paUW8Crg6h0Np7k=
X-Received: by 2002:a0c:d25a:: with SMTP id o26mr62114176qvh.78.1554265463802;
        Tue, 02 Apr 2019 21:24:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMx+FSty8XJ+f6wtel8o/wODmPu3LTtDn0fTyGBWceT7VIhixxXWiuN+BirQoX4WVCD77r
X-Received: by 2002:a0c:d25a:: with SMTP id o26mr62114137qvh.78.1554265462736;
        Tue, 02 Apr 2019 21:24:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265462; cv=none;
        d=google.com; s=arc-20160816;
        b=A1YAZAEr3djhYO/s8CxwctM0AdWYI/rcFcg40kyAY0jXZVOhqlgkpIDyhc2CbQugtm
         3OWOQFpJWW1NqjWozrJhFDgKVV5/pDwhxgPVDihojCm5JDp2e7q9xH8bX/LS8UHOVYAD
         bxG5TNEhBe1RcgLOw8ETyncuxkodkZd4fzrwsPjYDKuwVCfjzQiYp8UIWPggPNBZ+LM1
         GjSzssVAsXA5NXSR+BN5K2FtpnwtW06LEpZcGvOXx1U5cQ4nLM/B9LMthCXTf+rO+t7k
         weqsK/N2Y8ixUArXH2dXGJVsP04TsRMSJjWompMBgDcP9gLPTI/RDyzmewsIfxbp+225
         mZNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bbV+w3gF2LYD1FivN0kmZexmR5wyxe6wR2gkjGxFRYI=;
        b=F1gKre+tZTexyUWS0SZ4kZ+VEMjtq2fdDlPd3q5cVfyd1TeocAJzWPqnuuKqIjdpCq
         +J6TCsYbnEjJ7Ck5JO85zGUrnsz4lodOF3qiR5hmJM34bQJB/26AW85HUA4clraoQYYf
         g2qsYEe5rvn5RK/7rQO9CDUco3ozH6I2scs0fSFwgxQs1LgVRgNvIiyv0+BwhHUDhjdu
         6pTTfHQMdGWcnwi2oFM+3llkL5/t20pVc7AhinOPCs4FGf+ZOd33rVtqnMK9X8X8RuBG
         KwiIGmuDz4vxoAw9JO8fkGhvxRRz5TRSNMaOpyJQ6YxGVERILveVWu4VHmBxO+sEVwZx
         z+Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=A2qei93U;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id p9si2375945qkj.232.2019.04.02.21.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:24:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=A2qei93U;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 79D1021F93;
	Wed,  3 Apr 2019 00:24:22 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:24:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bbV+w3gF2LYD1FivN0kmZexmR5wyxe6wR2gkjGxFRYI=; b=A2qei93U
	HU48t5f6nD+xKkxRcoxHrLa8FeTIc145hRYP6nIdf5yeW5Zh1r9KqwlDsYVUWOg0
	wSndlC0Vr0TaWNSFGBsHApW+etgX/1SU/sgVCBjNp+JmkFvfLouRJ0hXN6DN1XXj
	cyiPzg1vPdxP6JhKQUnxEMMwJoJJCZa+YTEJQGaQaoB3J8eQ6Ghlx2PVy6Oi+lKI
	Jan3g6XBb0xIBNe1y9V6kSiajNCgmekjCpmw2E4+7S9L5AJQOXoI8xp9QQLrs1st
	bbj3mmvbN36dWYpHFUCPnY8100JoI/4MMxfQlz6CR2rqRfQHD7VbaDLR1uZASy2i
	oIB3q1xqQ7hy2w==
X-ME-Sender: <xms:djWkXNYl4V-tXMjSxPgkCb9vE92NzxxC-S7vTpM-I-D7GsuuiDLNLw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeduvd
X-ME-Proxy: <xmx:djWkXAQzCIfbRRgLj9ibmclaRc4KcPsFh2s6GgfbMB53slSRW2Y_GA>
    <xmx:djWkXM9rzitkUfHrXV69NA0J_KGyZFzMKkJsVkEMBFNTBEuX98mJmA>
    <xmx:djWkXAhMxb1Fwy_EoE5JAFyEQakVlppE5UOnEHYhCz0avxAnJC9Ouw>
    <xmx:djWkXFjDb3dhBwbdUJMGq_wxasP-aJaOWtbCJsiGdZXUedbbsxZMEA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8369E1030F;
	Wed,  3 Apr 2019 00:24:15 -0400 (EDT)
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
Subject: [RFC PATCH v2 13/14] dcache: Provide a dentry constructor
Date: Wed,  3 Apr 2019 15:21:26 +1100
Message-Id: <20190403042127.18755-14-tobin@kernel.org>
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

In order to support object migration on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

Provide a dentry constructor.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index aac41adf4743..606844ad5171 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1603,6 +1603,22 @@ void d_invalidate(struct dentry *dentry)
 }
 EXPORT_SYMBOL(d_invalidate);
 
+static void dcache_ctor(void *p)
+{
+	struct dentry *dentry = p;
+
+	dentry->d_lockref.count = 0;
+	dentry->d_inode = NULL;
+
+	spin_lock_init(&dentry->d_lock);
+
+	INIT_HLIST_BL_NODE(&dentry->d_hash);
+	INIT_LIST_HEAD(&dentry->d_lru);
+	INIT_LIST_HEAD(&dentry->d_subdirs);
+	INIT_HLIST_NODE(&dentry->d_u.d_alias);
+	INIT_LIST_HEAD(&dentry->d_child);
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
@@ -1658,7 +1674,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 
 	dentry->d_lockref.count = 1;
 	dentry->d_flags = 0;
-	spin_lock_init(&dentry->d_lock);
+
 	seqcount_init(&dentry->d_seq);
 	dentry->d_inode = NULL;
 	dentry->d_parent = dentry;
@@ -3091,14 +3107,17 @@ static void __init dcache_init_early(void)
 
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

