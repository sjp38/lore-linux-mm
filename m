Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0711C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:47:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CBE6214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:47:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="y7wXdvON";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Kz4fpROf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CBE6214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5AA18E0003; Mon, 11 Mar 2019 21:47:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0AC18E0002; Mon, 11 Mar 2019 21:47:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1138E0003; Mon, 11 Mar 2019 21:47:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78A938E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:47:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 23so478714qkl.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:47:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2hF6d6fZeUwH8051ioQNCV9dfHEA8Z+yoBZ4if8TWas=;
        b=Nugainhtuop27SQ3Je22Db6wNH3wo4zUffcBdXDXTSB/Z7WV0elbfzvvoMnXUooK50
         Xn4WIxYJ6VmZwZUzgNvUSazOkUzIxDmzQUQv1veYiy4Mreeh1bj2jJyK8OG0XYl3yQrj
         4/qt7Xcdu9MfmhD/NnBpOAzC2QxeHVm9UDNS2QH5Sr8iipE1De2BXtoBkSHZSUe4Nq8m
         CqvofEk5gqpVYtx0agoXU7Jwa52q+KItseyssbk2d/Z0PjQRge8z8YFxwOf4nPiZ0KFh
         lPW676VvHpbi+cRceyDeygQnCP31A+qDeNwJ1hO2SKY//2gdi4OtN+s/T9j1giXXi43L
         AkTA==
X-Gm-Message-State: APjAAAUXqo/5EfgdeXupd5wolsKFgMBW0FUaB32ryXom8PLbB1nBCrxo
	t85PPa5F+zCjO04prue3D/HLiGSYrf5hY+i4/RV9VXvKNPuKEIb0aQo4eJ6LhzJeuq/3zw8iHhh
	HG4FdvWqfJdd9ADU0gqUOhWK509R3avh5LaKZCaoKtqSSz5Q9YUhKx4fxcprP8/U/0w==
X-Received: by 2002:aed:3b14:: with SMTP id p20mr28259588qte.240.1552355264235;
        Mon, 11 Mar 2019 18:47:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNw26CX4DTZIGQLtL0Ajje+hC4gbO3p1jOrRHbWt8GDo8jMXw4T4ISNScHNqxuD0zp8yfC
X-Received: by 2002:aed:3b14:: with SMTP id p20mr28259544qte.240.1552355263252;
        Mon, 11 Mar 2019 18:47:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552355263; cv=none;
        d=google.com; s=arc-20160816;
        b=z9H2AnuFv5Xg92o4eoSgkSP3NjwARe4n50xFx2W6E5N23vPDOIacigNLMqKnapeRjH
         UR42RaYiPbNPke5gNF3Hp6UciU65ZycQijkDvosr4SWmSUIQ+CMX820dRWnvuOUZ45Wx
         wB/7zi/mPGBo0rIqdF3PI6CgwNo3gRct+Qyql8K3A3QocSWjqOPFFBkgHXcuuFDpwlpU
         k90tDK70cn5eezTOPL8RjRqmUa6sokKd+hLQcpBF0Ft3AQBLr23w4iBzm06shTzAXOlx
         zMqvJusoiASE+MpsVfJ6knQ+E2Z7o0GXAt1k1kMB+VKssfq+rjNPI3pN44FRWzKXRzgj
         UyuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=2hF6d6fZeUwH8051ioQNCV9dfHEA8Z+yoBZ4if8TWas=;
        b=CauSI0N6bacYO2rvfidzgRRV0fKjc/wtYH8njheM3OKzpT9WEFtFdBfJXspOWJ2RpC
         ND5OknWWTkswphL6oQvdgtXu9xDGC55bs9ROlpXIjnSDFvMBuaiOJ13qN9GYYyRoQpwS
         j/quumL8bfrz0/G/ZIv+7Mc2LYvc0HsDJnub3Lup/qfpxsVuhkLi+DXoioQEQGU2ExPq
         Kuh75k97aG5OzbHH1vM3WSmIWRudw5j3RAxI0L4csFJM8XeZOJnmYOAvgE+0AVMPPy+i
         ZD3KGl0CnVNxCYjqnAiJxDX4tstWHsAxD/wUufG6DUirX3psQYw1+w9PUCX8Hsy4CbwE
         k1Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=y7wXdvON;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Kz4fpROf;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id e7si4177127qkb.189.2019.03.11.18.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:47:43 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=y7wXdvON;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Kz4fpROf;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D3616216AC;
	Mon, 11 Mar 2019 21:47:42 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:47:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=2hF6d6fZeUwH8051ioQNCV9dfHE
	A8Z+yoBZ4if8TWas=; b=y7wXdvON5UqpZqv6I9bl5qlvGVkSNQut+QiNC5WuiRI
	6cDOuowo+0exbKZC+0SBnVP0/mQlREiNtXSgPC25DwCZTa1dtZ9PhWkoi9jaGkEP
	1CoBeHEE2LVsii0ano+1sufTQS07h1CBNGZ4c0w4mnQ91ewrcz51IrwBiB/2ygRV
	fuwds1wxZVoZ/Cl7PEpNDEPSxd5AHVSmbmBnrvnvbpjwS71wTQ3rJj/fEpuvd50v
	BMTW1NdkG6DnniyuLCv3jcFTaQt3V9YZ60sdtzVRRWuyxsaojPbhRLNILm654otH
	unJrAbB/pX54P9xm5C5W7E9vn0wi+PuCxDIKsOHpLfA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=2hF6d6
	fZeUwH8051ioQNCV9dfHEA8Z+yoBZ4if8TWas=; b=Kz4fpROf5JbK8QyCEK1XcJ
	xi0JWRY74K+KM25IOs5B0hwQ7hdrag5FQRkHGd1C+QfatPpw5e082LlUlf4ovxZ9
	PcktF5T5OOXab698bMX2pv9xwla09MpUzCPLFsQ1/upIYy7gW7Jp5OKyJpdFh9rY
	1hYc4sQDW9hueXdUFWnWksz8v5tSxKfWx48IEkNUocLM99oZGrxYmXTQG71+nXAw
	kV0qnR5ImOfoGkjyEhNH1D0MK9ekbY9QmB9kjxUdzb8rj5gB/9U86f0NTLp74k0q
	kUSIuUBSJ0a7ZvKP2iDLMcW8jihRJdZU42o4qB8Q1Ny6tlr5CD6kJd7nON42zKPg
	==
X-ME-Sender: <xms:vA-HXLDDBpTjR7fu0GkQKx54-My5pTOzdhXuXKgyAFmASD5jZ5kxnA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdefiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:vA-HXIZWmcW2v-OhaM7udWya5_5cfPglg8-0h1uybAdtAJrMbEAcWg>
    <xmx:vA-HXM1cIQwkwFcPy3YRgjhx_Jj6zXqrV-_d-FJ7iUOkjWS65RGG0w>
    <xmx:vA-HXOICcOK3g0CwrkIERjWa_-gN0yl_EG1H9YNq8iFjLRZkDgacBQ>
    <xmx:vg-HXIpGGPrblNnDNsHLPonET9_uGkpM1WpPei2X6G_xbdEV45ckkw>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id A158B1033A;
	Mon, 11 Mar 2019 21:47:39 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:47:12 +1100
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
Subject: Re: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Message-ID: <20190312014712.GF9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-5-tobin@kernel.org>
 <20190311224842.GC7915@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311224842.GC7915@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 10:48:45PM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:15PM +1100, Tobin C. Harding wrote:
> > We have now in place a mechanism for adding callbacks to a cache in
> > order to be able to implement object migration.
> > 
> > Add a function __move() that implements SMO by moving all objects in a
> > slab page using the isolate/migrate callback methods.
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  mm/slub.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 85 insertions(+)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 0133168d1089..6ce866b420f1 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -4325,6 +4325,91 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
> >  	return err;
> >  }
> >  
> > +/*
> > + * Allocate a slab scratch space that is sufficient to keep pointers to
> > + * individual objects for all objects in cache and also a bitmap for the
> > + * objects (used to mark which objects are active).
> > + */
> > +static inline void *alloc_scratch(struct kmem_cache *s)
> > +{
> > +	unsigned int size = oo_objects(s->max);
> > +
> > +	return kmalloc(size * sizeof(void *) +
> > +		       BITS_TO_LONGS(size) * sizeof(unsigned long),
> > +		       GFP_KERNEL);
> 
> I wonder how big this allocation can be?
> Given that the reason for migration is probably highly fragmented memory,
> we probably don't want to have a high-order allocation here. So maybe
> kvmalloc()?
> 
> > +}
> > +
> > +/*
> > + * __move() - Move all objects in the given slab.
> > + * @page: The slab we are working on.
> > + * @scratch: Pointer to scratch space.
> > + * @node: The target node to move objects to.
> > + *
> > + * If the target node is not the current node then the object is moved
> > + * to the target node.  If the target node is the current node then this
> > + * is an effective way of defragmentation since the current slab page
> > + * with its object is exempt from allocation.
> > + */
> > +static void __move(struct page *page, void *scratch, int node)
> > +{
> 
> __move() isn't a very explanatory name. kmem_cache_move() (as in Christopher's
> version) is much better, IMO. Or maybe move_slab_objects()?

How about move_slab_page()?  We use kmem_cache_move() later in the
series.  __move() moves all objects in the given page but not all
objects in this cache (which kmem_cache_move() later does).  Open to
further suggestions though, naming things is hard :)

Christopher's original patch uses kmem_cache_move() for a function that
only moves objects from within partial slabs, I changed it because I did
not think this name suitably describes the behaviour.  So from the
original I rename:

	__move() -> __defrag()
	kmem_cache_move() -> __move()
	
And reuse kmem_cache_move() for move _all_ objects (includes full list).

With this set applied we have the call chains

kmem_cache_shrink()		# Defined in slab_common.c, exported to kernel.
 -> __kmem_cache_shrink()	# Defined in slub.c
   -> __defrag()		# Unconditionally (i.e 100%)
     -> __move()

kmem_cache_defrag()		# Exported to kernel
 -> __defrag()
   -> __move()

move_store()			# sysfs
 -> kmem_cache_move()
   -> __move()
 or
 -> __move_all_objects_to()
   -> kmem_cache_move()
     -> __move()


Suggested improvements?

> Also, it's usually better to avoid adding new functions without calling them.
> Maybe it's possible to merge this patch with (9)?

Understood.  The reason behind this is that I attempted to break this
set up separating the implementation of SMO with the addition of each
feature.  This function is only called when features are implemented to
use SMO, I did not want to elevate any feature above any other by
including it in this patch.  I'm open to suggestions on how to order
though, also I'm happy to order it differently if/when we do PATCH
version.  Is that acceptable for the RFC versions?


thanks,
Tobin.

