Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60909C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:24:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 088FE20854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:24:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="fFNsm8gj";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Q14FmF+x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 088FE20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9740D8E0003; Wed, 13 Mar 2019 23:24:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 924168E0001; Wed, 13 Mar 2019 23:24:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EC048E0003; Wed, 13 Mar 2019 23:24:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9178E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:24:47 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 23so3522320qkl.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 20:24:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QD/L4U5YxRm2Guw00dch8PmlTQ/omLCRelsZiBSPVsY=;
        b=P+/fCkafTx0xwtEOgWjKpj6S6cMOGELHS7ceYSvNvDw6yUgx8XQnbWlVSA1+2otUkY
         UdKCoRlyUuxGoF0xz2LFRkanpXlA2Xc9ucggBVpMCIXGd8n8Iqge6h0SD8gZvuTce3w8
         stbV+PsVN7O6i6TPdtV5Vw5ayzRuSw/wAvxdg4yZzMuzC8SulqFZhnBKoxk9unhj4ZxC
         zcU1gkg/Wp6I5Ol4K28yling5y4+RAxJYQmtByURpLqrKa1WW9Cw3bNCXBgVLkJHtCXO
         McfYbqGXSWBbhLRKBM7g9EWNEbV1kqRvXCly3WGVnOw/hzw5mgLcA3dRrYy47RZYewTm
         L+uQ==
X-Gm-Message-State: APjAAAVqPl10sRpJe43zun+ilE1vV1dd4ISkhEtxf2lAsxbpd2p1lS5x
	IGOONbr1BdbELvM0p8z4PmAhQffYvBxmWrMMQMRN893PFJT++y7Qa3ZfyxL7iG1PINykvCdaqPt
	U7Eq1phJJKWA1PPAsaYAt3Xtm9MUgnrtwRzpLsRy6nYKUaVmKJoU9KgTsQASFgwiFkA==
X-Received: by 2002:a37:8fc7:: with SMTP id r190mr7045542qkd.193.1552533887103;
        Wed, 13 Mar 2019 20:24:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8exN+6DjxX0UDA1T/c9LBydTF26I1KB4otLTtXdvUye7uxaLNgZyZs3m84GQ+WYBxtJu3
X-Received: by 2002:a37:8fc7:: with SMTP id r190mr7045519qkd.193.1552533886464;
        Wed, 13 Mar 2019 20:24:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552533886; cv=none;
        d=google.com; s=arc-20160816;
        b=Fv827z0ssyeuUVxh/yLndGQhP3GWTmcfbJvsfx13kTd5uZNSw+0yztHLSkS+G+KnNi
         oNUYMhdpuc3xjI0vMBNTfdqxmWS2YBaIX7b47XNZe4/r7DWhEZhpjdXnblHxh7HJLIfP
         SDbIRHDilBKoc6OEYMGXSBq6n6SWVyikSapaAW0q7cszWmWtMWv6FyUhYfd30ZNG/BAA
         hsN8B31ajwiStn1NzcbdJ1sM+xWNXFJFfxGWiI6UxJrSSvLuxfQX1Q97URemZI6tykwK
         03sTbggvfBLJkNl5pRsqq5A4Zcnno9tsoTns+EYG1+/vm5difIVd0MY/3p4lJJrGTSjx
         y0Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=QD/L4U5YxRm2Guw00dch8PmlTQ/omLCRelsZiBSPVsY=;
        b=DJu+FtLwcVySGSMXiTc5auqQp5iM5yBUYgcv5xHk8xhrc+tDr2E29E1h5iQIiUczUk
         IckvPYClsjHP+EGpmkpKnKQnUQHxrtlIY5FN7Vzvy/B8fr6pm7TkB0n7JSzoq4dnmhYT
         g47ATV3WsPWpHnHTDSUkmcUGcqHz5D1EIQXvzjImnJX/qWUQ3li5oNOkPEFA16/yldPr
         b72ePQlfReX71MdE1Kbvr1xzGHVtBC0kJ2tklMHTBpBCmu09hhHokhyOfzQn0WdBE6vr
         kYrdID0tPg4cbo9az3n0+6nUfc/FA0oHOWqDr2sWpoHR/cL3DY5nlTUnMQm63vPmbAYd
         R+yA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=fFNsm8gj;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Q14FmF+x;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id h7si2573169qth.20.2019.03.13.20.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 20:24:46 -0700 (PDT)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=fFNsm8gj;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Q14FmF+x;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.west.internal (Postfix) with ESMTP id 609AD3739;
	Wed, 13 Mar 2019 23:24:44 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Wed, 13 Mar 2019 23:24:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=QD/L4U5YxRm2Guw00dch8PmlTQ/
	omLCRelsZiBSPVsY=; b=fFNsm8gjbOopziwP/as9hJ3WnJSe6neNNC0/pLoTrln
	5egdSuSKvOOgq5hW03NC9btqGVfvcJFp0GJwHwgHPPSWwNy5VYnG82I137mqhwkU
	ApaZHxuGXwWMR3o0RKCORoLe+vYesHhEYfRVl9YoEnsmce6yfAAUUtuWBefV/D8K
	c7VzhJz9IB6iKNRzUwJ8VRvdI5R9iQilt9ML3P7tkgs5YOgaVvHRT0bVHaHKgKT3
	Ym8Wi0XkDZSDdYb+Nzd627/Rgpglego+/4ia25zEEdJbdF4FmD5N1Umc5gM8hamh
	Xxh5qYKHzh/7Fq2bvL4Rom+RSKeYFbGMMRq+eKh/SjQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=QD/L4U
	5YxRm2Guw00dch8PmlTQ/omLCRelsZiBSPVsY=; b=Q14FmF+xo3wVrkrc8Azank
	0VTTApneGjeGoytQPhAQlW2gXnOwJ4qGRHpPNZTQrGzgLvBM4HVy276HCQHN505+
	QgrnR8NP3WjXiW9EftW2PjGbSRoE7OqfR6YfZJhnq+ghVvoHzHJgMFFLD6cFuLtx
	JYAljqI9gX5A76iPSHcG0ns0peC5Z3nMPLP+HCwYHodzzJVDPsB9tdtNKwwz4dAb
	AF43tS4H77Vmd9JZZpP/ild5SSBimDWhI1AbZONj/IFKZUnWyN4ZxNMNEG6MoBD6
	qJ57xEYnANEr5Xr7lFJBENDsKihLD/6UHG10WE/CQYR4yWo4H+ze2xTp61FVxaGQ
	==
X-ME-Sender: <xms:d8mJXCBJs40Wf9tZwsWTj6N7UnQGNbVquJ206Ex30GBgfr8h8or0Qw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdehkecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:d8mJXAzYrTOZT0XFO4AzJ9gXW3byODdFP73B8AlIfLpkfUiMx0FC2Q>
    <xmx:d8mJXAmy2oW8cIw4AWAQnZaEVBobqavKAkwd__apBoRMbno81KP5qA>
    <xmx:d8mJXFHtXHcc8h_DSJBz4cIvJdnq8iPsPPpfIye_npg5BKalkEqEQQ>
    <xmx:e8mJXKJrNFYDc7_iP2hLY8xMYLPq1hzXCvcOS-MYYq31qNC4--iqIQ>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 31C52E4210;
	Wed, 13 Mar 2019 23:24:37 -0400 (EDT)
Date: Thu, 14 Mar 2019 14:24:16 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/5] slob: Use slab_list instead of lru
Message-ID: <20190314032416.GA25492@eros.localdomain>
References: <20190313052030.13392-1-tobin@kernel.org>
 <20190313052030.13392-5-tobin@kernel.org>
 <0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@email.amazonses.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 07:05:02PM +0000, Christopher Lameter wrote:
> On Wed, 13 Mar 2019, Tobin C. Harding wrote:
> 
> > @@ -297,7 +297,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
> >  			continue;
> >
> >  		/* Attempt to alloc */
> > -		prev = sp->lru.prev;
> > +		prev = sp->slab_list.prev;
> >  		b = slob_page_alloc(sp, size, align);
> >  		if (!b)
> >  			continue;
> 
> Hmmm... Is there a way to use a macro or so to avoid referencing the field
> within the slab_list?

Thanks for the review.  Next version includes a fix for this.

	Tobin.
	

