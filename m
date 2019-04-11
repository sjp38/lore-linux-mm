Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FE4EC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAC9F217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:48:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="CczKK/Up";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Nij/jYo7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAC9F217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A13D6B0005; Wed, 10 Apr 2019 22:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3312E6B0006; Wed, 10 Apr 2019 22:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CB0D6B0007; Wed, 10 Apr 2019 22:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC6B66B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 22:48:58 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id g25so3781979qkm.22
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 19:48:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ztcvo5tzwaFClMvheLNTkVLAOO9IWg4XzDUHACT0MIk=;
        b=YLF81aAu4JQ3Y1v66wgmDa00RbS1xDo6FKIzfWeXxpDs474kUN26lKPO4i0ehLruGL
         nUhLPwnnBdLVvKRF+gJxVciD9AUHdv81YlF+Th8A8z2Lytns2QMqpd6UXLD8jWms1VD2
         9BNBtzAXc4yzz3IyZKsifoVi6Kqtc7FKG4AY2G42PJbBKtb12eUnlyGK6DXO9/9+IPI/
         BbJDxPAnVs5EXG5fgGhnX1C5HU/bjojV+9t8YbR3rPf/WY1+tIoEeXKsUgiJG8lO8LFq
         ELQvg5QZbHzERHd1iHrZaNel1nxRzz8Iok9G8iXSTSTCNGNGhh5yW0wilmH8sWc92smx
         ZGBw==
X-Gm-Message-State: APjAAAXPLRhb7QZi4oqBRrYc6qEoeiGw/Z61t0xnlTNbLuvROS/WRa+r
	/IdS7XguOf1oNQvtb0D6+kuxQSo1WPvkoyD4IyaEwww/21ZNJMyhMPoBZQjZEKWBVmf5OETJynA
	zqBuh8rxrJTY6dcvdXOsiCkxD60tnw7o8KdBQhTDOprwZbDK3f5ZyV40ZN13iWQlZtQ==
X-Received: by 2002:ac8:3202:: with SMTP id x2mr41065776qta.56.1554950938680;
        Wed, 10 Apr 2019 19:48:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwelyecPLHn28ry+iD4KKBgGbqwb8QHZGdkfYMHOXiNF/4i2QpEZbxNKEzFIoOE+fMFRMmc
X-Received: by 2002:ac8:3202:: with SMTP id x2mr41065740qta.56.1554950937837;
        Wed, 10 Apr 2019 19:48:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554950937; cv=none;
        d=google.com; s=arc-20160816;
        b=wX74mm7RtiGSDwSBOOqwNp8aHCDkdfjTa+RKgD3aEyrk/Is2/JVhaDmKuMZ2FWf+DV
         vv6AXuY8D5QS2QlJm80wUgyWgYAQuLUKMSk1OKEiJYNbRTzwozOGF8cnuX0E0eVqDdid
         q6cfx7+l0d5+GyK6jNquyojFZespFsGYNf6lzKQ93L3BicrbIdE3TodiTug0euZG5kU8
         TuGtb1O7xaQ7JwdCWQrB9Tdoh+/pPJQxRCjSqCita1PTAxbSVhwHasOvn1etTCe4E26/
         KgGJLM4WsNzuDhRAyuoui7Hl0ylldFSHbr/S3uQGZ1RFrTomR2KaZwKSJQPWYtJ+2yYL
         9WPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=Ztcvo5tzwaFClMvheLNTkVLAOO9IWg4XzDUHACT0MIk=;
        b=NJtw13G+WonVLSVwlg/9B6VCAdV4jwtGs9dJdPzXK60YUg7tvZHls2rC1xgxttQB/z
         LfU5ek8S80pc04PQrh5/r63wvxy3jcdEzsofaMoAbvZgFKtoVHHrU3YzQvPzwJ1I575i
         Xgiv+Q2ozJZ7zKMKXqewjH8E0K4bfSSoC6LiK8K30oKpRXPnRsKzLcWcuJiEPNu4BddE
         GiK82/S8jMz77fOYMvZDnk/ESw9M3s7XrD/QAPQWyG4h9H/zajFzD7TEAquQfzhoxA99
         iKjILZkvaNDt2odQImZx8+H9mlsqbSW7nOd3uK8Vv1qJDGpg0MuEyo7E8nvg7iDPfa/Y
         4Rrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="CczKK/Up";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="Nij/jYo7";
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id n36si12114307qtc.149.2019.04.10.19.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 19:48:57 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="CczKK/Up";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="Nij/jYo7";
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id 649D2113D7;
	Wed, 10 Apr 2019 22:48:57 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Wed, 10 Apr 2019 22:48:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=Ztcvo5tzwaFClMvheLNTkVLAOO9
	IWg4XzDUHACT0MIk=; b=CczKK/UpqlaE8ij9ODtsMzCN51UGs5BaN3vhxw+QzQN
	QiBxrC9EhyYD/YSP1PLlyh5jckFIkvJo2dGY22ABQBz4ROJaLJ7NMVoZDhBW0cGf
	7r32PoV8+ClgincFaKBqpEVZYYBOzSB9rRBbDSrDH+Rhr8mZs645XaJx5XaEuyOL
	vrosurzjoQYAg2WzwHJcSyuP2R+qBhbnETWUTZLyfrngzqPc9qcdQbokMP+xmy0g
	rWdCNnuXvC+k8nYe3aHDTaeFunsgx9UOKoKGV9nQjOXycahk5cVlWHY4nx5kZnje
	sa2caR+gXKt3FZ+6Zq4sJppDEL0HEPZGBtFJpvMirYQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=Ztcvo5
	tzwaFClMvheLNTkVLAOO9IWg4XzDUHACT0MIk=; b=Nij/jYo73SXKw9F3WTL7v7
	2LKISPZawvwkYwwBjJ8fnt/37bdO75Gpsx1rqZhhPf633E8j63zNYoVFkLI831+N
	q++a5LJDjOnBzPtUiqAmb9m1x9nm9/XkUEAER6H/XQWc0E0iaVZ5PTMG0Z7cyb+J
	PYeJ2kTRPwAjI6xVOkUSb0HSkE67m8bMt4Jph72HQEajl+Cj7OXiBBUnpqkAP7pZ
	LGD0T31Kw6OL6wmy5bleLqJYmjnMOwyhcV6wZutAXbNVJVi/2k0+uUnaSxum3Zap
	e40lS2AaiWEzE7/k5EqEW6VfYxfMc8kOBet9Q3Yds9NgKizb14e4FfZB9EtjRvmA
	==
X-ME-Sender: <xms:FquuXCD__WHgfLF1IgUJ_mZLRxvFpv_PDh5i36exKA95qOKgSmo4Og>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdehjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:FquuXI1Nh58jOHfjG361yQauKiJS0oO07wMS4ycnqLIVs5jyuXUNmw>
    <xmx:FquuXIW8Q0__Zv7zpyWgw-n8Hfi5KXsTSYMxpbFWFsPz3uj1hNAtSw>
    <xmx:FquuXCliZpS2tGZzv9ewDpxic2VCl_h1kvHrKz6782qS8NTlE3TSbw>
    <xmx:GauuXD1FhZA59VGtRmR7cFmcKrurXFHxl-UoOjiv5xYGOT5YMrOBOw>
Received: from localhost (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id E902FE4382;
	Wed, 10 Apr 2019 22:48:52 -0400 (EDT)
Date: Thu, 11 Apr 2019 12:48:21 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
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
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190411024821.GB6941@eros.localdomain>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411023322.GD2217@ZenIV.linux.org.uk>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 03:33:22AM +0100, Al Viro wrote:
> On Thu, Apr 11, 2019 at 11:34:40AM +1000, Tobin C. Harding wrote:
> > +/*
> > + * d_isolate() - Dentry isolation callback function.
> > + * @s: The dentry cache.
> > + * @v: Vector of pointers to the objects to isolate.
> > + * @nr: Number of objects in @v.
> > + *
> > + * The slab allocator is holding off frees. We can safely examine
> > + * the object without the danger of it vanishing from under us.
> > + */
> > +static void *d_isolate(struct kmem_cache *s, void **v, int nr)
> > +{
> > +	struct dentry *dentry;
> > +	int i;
> > +
> > +	for (i = 0; i < nr; i++) {
> > +		dentry = v[i];
> > +		__dget(dentry);
> > +	}
> > +
> > +	return NULL;		/* No need for private data */
> > +}
> 
> Huh?  This is compeletely wrong; what you need is collecting the ones
> with zero refcount (and not on shrink lists) into a private list.
> *NOT* bumping the refcounts at all.  And do it in your isolate thing.

Oh, so putting entries on a shrink list is enough to pin them?

> 
> > +static void d_partial_shrink(struct kmem_cache *s, void **v, int nr,
> > +		      int node, void *_unused)
> > +{
> > +	struct dentry *dentry;
> > +	LIST_HEAD(dispose);
> > +	int i;
> > +
> > +	for (i = 0; i < nr; i++) {
> > +		dentry = v[i];
> > +		spin_lock(&dentry->d_lock);
> > +		dentry->d_lockref.count--;
> > +
> > +		if (dentry->d_lockref.count > 0 ||
> > +		    dentry->d_flags & DCACHE_SHRINK_LIST) {
> > +			spin_unlock(&dentry->d_lock);
> > +			continue;
> > +		}
> > +
> > +		if (dentry->d_flags & DCACHE_LRU_LIST)
> > +			d_lru_del(dentry);
> > +
> > +		d_shrink_add(dentry, &dispose);
> > +
> > +		spin_unlock(&dentry->d_lock);
> > +	}
> 
> Basically, that loop (sans jerking the refcount up and down) should
> get moved into d_isolate().
> > +
> > +	if (!list_empty(&dispose))
> > +		shrink_dentry_list(&dispose);
> > +}
> 
> ... with this left in d_partial_shrink().  And you obviously need some way
> to pass the list from the former to the latter...

Easy enough, we have a void * return value from the isolate function
just for this purpose.

Thanks Al, hackety hack ...


	Tobin
	

