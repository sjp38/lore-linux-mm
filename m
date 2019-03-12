Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C2B9C10F06
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:02:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B6842175B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="qNSobwJB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OBy44wk1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B6842175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB3F58E0004; Mon, 11 Mar 2019 22:02:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3B618E0002; Mon, 11 Mar 2019 22:02:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4968E0004; Mon, 11 Mar 2019 22:02:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66D248E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:02:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so795757qke.11
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:02:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t+vi9vkWEvQdhqL9XEq4Jv0l/8VRKRuscgdakwpYeMI=;
        b=Qy1VtUmrH1hO+m79PiWsbdOBE6AjyUSRVProo7O/GlmKZ8f3Y8cW2+u6AFpCI+Eoyh
         8sEBDzBnvwCJ50n5u0KWXRjS8zPWIe1sZPlXFXrEMRG8BepcapHanywaEYsHanLZUY6E
         e9aTDexWD+ZMngnRapEzjcTwlwt+uYif+l4zVmslXLke032baciFVmRcd8CjJuHQ2WzY
         ZMVxOZWOZmlAqxYNu2LwxJoYXd8mFF331hxrC9FPtwVLG/pd5yIKsTdbBuITdRkJjb4P
         n5ngRLRM9YLp5xcUxear3JD7Bwe8R2OttQAw4IVJBtfxzIXJI1JRagMa7IgpL98yGVu5
         A9jA==
X-Gm-Message-State: APjAAAUOuGOVT819Dq7otNNoBTvQBT/+de0GKwWKsT1EFc56sDMv04GT
	nnyaZRn+F2P7s1cmO7C9LTTRlBbZBSB+RQeIfVhSY2IDy4eiTxpXhb7Kh32e6UNKDAoAHC86s67
	WLfEK5Vxjl4kfYXiQ5BmvG8P6MlWBum4zmRy8kn2sDEFZSYqEBreKhSkcXOayCFIluw==
X-Received: by 2002:ac8:7194:: with SMTP id w20mr11867569qto.213.1552356154224;
        Mon, 11 Mar 2019 19:02:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjj+uDNWMZZ5jGNketiomLr6YoXPUfCxC9lZU0Vx8A5TOHqSLb6HT9JU1HyWcwegxhMwsR
X-Received: by 2002:ac8:7194:: with SMTP id w20mr11867534qto.213.1552356153495;
        Mon, 11 Mar 2019 19:02:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552356153; cv=none;
        d=google.com; s=arc-20160816;
        b=zSRu/y171Myz7MzFrvEk4hOR0iZqko3qOYl3sqOuk/RS6TliGWudti2ZlsdZCoDxA3
         zq/hjBRzMwQvV0lUk1MfdyhqVNMC7bFXJyVQ1YGT+wJ6DYKNBe1xYSMRxnjpOznUQcqs
         4IqZImaOlvbzSipHmGKpQE18PQCeZ2r+0LrohT+Oxn0kcO1WU1cDUi0Eh4svWiq2IZ86
         r2HTRXIHTQ1AcWQGW7eXo5vAFvNi5kmywucnpPMHQ4Sn1BdPdHuit+bDbDUq77jYtdZV
         pWBYlII5tHQy3/cvodoHfqH6t9GUHb9pXH9ugosgn/S/MxQCbGJ8j3F+cyf5E6bSrUd+
         7gbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=t+vi9vkWEvQdhqL9XEq4Jv0l/8VRKRuscgdakwpYeMI=;
        b=npJ7+RAmsFKgPW1VVAzow1K5mCxfZr7jDS2Iy/n31vuY78CqjKfrqMIOhKvGMMojHx
         FoBGsmRNKLgYslufvPNJnvcsy1a+q9Gl1rwTewmAfJilgv9kjqIzJlAyTaX4yw5AJPqQ
         SA5OXXiQF6tXgObxCXk8HOb6r/zwa2PGrrjbckF7arJe2jwNFPHbc7mqEFmF1sR4UBrJ
         Dk6vBWOEcwAbexIAJXHVjQHgui/cgz3OKbmrqIhMMLq6BrjG/T2WQgHiEa5IdYKeKMgQ
         UmVc7SOzDXtquLT/wOQ5iJ129UNePxVwb32OhaiI9UbVZK360/vC3wKJekdqsh00wfHU
         YdQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=qNSobwJB;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OBy44wk1;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id n19si323562qtn.138.2019.03.11.19.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 19:02:33 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=qNSobwJB;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OBy44wk1;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 32CAC22101;
	Mon, 11 Mar 2019 22:02:33 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 22:02:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=t+vi9vkWEvQdhqL9XEq4Jv0l/8V
	RKRuscgdakwpYeMI=; b=qNSobwJBVluA9sSGqRjqg+kqOcrP67t1AkbwiMVfzzM
	o0uxLX/KyTEryiaHt/vQk5JY0AN8onQHLrwEDA5YI0IZ7teDzOOfJ2rR5BfGtLcf
	d1BDX7RHuMbFLcg3vdmFE90JubG+4y84cKyUNqgxuVSTyVfSsCvcmDLbr4bgDtmp
	eNSSL2uy5hQSIc0j3l3ULHYef9kf9eWNVbQ1xHi9hgmA4Brrudc54U1LCFddlMhb
	zYuabPa1l14nYBaemf2MWumqrui5UcAizYKu1M5RC12G9vN8FXfFgtGnNyKgsdRj
	LViUz233at3c22Dp8PmvJEoCX/1YMUnPqwYHed0RMFw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=t+vi9v
	kWEvQdhqL9XEq4Jv0l/8VRKRuscgdakwpYeMI=; b=OBy44wk1OXwkB4anjukE4N
	uQuxYdiGaXE8BrymM+qmULY9p22YP20pOa6J9qLPnySUVKXxw6MueXROxKziFsE0
	G9WutsuHH6w4bSj6qxFlCjnVaqMv0yxlvHXgOQcXxVSTaWbqkj+kE4RvJhSB7mHu
	5njYpNTNa00gP3KHfvgQLdp8L5wRDgXdrevU2KHzea5UlR3oSwpFggaT005fSSLg
	Q7qOM9yI64A0aDbt1RckmbRuWgchfSpksbCQ13RB1j0haanIFcvgVxPGL1Y5SSpx
	wuPEaPQ0TS79We8HOt4ZV8T5xOHoi2b55Xs/ApNVxJS5j4IttaAp1WlGMqP2fz8A
	==
X-ME-Sender: <xms:OBOHXCdz5yjplf3hng7QceLw_74KLL4fYxtYRZRSzBpTeTpveQaaBw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdeflecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:OBOHXCmoFxQCehxzRvZHOC7ap5bN8wv_9NxbJfd34I-P0ImNg-xiJw>
    <xmx:OBOHXINvmauqekS8ns7PY5srYUDIy5_W2q7VPhBIu1jo0vmg9-l_3A>
    <xmx:OBOHXDFT6iOnESa8f9dB6RAeLidUBguI-hTmml45gkB7YIUSo77y_A>
    <xmx:OROHXCJ2QvHv4IhExcGHzk9QK4DbrBWIeobQXFteCxap0qATy9XoNw>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 48D7BE4665;
	Mon, 11 Mar 2019 22:02:31 -0400 (EDT)
Date: Tue, 12 Mar 2019 13:01:53 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190312020153.GJ9362@eros.localdomain>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
 <20190312002217.GA31718@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312002217.GA31718@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:22:23AM +0000, Roman Gushchin wrote:
> On Mon, Mar 11, 2019 at 04:16:33PM -0700, Matthew Wilcox wrote:
> > On Mon, Mar 11, 2019 at 08:49:23PM +0000, Roman Gushchin wrote:
> > > The patchset looks good to me, however I'd add some clarifications
> > > why switching from lru to slab_list is safe.
> > > 
> > > My understanding is that the slab_list fields isn't currently in use,
> > > but it's not that obvious that putting slab_list and next/pages/pobjects
> > > fields into a union is safe (for the slub case).
> > 
> > It's already in a union.
> > 
> > struct page {
> >         union {
> >                 struct {        /* Page cache and anonymous pages */
> >                         struct list_head lru;
> > ...
> >                 struct {        /* slab, slob and slub */
> >                         union {
> >                                 struct list_head slab_list;     /* uses lru */
> >                                 struct {        /* Partial pages */
> >                                         struct page *next;
> > 
> > slab_list and lru are in the same bits.  Once this patch set is in,
> > we can remove the enigmatic 'uses lru' comment that I added.
> 
> Ah, perfect, thanks! Makes total sense then.
> 
> Tobin, can you, please, add a note to the commit message?
> With the note:
> Reviewed-by: Roman Gushchin <guro@fb.com>

Awesome, thanks.  That's for all 4 patches or excluding 2?

thanks,
Tobin.

