Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C7F9C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:52:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB7292087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:52:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="f/6ZWKqM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LFxA7GxU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB7292087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E8538E0003; Thu, 31 Jan 2019 03:52:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 497728E0001; Thu, 31 Jan 2019 03:52:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33A918E0003; Thu, 31 Jan 2019 03:52:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07A478E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:52:58 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so2518217qka.10
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:52:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B4i8qu8Fhn3wH5KYylYCfJYRSoBWJG1mc5WVkWS3Sv0=;
        b=Rhq2V+WFWhvbPeaerQBiouykV+WxJV6pBgN1r+MfBErIbC8VI2jYrpenUO7dzjAeck
         1X4yGXv+Jan/YtEN2a9kZPl4nygWDAsdABSGiseS3H0X+VUszrh9jwMqWtBA2zqGLtJI
         OgzvS4KCMR45FzMuM6KlGmDu0Od2/gQigbgMTV5nf1EI6WPDCMHaoLv3/QSmUkK8CpH7
         DDV2Duf+r5N9R2q7dxB/s2zVJpsmkoR4Rkcof2c4SKShqqsy9AQdUmuevPdmYAlYQmoW
         kjTvSik6GV/iT0W6vHhXYJFyQVU9uy1t6xuaGLpRVEP45IQpfF12AI7fyAjyR2xbV2Yi
         3obA==
X-Gm-Message-State: AJcUukcSywy3fyL9a9OGMZXIGVvRfmreBIhCRoSo8wGnaPb8Q1NIHCQf
	UJpwOAtyWrtiaTApSslzzCWbKBzYS4yp79QHNQR2p1NURlh16U0r17w1ffcuP2Y1M2FCvHPYkjh
	Waqwszt+vXELRUofVlcFLS1ItD665vK7YS9zeZUlfWkiLBofv0ytnYY71FsQuE+EQHw==
X-Received: by 2002:a37:484c:: with SMTP id v73mr29850353qka.196.1548924777790;
        Thu, 31 Jan 2019 00:52:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7tAxBD13rLahqggWK2zGPZ7yNxTjUFvTrd4srlimLLLIHmffx5CYubtUqpp5v2XqBGlSHU
X-Received: by 2002:a37:484c:: with SMTP id v73mr29850337qka.196.1548924777261;
        Thu, 31 Jan 2019 00:52:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548924777; cv=none;
        d=google.com; s=arc-20160816;
        b=xO5v2DUGDqvT8LnUzsh76KHR2EYYPLiOjT+bgvi7j/ejkxT0v8puHv+3NS5ogDyYy4
         p3Hq3ZTTk9PTP8pEWJ/PT1+LZmMr3IgMO0YgTH866Z9O1TIimXGd0nRTUBicBQ3VadMR
         3c8tzRXF7xXX68Ei1PS31tEtBXxZfwmAEDGIihW24U3mAfYHscQFbB5dCeGinKvaeKeC
         BuqoJFY7TdYmoOI6fcbKH7abHvorUxzd1oP7B9D3CIMhUkcABOI7VlV2qwF5PI5jZ84z
         K4ErKkCdBCl7mgt7tW/94XtzuXFqx2sr76plxQII3vekFMtYJGwBW+NQHW+hyK8Lr7Pf
         QJdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=B4i8qu8Fhn3wH5KYylYCfJYRSoBWJG1mc5WVkWS3Sv0=;
        b=M6W5Zd+63OutAQDJ1rQ/KX+hahYAFUFPpICxldF4hSTfwtpBKT6yLMwQ/iC1XibXfu
         sTE6WjBZWrSyvr6jJeW1o6OpyGNNBD+JfSDvpojvFfZ9r2XCclwhkoEwDAq00JLO60BG
         TD2wiIbrIbJdoRji9fXBDMY14h3GkGM4Rn9+Szwttk4MyULT7PAlMU87kMUVfOqgQNpk
         wbvxjcGBIJDfiu/brMvveGh3OHV1tnyV4Q5JVEJW7xHKeM1oTaNBfwDrzzZf6F+VcjY7
         X0+RRYcF2KZrGYiUXYeISjGyM7/5z2jo/MefzVFEzwQhZCERxuqhoRZpl6j1TP898nJg
         gzzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="f/6ZWKqM";
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=LFxA7GxU;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id e7si435660qvp.159.2019.01.31.00.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:52:57 -0800 (PST)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="f/6ZWKqM";
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=LFxA7GxU;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.west.internal (Postfix) with ESMTP id BF6512015;
	Thu, 31 Jan 2019 03:52:55 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 31 Jan 2019 03:52:56 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=B4i8qu8Fhn3wH5KYylYCfJYRSoB
	WJG1mc5WVkWS3Sv0=; b=f/6ZWKqMpfmzi8BggP+kG7UclJd3TcKUp6aykC11Zlk
	GuqTgTsaWBkm7/GShzosW+kiXEvjmNfDJLVARPleDfWsXtY0937zj1lQS6VjtAQs
	s+ows7N3cR1tpkiqcjUDKp86n3XqQpwTMckQQwBtnDcc5OGTQWlHS6Ib28RUxbiy
	4TmMeCrBo4wyU1BJ6dKk2DKlTEZJ3ehVjbAYwUVWst/rJEXbaA1ZdiCsykWEvnLq
	oGXG4iuvI84q/JmZXciorj8vuVffeALbxIvgKRyJLY7vgvsigBtsoy8oxnlR9KrD
	a3JmwxH4Serrpf1bvXu8sD32ckHZUWABPLA4gTpmhjQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=B4i8qu
	8Fhn3wH5KYylYCfJYRSoBWJG1mc5WVkWS3Sv0=; b=LFxA7GxUQGCo/l67XrOaZB
	j/AAxKqZhm0P7JsNO6J7+OGvIrfi4l0zMDA6OaWe6dWfXBavJqd1dFO1omVlRSGB
	YFSsPPRdgCSsncXqIKFf1Owhfc+Za2qFJuF8xELS4xr5Lg2dFGo91WlzIowk+LMk
	DTMa7UavBDh6OkaaWEu5t8rgJdRNXfff5WkuW9Xzy6sHAZb36Q4u51NHv+Cym/tc
	ff9ze7GSG/xifQsiRJdzmRNVxGupCj22aww7cxiWBvbjUbl7/Qfd269p/rF1lmuf
	goTPK1ehec5uvj3+HoNari2rjZZuRgXErqOIoVknT84Lg9r0x9z+6qNcWeoD6kGQ
	==
X-ME-Sender: <xms:Z7dSXAel76isXfZW20rwCv9tR4kmKiNP2Sy-4sINVRIdbCY_1QdhEA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdduvdehucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfquhhtnecuuegrihhlohhuthemucef
    tddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfghrlhcuvffnffculdeftd
    dmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdforedvnecuhfhrohhmpedf
    vfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosghinhdrtggtqeenucfkph
    epuddukedrvdduuddrvddufedruddvvdenucfrrghrrghmpehmrghilhhfrhhomhepmhgv
    sehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:Z7dSXOOLeVGNKHitqM-b2LiSRTL5g3tkzLCfLXJvYUeytV_wOSiJ_g>
    <xmx:Z7dSXDvSdTbEiE6iLyJtEb8UqMSTYqtrkEesdCABBvLN0XmWZ9E7KQ>
    <xmx:Z7dSXHBlIzaPbVbRRrNPAIZe9vPN_Jwcc8fLvPXjN6DEf5yVFRZXbw>
    <xmx:Z7dSXJh0XY8j1K8Pkx3rHg3YAjnwf8-FpygCmlNUz2vT614UJEdWSw>
Received: from localhost (ppp118-211-213-122.bras1.syd2.internode.on.net [118.211.213.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5EF431030F;
	Thu, 31 Jan 2019 03:52:54 -0500 (EST)
Date: Thu, 31 Jan 2019 19:52:49 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Pekka Enberg <penberg@iki.fi>
Cc: Christopher Lameter <cl@linux.com>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] slub: Do trivial comments fixes
Message-ID: <20190131085249.GC23538@eros.localdomain>
References: <20190131041003.15772-1-me@tobin.cc>
 <01ec2c57-4ece-5ee1-4d0d-d2f24695f482@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01ec2c57-4ece-5ee1-4d0d-d2f24695f482@iki.fi>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 08:06:31AM +0200, Pekka Enberg wrote:
> On 31/01/2019 6.10, Tobin C. Harding wrote:
> > From: "Tobin C. Harding" <tobin@kernel.org>
> > 
> > Hi Christopher,
> > 
> > Here is a trivial patchset to wet my toes. This is my first patchset to
> > mm, if there are some mm specific nuances in relation to when in the dev
> > cycle (if ever) that minor (*cough* trivial) pathsets are acceptable
> > please say so
> > 
> > This patchset fixes comments strings in the SLUB subsystem.
> > 
> > As per discussion at LCA I am working on getting my head around the SLUB
> > allocator.  If you specifically do *not* want me to do minor clean up
> > while I'm reading please say so, I will not be offended.
> 
> For the series:
> 
> Reviewed-by: Pekka Enberg <penberg@kernel.org>

Thanks for the review Pekka.


	Tobin

