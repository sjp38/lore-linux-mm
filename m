Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA22BC10F0E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A68620879
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:59:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="vEETgM2q";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="J+oHpI9r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A68620879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19E926B000A; Sun,  7 Apr 2019 21:59:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14F156B000C; Sun,  7 Apr 2019 21:59:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03CA06B000E; Sun,  7 Apr 2019 21:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5B1D6B000A
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 21:59:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so11480157qtk.9
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 18:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DLP3NAwsImXCyFEGzPGaWnfGENpKl0W4NenoS/NwlKo=;
        b=VJnGoHooCFkcANM5WTI1yYXiHGI5+hfjkjswRJfRsTzQDlYDeGkU+dcnEshtRMdtJd
         r7fLFUPmedtICGf+yrcApKJGgJtk2orEB2grEtceMo1LAIOTD6brV93e+KuAI1BtDzXI
         l8DhjGnMKsRbDulcJQEBJLTpxzAqK5J/6oEbL9T21anMRIs0Q24z0GnneTMW0rjLZwTo
         sFAL2aK6NQxA/I4tztyHutnguLRkrsp9iMLvcIrHV3aWEtE91X+vjKm85BiwLAr13KIk
         qczdKcwc8HosPPOP2RkWV+QOVN4+QVNyjLEeQE8Zs8wk6eDjQPcnE17pMiDg7Z57HMoS
         Hi4A==
X-Gm-Message-State: APjAAAVsjkBmB4Pkun6rPb0sNDdQkN/sarE266zDPLpTYNja/hVHCT1o
	X9UxvnZmEV7iwpEIqgKXeeYRvwdKZMi2FGxhWPw3lSDb+/DeRumpPeCy9yyAryCy6lrXTyV3+NS
	mFvBeN+lbm81q9SCzZ+rwNlHnF4wwaNw4///nwxczosTbmIzMWMNPjBYg3Cl0rDnuvA==
X-Received: by 2002:a0c:ac0e:: with SMTP id l14mr20724094qvb.86.1554688793615;
        Sun, 07 Apr 2019 18:59:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9yP3jfDlyatVKPF69AerGJkFETPpEAKiRnrRklPJwmEC/qX/Vw8T9e6YtdLQkpxWfzmq2
X-Received: by 2002:a0c:ac0e:: with SMTP id l14mr20724072qvb.86.1554688793001;
        Sun, 07 Apr 2019 18:59:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554688792; cv=none;
        d=google.com; s=arc-20160816;
        b=tigOx0o3Tu+HQoEKvPBDPWpmklp7ZT8NnH2REBNnakclxEt776vUArc6Qf81neCT5F
         IKphfV2lDqvpZCxopYAc3/Tv+J/Gvq2D/d/er3muIXnYXyoqZ8n9n226vtX4F5oxzz2M
         fBOginQtA0cC8mgXvG4TE3l7os7SrtQjXzRP23CvyXT/KNbXk1fKx/JVjsLa7J4izz8l
         ovQbsv0K3bRSXKIrfSwQVb68uzirJiewsZBlDsCahC3Hpo2LbU3SpVG0iKtzMmSAnqlR
         xHpAItxGF1n7lLAa/5xDinge8yi6gknvLo9Yi2HCqe8KJlTH1IAz1sGrGkfYKm8vRPQa
         eoZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=DLP3NAwsImXCyFEGzPGaWnfGENpKl0W4NenoS/NwlKo=;
        b=M4aEU9C90CKbc495BP40iKIaru8QGkhnz8LgE8cCNTgDsSR0f1HS1g4YZwZ4O/yNj8
         qWt/h6sIqZ+7WLiswEjg3RLX4a1qbmAQelZ7cJ7iZZi+850x+jP6wmRMy+nOH+45pgsS
         iv8vUYjYKk0+RogdKA0yEPImX7cx8Bpr9dQi5sVL3fgjIrvOedamYCcQaHa8y8cZNP4o
         P6O6XvfrpEZQkX6GbF4a84D1hiCv8wgZoanILm//8jnVZ3f9Kkkhlm5G3mT+QOQOcpxJ
         09ZszBvpieVWO7iSsjg73+wCRuMuhgMPNEOy9c0L13YnxOhN4k1034Ui7W0YL9jPXhDN
         y79g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=vEETgM2q;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J+oHpI9r;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id n90si2433435qte.387.2019.04.07.18.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 18:59:52 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=vEETgM2q;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J+oHpI9r;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 980632201F;
	Sun,  7 Apr 2019 21:59:50 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Sun, 07 Apr 2019 21:59:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=DLP3NAwsImXCyFEGzPGaWnfGENp
	Kl0W4NenoS/NwlKo=; b=vEETgM2qKwAeqZTyu5/6N8i6o+pHju7yaWcyXNbTvO/
	O3WwO5BSK27gbI86VJd/+r+0QwfY3mCoeh3ZfT7I0D7bD5qJBatarpthEK5nxys8
	7IyhhL7L/UlFf2D0tZxO/r1WAL7ietshkugAcI9nyfqYZq9FdLeiQ3I5ACrCwXpV
	PCfgqZTFl367PEIeolnqmwDvaM6DJx24JiDDNctHIE3uzOyfMVMw6mi4KLQepTib
	9iEsO5xLpNRt0lev7K7KvmQKXco54H9sOX1CN+RCmb7UBKgGNxDOmc62z7AfgMpW
	6wYUQ6fHkubTjveBMeYVi/i6hwLu/CvKONdI4aN7d8A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=DLP3NA
	wsImXCyFEGzPGaWnfGENpKl0W4NenoS/NwlKo=; b=J+oHpI9r4y1nh7M9QBmbDv
	xM4qwyjPjQwvkoLL3tjVued5Q1vsShVOurokrbqNedL7xt4iOaAnENG7Q+LDmGN+
	bf30Cx2+6/Ij39sGqIGF9VbTFqjPepzUxIWowGWg3Ydgdw4/CgcM0ktbgxd3C8Qr
	WAy8R9N7YIRuMel+FZjSY2NgOYPD/NMtYi5HS8RNd8mHl7nY0q8nCp26NlVEd0Xi
	tPpAIbLtqInrxJX4UGTEMs3AXyj2QAGrE+2pESH8ZXeojPV8cb7KH9R/HIcArnvT
	TIMdE6Dvf8loYpVbMnifwn4340pgzvtYK4L0Nllmpqb9Ryga3FFyx/QNLmgC6LeQ
	==
X-ME-Sender: <xms:FKuqXGMTKFyfJw4O66k-KwPOzMP3lYeWqM8e7QvlqEgN90EnTvs0QQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddvgdehfeculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecufghrlhcuvffnffculd
    eftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdforedvnecuhfhrohhm
    pedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosghinhdrtggtqeenuc
    fkphepuddvgedrudeiledrudehvddrvddvleenucfrrghrrghmpehmrghilhhfrhhomhep
    mhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:FKuqXAXKRxDbPvXwiWVW7xV-CBCyDj6RtRq76UJewYN51rV0J0rJKA>
    <xmx:FKuqXLIGw1jIzCq_TAkHlTaWpLsw9U-qlwpIE52XTGxxrMUmERRgiQ>
    <xmx:FKuqXB1PQjLZTZTK2UixZ6vCPIHVFYNN0PWpY5GmNNkGOFBArPGgnw>
    <xmx:FquqXCLLSKwsdJS02kQVBWJKFGLJCbWEPIQe1aKyvpM6QeCeXLexyA>
Received: from localhost (124-169-152-229.dyn.iinet.net.au [124.169.152.229])
	by mail.messagingengine.com (Postfix) with ESMTPA id DEA87E4619;
	Sun,  7 Apr 2019 21:59:47 -0400 (EDT)
Date: Mon, 8 Apr 2019 11:59:17 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, tj@kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
Message-ID: <20190408015917.GA633@eros.localdomain>
References: <20190406225901.35465-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190406225901.35465-1-cai@lca.pw>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 06, 2019 at 06:59:01PM -0400, Qian Cai wrote:
> The commit 510ded33e075 ("slab: implement slab_root_caches list")
> changes the name of the list node within "struct kmem_cache" from
> "list" to "root_caches_node"

Are you sure? It looks to me like it adds a member to the memcg_cache_array

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a0cc7a77cda2..af1a5bef80f4 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -556,6 +556,8 @@ struct memcg_cache_array {
  *             used to index child cachces during allocation and cleared
  *             early during shutdown.
  * 
+ * @root_caches_node: List node for slab_root_caches list.
+ * 
  * @children:  List of all child caches.  While the child caches are also
  *             reachable through @memcg_caches, a child cache remains on
  *             this list until it is actually destroyed.
@@ -573,6 +575,7 @@ struct memcg_cache_params {
        union { 
                struct {
                        struct memcg_cache_array __rcu *memcg_caches;
+                       struct list_head __root_caches_node;
                        struct list_head children;
                };

And then defines 'root_caches_node' to be 'memcg_params.__root_caches_node'
if we have CONFIG_MEMCG otherwise defines 'root_caches_node' to be 'list'


> but leaks_show() still use the "list"

I believe it should since 'list' is used to add to slab_caches list.

> which causes a crash when reading /proc/slab_allocators.

I was unable to reproduce this crash, I built with

# CONFIG_MEMCG is not set
CONFIG_SLAB=y
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_DEBUG_SLAB=y
CONFIG_DEBUG_SLAB_LEAK=y

I then booted in Qemu and successfully ran 
$ cat slab_allocators

Perhaps you could post your config?

Hope this helps,
Tobin.

