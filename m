Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D228DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:53:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8204D21734
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:53:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="tHxvFSp+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="MOv1MgBY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8204D21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 138308E0004; Mon, 11 Mar 2019 23:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E7C98E0002; Mon, 11 Mar 2019 23:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F18F68E0004; Mon, 11 Mar 2019 23:53:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8B888E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:53:39 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id y12so1126339qti.4
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:53:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iIK4K2fa3ctQzOW1hEie5Z6OZpaasuw7MQHhKT6+nNg=;
        b=DtycOEg4NCailmTqp/eqjDX+X9d396VavObmTCq4QZXP7e9d+e0UQu7wmfIxNt7/xS
         divaD+T6rTq5NX1Z9/m0KJMiWqzxFyGY8wFlNu2sh2qP5mhJXX2WEI8RkUi3++rWZG/V
         OmwZsplawx49/2w3yovlHoP1+RKmYWKjvRiSWnQto5BECrR4IthZLvcCPKv63QZrIreC
         3zi0dEZM79s126euZbw995YBekTHL1zqQBAFKgh1jUe5oajEEVD3ZmKLosHgWr8tELyp
         EjCqq6KTQ6wDpM8dl1wQe4t9GTOHnben9AiVF4W/v1xoicqZT/NNMxiJzbkfNNevhpTP
         fCCA==
X-Gm-Message-State: APjAAAUlmrkr6livXY5iDNXaFLSvMisgjXhzr4ZQPKa6IQa0rawjloLp
	5TtYvym3Z5lTEjYPAuZeunvteq5qjDBV034jarB9NXhq6a7pwfBvbkPsuQII81O0GiSDMsQQu8p
	CfcenmT/bnLjiwSHc40wMEwTH7ZplU9i0amu5sNpG15SgNVs1fbYCeWHVUM+xJyzPWg==
X-Received: by 2002:a37:5786:: with SMTP id l128mr26749553qkb.263.1552362819610;
        Mon, 11 Mar 2019 20:53:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoIvlHc3CWiWio5zHNXoDJhAyaqPxuLCAbKsAFLylQSbxoDwKcf7CW6nfRuAyGFCmC3qlJ
X-Received: by 2002:a37:5786:: with SMTP id l128mr26749537qkb.263.1552362819021;
        Mon, 11 Mar 2019 20:53:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552362819; cv=none;
        d=google.com; s=arc-20160816;
        b=N2jJoyO1R0Hqb0v1h3Kb+TWsKCN4lCnOJbkglKy5A8vjRaZEAItc81MUjzhkJggvEz
         +OY0L3rcxUrh8nUE37zGM/82QQaSEoyXGiz3TvlPep3bQUfcZYB+sAfgOUtQjwE03sLF
         5dyBmioBBtw40RkOrEtFekvsdaMJs8V9Ehzg5HIKHON9DJ9ynKhEvt4u7Vc8GFHG8rYP
         qRAA+VoWkKsk3iWmfSE6Yo9n7moiQfrTUCrXjJ1+FsMTEFeMXUW/IBFaDBT0vP3uk7FF
         NOtpaofnUmnevWZGPOMWwvvncRIW+ByZEhwen3LZaSASwVbVdsrqB/BqSKlXjMjxTIwO
         43PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=iIK4K2fa3ctQzOW1hEie5Z6OZpaasuw7MQHhKT6+nNg=;
        b=sbgBz8w+QCMtR3DFeXn84nEjGr5pZFCRwT9ADSZsOY5c/pxDDuNBu6oDl/IAaYz27o
         iW5g8Khedly94dsbqb43OphZsD+qKNwb5/RkeORDrCzGWlvdc7/cTC21mPYOQy6HIYQg
         NzGSKPIP6dttW2hHABpHykFKFk44/9WnGCDuMdC9eSKqEn0RvZE8krWmBkKSqFQBWZx5
         jZGn+rAWd7r2K7Npj8osVtaC13ovD1WlIAJOM/R2YVIJdnR1viJPvMo6i6J0DyvTmCeS
         rxoX+apG/eZjVbR7Tj3fti5fHsZbQCafMNV5g8u5aC+30HYAPWSuXz7KkgvCm/6FbEQ6
         vWew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=tHxvFSp+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=MOv1MgBY;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id z6si630105qke.0.2019.03.11.20.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 20:53:38 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=tHxvFSp+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=MOv1MgBY;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A875322158;
	Mon, 11 Mar 2019 23:53:38 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 23:53:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=iIK4K2fa3ctQzOW1hEie5Z6OZpa
	asuw7MQHhKT6+nNg=; b=tHxvFSp+CUHlW4XvKgJVQ6ivgkukQyPY5PrtQ/L0Y1L
	EQS7wopd5mDz0wplgsXe4FQRHuqhOGZ+6cCqxXfvFq2SRJtAfBVNrok7pJbhQ48Z
	1ZISRc6zdVQ78Ld74kV7hXk+cVVVQlaNX+TtOSBKri0Ca/rx5sV512AT2WYWYTdX
	Bk2E6SHq6Nn+JjNLhJzzuxGvyTA1Pecu2HVJkurWAw5kT8Y9mf2xzmkR6hAGL68r
	6rdR7t7ioUB0ZHq0rnYpaMUP7s1hF9c+j4+XVPcLWPuBJKZH5Aru9WA4eBzMRRUw
	V4ArZGc7BV3R3tEU22DaZkjp+Fu2PEcDKzkxh0L77QQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=iIK4K2
	fa3ctQzOW1hEie5Z6OZpaasuw7MQHhKT6+nNg=; b=MOv1MgBY4r10k5L939lC+2
	BRbRLpO4l8SupEVwV3P8j27HBaN+xbI5pvHe3Y7PsqIjZEcNFtG/n5kEBD6ekFRQ
	PfhPjRMbt2EPb6A7MZnQgVfUQ/4rqmrKF8sXiN2sfR+u7821nb12sOM3b/0aXSRM
	QoTFAbS/qsyOSSBPozzu6CRmtSo2w9+1qz/czIAFC4Skt0LoP8bCaxTDB+mxsu2O
	QVHQqSA9N6MPHPb6FfN9SVmyCgkWJr/CXBbv5U57heWbM4yHYbzs+K5M0rojsIAc
	hBifnaC1gc5oj6e8oaphGAUiAvhWb+RK+B1XFAy5f7jo/0pW5eT4CAtQvmMJ4cBw
	==
X-ME-Sender: <xms:QC2HXNRxkO9CivC5ngbaRVL4QXVF78_hCXiBIzJcrBEv-aLrWVeiFA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdeiudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:QS2HXDHc30-0s-L8snngdeGWnPD6ol9M14zXJXmllYFWtw7tNMOkVQ>
    <xmx:QS2HXFnQT6zjRiPa4jYPflzW4JsQ2Y-N3iY85716OvvlmQtfr1vXZg>
    <xmx:QS2HXG1Lyyup8k9GC4-lrC7GB_0sxYJ84fWbYG5GGrar7Lb-3jRxDw>
    <xmx:Qi2HXHpuPVHym96-PKRAzJGfdFN-_9IKqMkoKAHbdKQJPxNDjEubBw>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 74CB1E4752;
	Mon, 11 Mar 2019 23:53:35 -0400 (EDT)
Date: Tue, 12 Mar 2019 14:53:10 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guro@fb.com>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190312035310.GA29476@eros.localdomain>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
 <20190312010554.GA9362@eros.localdomain>
 <20190312023828.GH19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312023828.GH19508@bombadil.infradead.org>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 07:38:28PM -0700, Matthew Wilcox wrote:
> On Tue, Mar 12, 2019 at 12:05:54PM +1100, Tobin C. Harding wrote:
> > > slab_list and lru are in the same bits.  Once this patch set is in,
> > > we can remove the enigmatic 'uses lru' comment that I added.
> > 
> > Funny you should say this, I came to me today while daydreaming that I
> > should have removed that comment :)
> > 
> > I'll remove it in v2.
> 
> That's great.  BTW, something else you could do to verify this patch
> set is check that the object file is unchanged before/after the patch.
> I tend to use 'objdump -dr' to before.s and after.s and use 'diff'
> to compare the two.

Oh cool, I didn't know to do that.  I'm not super familiar with the use
of unions having never had need to use one myself so any other union
related tips you think of please share.

thanks,
Tobin.

