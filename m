Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AEA7C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 397D62075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="yBlNj5Aj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 397D62075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E346E6B0273; Wed, 10 Apr 2019 21:37:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE48F6B0274; Wed, 10 Apr 2019 21:37:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86E66B0275; Wed, 10 Apr 2019 21:37:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A807A6B0273
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:37:43 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o135so3690913qke.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:37:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bQrKJO1ca6Jnb6VAVcy4YOcaMtIAYDp36gD1sjc6/M8=;
        b=bBbW7XcvhwdoEcFf+SLuF55gskwgAdEigO5YE4Ow+xZJAMuntb07JfYdZ+aLPufIBa
         IElGzOa7NXxHb4URDzCX1AqsMreHafl91tWsPSTu01ILhHtm23NeZ6QxKknM3pPb8YSD
         55DPDroVZdZYDrR3UkLlRsnHRWl54cAXNbg0hC3JhHL9zGx0XD+9RGtFuOt5gJO7bPrx
         5n6f8W8G4meyQBjkgozYcb89TXFshOgxzaAtEfJDB86HJT0LlGZE2MlQfamhgxnT44Bq
         ZWOf5NmL6beGIbs4g12Sc0Q3DSB6qNnAOUMkyI5RLKCwyn49/KXJNlmShUHatfq6RpAJ
         wOcA==
X-Gm-Message-State: APjAAAU0JRpEFFHQQK6ULTCMFzumonWDQw/CVVhVqtKJYwbkvIQNab1c
	QrLCAKkOn3Wc/rF9xJE2PfBO7/UTnvQrgLEqBxPr+OBHFe5UNjPvX4LKvVc5W2GzIc//8/tuoam
	lTJMPFOtqT5sOp/QtLTY8HcyFP4Y3EjWBloqcYDTxMHnv8f3sAmASgBNT5dzPa2I=
X-Received: by 2002:a0c:f806:: with SMTP id r6mr36700376qvn.188.1554946663429;
        Wed, 10 Apr 2019 18:37:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz68k1rRPb84r6AWeFC8RCH7p6WHxvOFj6slNaIvpkOioXJkk4EG11c4G6CiRjeN0KB7L6m
X-Received: by 2002:a0c:f806:: with SMTP id r6mr36700338qvn.188.1554946662494;
        Wed, 10 Apr 2019 18:37:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946662; cv=none;
        d=google.com; s=arc-20160816;
        b=KUkBu9fy8iTWIoQMOKTi5xhRhVlh5eZ6BdaUoWhqlM/lNOz3yRF+XmwwEgTvf1wJTy
         se1lmZu+Y2ERv4Nnf2eoQUov9Z3RF9Elab38rXRI4KamTON1S5zMNqhhwsxeS1NTIWpr
         1tlvSUHdJylzIksotIIODunLyDv2+OMaaGgBEqnmO+deUOCEWct8X3v8rrbn88EPPUFE
         pzdsdO7kU4vMD+Ku8YmEzb8f1htcoTrFMHTLGsTvcDJ0BldG9woeJNRi8CYvyYimLG16
         +EqnIr/yt/I8XDmi5FWfyQY4N5qjzWYRFLSgzDWl5HcfHmNFNbPSoMkPatkQMm7o3E3l
         oADA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bQrKJO1ca6Jnb6VAVcy4YOcaMtIAYDp36gD1sjc6/M8=;
        b=BLlDz1kTpmEgsWI01KT69vqXf1lEcUxvywE1egLkozulLO6dfpemOUAsKd0iLFLG0x
         mE8w3X++wU2ANhtkjbG9koQcVA9N5QKnACNCKoQwXkGYGfvGbj02N60AYIPsAmztZ3NN
         qqZ0H6DBNJa6v0QIqBolGbDJ1q4j9ET9JJ2q5uKYgFtMsToBld9rh5jFEXGd3wmieZqC
         iUNlVVih4HnoryUS8CwhrbH2mRYEEVO0gC0Ben4g51bHS6NRERHt8NzOMQOo6ISSYV1i
         /jyoc8W8Ij+WIXasufKonR1PnYFHTtc3iuJ1tonBV6AR7I/Pp0NJG7liKtT2eN0hCkiw
         qQyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yBlNj5Aj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id k59si3146115qte.346.2019.04.10.18.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:37:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yBlNj5Aj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 3835E999B;
	Wed, 10 Apr 2019 21:37:42 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:37:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bQrKJO1ca6Jnb6VAVcy4YOcaMtIAYDp36gD1sjc6/M8=; b=yBlNj5Aj
	x0jERAcX2nr8Cd8pENxlZdO97pwvF1NoK6TuCQ1brau0DWTvV1ZSAt1dD+zRVwt1
	f7G5jP181kU6gbOeouIaRF4A6IZLX20cnJ0PCFa/nGlv/IfL6IJWJtdT0N3ZOXBU
	TEj8iyiSmiX8iwAMHX9jUxkgs4KHVBbZL5HdCCorCoHBuh4x0Fr43See53XVlJl5
	vzXXuJUfpxuFmBKCN8ruXW6Q8GiYxgFV1oW8b40DUJ3RHiA+nFIPaSBX6MckJ9W+
	UUSWKB2gpBjc4X76BEUfeXBA9tKmd1n+ZV7ZxbWuO4pxRq1wdrzfVUn39bFzO9sn
	v4xFOp3swHx1Ug==
X-ME-Sender: <xms:ZZquXJCrAVQEDp_0eq0hFxaFtI5OiOF4bIethMS67w2YR9Kdq7_Dbg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:ZZquXLezwxv2nRBUMSG-riGoxXI303uykE5A8vzzWrl_5OtCCx5O7A>
    <xmx:ZZquXNEuO00nfKwnCztsTH-gnPDWMoTAfPvgDz7HuE_iOP6tDZxdUQ>
    <xmx:ZZquXNXFyubUjW-O0i8GykgVGgog10PVBVThGrr6IJvGV-RRXL4kCw>
    <xmx:ZpquXO5IVF19Ojbcc8e9uXN0JvZAt1FudYX4shceC83MWYKHF_PAYQ>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 62D49E408B;
	Wed, 10 Apr 2019 21:37:34 -0400 (EDT)
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
Subject: [RFC PATCH v3 15/15] dcache: Add CONFIG_DCACHE_SMO
Date: Thu, 11 Apr 2019 11:34:41 +1000
Message-Id: <20190411013441.5415-16-tobin@kernel.org>
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

In an attempt to make the SMO patchset as non-invasive as possible add a
config option CONFIG_DCACHE_SMO (under "Memory Management options") for
enabling SMO for the DCACHE.  Whithout this option dcache constructor is
used but no other code is built in, with this option enabled slab
mobility is enabled and the isolate/migrate functions are built in.

Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache via
Slab Movable Objects infrastructure.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 4 ++++
 mm/Kconfig  | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c707ed9ab5a..5ef68b78b457 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3069,6 +3069,7 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+#ifdef CONFIG_DCACHE_SMO
 /*
  * d_isolate() - Dentry isolation callback function.
  * @s: The dentry cache.
@@ -3136,6 +3137,7 @@ static void d_partial_shrink(struct kmem_cache *s, void **v, int nr,
 	if (!list_empty(&dispose))
 		shrink_dentry_list(&dispose);
 }
+#endif	/* CONFIG_DCACHE_SMO */
 
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
@@ -3182,7 +3184,9 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+#ifdef CONFIG_DCACHE_SMO
 	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+#endif
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/mm/Kconfig b/mm/Kconfig
index 47040d939f3b..92fc27ad3472 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -265,6 +265,13 @@ config SMO_NODE
        help
          On NUMA systems enable moving objects to and from a specified node.
 
+config DCACHE_SMO
+       bool "Enable Slab Movable Objects for the dcache"
+       depends on SLUB
+       help
+         Under memory pressure we can try to free dentry slab cache objects from
+         the partial slab list if this is enabled.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
-- 
2.21.0

