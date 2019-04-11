Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0AB5C10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 723BD2075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="2CRQThrQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 723BD2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C77E6B026F; Wed, 10 Apr 2019 21:37:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 077CD6B0270; Wed, 10 Apr 2019 21:37:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E81C26B0271; Wed, 10 Apr 2019 21:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C85786B026F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:37:27 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k13so4065658qtc.23
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Tq6hWwswYs/S8V9g57LOLmjTNN0NoV+f6Q5VLbbSnZY=;
        b=Hweduz0GbrmX/qU9oEvCXkU1eKPFFByZS8SEoYnbgBZZ6k8Nuh62Mb9GKkAr5i6Adc
         rjGnNw10uSpTYKS0ODwqFiYIcOl/DXvJbCzR48S7aNzU/wYOx24JBYVkWG2sjdvRrhGE
         crwf80L+1j6Hmja1aqZFH/8hLLd5oLTigJ5o3A3HqFjGNbkR+OIKwAsrBmjweRk2G11J
         z2Xkc1CRYB5DTmKhcEG4Ipeohw2fa23yJoPn0I5yb1EP+dPHE4tglt79reimLep3XWaT
         gG09NI7mtt5YC6oA9YYu42Hfxc2UtFL4KaOvnjen/miod6+smI2m+XBe6HMKof01CKdZ
         9IVA==
X-Gm-Message-State: APjAAAWwB0fhs5ahlWDdMTZo/VBWAMbdeOGw3mZy9HU8frGRSmM11Jdw
	AEbKVmU5K/hJjd4j1CzG/ayhez8ri5Nr4nzkvkNhgCpDNGcHEPGsS0U6735Wpfqu/8KeuAcTLiG
	Wr6u91vY3K84gztNwNPjMggbbIn9HjFxdDrZYbmWgxiz30xluzKCOswHVHPSFIGc=
X-Received: by 2002:ac8:3786:: with SMTP id d6mr39089124qtc.328.1554946647597;
        Wed, 10 Apr 2019 18:37:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybuh9vh6d3bvcMWQjQHH+D6K8Mrnjk4PfmltQd9sSBT6JOUW+a8htXR1MQd0aGETpP8q7a
X-Received: by 2002:ac8:3786:: with SMTP id d6mr39089064qtc.328.1554946646637;
        Wed, 10 Apr 2019 18:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946646; cv=none;
        d=google.com; s=arc-20160816;
        b=spZgO+DEGaptUajRw94cZIzz5IPJXcuznf7+g73bAZja92FAhE4YBvM32MlijF3/lB
         +6djgXNWeT0NJvu2uWyW8xKJW6ESf68Dp3b8nDhesLixnVbIRS5uJCzDPfbIb6I/sT6A
         Nff20zgQ5mEHEtHc5cCKLautLcu7MwYJRlvkmG82puQQ0Xn3JyrCMSMLxPuWv6CxDDBg
         OF97uwH04uASPstYaAJfy4iEN0k6818RzYxHerQIi/kgjwrJTAlf81MruokSo++mzFOH
         CHSMR1pBJFW+TuKcNDCYCpYQIRdpnRayKzwC8xrWCYSk3ED2S1GHRGndHNiNpX5ngsZW
         4oZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Tq6hWwswYs/S8V9g57LOLmjTNN0NoV+f6Q5VLbbSnZY=;
        b=j5mY2Ww4tYndtaESviWk1ptpn/m8x8uwBuvvMEI33B6Iy28vtuNSmjZABaK93g0O2s
         DFfh9pLS9sRMxsNxl97Ed5mnlZOENbwBnc/kLNlcWVge4FQ+MSqNaCABRRSsu4uXZ1H8
         /HxQgYbrW4IGGPWS9ud/tQjXSrUZ7H4NSDCAEBlC/5YleRMS1Y+sNwZiMELi/Hyg5SAn
         GmBzrQhTbAu5jwh7DQaqHIkblKLRBM/ltdBUYBdPtlTU62q/s1pgrzYJxPaG8CfMLHNK
         bN5CxuXa1eYU/h0zX+t1oDCIg+LOAkEmuhERo76N42TXPdzUZsiqbeBcMeDldJj1TzBK
         xWiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2CRQThrQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id f50si33950qtk.357.2019.04.10.18.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:37:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2CRQThrQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 59C58B79A;
	Wed, 10 Apr 2019 21:37:26 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:37:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Tq6hWwswYs/S8V9g57LOLmjTNN0NoV+f6Q5VLbbSnZY=; b=2CRQThrQ
	eRsRFpQwkExGuy4vU8Wmq+XtUbO/D19tvIhEaDKMVcNYwDQ46PNrEAI8EH8/HKx7
	FTIM1nhNO2pXs4zZKFKogUkU1Z6hCDQD9Zwn4jUDztIlyNa/kBlLxB10AXVs2B9r
	/COdMWuyRClZFWnN24mFPzhXKsiV+cU9aItt0t4fyZzSfQ4e8YWiQMv8tm9xFVu+
	DXPS5uvMffVixFrAjqTvzdxbdvXap+uO7hpIIAIu+cHzXJyRdYn3Wew5OKX41vf9
	sRPV41XoTj7YNB0Tj+ixOAUbqElipOaRs0ZJSRekdMJGWlQ6nyG5gZCye3z//aPn
	2fQUbHpFdTBFkw==
X-ME-Sender: <xms:VpquXMGS26eFg6i-es3Z8Mh3hisNGC2C1S9fAsmsqMgAh3NK2gIGsQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:VpquXB8u36Lty0pKwbuPGBrpMgmuYVY9KZDjm07gm79pm7Dq4MLy_w>
    <xmx:VpquXMjiKuctTUwsZZF5d5GT0XNgcScCg-0nVv93o40zIaFVfsr_fw>
    <xmx:VpquXH_V71LveNuTW3SNdBCUpHRhEAx0GBiCvSabhy7Hw0whIyvmXg>
    <xmx:VpquXNLrgar-UUH1BZVBzzI8LezKEIfe0xO-WnSCgAqpWkQ257vaVw>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5A211E408B;
	Wed, 10 Apr 2019 21:37:18 -0400 (EDT)
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
Subject: [RFC PATCH v3 13/15] dcache: Provide a dentry constructor
Date: Thu, 11 Apr 2019 11:34:39 +1000
Message-Id: <20190411013441.5415-14-tobin@kernel.org>
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

In order to support object migration on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

Provide a dentry constructor.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index aac41adf4743..606cfca20d42 100644
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
@@ -1658,7 +1668,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 
 	dentry->d_lockref.count = 1;
 	dentry->d_flags = 0;
-	spin_lock_init(&dentry->d_lock);
+
 	seqcount_init(&dentry->d_seq);
 	dentry->d_inode = NULL;
 	dentry->d_parent = dentry;
@@ -3091,14 +3101,17 @@ static void __init dcache_init_early(void)
 
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

