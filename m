Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D08B8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:09:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47281214D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:09:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="Uheoh4/k";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="YPQSz9Yt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47281214D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3DF88E0003; Mon, 11 Mar 2019 21:09:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE048E0002; Mon, 11 Mar 2019 21:09:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6018E0003; Mon, 11 Mar 2019 21:09:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6218A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:09:01 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b3so862401qkd.21
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:09:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l+C/7t2HYUsJ+vHzttMBMbmbnzSVGZi9bwSrZ1S6aNQ=;
        b=hF6/+Xo08A/XhQL+fvaL4ktvBwKM8jMRUTaUwzLuW2TiIUpt3cjD0O5Ii9nq/SlV+O
         7twHHpYFwJBPIZAjDTOMdyvScvmDQBECd6HAMLgbRRFgrUT5JAJYwfPcAUYvVwAMRJwz
         x6oJDx0XTL6tBDMyguXBwHhmZ2Lk1TKP/IzwuCq/ManbmtstE77a0T+AT6yr8UjrgrZ4
         dj7ZRD4jwO38ooqDU+ITV/7WePWu8H0BQ5dX1v2aKzV6ftSLJOyPvuOMf42CCspkBL40
         3EgApa7C7mKyCP432KaZsDI6/ZG8XZgPExPd6bzNfLQrHw6wAPni5FU3O7DXFXbRyqgf
         4s7Q==
X-Gm-Message-State: APjAAAUyVfvYD6n9pMQTjUPkf2AP9Sm5iYLhF34FTYLSMqKPExCllRiM
	ay9rWEQ+7aeMbP92EYR4Nk0ME5VBPJjuAxn3s78E0aw73uixcEqge4weHM6brhSB7jhcEJob0TO
	WUBRunxCTbDbhGWrjEqH1IShkqg1sulQ4qydatxvpFmcVWtYXjb+cjHwhTT5nx3kRpA==
X-Received: by 2002:a05:620a:148a:: with SMTP id w10mr25624275qkj.172.1552352941062;
        Mon, 11 Mar 2019 18:09:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA315iuDBtQeteQyzWrQ8+RtuPW5u/aufndEYyBGmmO/lG2T5VZ1YiPeAPd8AHXBeQJ1ks
X-Received: by 2002:a05:620a:148a:: with SMTP id w10mr25624241qkj.172.1552352940169;
        Mon, 11 Mar 2019 18:09:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352940; cv=none;
        d=google.com; s=arc-20160816;
        b=agkANS3S2JgjObuCNh9qeInJoEDEiKIBwELInD9iGcGnJckJUuLnDHm+5zEVyygwR+
         G+gL68vIdNQtGeqZylUfDel2WAtjqygNFngmVylBs+zFVEhyICYS0EMHe2g0QFNmSNSq
         bBBYDOfSpipUX1DNvnpWznZC51Oni2vJo/hWpojElk3jz2M/S61d930/qQBXw3zpadW4
         GKBnEeNGczFRjfXWTmiHDeLjdxPsqWrav4c0ESz5PnK14GSz5iPG5g3eqkDh0Osh3ga2
         grt+n8ohLH9lftGzMPhkwY7s50ZrAWQSJE6ML1nIRGI7KgGXL/W+749K131Qs8yJXZ1l
         pNcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=l+C/7t2HYUsJ+vHzttMBMbmbnzSVGZi9bwSrZ1S6aNQ=;
        b=EE8nQmMwDkHTaUqMTh/A5HNy8XKkddAUUMeqlEknjjf2G3qSCcF9QsVtAqyzWs3Vl/
         ljUSSvJDm2Z1DMinqrY/kYRNiK8MTH6IUwFPa4ZKqqFuHJNQ8U+MzGgpwJEfvkNQBQnw
         ua0ICGmXJI6U4r1CwqzW66SNgeS98XSwDFp7nm1MQ2EQYH0dyTi/q/l0LtgQ69pk8FSr
         w63hM6FRRIqw6v1+GS1D8aGt7AkKPs9K2zpxhihQ+gg+Mf2HadaSG+7EM9FyHj+nChpS
         +aaxnbpktMQjPVxxaXfHJaPopoNZ24tnuXeAbBnwJgQx2Z+aV0bEFsiAaP2jYwNCfuEA
         rOsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="Uheoh4/k";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=YPQSz9Yt;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id p67si2174636qkd.272.2019.03.11.18.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:09:00 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="Uheoh4/k";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=YPQSz9Yt;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id DBA9A20F1D;
	Mon, 11 Mar 2019 21:08:59 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:08:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=l+C/7t2HYUsJ+vHzttMBMbmbnzS
	VGZi9bwSrZ1S6aNQ=; b=Uheoh4/k18RVAtyaSvdDzav1sS4BEphLjUFPISDNot9
	Pr232WN4jiV/YOkZN/RWWHdmc3M36UuFaJHUc3BSFFHq5CCys/aluNfa/KXKZ+cm
	cZ4GoxsNQyObJTAn5A3eTNBxjtJvYLjHzmGIVQH14VR5CBIF0ODT5pA7f9SESjlt
	eZC55u/ySuJKpp/Ka6RN0yo5gNd5fP1iW7rFR0hLDdRmMU63+O50FAVbvAhlpcrz
	JRl5IOGErjcASKROUx/udIQx1UF8ngA/g6LvftQBG2xPISldAemptfqsSrPEaTbE
	6edDQvDz6NJQO436U3nVfof2W21b8BT1084uDhWsvEw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=l+C/7t
	2HYUsJ+vHzttMBMbmbnzSVGZi9bwSrZ1S6aNQ=; b=YPQSz9Ytma4UM+MH+EK+bA
	ThoF562ihz3sItoOzJU8L6IbvaG1WMVF/4+N4qhrrVS5dnihZtds4i2MKUhDUzrS
	b4IWfMDw35F5+Updgp8GAryvRXgWaMkX8sozwwu12DbxnO4yVxMDlv4OEGcAlT/u
	svydKo+H0lnHaZ3czLpCbWk70loNURM9r6csJoIgmtwbuGW41QZ2ZajkHj1J50hJ
	1oqMTBx2kH+JeSEZKlszIf/L5MtR00u4lEL2GzIUjscKu6qNAYm2qAwb2nrl8W66
	FVeo1fuUWSFVcEzypgHemCOcJAeRBZmpL4rANXP8VpKqhp3U0IcDzrTcGcAMf9VA
	==
X-ME-Sender: <xms:qgaHXMWjQk_xQiGODPIlFygEYplFd1b7v9-el5HrxSO6NM4l2f1pFw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:qgaHXBFAhfEIuza9nPkF1MC6_6rug-JyLmFTkZR0_N9pOucZo7sBkg>
    <xmx:qgaHXCF3X3QziVMHnS9NIrnv6qdG0pk5h-J3zZESLGQ-iQwhGTrk2w>
    <xmx:qgaHXGuUulTPXm44ORkRh29yfMcHQwtpbnwqYKhrPTjSZsfBIcPqXQ>
    <xmx:qwaHXE4iA9hAnQ6I0ZVJ0MGiaKchssMQgGOOL8K5LBXOTOAjdLuddA>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0A36AE40C1;
	Mon, 11 Mar 2019 21:08:57 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:08:36 +1100
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
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Message-ID: <20190312010836.GC9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
 <20190311215106.GA7915@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311215106.GA7915@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 09:51:09PM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> > Add the two methods needed for moving objects and enable the display of
> > the callbacks via the /sys/kernel/slab interface.
> > 
> > Add documentation explaining the use of these methods and the prototypes
> > for slab.h. Add functions to setup the callbacks method for a slab
> > cache.
> > 
> > Add empty functions for SLAB/SLOB. The API is generic so it could be
> > theoretically implemented for these allocators as well.
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  include/linux/slab.h     | 69 ++++++++++++++++++++++++++++++++++++++++
> >  include/linux/slub_def.h |  3 ++
> >  mm/slab_common.c         |  4 +++
> >  mm/slub.c                | 42 ++++++++++++++++++++++++
> >  4 files changed, 118 insertions(+)
> > 
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 11b45f7ae405..22e87c41b8a4 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -152,6 +152,75 @@ void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
> >  void memcg_deactivate_kmem_caches(struct mem_cgroup *);
> >  void memcg_destroy_kmem_caches(struct mem_cgroup *);
> >  
> > +/*
> > + * Function prototypes passed to kmem_cache_setup_mobility() to enable
> > + * mobile objects and targeted reclaim in slab caches.
> > + */
> > +
> > +/**
> > + * typedef kmem_cache_isolate_func - Object migration callback function.
> > + * @s: The cache we are working on.
> > + * @ptr: Pointer to an array of pointers to the objects to migrate.
> > + * @nr: Number of objects in array.
> > + *
> > + * The purpose of kmem_cache_isolate_func() is to pin each object so that
> > + * they cannot be freed until kmem_cache_migrate_func() has processed
> > + * them. This may be accomplished by increasing the refcount or setting
> > + * a flag.
> > + *
> > + * The object pointer array passed is also passed to
> > + * kmem_cache_migrate_func().  The function may remove objects from the
> > + * array by setting pointers to NULL. This is useful if we can determine
> > + * that an object is being freed because kmem_cache_isolate_func() was
> > + * called when the subsystem was calling kmem_cache_free().  In that
> > + * case it is not necessary to increase the refcount or specially mark
> > + * the object because the release of the slab lock will lead to the
> > + * immediate freeing of the object.
> > + *
> > + * Context: Called with locks held so that the slab objects cannot be
> > + *          freed.  We are in an atomic context and no slab operations
> > + *          may be performed.
> > + * Return: A pointer that is passed to the migrate function. If any
> > + *         objects cannot be touched at this point then the pointer may
> > + *         indicate a failure and then the migration function can simply
> > + *         remove the references that were already obtained. The private
> > + *         data could be used to track the objects that were already pinned.
> > + */
> > +typedef void *kmem_cache_isolate_func(struct kmem_cache *s, void **ptr, int nr);
> > +
> > +/**
> > + * typedef kmem_cache_migrate_func - Object migration callback function.
> > + * @s: The cache we are working on.
> > + * @ptr: Pointer to an array of pointers to the objects to migrate.
> > + * @nr: Number of objects in array.
> > + * @node: The NUMA node where the object should be allocated.
> > + * @private: The pointer returned by kmem_cache_isolate_func().
> > + *
> > + * This function is responsible for migrating objects.  Typically, for
> > + * each object in the input array you will want to allocate an new
> > + * object, copy the original object, update any pointers, and free the
> > + * old object.
> > + *
> > + * After this function returns all pointers to the old object should now
> > + * point to the new object.
> > + *
> > + * Context: Called with no locks held and interrupts enabled.  Sleeping
> > + *          is possible.  Any operation may be performed.
> > + */
> > +typedef void kmem_cache_migrate_func(struct kmem_cache *s, void **ptr,
> > +				     int nr, int node, void *private);
> > +
> > +/*
> > + * kmem_cache_setup_mobility() is used to setup callbacks for a slab cache.
> > + */
> > +#ifdef CONFIG_SLUB
> > +void kmem_cache_setup_mobility(struct kmem_cache *, kmem_cache_isolate_func,
> > +			       kmem_cache_migrate_func);
> > +#else
> > +static inline void kmem_cache_setup_mobility(struct kmem_cache *s,
> > +	kmem_cache_isolate_func isolate, kmem_cache_migrate_func migrate) {}
> > +#endif
> > +
> >  /*
> >   * Please use this macro to create slab caches. Simply specify the
> >   * name of the structure and maybe some flags that are listed above.
> > diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> > index 3a1a1dbc6f49..a7340a1ed5dc 100644
> > --- a/include/linux/slub_def.h
> > +++ b/include/linux/slub_def.h
> > @@ -99,6 +99,9 @@ struct kmem_cache {
> >  	gfp_t allocflags;	/* gfp flags to use on each alloc */
> >  	int refcount;		/* Refcount for slab cache destroy */
> >  	void (*ctor)(void *);
> > +	kmem_cache_isolate_func *isolate;
> > +	kmem_cache_migrate_func *migrate;
> > +
> >  	unsigned int inuse;		/* Offset to metadata */
> >  	unsigned int align;		/* Alignment */
> >  	unsigned int red_left_pad;	/* Left redzone padding size */
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index f9d89c1b5977..754acdb292e4 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
> >  	if (!is_root_cache(s))
> >  		return 1;
> >  
> > +	/*
> > +	 * s->isolate and s->migrate imply s->ctor so no need to
> > +	 * check them explicitly.
> > +	 */
> >  	if (s->ctor)
> >  		return 1;
> >  
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 69164aa7cbbf..0133168d1089 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -4325,6 +4325,34 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
> >  	return err;
> >  }
> >  
> > +void kmem_cache_setup_mobility(struct kmem_cache *s,
> > +			       kmem_cache_isolate_func isolate,
> > +			       kmem_cache_migrate_func migrate)
> > +{
> 
> I wonder if it's better to adapt kmem_cache_create() to take two additional
> argument? I suspect mobility is not a dynamic option, so it can be
> set on kmem_cache creation.


Thanks for the review.  You are correct mobility is not dynamic (at the
moment once enabled it cannot be disabled).  I don't think we want to
change every caller of kmem_cache_create() though, adding two new
parameters that are almost always going to be NULL.  Also, I cannot ATM
see how object migration would be useful to SLOB so changing the API for
all slab allocators does not seem like a good thing.

thanks,
Tobin.

