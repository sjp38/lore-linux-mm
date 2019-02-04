Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 376C2C282D8
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:55:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA3E52083B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:55:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="RevxtlRi";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KCqVuHJV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA3E52083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F7F38E0038; Mon,  4 Feb 2019 00:55:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57F578E001C; Mon,  4 Feb 2019 00:55:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41F4E8E0038; Mon,  4 Feb 2019 00:55:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10EF08E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:55:38 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so620654qkl.2
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:55:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Cnv3ii0vTX6c//dFrqytCvGGSFfVQGMLpdqPG0BQ0I8=;
        b=IqA7uGjrsbwP/Qg3jASYRqE+C7VCLoCbNOq2oflsxg7Vmzhvhe2lf5s+Kbgsz4+RpG
         sePprQz3RPPUKj5IudPeWEPCKf1JeIXYg4r/7tXsCHEXyczxAk9FkIqm2coN/nTGtloH
         rmKuLkRUvS1F6BByMraVc/nbnu27vYCOyXKwjMtDNGSXZ39v0l0jUYrP2xNFTiof1RNE
         1VAOgl6ZvGuHDqvbE+sakd5j/JHKcoZj4TTHuPzB+hK75HLUW7yjfW32vgbseSI8e1ym
         d/r5EDHH4+6WF7YafPSEwcBU8GUC8fs4cH03Oyx+M1zx94ceoi5BgO0JRSQYuv1Lev6M
         v8Kg==
X-Gm-Message-State: AJcUukfNoUghZkZqqTxipEMh0ZOXx8tzWF/FccV78pHlO52qTl1tB4k/
	Im4dc/Pme2FhdRtPv5p7vz4r454fPDJU028UKJAXjAErF3XiEhgt6SibYSY8QEEXIx5RidJqBG8
	JQ9FGXZyoIjnoCUcHRKLcV7TY57qWgdkUznenWzjIvcPZ7eJYDK4w+Tq9NDHRpzXFkg==
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr48984274qtf.127.1549259737824;
        Sun, 03 Feb 2019 21:55:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4zXgOXolVlYsnigdQebNWBzMMGCvtRjARcGTXAG9yooccbshF2uPzg/TejjUcPCfSig1Lt
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr48984253qtf.127.1549259737154;
        Sun, 03 Feb 2019 21:55:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549259737; cv=none;
        d=google.com; s=arc-20160816;
        b=chHLWUmga6ErtPn6yDlXs1s5iATNvBcbMpIl7DiQzEz+tSfBEf4f9mdXu0YP7GC4r0
         ZXb63vIKNe+F8q3aV7S4b6GfQ6Mq08emwaFuISrOvpBAjj4nBp7slsTTAOLNgyya7TYf
         Q4V0n4gL4zS1su9v49XkmAUs/rNFkP2pJXg7bM0BnroDQk6em56hAusBuf1eElsjGevW
         yBXT1rmrrBFBCGoZh+QriQBbJN9Podcs8x0eCdFrAI5/NJyOxfHHRUnoYoTULFpej6xe
         mlQUxzxuHvuWvmr13zah/D7xtkOC79QVXruna/pW8zhDQJJ4WmWr9Ze33Wdc3OlBff7s
         7bVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=Cnv3ii0vTX6c//dFrqytCvGGSFfVQGMLpdqPG0BQ0I8=;
        b=LkQvTBFfiSjllZvVNOhBrHW49W9Y8J/nd5z4uqSWnYe9z6Zy7OpXWmHPvDBtmdLmdw
         fW6YVNVeeED0OkI2yyeDh8NwoTFZESsc6LA/Tsy92kpXM4kxZHFEByWWyGmPkZ9rZPAX
         lLujVYzlzNEh/Oe202sbIbYC+OWNgnl+nIMelfLfmzWLv3p+3I49A67ald6rarXy7FGE
         K5UhxZej0WeRKJON5EoQEz5e5TdCWolC2EpU4iZweOmFvZC0BTUz71xVYAkIwGS1Xr2n
         GyaybP60ESH39uu9eolgmtTfw4VqI7UQ+32BzKqySV2Cu7m/27JV0Cj28M7wx/jJjyn6
         xXBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=RevxtlRi;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=KCqVuHJV;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l19si254978qtn.352.2019.02.03.21.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:55:36 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=RevxtlRi;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=KCqVuHJV;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A28B521AB8;
	Mon,  4 Feb 2019 00:55:36 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 04 Feb 2019 00:55:36 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=Cnv3ii0vTX6c//dFrqytCvGGSFf
	VQGMLpdqPG0BQ0I8=; b=RevxtlRi+0lFihLOIh9TssVLxk6EOb+KRrleA+y4H/m
	DSlQlOy8U730z2ydsvU6zAxKwN5fx9wPTKPVcQjOj+8XcMeeSCu3vg182C2ZoVbB
	Dt400bkItxzpZUfoKGnf+A/QNworbQA9xyqkkBqM12s7MkT1wGgHIorQX3aQ/+YV
	FxOWr/5dwG3xvJzpLt+dO25OO/5PXsfyy+bMgRgQDnmIGLEdVmrqzG4cZTlupPiZ
	G9TEo2mKoavIx8G0MVuZM2eFt5b28YXkk+bxtKzj0jp5qpeVVARO9kYsDaAB9N5h
	jA5k7aVU8+/u6LqZVl7jjkmWvbCdemV7gHve84BoAbQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=Cnv3ii
	0vTX6c//dFrqytCvGGSFfVQGMLpdqPG0BQ0I8=; b=KCqVuHJVaIhmIuKIpb5RYm
	+uyMTTrHzKrarBqn0lw61zbBe/knvFOq+k2eBZwge+fSc9SxoEymXKvQqpgtzwXn
	6gEu3e8J6lEcjwB9eVa/DUErE5XqxmKQuCQWjz9pSEfm6usEi6TJYjz+b9vX4gZh
	En8gOEC/+B64IjsWRE8T1NVb8rIC6GEt6gHnXHYHl7VakMhfTNzAm1HgbGbN4iSy
	55B8zdBaem+o4UeOPnD8RbNiiIso+Awcu8tvg9Tdd7Jce1fyr1vuiqTYL5QSfEGx
	sOVbZBE0exAfojCsNhBNlSolCmx3FJKS72J4hBa/aj/EGQ69AoctS/sC3fafqTLA
	==
X-ME-Sender: <xms:1tNXXFAGUviouBUVA1T7fOkXugaMjfsWK6WlCOoHqBW0D_Q4ZFACmA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgdeklecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddvjedrudehjeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:1tNXXJgv7Hbhx1jO8holvgIVYG5DoAJ8qeflgDR-d8ynU2H1KOxE4w>
    <xmx:1tNXXOPJu7nwsa3nNmqD2I06-_wWE_m9qWjK-kyqJ3x2RMwvunai8g>
    <xmx:1tNXXK4wdesBM13bOCGa7vYtkw7ld_cZya7mNiD_mY04_ECapeJM4Q>
    <xmx:2NNXXOI6LWHp3eo1nJjtZwrE8yDwJzEF5TLV2pzditwb45JJAMbwbg>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id E7021E4543;
	Mon,  4 Feb 2019 00:55:33 -0500 (EST)
Date: Mon, 4 Feb 2019 16:55:26 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190204055526.GA14242@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
 <20190201024310.GC26359@bombadil.infradead.org>
 <20190201140346.fdcd6c4b663fbe3b5d93820d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201140346.fdcd6c4b663fbe3b5d93820d@linux-foundation.org>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 02:03:46PM -0800, Andrew Morton wrote:
> On Thu, 31 Jan 2019 18:43:10 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> > > Currently when displaying /proc/slabinfo if any cache names are too long
> > > then the output columns are not aligned.  We could do something fancy to
> > > get the maximum length of any cache name in the system or we could just
> > > increase the hardcoded width.  Currently it is 17 characters.  Monitors
> > > are wide these days so lets just increase it to 30 characters.
> > 
> > I had a proposal some time ago to turn the slab name from being kmalloced
> > to being an inline 16 bytes (with some fun hacks for cgroups).  I think
> > that's a better approach than permitting such long names.  For example,
> > ext4_allocation_context could be shortened to ext4_alloc_ctx without
> > losing any expressivity.
> > 
> 
> There are some back-compatibility concerns here.

I'm don't understand sorry what back-compatibility concerns (please see
sentiment at end of email :)

> And truncating long names might result in duplicates.

So I thought I had a good idea - add a pr_warn() if cache name > 16 and
patch all current intree calls to kmem_cache_create() called as such.

This process very kindly lead me to the fact that this does *not* work
because of the macro KMEM_CACHE (which uses the struct name as the cache
name).

So, back to the drawing board.  I'm concerned that this may be a waste
of peoples time, if so please say so and I'll move on to something else.

thanks,
Tobin.

