Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2C11C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 23:42:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E982148E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 23:42:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="w/av7o+I";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OCovG6R/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E982148E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33A96B026B; Mon,  8 Apr 2019 19:42:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE24A6B026C; Mon,  8 Apr 2019 19:42:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAAD96B026D; Mon,  8 Apr 2019 19:42:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B90296B026B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 19:42:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 75so13148950qki.13
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 16:42:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hlrG1h5r/gtTe9wlG2O5Vs6sRSaHOgL/v3YX7qAdA4k=;
        b=V6ssaHz5Npif3Nx2q/0W6K+/GgHYnAXVeEtKLPCecHZetNsnzyGZbwogXIA42iPQrc
         gtBzK79whRop1bmkzUQD3bFNGEl7tXHez5WD8YUqDT+PjAEyTqDdriONfK08oIFFHp5q
         xF+haoP7Ph5TNOl11klVDch2CeN0V/xFjpvM7L6q2bT3k3YcX1woU8aAiv6reF37PDfE
         yBCrtqh7el/ruwogqiGndaxn4w55dZG4EzSMxNy5gZq2hsuHe/Ty4nyQSLVfZOB1OW0R
         dPxLrgf5Pmx/q8S65mFaFBtsqFKw2X/NfB6lAMBaC+plNvBck7jg68uiApuAxAJ3GY+H
         JDEg==
X-Gm-Message-State: APjAAAV9wgZX4m1pdBaEk8Xo6985hzhtSziU0RS0ad51gyn6DiB4UUar
	YIsffcD2i8KMCBOKGHkeN2LpPV9wbPRRCFblFOXb+nuhE0Yi5MskYpH8aAJBGiacCVKBS4tAD8e
	2jpuDNTW87mQY14x8+hz+vHC1RBnNuCT31sCmqObgvhPLTWStkzJz12mE092S2bJvRA==
X-Received: by 2002:ac8:2f59:: with SMTP id k25mr28227993qta.254.1554766942383;
        Mon, 08 Apr 2019 16:42:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1vRSdq6gYEJDUnnr/ndPYvR488Ad9awMMg8FH26JR67xNM84MrRWcBAmQpL/O3fxmpY6C
X-Received: by 2002:ac8:2f59:: with SMTP id k25mr28227852qta.254.1554766940034;
        Mon, 08 Apr 2019 16:42:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554766940; cv=none;
        d=google.com; s=arc-20160816;
        b=PSgpT0sPIqa8m3DpG97Mp3BvIYACAyAVTZ/iexAloB/cPh8zCAUCWAG/ltFegUQif6
         wYk2lVDQULiLogHqAMYRvuUcwjtt2MtJnD0LlC3ieXuy5pRwhwK5DSYk2GR4MQGIlmP8
         WS0UGH3jx4xegiALMcP4PG7eJbSDA5hlUSVb7dE1SlP7G8wiZAw1KF9cu0rVUCGb0+RV
         8XVOR+ak9TQuhEuNdJQrcIDu79OU/C7+jld7e8Vtcs0R0Mqh7HkfaLeG7NrKSfdr/suZ
         2K66anSnZtUv9XuSQYKYbUgoumL9sQiOF6mxQ/hQZnLhRgI+bCBo8xEvH/zrq/FegVFC
         z4lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=hlrG1h5r/gtTe9wlG2O5Vs6sRSaHOgL/v3YX7qAdA4k=;
        b=XMZXm6dXTBZUkVTaq21XnQ5VJL9S7S6KJdKmlQoZlLhi5/ucrA3SjhaEmST1iUd767
         /eNuY0BO/R04lKQdp5C299T9frXnckwpFvkOaDgUp/BaEEW9FicitQw+Kshi33PIx1FE
         f06Tp8A12sYg+PjVjTJ3E2SowOjNl03ECbAkdQ8Lp4FfxksFe8sYuPXV1d2Yhz2YEbLP
         Rjxq8KkhUxrPVLQCFL2AmKp+SikqVwng/OMjoomXOw7Pf88xi4XUTEX4up2Q2jJ6ynTN
         OLySstLJduGOCHSYWkRTbhI6qOc0HwSeZRk/GIRvUUCb1Lw7idFOpGZtxzFa2uT8TUuZ
         UO2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="w/av7o+I";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="OCovG6R/";
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id h33si11841296qta.277.2019.04.08.16.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 16:42:19 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="w/av7o+I";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="OCovG6R/";
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 7D5EE238DF;
	Mon,  8 Apr 2019 19:42:19 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 08 Apr 2019 19:42:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=hlrG1h5r/gtTe9wlG2O5Vs6sRSa
	HOgL/v3YX7qAdA4k=; b=w/av7o+IwXSGj1V70Q3QWVcKDR60fRQL5+aswcuOwpg
	XaRQmcLlNHYv7bV4dfZ6wogqqK5DFkO9Fw+b5f9uvhEXIojNsCoL7kZBmeH5zozO
	gw2WGf3XScadCUS7tdzh+D8FVVRim5hCxkaDUnWQrSTJDdK/wae/hbQKnAe/U2SO
	6zyiJriT5Jaot3G2toKJWSOLP2NZ9+K0iL3bFNMG0hOFop0StbEWGw4JlOtxzKsN
	8mG7R92+ywMuR6/KNVLBXmg0uJbkSMsaKhHKn4a7CNA+0h7w98HzmqJkh87N2Fm5
	+fN4oAVefabaGT1+WSkkf5mG57fkQPwaPnICiCTHU7g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=hlrG1h
	5r/gtTe9wlG2O5Vs6sRSaHOgL/v3YX7qAdA4k=; b=OCovG6R/WvyuxOYGYf4fth
	CHKmiPCgH3DrJJL3gbmJL7YUFy1yieQ6yRJhk4PxZwfompZZpbgDrx0PbbHCWle2
	Ew4LjCxF36vqm3pChXQ7v/euATtfwa1CRGEJl3+Puy/7l78LTibLvHHz+VTrDY5C
	VWx0jK/LCAHAq/B9RVCJJTAtohj0W4mJiSIW/PeUiH0uE/KLRzQkDR2fcOAk89o1
	yzFJia4z19S9cS8lNTAkMAqYB1Bk1WlNp5zssKPrKT+ZAzBUlB0Wn4UTYFaVx70t
	Dv7JVPMRd3VQoIUB6/uEzGUcWQFjJR9Zsd/PuFNOWfOO0zWFxg0WFCSdvDbZOjZQ
	==
X-ME-Sender: <xms:WtyrXCi-7pr352NwUPXvPhz81KLfeds4l6FtgBSt2y11JQ4pbwa43w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudeggddvgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvuddrgeegrddvudejrdehtdenucfrrghrrghmpehmrghi
    lhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:WtyrXEQDue7xOJC7j_VbLlqiYyBf4CMyM0lkPWTONxMqllMDk3bYEQ>
    <xmx:WtyrXCiALVvUHvtN51wuLdpCzvKPE-C2SbbdlN6rqOng0ba6nb3fwA>
    <xmx:WtyrXBeS1NrAAXUCsI5xO5zzX73n1AMQ-1YIB75jXNnHK46W8-MGxg>
    <xmx:W9yrXNhyDygMXLcwcnmTtvx4AJ1CKQwwJ2WDIeo_kilRy-A5iA_rHQ>
Received: from localhost (ppp121-44-217-50.bras1.syd2.internode.on.net [121.44.217.50])
	by mail.messagingengine.com (Postfix) with ESMTPA id 552E310394;
	Mon,  8 Apr 2019 19:42:17 -0400 (EDT)
Date: Tue, 9 Apr 2019 09:41:47 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, penberg@kernel.org,
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com,
	Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
Message-ID: <20190408234147.GA14359@eros.localdomain>
References: <20190406225901.35465-1-cai@lca.pw>
 <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 07, 2019 at 07:35:34PM -1000, Linus Torvalds wrote:
> On Sat, Apr 6, 2019 at 12:59 PM Qian Cai <cai@lca.pw> wrote:
> >
> > The commit 510ded33e075 ("slab: implement slab_root_caches list")
> > changes the name of the list node within "struct kmem_cache" from
> > "list" to "root_caches_node", but leaks_show() still use the "list"
> > which causes a crash when reading /proc/slab_allocators.
> 
> The patch does seem to be correct, and I have applied it.
> 
> However, it does strike me that apparently this wasn't caught for two
> years. Which makes me wonder whether we should (once again) discuss
> just removing SLAB entirely, or at least removing the
> /proc/slab_allocators file. Apparently it has never been used in the
> last two years. At some point a "this can't have worked if  anybody
> ever tried to use it" situation means that the code should likely be
> excised.

The bug doesn't trigger on every read of /proc/slab_allocators (as noted
later in this thread by Qian).  I tried to repro it with a bunch of
different configs and often `cat /proc/slab_allocators` just returns
empty.

I've got a patchset ready to go sitting in my tree that removes SLAB, I
could just send it to start the conversation :)


	Tobin

