Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A110C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4970F2171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:48:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="pGvDwEfv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="2YNzJaxi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4970F2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCC048E0004; Mon, 11 Mar 2019 21:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7A478E0002; Mon, 11 Mar 2019 21:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42398E0004; Mon, 11 Mar 2019 21:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF688E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:48:44 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t10so997682qkt.0
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YumzYCgBI9xJMhg5Wsctsp5d1ycnDB6rZ6uDRbC1240=;
        b=nBUFX2WBLRSbOV8XO3r8KOow6qTJrBJV+kqrAgkJstijQEUab0oJsp4SPKjriKvsp/
         a0ds+8QL6ahv2LYuinNF3JaWfZp4bcLN2c+m0Pk/QIfIbjx46PdUMrDjnlJKP3F+bw85
         zumtuofjq4Gat73gcDA8GUiYzDbbTtUQPvNNjWUGOj02Qvr3KldK8rM6lQZ0YUQOHcMW
         zCPw42uKD5DGvCwUGb9jYDP8C4+IX98Mtmjul5yjxA7fllysrH/JQ/jwVATP8QMiIN/k
         6yaCHFfxWodP598e0A2Apyf1SXGCT1O70w1JaNpPJoKYuS31bKukAdEEmIMx9XS/6Ba1
         bZTg==
X-Gm-Message-State: APjAAAU2oLNtTkfVTn8sMcIBbsaPXg9+KRQYtFuZ70SEKx/4QwsXtJKZ
	PQD99bi1SVrNzUivkzxSK0w3in5rkXsV6Ebe5E2h0bq3CVxE8N7vquY+Z9QPfr1iVCjcLPQny/C
	KAHIFaDPn1uuvDXeupmCDy5KwX2vlolYoHKN4/XWJfzA27updRRzu7czZXXO+RaUW3A==
X-Received: by 2002:a0c:9368:: with SMTP id e37mr28475911qve.61.1552355324424;
        Mon, 11 Mar 2019 18:48:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH028sYluIjzCJ3D3Ibdvc5jl1CeQORdh+Uzn1a4xVaUnXRwlivyD5hu2Zl9wSwvpmFMYm
X-Received: by 2002:a0c:9368:: with SMTP id e37mr28475896qve.61.1552355323734;
        Mon, 11 Mar 2019 18:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552355323; cv=none;
        d=google.com; s=arc-20160816;
        b=V40/709pFRggu/uYQ7hu7KNDrtH5DERLkiKl0SvQMBrkzBgHv6WYVH6h+fV1Ne5SGs
         h+DI9ncGifgsOIEAtPdo1R/cnN4PHdXQ0nihrVtYAaH/FWUbrbLOOZpVjJHxDKinCmcj
         4MoOz1NrSV5cjclAMj+65/C5kNwGbEfG5SkoxOIqBZ9xxkZTEnhZiGp30BvdtAwjUGzl
         xn4p2kPlZnpxqPQu0hnpoRq3gK5ydOsEKV2vi6dGEvP0K8VHj6n3viPnntbPOrPxqsF1
         3OCA1xMa/XBcgcMVS4Nd2nTcTWZm4To6AJIzgjLuCXMUJjm9UIC4J7rPnCqbASSHAZ8Q
         ustQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=YumzYCgBI9xJMhg5Wsctsp5d1ycnDB6rZ6uDRbC1240=;
        b=W00UU2/OePWAEIUKYa5eFugH166+qjMUT2igHsrSVCqg9yvnpjfX8yPxb4rngIEhBV
         MW9uUolDoYt19l7hTcQ9ZnotDufGliTya8tuVw+SospAtKoaMzQxbwLr2BfamNOrpoip
         NjWy9/JhUPwy4lUumqNzFKFJVSfP/0e12NXDgPBoCN7wyRM4N4PYzWDJsoYQ2HSf+1Qg
         wcQDpHGtyNg/wXKbsHt67OquoiEaeto+ftW5zGJfp5W4KcgPXmYjtKIe2JxsSYSrHmrv
         ASVAGlXsHc1836SHiDvJD8d+0tUKYrIe+PtcNRQ2f3p0OF78tXBDRKRnJ/2xkGLD6AQ+
         GGrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=pGvDwEfv;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2YNzJaxi;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id c5si742976qvr.0.2019.03.11.18.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:48:43 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=pGvDwEfv;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2YNzJaxi;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1C5E622F1C;
	Mon, 11 Mar 2019 21:48:43 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:48:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=YumzYCgBI9xJMhg5Wsctsp5d1yc
	nDB6rZ6uDRbC1240=; b=pGvDwEfv1TwH5ymz6Jyk9gdHCd5rMUD6iyH5kN5l1g4
	w39q+m5OWqMIM+LjWaFu+vQ+1xRpS6m1alirjgEIQaPHWJuPYozaQ8h8QOcOi2Ij
	iZexJa12DgYEThC6XzhBj5BSU4yCouQqc2RpJ+juV4ljVr/YuaiP4Ed3H3b3yc3P
	oeWcjOBbxyBucB4z9eLQSo+08sqfBlTveifM3D8pb4IrOjjY9oqIZUoRblbYYd31
	hYe2SMiOhXOwXkU64h3ROCCY9Nvb1BkCqRzObMgNmYp/fqQaWhGqSXZkEHn37PA6
	AcuJeTsLiOS+mfsGaQtcdP1V3QRNfHfBHt8+rr+49vg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=YumzYC
	gBI9xJMhg5Wsctsp5d1ycnDB6rZ6uDRbC1240=; b=2YNzJaxim2JIwSGfycO/BA
	k0JMHAhdj5pOpH05oDSMmxd9TTn+dUfBIprYsUu008eVZz3Wd2xJkoiWNndm1j84
	8FoNIuxk21wr3dCQMGxAMpaJ9aIa4xLWWYls4vK0Q16Y1mKoW8sUWuyn9WeIxuoI
	qimyhvbfvBRpaQzXQfZa1rcW+3tXsaNgpFpQtMAO3Vf/tOT5nnXzC3hNvz0w28pF
	gZ9wEBYHWrsBWLHrkGnS0/qP/WNFxMNiUS3CLuzxUaCSj+DbSERWrjLlD01+UyuA
	Ekj5gBJwcH2AyG/lvPDT3ZaFeuNSXGQ6cV1ieE1nguAopi3aJANhyl4LU+pbWTsw
	==
X-ME-Sender: <xms:-g-HXA6wXZG4kuDkeoPhNYCUAqbG5cAAXv7FIjsnOCBJT3k6-atM9g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdefiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrddu
    ieelrddvfedrudekgeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrd
    gttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:-g-HXGJ_HSPrhKQvKwkkIFexhG3F8lDwHBPQ0r79FHlEY5b7RDReTg>
    <xmx:-g-HXKc1BKB8gXGCfEVKQuLkUOmsP_St5k0Emd7pveRHj1kc83kc0Q>
    <xmx:-g-HXJfr8UBJPbL9Yl_bU5j63KM-aBiItZ28sk8TE-VWh6ErX8eYbw>
    <xmx:-w-HXLpK5BAGXVZT9rxLlGmyKXkemLI6CiG8UBAuz3f-Z_Mqty6lqA>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3991DE4742;
	Mon, 11 Mar 2019 21:48:41 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:48:20 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 00/15] mm: Implement Slab Movable Objects (SMO)
Message-ID: <20190312014820.GG9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190312000928.GA25059@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312000928.GA25059@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:09:31AM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:11PM +1100, Tobin C. Harding wrote:
> > Hi,
> > 
> > Here is a patch set implementing movable objects within the SLUB
> > allocator.  This is work based on Christopher's patch set:
> > 
> >  https://lore.kernel.org/patchwork/project/lkml/list/?series=377335
> > 
> > The original code logic is from that set and implemented by Christopher.
> > Clean up, refactoring, documentation, and additional features by myself.
> > Blame for any bugs remaining falls solely with myself.  Patches using
> > Christopher's code use the Co-developed-by tag.
> > 
> > After movable objects are implemented a number of useful features become
> > possible.  Some of these are implemented in this series, including:
> > 
> >  - Cache defragmentation.	   
> > 
> >     Currently the SLUB allocator is susceptible to internal
> >     fragmentation.  This occurs when a large number of cached objects
> >     are allocated and then freed in an arbitrary order.  As the cache
> >     fragments the number of pages used by the partial slabs list
> >     increases.  This wastes memory.
> > 
> >     Patch set implements the machinery to facilitate conditional cache
> >     defragmentation (via kmem_cache_defrag()) and unconditional
> >     defragmentation (via kmem_cache_shrink()).  Various sysfs knobs are
> >     provided to interact with and configure this.
> > 
> >     Patch set implements movable objects and cache defragmentation for
> >     the XArray.
> > 
> >  - Moving objects to and from a specific NUMA node.
> > 
> >  - Balancing objects across all NUMA nodes.
> > 
> > We add a test module to facilitate playing around with movable objects
> > and a python test suite that uses the module.
> > 
> > Everything except the NUMA stuff was tested on bare metal, the NUMA
> > stuff was tested with Qemu NUMA emulation.
> > 
> > Possible further work:
> > 
> > 1. Implementing movable objects for the inode and dentry caches.
> > 
> > 2. Tying into the page migration and page defragmentation logic so that
> >    so far unmovable pages that are in the way of creating a contiguous
> >    block of memory will become movable.  This would mean checking for
> >    slab pages in the migration logic and calling slab to see if it can
> >    move the page by migrating all objects.
> 
> 
> Hi Tobin!
> 
> Very interesting and promising patchset! Looking forward for inode/dentry
> moving support, might be a big deal for allocating huge pages dynamically.

Thanks Roman, appreciate the support.  I'm working on inode and dentry
now.

	Tobin

