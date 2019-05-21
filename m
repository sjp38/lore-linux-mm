Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A95F2C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:32:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D20821479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:32:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="lB8rpyD1";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Berg9P+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D20821479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27876B0003; Mon, 20 May 2019 21:32:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB0996B0005; Mon, 20 May 2019 21:32:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D77C76B0006; Mon, 20 May 2019 21:32:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3C026B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:32:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z7so9534745qtj.2
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:32:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XT/UdYnmx7GrDaJa60CFoxeSSHk/OGQKeLYVIbFsryY=;
        b=DQU4WQeXIoJI7SVDl3d9UY3Ti4qe44PeUdN1px4muN7Ay8J3S7rYexrVRCFONzmjk6
         eDKPqd829PrY6k2+kbKqoFII9RsbgY+PMwiiyjJsuD3togYfRL269Lmj0NzIh9zmC85i
         i2ckPy2wclpOjaqw+2zjbBe+Q+9FHWCQpmdsUABOj4PRBZYwajfN9QgkHGAsorF0eYix
         ZD3b7sBDoqkxpmNaNwGdo+2VV4tFXEqYrwErtFyPkuOJgOMnOTSuLb8IlnG5vYM9eFMA
         wWlLnUUMaUQLxqmwfPRVJIGOmdbKmTLpXRqGwXdDVxx3yQw57lwAf8xqmAIZDfsT613j
         Pkcw==
X-Gm-Message-State: APjAAAVZW81EiuNjFEA4xwjXLpVFMPsUJ2Zi38e3zYVi6fGSAL+73X+t
	khaTbZrkCgzEFdIXnWXf8DI5EwtWB9u2cfK1NZS6iHMWmsUOv5ZZOcg+sfLSJALoVAxO8M2D0t9
	zuE0+z8fcj8w3Ri95Ef7w5WdmIIbbaqkGb7NYmzoIlsqzNxKeyFDERQVsSu0Akj+GaA==
X-Received: by 2002:a0c:980b:: with SMTP id c11mr63775963qvd.115.1558402324467;
        Mon, 20 May 2019 18:32:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQNR57AO/XLyvj7n0zaRzqGuQX+nECLcXS88a8SHRE5DxZ956Ybdsp/2EZnIOzDiua/TOG
X-Received: by 2002:a0c:980b:: with SMTP id c11mr63775910qvd.115.1558402323831;
        Mon, 20 May 2019 18:32:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558402323; cv=none;
        d=google.com; s=arc-20160816;
        b=JA+pBUlAO3FTdci8R2xlJoWpkCwyJpXlaFdwGglfV2u4OAx8N5/dLdBt8LRHNNd43p
         HwPQVdtglA22xWSLfRymt+gPP/VWTom3JRGjxVLbwBzSuN4zy1vS5i8zLhFW6eY0dtnS
         S05XzvYZO17vXxRcwpAIkz3IFx6UYUjAsJiYpBOOYrnB6fcP30IGVPedSuVfdKqfhFPM
         4NiTP0V8mZueHXBw9xdcfZKfvjIO/B3VZnE2DyInmJguKHD8H/loXRfEnwHgkLgpN7U1
         4j75VxRfeiQLmvjyxaA8rQsjl7u1cnFFmomsCSs2mDshTxzNutcLZSCVefy/O/PYiO+I
         mS5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=XT/UdYnmx7GrDaJa60CFoxeSSHk/OGQKeLYVIbFsryY=;
        b=J/ao+Mc78QtrdESnqmqC+PMRzclbs8aAyn7r5SUCcOF3ftff0yiCtcuLCYCSBdZXtc
         RsAKhLsPvtQMCSfGXClqmcZPdM2b7y2dlCr4MhpM44mPvvGLoOaY2zgHRhqXdlI1dG+2
         ZbNUXk7TGOU60PjSyXTwcp5mSL1lpffGOSi1hsYpujAG8DBeN3jotF5bAjlwReHjqZiH
         sOiZ822OKN9ghsr3yeycehleRRYFXt02iRCrLruArWqAdpdboJW8U9R/gdNPR+kL8sYi
         OSCvYP5YSSAZ73JmP/Xrsl57VJHAbfJQwHTvhTWxUNTPm2nu4VFhjTaCGz1D9s5kUg7m
         m5iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=lB8rpyD1;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Berg9P+n;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id o18si1628119qkk.157.2019.05.20.18.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:32:03 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=lB8rpyD1;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Berg9P+n;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id 3E68295B1;
	Mon, 20 May 2019 21:32:03 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 20 May 2019 21:32:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=XT/UdYnmx7GrDaJa60CFoxeSSHk
	/OGQKeLYVIbFsryY=; b=lB8rpyD1L4izyfnU4fBk6mH7b53SchEIWKjue1YVeRl
	NaxeXlXU3AaPgw36mvOLaTbLtOUPaDqMeT+GaLwkFcvhHpd8QV5CTYxWtlLjz7YE
	zCMCS+eSHHf3MGGbaplZ9ZHBqMEbvDTmovpvTZNIl3eC79ObvEjTPK4so04BUjH4
	xTz/EIuOAoBWxpMI1bk03H3M2qey9Wmhj0nxuo24oYJolUm31DvtrPDTfLwxua0U
	AJyYFkychOiXckDOeIr78aAlFUCDhP4WE2x7fE6WlwlzijeFQ5ve14lm4INg0KpF
	OjFJFr0Uy8Vp9Yzk4ITBJG7Qkrj8hpH1+jnXnIDGkbQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=XT/UdY
	nmx7GrDaJa60CFoxeSSHk/OGQKeLYVIbFsryY=; b=Berg9P+nH9RaKmggVwHyFY
	ApnFW6s0HIqbC+uMEYd8rjX2+6kWRsRoQp+raQ2T9qfB7WC+tagKTopn3HoXZ27s
	39IJChaiXtznrwkVkZTcAJSBT0LGYCBfs7/B8Ht/4L7CPKM6pME6GRqigMejfStF
	T3CfnV8eyI/SSLfHCcngFmO5+CE/puyR5j7NHmCWaEVDWYDPNSMreOeK8bB+sNkZ
	SLCOgynt+12z9I141bI2lzYDPCZimSWYxkjaUqUcNPrr9FyjJrDg2RnX1X3zh5sO
	W7Wg09xwB2quTckKG1cV1Fbj0QeZMUrx4GOQKLPk/zRmgjUjYBMGW7mnY5NClFTw
	==
X-ME-Sender: <xms:D1XjXAfATuU3Uag8wco2cm4s08ym59tHCiZtH1Cc9iosm-DbvUQ9jA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtledggeeiucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrdduieelrdduheeirddvtdefnecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:D1XjXOIir_QTYGS-KY606mTBNFzQq-3A2lmPVbGkjZzrv9G36JbWGw>
    <xmx:D1XjXEkD0kkSzgiUKY5Y1K_HxDHL4yq4zvtG4DB2Yo4nWmGOySzttA>
    <xmx:D1XjXBWseqKrRdaZT63yAe7xvv8CMZwaOc-enQ-nA1EZod8iZkHtRQ>
    <xmx:E1XjXIGw8idhiXFZEFQXC6iOs0Uu7FRcPRe_sWu08XKXEIq31RyoTw>
Received: from localhost (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id D925610379;
	Mon, 20 May 2019 21:31:57 -0400 (EDT)
Date: Tue, 21 May 2019 11:31:18 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Message-ID: <20190521013118.GB25898@eros.localdomain>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-17-tobin@kernel.org>
 <20190521005740.GA9552@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521005740.GA9552@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:57:47AM +0000, Roman Gushchin wrote:
> On Mon, May 20, 2019 at 03:40:17PM +1000, Tobin C. Harding wrote:
> > In an attempt to make the SMO patchset as non-invasive as possible add a
> > config option CONFIG_DCACHE_SMO (under "Memory Management options") for
> > enabling SMO for the DCACHE.  Whithout this option dcache constructor is
> > used but no other code is built in, with this option enabled slab
> > mobility is enabled and the isolate/migrate functions are built in.
> > 
> > Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache via
> > Slab Movable Objects infrastructure.
> 
> Hm, isn't it better to make it a static branch? Or basically anything
> that allows switching on the fly?

If that is wanted, turning SMO on and off per cache, we can probably do
this in the SMO code in SLUB.

> It seems that the cost of just building it in shouldn't be that high.
> And the question if the defragmentation worth the trouble is so much
> easier to answer if it's possible to turn it on and off without rebooting.

If the question is 'is defragmentation worth the trouble for the
dcache', I'm not sure having SMO turned off helps answer that question.
If one doesn't shrink the dentry cache there should be very little
overhead in having SMO enabled.  So if one wants to explore this
question then they can turn on the config option.  Please correct me if
I'm wrong.

The ifdef guard is there so memory management is not having any negative
effects on the dcache/VFS (no matter how small).  It also means that the
VFS guys don't have to keep an eye on what SMO is doing, they can
just configure SMO out.  The dcache is already fairly complex, I'm not
sure adding complexity to it without good reason is sound practice.  At
best SMO is only going to by mildly useful to the dcache so I feel we
should err on the side of caution.

Open to ideas.

Thanks,
Tobin.

