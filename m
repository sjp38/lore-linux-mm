Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95C48C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4744E206DF
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="BUbr09iH";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="0AySjuOW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4744E206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9DBF8E0003; Fri,  8 Mar 2019 14:53:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C398E0002; Fri,  8 Mar 2019 14:53:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3B088E0003; Fri,  8 Mar 2019 14:53:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 987B38E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:53:46 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so19523140qty.12
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:53:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EBeIov4ac8U20cNceUuu8eIcm0AkI9pPam0NCd5Le2I=;
        b=eK/QwY/86uDcuURoD3PdtarktKCMhfMcMdmtI8li9a71Ub7rkGva2IsJXzy9h1KnZ9
         xVC79AVe4oxssnZ5jPtd7PaQBmtB/DHQl0ylWtNoRIRSw7Ss8o9Hc/FqFtRTlOPW3Aew
         Q1IFXXdEAZg+FEukjTmancGw8/TVv3IsIpba1NDgaGA5PqtGDvgLVCt4eFexUKrjefKi
         oZk4rnUU2jUJk5Hgl9q9VzRKn8l8gw6pvuP4vozgxZ9ijIGd3w8yOYr4EGI+7M8777qn
         5U7+wObu1d1aUsrlPQazSZtuo+/Nrqb9m4gsdpTwbmpMXUCx2m1G3RKdwHXXXx7xs6uv
         N5Vg==
X-Gm-Message-State: APjAAAViQIBeEN0tMdRXAzeU4fQUgfCMOv2LF70kUDIn4XVtGaOFIc4e
	CWeDFOovaPtpVQMlo7ZSZnTig+YpON99Pt5hnwEtZMZXVMLZ8guAeNRDjOyDycRwqnhy1Ga/uJC
	EJkxAx+82XEWWVDzXKZoyJ/qPXSojLQLtNNYHOJj9BcXFyjtLf829zbZUsdH1zL1JLw==
X-Received: by 2002:ac8:3f3b:: with SMTP id c56mr15777781qtk.81.1552074826257;
        Fri, 08 Mar 2019 11:53:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqyIL+OX0+eg+gr0yP6gz+wKBImCVom3/YkMIufpnb5cjvr9gleJdzKa5jycCTpdgYwpcrrY
X-Received: by 2002:ac8:3f3b:: with SMTP id c56mr15777752qtk.81.1552074825618;
        Fri, 08 Mar 2019 11:53:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552074825; cv=none;
        d=google.com; s=arc-20160816;
        b=AX3WHkkGqgfrl7G63tmcxDMXgHXVMYXQiH2aSJVpAhiVT808Bxi2r4pgSntyVf9OBN
         RoW2fVe6jnbc1xj9AkZYhIm5kdEfBjiML42KWNQ4nLCPF7RQffgt+m/3TMXyPuF3+3wP
         cpFOa1uOMw0sUb6GnTAHbtsNnUJDJyahMlTTCUsB+MODSC6nYXmV36U5hwDYGnCdmyhL
         yfrZ7/RctwrL1JJygFmQCMTnRXQF+WoVtbxFx7zWMN9ubYyeLYhJeNT5yMeW6VoDU8yn
         phboeUE7HGg6eTbXZMoZtH8Lx9QlPuy9ZiNYt2ffvGe25AzaoK3zHb/zy243nq63TzzI
         my1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=EBeIov4ac8U20cNceUuu8eIcm0AkI9pPam0NCd5Le2I=;
        b=YjRPS5Oa9j6knHl38COlmgGUMQawtgne4NBIOAHn1NJf/0wjTnGKBLdSZ/xIHO7rmA
         FkJhMVPzgHSrC32Og3raHn10ZDNoZ5jL/cZgnjmBFsVUO5gockRm8MzD2liAGMDdXS6o
         mzyOZ+8MbEZhKoY0p0a2eGb9vYerEzrT7W2p/oPB0RYT7QcAvm26XUw9imNkg4h+/Q23
         DetKSJqCdJscsHTbr4m3o39pOMC9GJ0ulOEnj4C0oKC0BVCQEYQVxrkPPNrrslLEv4pQ
         NINQIwp6IvzPnzRCBFJlNT61XiqbnP5ObrvxbNNkVzNiiqtT6mZm+bZjVrylvIfYfe5J
         Yk9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=BUbr09iH;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=0AySjuOW;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id s39si5501702qth.326.2019.03.08.11.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:53:45 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=BUbr09iH;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=0AySjuOW;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1C49A21D09;
	Fri,  8 Mar 2019 14:53:45 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Fri, 08 Mar 2019 14:53:45 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=EBeIov4ac8U20cNceUuu8eIcm0A
	kI9pPam0NCd5Le2I=; b=BUbr09iHTMItQ+AEddCgSvILkEYUNSVYYlK/MWgiMxk
	AEWgI8NbJln/frY8FDRE2kAo4w3NVlS+GbV6zx1sMNPkPCel1mTFJg0VVCdSvfH1
	rMedU/68F+VUu2pBKauLDOH1/MgchW8AbGsUCTqGOW4w/Jd7YuyY426RWC5dq20S
	m83KHrYPDvrai/SSF6fiRbA4d21JAHAETFTVH40p9tVIFh+H1TkBhZXGjjRZ6faq
	oakalofcQM3HZBcDq5croPga0u4gbJ4R3oasSGQFinCmarA5M8deKVVYlmaAM4QB
	RXYypTJ8rO2cstnVe3wEsi8ZhHkBaRvozc/nkzQ0ZOQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=EBeIov
	4ac8U20cNceUuu8eIcm0AkI9pPam0NCd5Le2I=; b=0AySjuOWbHUlQvcfVmKTb/
	b7L8MXhYcPXIBdQjnKCiDkMlmeIgqdGPJOOArx7Qsxco0X3kzHmPTINZ301eKAWA
	ld3e6np52dkiwIJrwc4QOWGBfDguQ0BI+/lg4qhwnDJy3/defAUYPmYfnslBwGck
	2VFgMmP0dk5FVtmSNzg7uGF8LjrZa8kQY3Jcq9zW0U6RNIRWWQRKbdAaJ+tAgZTd
	lbD9QKf5XE3sPovIy44rzssEd5zbCt37abc27W3uH62frhFkRzp58YFFYHjd1zqO
	Gvko/KFqvdB7iPT7WTaMAoLn9ub8zrq9Ozd+Oq5CXp26K75MuXYVjIoVl4OR2qeg
	==
X-ME-Sender: <xms:R8iCXBsb21leKgdIC_wpHG-ZdZUgLApRAvzuZa8Rg0is5mZxBfgMpw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgedtgddufedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrdduieelrdduledrudektdenucfrrghrrghmpehm
    rghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:R8iCXNeIMLvbpuGgV5tcA8BbkOVE_iDoTFr3tvTSTFkfN3Q9Foe7xQ>
    <xmx:R8iCXHXSpwCXlaRwJwZMrUAY0t1siwlxRV1g0bkyxCwX7I09op0ZjA>
    <xmx:R8iCXCotG_YL4ud0CGRwcOsMTKPTQlbnWyWyR66Kg9Sq8jOhs5Gj1Q>
    <xmx:SciCXCbtC86L5OOBtR6TLEpjglOTRqg_ix6c8WFlTD0ar0kgD_qJKw>
Received: from localhost (124-169-19-180.dyn.iinet.net.au [124.169.19.180])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3CCB8E4580;
	Fri,  8 Mar 2019 14:53:42 -0500 (EST)
Date: Sat, 9 Mar 2019 06:53:22 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Tycho Andersen <tycho@tycho.ws>
Cc: Christopher Lameter <cl@linux.com>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Message-ID: <20190308195322.GA25102@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
 <20190308152820.GB373@cisco>
 <010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@email.amazonses.com>
 <20190308162237.GD373@cisco>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308162237.GD373@cisco>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 09:22:37AM -0700, Tycho Andersen wrote:
> On Fri, Mar 08, 2019 at 04:15:46PM +0000, Christopher Lameter wrote:
> > On Fri, 8 Mar 2019, Tycho Andersen wrote:
> > 
> > > On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> > > > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > > > index f9d89c1b5977..754acdb292e4 100644
> > > > --- a/mm/slab_common.c
> > > > +++ b/mm/slab_common.c
> > > > @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
> > > >  	if (!is_root_cache(s))
> > > >  		return 1;
> > > >
> > > > +	/*
> > > > +	 * s->isolate and s->migrate imply s->ctor so no need to
> > > > +	 * check them explicitly.
> > > > +	 */
> > >
> > > Shouldn't this implication go the other way, i.e.
> > >     s->ctor => s->isolate & s->migrate
> > 
> > A cache can have a constructor but the object may not be movable (I.e.
> > currently dentries and inodes).
> 
> Yep, thanks. Somehow I got confused by the comment.

I removed code here from the original RFC-v2, if this comment is
confusing perhaps we are better off without it.

thanks,
Tobin.

