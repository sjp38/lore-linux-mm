Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98BE4C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FC872133D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="vTv86x89";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JAeVhB+R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FC872133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 730416B0273; Wed, 10 Apr 2019 04:16:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DFB96B0274; Wed, 10 Apr 2019 04:16:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7436B0275; Wed, 10 Apr 2019 04:16:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 369176B0273
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:16:59 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id f196so1320267qke.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 01:16:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m/uVHFT1jhHjwl1wvSmrccMP41EGDLxAQtR3VjpelW4=;
        b=C4iYiQWySOOFPWiGkc18Dbhm2qEssr0lwoqa+I9t2qtncKD4vSrQ5tHknNU9kExgcV
         MgLgycHNyfK1GMuxp3vsGouFYbKuIw+aA/g5F1k7zrJrZSE4btmepJw5+rCvexb783Il
         hAQeQQXTG9B1iHga1YagArFu7kyqI3uL55gRIgTSJkSAaI3ZpL9aGCVpXU4qDdk3Sm4P
         QG+1slzBlqi54keVMdGi2ZkUEPQXmHxgeHvTQeCjbnjKIxeAZCvgAmCEFhOZPBvRzEX7
         dZogFHT8ryLRIA7y0jpXSNmTb8+CHvPtBrX7fXhrMKiQ+AMutZTlZ1gW0mb5KZatf4oc
         SqzQ==
X-Gm-Message-State: APjAAAU8Ans6XqGVA5SagbmZcy9k5Uvt8je7p0Igo7Sc8IAaY2fhpVGd
	wg3bGxPAfTMjaEbqpVHvMuu/gesOlsHBJzWQRuAeb2ZbaCRq7Ff7r5HCB8CuFVNfCdjj8cmn5HJ
	7a/5xwOsbp22ight7wWYTG7dyytW+BsjsUna4ja4pVwk4hovph8uINN8L7He54i5WYQ==
X-Received: by 2002:aed:2208:: with SMTP id n8mr33352801qtc.168.1554884218845;
        Wed, 10 Apr 2019 01:16:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFecq/0FrPiWLm7GDiO/QiYjyV4/xBB6w5lqGmF0bAwhwCn6jZD8ngCe2RvIJ4tmZ0Wa/w
X-Received: by 2002:aed:2208:: with SMTP id n8mr33352762qtc.168.1554884218219;
        Wed, 10 Apr 2019 01:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554884218; cv=none;
        d=google.com; s=arc-20160816;
        b=D1wm8tgi2r9wkBQBxFLohwYfnaSZaQkUzgR6pY49T6Yux+M5I2cRDZO1WmLiRTGzal
         z2QQ963ed0zqIgKpK4c3wx31FxCt3p3aHXhkxYQvn+iB3Fu2kcoC7d5YlDwW+mK/rmS2
         8RY4GdmcY0xB9DerWTcs3fv+2t6Lv1zOBqbEFCQU5OkpXPIp3V9uLzGKDaW9X9fxUPSl
         KGAIY+NBMy1DvMD+Lt/nNKXzlUprogPTb3aAX3MPRu1Y/SlMyIhTGZjLjW5mVP8THJDq
         fafiuuM9PGSQbTOJkPFdVYVDZ8zw7howaDGP3dLEvlaLP7DnpA+tf/9JFCJzJVD+9b87
         g0Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=m/uVHFT1jhHjwl1wvSmrccMP41EGDLxAQtR3VjpelW4=;
        b=DhXlsnXRiOW7tG4W5JfB62m+bLjQ+xS/pyLHG6o5Wi7CunDc6JvaC7KVNydXwYYfTY
         g5Tib77xgP2LyADbsmb493ZJNOxsh7goAEFoRVgyR3CM9xAdpT28WfSEbI1LiitTzU0C
         A9xfiR7Z42JrzkEQOJ5HP072YlffUz0Nlvbm0Tfake7Fu6v8te2iT8/CVsO0DORVeA85
         yBNRc4AfMBhjp/qkvWAdn1jRe70lJ4F5ISQyTTLRIuMvFKMq1W3S7VW+SuUTmQV7c73z
         rahvYsS2rt0A2Btrrvpgil85on72a83T+oFEYvPREHaLELK7U6K6huSKy157V8hB+qwP
         vc0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=vTv86x89;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=JAeVhB+R;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id 7si6039366qvg.130.2019.04.10.01.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 01:16:58 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=vTv86x89;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=JAeVhB+R;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id C3C1D14D2E;
	Wed, 10 Apr 2019 04:16:57 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 10 Apr 2019 04:16:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=m/uVHFT1jhHjwl1wvSmrccMP41E
	GDLxAQtR3VjpelW4=; b=vTv86x891gs2zeQ0anLIdh4jLJdItCLHC1bgyKJpLQp
	ueh4sVyQQ2jtNvo/eVjk94ChD/ZBcaiKZsM1hxlnWDXRZfkHXA1Mp6Ju2XulA3ne
	ljIrjTtYu4/EGl3LdEuEaGv7O8fMdxH/tuVCZhBiY9hwiVDKsZx8MG9eQn9onC7b
	wHfhXhOGNgOEJpZcoO3Cf97G/Aq2y8ZVYLrW6JM/1S9SnVG+CJup/w4O+9CWlRzZ
	EdOZWu/uXOmyw7ewfpl/9eqhaUTKu1DflnbdmPCn5w1aZgOzC+N++2Fh0Psa9HYK
	6W6th5LMUpOpz9KPa6RpVOk9sp6llI8V+/Jjcx3juDQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=m/uVHF
	T1jhHjwl1wvSmrccMP41EGDLxAQtR3VjpelW4=; b=JAeVhB+RKxo8VoPuYMZRnW
	RNw4G56faDioJGzB8f3p5qK1ktZ3FlJQrS9IivEQdBV5CpoekLVR1PJmlXyRLr2y
	rW3iIc36+1l7LdmiSdp7WoI4oH6wIR7XAUzsFpSk0A91OjuKiB8rLXBUhF1rvXcM
	VCQsTnCPI1JVgR7dOpb1V4x+3+H7wFl3+xIbDAMc/LVse+1iyBpQv3vew8GRS1ZP
	Z3AwQbrTX6sDUJhX1zSSSP1FmtXNvmC+NvCGLVq6FkMU/CAcjAP5WMPS38ZONYmA
	oVK2MtyDWSDWmEnLKy160OKFVR3tuRX5j5CKowEYj1TZllSARVIjdE21W7FbhUJQ
	==
X-ME-Sender: <xms:d6atXON43mYmyfinx8E3M1GfCH8J9ndOCkiOy5a7T67NI3LRxTDHzw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudejgddtvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrddu
    jedurdduledrudelgeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrd
    gttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:d6atXBENj7Kztz9HxoAFCfV4BhEOGaPkjHPtD9nc3yyJigy9IxGY4w>
    <xmx:d6atXCSVlp-e5sEUFdE8SLndAtySbZIw6maP-T0gaD0UjWT9318sNg>
    <xmx:d6atXJR0LbXjKnimvSSiWK71bTJ_nzcFTz7YnwdC2pZgChOYddRFVA>
    <xmx:eaatXFQI54cMgvE9WEp3tiwqaVEzSoVlT5cIixgnTBMNH0xPnE2Z5g>
Received: from localhost (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id EB0EA10394;
	Wed, 10 Apr 2019 04:16:54 -0400 (EDT)
Date: Wed, 10 Apr 2019 18:16:18 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190410081618.GA25494@eros.localdomain>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 10:02:36AM +0200, Vlastimil Babka wrote:
> On 4/10/19 4:47 AM, Tobin C. Harding wrote:
> > Recently a 2 year old bug was found in the SLAB allocator that crashes
> > the kernel.  This seems to imply that not that many people are using the
> > SLAB allocator.
> 
> AFAIK that bug required CONFIG_DEBUG_SLAB_LEAK, not just SLAB. That
> seems to imply not that many people are using SLAB when debugging and
> yeah, SLUB has better debugging support. But I wouldn't dare to make the
> broader implication :)

Point noted.

> > Currently we have 3 slab allocators.  Two is company three is a crowd -
> > let's get rid of one. 
> > 
> >  - The SLUB allocator has been the default since 2.6.23
> 
> Yeah, with a sophisticated reasoning :)
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a0acd820807680d2ccc4ef3448387fcdbf152c73
> 
> >  - The SLOB allocator is kinda sexy.  Its only 664 LOC, the general
> >    design is outlined in KnR, and there is an optimisation taken from
> >    Knuth - say no more.
> > 
> > If you are using the SLAB allocator please speak now or forever hold your peace ...
> 
> FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> kernels as well (with openSUSE Tumbleweed that includes latest
> kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> debug kernel flavours as it's just too slow.

Ok, so that probably already kills this.  Thanks for the response.  No
flaming, no swearing, man! and they said LKML was a harsh environment ...

> IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> winner, but I'll just CC him for details :)

Probably don't need to take up too much of Mel's time, if we have one
user in production we have to keep it, right.

Thanks for your time Vlastimil.


	Tobin

