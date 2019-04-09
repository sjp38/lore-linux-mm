Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C87AC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BAA22084B
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:07:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="UhkhtqBa";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="whCZ2VBs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BAA22084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7106B000D; Tue,  9 Apr 2019 16:07:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4DA86B0266; Tue,  9 Apr 2019 16:07:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EDF16B0269; Tue,  9 Apr 2019 16:07:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 798A86B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 16:07:24 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 75so15635808qki.13
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 13:07:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uNPq5bpauKJEYBLZHCcbi44o0QY1Z6szsBpVJ4N9HTc=;
        b=ZjFnMV/YSQOY+Vk/Y52onlZW+q5z9lAziYTfTmhvomyjif9sgHSQMv+dMkfWEOhKz5
         hB3G8VC/HNg03S6anoz7CbOI7DaIBot9OC7UVnacn8tF8UFWd1QvP1cMd85LAhQ8LeF8
         cBPWwaLC8goTt9cFZbMjVQ54C0Fh6F/yAana2yenguhFfiwHeBOUYPnaCFFYJneGwKWg
         amVCMN/8EbMHz/yH+PhAHzIL7UH+KiEDcnfhJwkyElXgNg6Onu22/22gBL/9Avf+K/rs
         n6Dk4Vo5A+RC3YpLb2AmMb0mVKb8iwFusN1eoQ1x3OyNfmT2ulXME4arYGl1Uk0DU9bu
         2kdw==
X-Gm-Message-State: APjAAAWwXdWMT3Fn6Tt8LGEZt3H+caMYIC4gzcRzvJmzeAnoCpFPxgdC
	BneREZ7yW5vMy7cq1t2ekZvV9rFVVOQQ1QwZSV1fb3ojS8dPpUvj6BIWEOL+yt8mLW0Ewo+AE+I
	kvyIDIZL2sOC8f8kuEZ6Pgm3/XFeFEPLnqMMwqACBXLLjU3YVZ2LAJMtfkd+e62I/eA==
X-Received: by 2002:ac8:3042:: with SMTP id g2mr31565987qte.1.1554840444206;
        Tue, 09 Apr 2019 13:07:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFcMPJokCY0lEqCeIBfaivn/F15SaRk5Mg8dOCIl3xOHcFt88VGGo6Igvn/fRZ0AqAxFC5
X-Received: by 2002:ac8:3042:: with SMTP id g2mr31565931qte.1.1554840443565;
        Tue, 09 Apr 2019 13:07:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554840443; cv=none;
        d=google.com; s=arc-20160816;
        b=UwvKRYW04+zuoq1pZ82Had2AJHgFw67Xhm2b+VJTww2FAOzLJfzKe12lJ6OWm0k9AR
         umz1vNvuG53UbxYMEGuuH9Z0Lsz1mfbIT4LRgPh32J1YfezBcxEGxcACnNPhVt0FgPME
         xZwazXdfJxTFfDCr1xM3P8Lpru+5mYMQpvD7fEeVoi8iJbl3h7EbG/NgLzh1ZssGHk2M
         Mw0zHUq96VQVjY/h8MtGiHV7jBGcw1xPTEHcLxyX0mZEB4aq/ICo2XeRq1RN5BCkRZnJ
         XOVps0lHTnFhALKGv/zUpnt9rzDPQfWefP7tH3DpN5BC8yi5HeUjZBNt+3rPsy9iwxCM
         mBzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=uNPq5bpauKJEYBLZHCcbi44o0QY1Z6szsBpVJ4N9HTc=;
        b=Z8Ip1hcitENVNNvwq7PrPmWKnD2xCmLjx0J1+kW0Y0WhWVwJE7H3bhWs0GhspirXdM
         dZEiGgM3KcTZrs4Ay9HZB1g+ME3TOlgMAOP1ZWXm46mjjh2rK2yc6jRczFFC+sBXKqZS
         msOiDljUq0UHsAK5WXy4wk1TibMbKh0g8InVdxJYzELiufJL165n1XMZ2kmicqCKASg9
         4Pej3z3bMxloMOa4hWEVUTfIpHp8VgDGetLBZbtoam7cmiLf+whfiFzh7S4dewvTGwlv
         zwfTQdPDaBnDoCDg/K2mvnyKHLKh9hzFSexg3KkGY37uMb91j92hpjpDpxE++ubn/v7B
         cNLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=UhkhtqBa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=whCZ2VBs;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id h12si850402qkm.85.2019.04.09.13.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 13:07:23 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=UhkhtqBa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=whCZ2VBs;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id 21F62271E;
	Tue,  9 Apr 2019 16:07:23 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Tue, 09 Apr 2019 16:07:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=uNPq5bpauKJEYBLZHCcbi44o0QY
	1Z6szsBpVJ4N9HTc=; b=UhkhtqBasH3JCFeeVRuGX6I8I1n5ITF/gy6ZxbQYjaX
	v+bUlPbgCUPIESkgF9rMZV7BQVXfYkgt3lEWhhWV8P73kA7eaXPxg9GF4w/iAR5B
	jAT/KiLCoxNETTsW9Y4VEk+qStRWp//+nYKQ94rWBWfhvmULnnVxWuCYIt0dOAXX
	xGUZTzdHcQ8MWKP7/ebdJfPgSBxFtJsTrzZvfCmMP0JjgmoaMzXNARpvONoNRMnY
	9MRwmJssBPKSoqtVoYJSwnFmhPqnIURfrKrQH5TRz1ewzAHscAt95AUZssKLCOBI
	PQl7FZ4Xd6HeX6/7285kSOvoX9m/SNnDnfxHcIBDFVA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=uNPq5b
	pauKJEYBLZHCcbi44o0QY1Z6szsBpVJ4N9HTc=; b=whCZ2VBsHqOBeUQattF/3t
	ZWnGdPxqkVlNBeanDtvSYngJNjoC1FgixnmlMQEOsKmTkey8U5BvBf3ge/Dkoh2S
	UrT4/Xnld5s4BW0tZD0ZkUga0+AdPN5oSTYnBShgeRokJKQoZnHV2h/eEi8xS56S
	iwIFK6yhOZafrrca7W5hl5TyxjKX8d+oeNduwB1w9zZsmoecrODP++QL3zgkevc3
	gFbKsduxFG9EvuGCxIRcxvNrPPR0IfgOlUxCw5raOjqqaxZpEH514rchhsFMja0c
	VrvxOFABB4jV47DPUAE7hp9Iag2TmEKu4yDw6pehVNJfUtczfA2983bMGCtCohew
	==
X-ME-Sender: <xms:ePusXJB1uKL3VT5Rg_L-6NvcxxW88_KoQFa8Lt5IXLkbAi-mm5aXvA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudehgddugeehucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrddujedurdduledrudelgeenucfrrghrrghmpehm
    rghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:ePusXFL5nl8Jv1o9uyT8x4VlSZ6Gh03V0yjFNjLEjxJ_eGQPEG3R3A>
    <xmx:ePusXKKZvtUK6vLiWq0klSxSt3rbX-2TXyjSVAb9lSWN6tJtONfqEQ>
    <xmx:ePusXHYJZBQlR0p7AWfwK_aSZqrOMd9VL9034A58UKaG5zO4BEoiUw>
    <xmx:e_usXMeqTy_xj851DrUUeJ78k5b18UIOYBcAo-Jescq8Q0y-NBtlrg>
Received: from localhost (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 374ED1039F;
	Tue,  9 Apr 2019 16:07:18 -0400 (EDT)
Date: Wed, 10 Apr 2019 06:06:49 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Roman Gushchin <guro@fb.com>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Message-ID: <20190409200649.GD19840@eros.localdomain>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-3-tobin@kernel.org>
 <20190403180026.GC6778@tower.DHCP.thefacebook.com>
 <20190403211354.GC23288@eros.localdomain>
 <63e395fc-41c5-00bf-0767-a313554f7b23@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63e395fc-41c5-00bf-0767-a313554f7b23@suse.cz>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 02:59:52PM +0200, Vlastimil Babka wrote:
> On 4/3/19 11:13 PM, Tobin C. Harding wrote:
> 
> > According to 0day test robot this is triggering an error from
> > CHECK_DATA_CORRUPTION when the kernel is built with CONFIG_DEBUG_LIST.
> 
> FWIW, that report [1] was for commit 15c8410c67adef from next-20190401. I've
> checked and it's still the v4 version, although the report came after you
> submitted v5 (it wasn't testing the patches from mailing list, but mmotm). I
> don't see any report for the v5 version so I'd expect it to be indeed fixed by
> the new approach that adds boolean return parameter to slob_page_alloc().
> 
> Vlastimil

Oh man thanks!  That is super cool, thanks for letting me know
Vlastimil.

	Tobin

