Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82516C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C253214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:54:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="Uf/KtrOT";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="2HSi7Br/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C253214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B56168E0004; Mon, 11 Mar 2019 21:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADCE78E0002; Mon, 11 Mar 2019 21:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5928E0004; Mon, 11 Mar 2019 21:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7517B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:54:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so943398qtk.2
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DWxYFqFht/GTnBUrw50jGcXbdTjgIErrdzyLX70BJKc=;
        b=r9HRvV7/qDKqQOUmfPjzhLES2yZJZrRyO0CAHu82gz/VouwwK6ch80exQQm3KDimZq
         RaYIQQWo+cHFv/9twSgrQxYYWRXQIcE7rRnwgSUdh5tek9DsrdGxRLv9xThLlgLMfsqN
         858kRck3NYSaDV+mXbCAE0ybmdBdKXu3hgoWKEZYtwQhEqEYWo6QdsU0E4EsoQbmYl86
         mwHlsj4Pl+2wl1gi5DwtxtA5q0mF1mmi/DsmEImg/VLTFuzn/FmXV/zMhaYd1H73wrWj
         9zOmL3F9BGop1YZ2fm++RH2NKiPgqaxPyakUsGHAd7sTb091Xq9f0XCpomCn51kT54d9
         3r0Q==
X-Gm-Message-State: APjAAAX+raGmSVdD+NrRYrtYLoQ4km8nfbVYPIxX85+KEqXPeSaakYuo
	W876TUfo7Qx6/51EME9qOLWL6QD2K7CfCChiS0U3EAnNmY5KTTUm+24NZO8PPp/0gNyjUmBVxOs
	/X7pi1NeW9mlpKFvoM2l1+9p845QdzrAywCHTOnb7qyCxpZ9cnb1IEBOfABLtLv4K+A==
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr4347789qta.272.1552355697203;
        Mon, 11 Mar 2019 18:54:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycAUNO9W5QS7/u1pJ9IWe0mJAJ1mppXpjm2Flh/ul4TKNX/G9LCglu2W76/F1Yt+4r6A4c
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr4347773qta.272.1552355696492;
        Mon, 11 Mar 2019 18:54:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552355696; cv=none;
        d=google.com; s=arc-20160816;
        b=hBeZ3YE1X8XX7/z5ZjG7kjLyiEwlqbvUG6Vq/gDAcImjAFSA6McddydlsBSMgZCFWC
         DVO1xhyzUtoHGwbifLxO2DN+NpvaYC8+0FnIJgupVZ6/0rCotNkTJiXrNiwEyEx9J/xu
         hU7HBeUYspFIxEWxWHuAFY7bcY4uYcT0A9P8YYUnQYqVShbTkxONbo74JM83nZFFfrbb
         YJWMbODJYZMp062PI5C2C8uB9j3IDEEYJRfpd/cIMS/0aLQSLcMa3BkecNZQ0nspSiT6
         NPhYjSUj0c+p23b2jyIikf65ne0pU+N/b7R6uv4bcl8sO+4vQu2jPFmQ3SiieNP7B1s2
         5bPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=DWxYFqFht/GTnBUrw50jGcXbdTjgIErrdzyLX70BJKc=;
        b=C+B0CjcBK2rmGk79rQUADraRDDu+poObSC4i9S6tezMCe5PU7ioagtyU20wMGOkqbd
         zLxed4tvSHNawUlvXZRmJ3RBFSOVVWAKMV59jmmFJ/I8dN30ABHKVr5Xycfjdkp6iiCg
         TK10MjtChqQiuEUq4hKy7rmpfiSAduJ8z/Pnx+Vhs3Iz2snsXgRysemw834MSqb39QFX
         lxEFQHxr/RQ9p9EKkL5bWfeWIQG/xZZE5vhGHiX1KuVC2XdRH8T3q6bR7o0hzhC5qb3s
         y1KRjdygpm9aa5eg3EHUNacU+ks+r9PNKy1iMvp0nqTPpNvebQYy5bpZTG+CFXo9946I
         MNVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="Uf/KtrOT";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="2HSi7Br/";
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id b16si3145679qtq.32.2019.03.11.18.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:54:56 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="Uf/KtrOT";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="2HSi7Br/";
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3818023176;
	Mon, 11 Mar 2019 21:54:56 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:54:56 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=DWxYFqFht/GTnBUrw50jGcXbdTj
	gIErrdzyLX70BJKc=; b=Uf/KtrOTzgHM/DVKJ0i0SYM1puQbNeo5DjesYmUCojg
	6eZDxn4eU6RurNSVtPL3EKm1kxCtoUmnnGkLStn2C62TmuywYz1t0+rqa9DbZVJY
	FZhC0HMn1KXZ3W9R0hvDfQpF3upZTuXeKhc6tNAFIqf/AXrHWphWpSo72TKkjXr0
	slBfXZzxZVqRe8lWzdX7bmfsN6CYQqM+uNnQlQmiLwRcGb/wWaEysYczOUmwag2Z
	fvT6vKzqUW8GO3b7hgGanMz6uebyNM6LShiHH7Y6eHQfHjIoRQ48FiTre2ZqH7tn
	6GYeQuIchvVTwEo00++K9cTyt6BwY45wGaH8NweGYlA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=DWxYFq
	Fht/GTnBUrw50jGcXbdTjgIErrdzyLX70BJKc=; b=2HSi7Br/pN+UMckjZh3KC5
	GZ1dG+6z2quFoSUwO4lPc64LxWCi1rfoF/shfxDC9swDyi7PJ74DdxYHDgIzs+xp
	pbMS1p7nA9DoO6i5EeJm2ae0sgIJPvLQ4BQ8rBe9zVpxAl+vhvjv1N8ytz3hb87q
	oKuZZYM9l6vMaNeezcsu5j8Dyqo3w8+VikvJjz76pHGsFhJwARlTJ+2clkzuBW9m
	PHgD9wpIZdRAuG8WsYdvAIL19J1kvbxaGGeeVgXu8KiweL0nbCnIW1n4+/wcIGag
	Ai7N7rGBCp0PCbaHZgUAHzOLDA7qMDzzhCI9jDkiLbmkji4KfihThzydv2CoLiSQ
	==
X-ME-Sender: <xms:bhGHXIY1Sa3BMaDcyURcL8rGVRZLnuMQqFvGaOKcopmG7Z2C4KEG8w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdefjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:bhGHXC-2KyZD3iH_YoXwop1pPkWXsZt6p2mdDJj_UAFUq3F-nqQirw>
    <xmx:bhGHXGtG51OEbRvgVdl2ZbrP3bMYpEjyQDqJ2VKlJOpB6eb6u__PhA>
    <xmx:bhGHXHFUgjSGEo9hBxyDTF5UYzjRLMmuTIL2evF0fJgPZz3Sob-10g>
    <xmx:cBGHXBnWiRcQl4KU5xa1yQEVHMLBa74qRrtCe8EkfFs0o5tX2Ni0ng>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1F935E4173;
	Mon, 11 Mar 2019 21:54:53 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:54:32 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 12/15] xarray: Implement migration function for objects
Message-ID: <20190312015432.GI9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-13-tobin@kernel.org>
 <20190312001602.GB25059@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312001602.GB25059@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:16:07AM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:23PM +1100, Tobin C. Harding wrote:
> > Implement functions to migrate objects. This is based on
> > initial code by Matthew Wilcox and was modified to work with
> > slab object migration.
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  lib/radix-tree.c | 13 +++++++++++++
> >  lib/xarray.c     | 44 ++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 57 insertions(+)
> > 
> > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> > index 14d51548bea6..9412c2853726 100644
> > --- a/lib/radix-tree.c
> > +++ b/lib/radix-tree.c
> > @@ -1613,6 +1613,17 @@ static int radix_tree_cpu_dead(unsigned int cpu)
> >  	return 0;
> >  }
> >  
> > +extern void xa_object_migrate(void *tree_node, int numa_node);
> > +
> > +static void radix_tree_migrate(struct kmem_cache *s, void **objects, int nr,
> > +			       int node, void *private)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < nr; i++)
> > +		xa_object_migrate(objects[i], node);
> > +}
> > +
> >  void __init radix_tree_init(void)
> >  {
> >  	int ret;
> > @@ -1627,4 +1638,6 @@ void __init radix_tree_init(void)
> >  	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
> >  					NULL, radix_tree_cpu_dead);
> >  	WARN_ON(ret < 0);
> > +	kmem_cache_setup_mobility(radix_tree_node_cachep, NULL,
> > +				  radix_tree_migrate);
> >  }
> > diff --git a/lib/xarray.c b/lib/xarray.c
> > index 81c3171ddde9..4f6f17c87769 100644
> > --- a/lib/xarray.c
> > +++ b/lib/xarray.c
> > @@ -1950,6 +1950,50 @@ void xa_destroy(struct xarray *xa)
> >  }
> >  EXPORT_SYMBOL(xa_destroy);
> >  
> > +void xa_object_migrate(struct xa_node *node, int numa_node)
> > +{
> > +	struct xarray *xa = READ_ONCE(node->array);
> > +	void __rcu **slot;
> > +	struct xa_node *new_node;
> > +	int i;
> > +
> > +	/* Freed or not yet in tree then skip */
> > +	if (!xa || xa == XA_FREE_MARK)
> > +		return;
> 
> XA_FREE_MARK is equal to 0, so the second check is redundant.
> 
> #define XA_MARK_0		((__force xa_mark_t)0U)
> #define XA_MARK_1		((__force xa_mark_t)1U)
> #define XA_MARK_2		((__force xa_mark_t)2U)
> #define XA_PRESENT		((__force xa_mark_t)8U)
> #define XA_MARK_MAX		XA_MARK_2
> #define XA_FREE_MARK		XA_MARK_0
> 
> xa_node_free() sets node->array to XA_RCU_FREE, so maybe it's
> what you need. I'm not sure however, Matthew should know better

Cheers, will wait for his input.

> > +
> > +	new_node = kmem_cache_alloc_node(radix_tree_node_cachep,
> > +					 GFP_KERNEL, numa_node);
> 
> We need to check here if the allocation was successful.

Woops, bad Tobin.  Thanks.


	Tobin.

