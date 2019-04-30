Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A301C04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B255F216FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ApONlV9R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B255F216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6417E6B0285; Mon, 29 Apr 2019 23:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F22C6B0286; Mon, 29 Apr 2019 23:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BAC36B0287; Mon, 29 Apr 2019 23:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5226B0285
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:10:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q57so12123837qtf.11
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:10:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xGuBBSB886petOw3w98G/aZf3m1f0zKs3QEeiyyCCSU=;
        b=C690kEfBs6r7QiTrmxjgatP72DRiKjdqYBzTysWhbJf1REIHg8dEeI2hrBTt8Y5dT8
         3S2/UZrY8pLlGk71d7iVB869f9yXtU8gCVHQ/IjxnVmAfY8bKBXnlRrHQJ0lBdx9mjOc
         Mi6KTRy4oEe2LMPqIfTmiaJz+66KYlXIRJcLXtmABrtrLfyzTIu0I6jnTPn2o/Mj1JHp
         gTIcifmuJ23CwenqnEk6bz9R+IoApr2Aj5jpZcUXww8UUKFXjf+ASEgRnGyRx0+UMJqo
         fTJK7YMYOlCO9pZ8uPBYB/JDhbwQp9aRSGBMjK1/tyeC2PCSWUQjEmMSCHVY99Z9Ty/v
         KdNQ==
X-Gm-Message-State: APjAAAWDqx9uhUSFvYtsUgKtdWdYNB6UeCHbIW9RyJ76IcRIDL6RJRHm
	RoG9NTnvVdB2Vxjm9oKYRtNcNKt0+H9WFnW9mKXe4Mo7SHOiQVKD3yT4qVZ0i4OH5srDxTn9BAm
	AJW6aLH4zGXq7FOSNSFaLUzMJiAptAYQV74KKF+6TYcmeE3lHb2cng9NB5eNG2a0=
X-Received: by 2002:a37:ef13:: with SMTP id j19mr29155874qkk.264.1556593829961;
        Mon, 29 Apr 2019 20:10:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznLK1M82EmxDlm1Xk87WakWTyurZBvvqfszyRGhWAzjDOUIs1FWTv9pYiSTgaD6dlBPRf8
X-Received: by 2002:a37:ef13:: with SMTP id j19mr29155827qkk.264.1556593828797;
        Mon, 29 Apr 2019 20:10:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593828; cv=none;
        d=google.com; s=arc-20160816;
        b=1D5rQq5DlEVx5OTT3ldYorb1GTYkClOYXBs5dve3Kw7rd9h2dxhVyahFwo9ABUE+sM
         dk4E8D8RlDRW29/qJrBjFEzGvbZZj0NgQmqthDitYsoiJlabLsf3jy+qTr/seQnxD1KO
         /nIl9QyaGVtmUro/hTuig+dXNFpg9merkwguNEwFuDgbl+meUCoG5sb3p0wPdJ9svrtx
         ioTtfpmL5ff2dKq9RxaywQPvNkTG+sIJP4CScMpbB6YWy6bKBge06bWytcuI6MyiU3vc
         VSzPgsP8fQ/cNBkad4BwNvPm7cvAVS7HXp+zFrdzFx0yNuD4hbxyd1taolJdYpjgWhZh
         mH7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xGuBBSB886petOw3w98G/aZf3m1f0zKs3QEeiyyCCSU=;
        b=eBBe65xUU0oaVKY7h5qs5uzSFqvq54tl/HONjGMogxN4fUFfaWBf1bX6JvdlNkfmr5
         jvVrFWHGa7xVzqRHQVeUXjeCtaOi+G64KkY153j0eSFYsy13g7DmcE1BNLdY0U3E4ZCJ
         mBiwdtO+sogVCnYjR6w3gox39b0Yq9lN34hZjYmn3uzxJ8G0RIPFpsYptOi9YRumx22w
         EvIkBeQpZXuvhFyWeRNsMXao34hY4NWfftv54s4iG7/fbv91EIgQxYBxN/+LA1143NEN
         4vnSqtdPDsczis2NTfI+nazWsw0RiW67fuY5+83s9obkgE1P2/d0fZKI9Xh7tQBhlBkl
         470w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ApONlV9R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id e18si7436331qkg.90.2019.04.29.20.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:10:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ApONlV9R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 8548FB542;
	Mon, 29 Apr 2019 23:10:28 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:10:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=xGuBBSB886petOw3w98G/aZf3m1f0zKs3QEeiyyCCSU=; b=ApONlV9R
	CYbP8MsPKwD89JCHecL+ibpiKvLaTyC2MjKvGMDLUPLGQTpzHcs27o4mzHiysfWC
	n7hDZB4eGPgwtwxsbVQ5W7t4HZzVZ/B7n0tpi0HpJn+VjqewjCoqt5eZphGvfhZb
	5uthRkIF5WbSgYA4ftlq5s/tFppzFc5BeU2WgvdpDJn+L5M/WJFBC9Du7qoukB1Y
	w2s23iqJ97QC0GYwqT3wgHCGH68Mg7bZVYXGeiZ2o7I5bYlP27wQ78XnG2dianoc
	m5TBnA6jyWPOz4isWQA7Qe0TMaby+2K9WTIAqVxx6JVxPNsbAoNJ/wJpcOvQLB8U
	bbo89/JC653vwg==
X-ME-Sender: <xms:pLzHXM0rpdV6zPsEEKWigd5-eb7j8xbcBW5ZhLMrC7g3omzLSq8yBw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeilecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:pLzHXN9PC-7NN6FbG-Jl6BdO9vOQuycKTJ_VM4iMQJ8SbARFN5zCgg>
    <xmx:pLzHXB3duJKSF_fylmIOqoDFZivvgjgFDo8mpzVShkoSFeTHY9Svpg>
    <xmx:pLzHXC897fnGWQNiWtvo9yi4r8E9s37ZaCcmVucEJxRDUOSM0askQg>
    <xmx:pLzHXHIkdl2O1PKIzy3nLJZ1F3dx9FVnL54Upuwr9eS7B0e6a5tLWQ>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 916CF103C8;
	Mon, 29 Apr 2019 23:10:20 -0400 (EDT)
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
Subject: [RFC PATCH v4 13/15] dcache: Provide a dentry constructor
Date: Tue, 30 Apr 2019 13:07:44 +1000
Message-Id: <20190430030746.26102-14-tobin@kernel.org>
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

In order to support object migration on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

Provide a dentry constructor.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index aac41adf4743..3d6cc06eca56 100644
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
@@ -3091,14 +3100,17 @@ static void __init dcache_init_early(void)
 
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

