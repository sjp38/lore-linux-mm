Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85F46C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 379442147A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4Na3wF3I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 379442147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E308E6B028B; Mon, 29 Apr 2019 23:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D91D66B028C; Mon, 29 Apr 2019 23:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C80FE6B028D; Mon, 29 Apr 2019 23:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E57B6B028B
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:10:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c2so10734142qkm.4
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BJo+tsGYz1UiYdilzcTz+d7vEhUJ+jp/yMih2keKOkE=;
        b=Lt+vd+hO4XVo8ppOcrxWDOaD9FA42OxUrk9eZCwRUH4GvRMHFyMzX4JIsIKS7CHfYA
         0kUuD8ZKP3CVmQsVtYgZ8GetWTgOPFylfvCwhoT2bgbSRMlDJJlC9Ib0rcWVvKh75UNQ
         MEKk3sky6k2lplRih/V/iVplFtDmsT8wqVZKVcwlsc6CzjwfE3mc3n7PIQSUTOHDDWf1
         BfA4lnQuGJG7BgNuZlQ9AV26kE5QZapRBtU7MxuO/Vd28MM39EM2FB551uT7y3ZsYV1Q
         1qqzdJny/KDRhCtFA3ITgJ/SJvSKOogqli70ZnlZUCm4lNEREKQR+/5sTWr5Ow/3P1Im
         OZbw==
X-Gm-Message-State: APjAAAWchtPOacq0ZPaTGr2pn10vNgqcuLlfRlW9Fqwifa75SY1EKIwL
	vg+HhLNyNT2URe5XwjtFGYMx8EniAAlNROVvcDSoXIqeGLsKy7SHOuCuQ85ycaC+bXaYfBuePco
	Ch10VxJx6crOYgmWiYndILokT9HTuFwW26crQyfHyIKKOFLI/s6/Uasql9HLn6cM=
X-Received: by 2002:a37:74c5:: with SMTP id p188mr27077876qkc.26.1556593846399;
        Mon, 29 Apr 2019 20:10:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJbvv36Tk/flcmEzKjdWTpLjXcWDV07qaA16Kaf+jpv3DI2Cfos7N/Phiy/90QJVlf/k+I
X-Received: by 2002:a37:74c5:: with SMTP id p188mr27077828qkc.26.1556593845171;
        Mon, 29 Apr 2019 20:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593845; cv=none;
        d=google.com; s=arc-20160816;
        b=IltXu5u0KXIB0eaY6OEzEYL6biWiUwytLPLCuE25IShAa+ui7GZJk4TTVN1LnjRBEG
         CQnhvGobXZ49q97/Q6jFFqpVfLb+OaAt/MPoExW+u0r3vX82U+DkxWUkIFnIzUPR9whn
         lakkPuql+56mmnxBkA4gaxf4oYz8MhCa52B+e3nzVmtyJG52FAOSLPLPvNwPB1QITwNd
         RDkrh5fCKLSF9GzC7h7FvSqCzD7yuPJ6UTuAoB8DDDAiGWLRl0igbeY7sx1bJ0mh27Uz
         4NoNwyFMeB4lkyQbUwgRfKO+aj4yo25A08LGJPWI6zoS0+pC1yQYuf9BC1SNVWV3rQJl
         QUuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BJo+tsGYz1UiYdilzcTz+d7vEhUJ+jp/yMih2keKOkE=;
        b=SimeB09ghUcqXQitUUAKnla36FwVRC5XcPidi/Tv42STJtsqnIkJUFNU5hVwJJaI1p
         Fonu7GqVpWGU3v/zhJ8fFfhsdNdk/OtlsBK5GtEPBoqKVRhoGgwaUezyayWWunNC16YN
         gFGN+pFRD1sJ0Pj6/5mWK8dVIEnGixsTaqFq/FxtQB+DVUj1AZC/2IK1mI/bgeic3tuG
         XMwi+6XzQOVF9LHITfbeTJiU9qe/zcOIB/2fM1K83nxgkV9Pq8vDNgIoN+7uExEs8Qu7
         RkEZpaw29DkWeclMKtJZi+VzjtbQ6z1XnCatwLdmyOOmbl+xMFxQvwGrRWF4K37RsC+m
         ICCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4Na3wF3I;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id t24si3649556qte.96.2019.04.29.20.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:10:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4Na3wF3I;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id BF1FE9A40;
	Mon, 29 Apr 2019 23:10:44 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:10:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=BJo+tsGYz1UiYdilzcTz+d7vEhUJ+jp/yMih2keKOkE=; b=4Na3wF3I
	x24V1uXx6GIXq0r+bQnjj+1SJ6YVMI1Ebj8HL9tPpVhag1zyRctWPePGEkZkDb4v
	T7JhLPqcmvcj9VujzI05sNPVwfXS0vPhfBS/txTRihZVWGrdwTWDzsjO7tbNbct2
	3ZiYs4yFlIkuKixNaDXTwotfl3aRZjWGc2rDrpHWUu+BnJojeC1RYL+JixYcJUM6
	C+JXs/TIyu6EyE4NieFwVUhgVzxXU7lRlrUVSF4AVEzYyMrFUl3DRRs5ubXilPyO
	Y35PGXi6rcuDrW/6tgzRfGh49RJelBQUWyRdHTfdrpcjbbL9uIz8RkLCWtYrNkDZ
	1TNDxczMcD8R/w==
X-ME-Sender: <xms:tLzHXDuYSrSroGo2gkFEkHVJlCaf-S_10nE0apXTQGzY2pvjrf6d4Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeilecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeef
X-ME-Proxy: <xmx:tLzHXNZQsjKKFsknSj4OyF0LAKM_GoPR3BSTJCijC8xBHCQ7HNljNA>
    <xmx:tLzHXIuabIEJy2sJOUJRbV_4ZhsABLIKgLzu7E4FJSXZu_ytLzhA-Q>
    <xmx:tLzHXPFhz4uEu-ZmPczNucHSGXPIFbgY0nBDkQXyUpzUiLTbhgEYgQ>
    <xmx:tLzHXCK8X0308eotLCAl5QQHXJMPI-RGNIDfTHVSva0RHVmQJBb1cw>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id EC48F103C8;
	Mon, 29 Apr 2019 23:10:36 -0400 (EDT)
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
Subject: [RFC PATCH v4 15/15] dcache: Add CONFIG_DCACHE_SMO
Date: Tue, 30 Apr 2019 13:07:46 +1000
Message-Id: <20190430030746.26102-16-tobin@kernel.org>
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
index 3f9daba1cc78..9edce104613b 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3068,6 +3068,7 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+#ifdef CONFIG_DCACHE_SMO
 /*
  * d_isolate() - Dentry isolation callback function.
  * @s: The dentry cache.
@@ -3140,6 +3141,7 @@ static void d_partial_shrink(struct kmem_cache *s, void **_unused, int __unused,
 
 	kfree(private);
 }
+#endif	/* CONFIG_DCACHE_SMO */
 
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
@@ -3186,7 +3188,9 @@ static void __init dcache_init(void)
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

