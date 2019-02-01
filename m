Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26F64C4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D769F20869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="iDCEb4dF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fibNY5iG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D769F20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AC5D8E0003; Thu, 31 Jan 2019 19:58:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65B818E0001; Thu, 31 Jan 2019 19:58:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5221E8E0003; Thu, 31 Jan 2019 19:58:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26FD98E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 19:58:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c71so5205806qke.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:58:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZT9ljo+ZXcqCXfaIqDIpaOjNxLT/0pY68f+LJGHdi4k=;
        b=TETGGv5S1AcRogYbFbUPiVkHl/oADPA4alxaYZ1uc9tdy32dVe6RBWH+AwBVkeu+CL
         zTpnvH/rMPotEbjqV0r1zsEURd2J7/YNHH1xS47UY7vorMm/PZXXq/z/KKLpXDpQ8Wro
         /4TGEFaITKgaQ65S/eL8YZpE/EuHpPawvZSTa+JgvC2QPuS2MZ/PmnVDB/xEOhVk8SUq
         UOnPtxKYeUxjpGiREYfs1BzFvnccBVC0Hcw/9PgFkFBT6YloexIG4PbIrKPDqGLTkV/f
         4Q6I3RZXsfzyLCrjCVmnbYmtT0lcSdxLvX6AK3R22Pzn8AVkBg8f/pPBPJY77EhRoDsY
         JAtA==
X-Gm-Message-State: AJcUukcYxjd9WkqHlMnMWyuAnOeKWBr1iclz8GcooXnhvjRPmX7WuL/T
	iZ8EHFy1LA0RYAtdrzXHqXR1V4HbXumAKoCU6QIRffMjAAftr0QnEhrLDVHuJdXH2FtOb2LCC9+
	UVzpjPD7vwpjU6mWEUpc22E0h3KAGqF+ge83HQzbTbs/vHhuRRKHTEHZP532B+TJ1pA==
X-Received: by 2002:ac8:1909:: with SMTP id t9mr35412921qtj.327.1548982728942;
        Thu, 31 Jan 2019 16:58:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7NlL1LdkTW2zlChEW60Z3G0/dQQXJ0faguFzegG05AQfWqmVKtKTGFMoevkWuLW+7eRcjo
X-Received: by 2002:ac8:1909:: with SMTP id t9mr35412901qtj.327.1548982728408;
        Thu, 31 Jan 2019 16:58:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548982728; cv=none;
        d=google.com; s=arc-20160816;
        b=zYAU+9c1/LMnRGn5IauW3jc079b/lc7FvUt0+LkB9a3q2ZvWXDZErKSIST622iGs18
         f37OZoExh3mOS5rxiPpCy9XEtlTOAZDKxa4mksVjlGWj9WP7hrJH5YV+vWvukuI4lHgL
         HNDVvXGbwK0oQuDS++qktnJM6pT/SHjupBg3zec/uGYbevooMKgalZjBbPEEub03Q5PR
         VU4UbHu9QH7YYWT2Sruj5661KinZHUC8VPREUKdGDNSdX5QRYMxlkAEynI9KeH1JhZde
         rFlu4escPiiR+ptAdoVAnXYCkYCem/o5wV57WZ6X8F4rV4jOOYzI0YgH7q+VJELvLbm9
         LZtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=ZT9ljo+ZXcqCXfaIqDIpaOjNxLT/0pY68f+LJGHdi4k=;
        b=avBwKiOtVI/mRE/p2/58Z8TrP0KvSPqew+3tiq4+ootE42RCuWd21xTF5vOc0/bm/n
         wTNdkb1w1wz5rY1mY+RsNCeg03/Dtm6Maoi300S0Lf1+zMQSeewSEykce22ohH1FTURR
         PTaEvvAWCYqYxXBwTfzB6MBIi2PTI6xrBrqO5PztnrcmHY2yHtPkySuiJH4KARW0gMSR
         CbMfxg+9uLCBGYu/L5NSMOJsH9SWD+lZthjLxPFLvqrzG0VtrH4XY4U87g9BTs7Q7yCa
         vvzkKS28H95zsVAhObbhbhncHT4UwNaoZ8/7Hsz52+NMMam5n+MyZg0BLph0RFDcH0JO
         AsHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=iDCEb4dF;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=fibNY5iG;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id n6si553548qkd.231.2019.01.31.16.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 16:58:48 -0800 (PST)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=iDCEb4dF;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=fibNY5iG;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.west.internal (Postfix) with ESMTP id BCCFB2D89;
	Thu, 31 Jan 2019 19:58:46 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 31 Jan 2019 19:58:47 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=ZT9ljo+ZXcqCXfaIqDIpaOjNxLT
	/0pY68f+LJGHdi4k=; b=iDCEb4dFuYjMdR3BFwDxpIsj7iEA4rdl0j/fbIO0Y5L
	35DrJX85pmr21SOxKR6GxySOe4BLEL14YQLyv4m0a/1bW7PzauyF1XthMpmMfB/E
	j2FKOlqwHwCCN82dGYIu7woyWkCejKzPix4eiTCbgUQZ1oIMjlEfHHEUQqZFM9IG
	fU/T0IBDuMdedE1+RikHRLLYju1nKNyiyvobmHD5VlNFFm+AjZtmABUJic/w+ChB
	4u3Ft+OVb7qWvokQC2IyXCzzOxI/mJbucvUsvdi1M4oKbv69lnEjLgSLKr9eNidI
	9VRG874qsh7vM3GfYTgnJPANIRDMJTC8oNtGm5RwzuA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=ZT9ljo
	+ZXcqCXfaIqDIpaOjNxLT/0pY68f+LJGHdi4k=; b=fibNY5iGO8VOO2bhZPWGPy
	bDwNE5qDQWg5jnmBkNFSmvWLWjwXxj85cmCtJn/Oi+uOI49IrLmkTe2SqGMkRyD6
	s389zPYAuRzA00XZDLYdBtuzFQIyASWkISLtxjBaLHjmY9klzFTjHuEEsa8P1MBu
	Qjhf7E/r/RmcZs9QUO0y+kwt7T9xYZpfH1CkxlK00UH4sRGCTO6PMP+0yclnM8Lj
	hSjNg9U6H8ITqXSDKToQNC2qo8EBILAOILd+yce3pilcd9htO6QgGfA7HQX830m2
	Wbxi56V9SQFKiRABFp8RaqL/N6NtG8MYiNoN68UC6j6ljlxlbCEEs6/s9tQi8b8A
	==
X-ME-Sender: <xms:xJlTXHgLxnfFBkh-2exrnCdSBSqdun8dywhXZ72ipMq6Ish-TjaONQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeejgddvlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddvjedrudehjeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:xZlTXISnZTH-dSVzJifEISez-n8sraP3H8sA95JoinTp6UfZ4AJhGw>
    <xmx:xZlTXCHYIwQEVgt-UX_snwAgthTWTH7umcJ9KVkGDCJ4y0BWg9f0BA>
    <xmx:xZlTXIm12-JnnhRbEwSbSeGRa3KVJK4UPVZ0bLSuF9dHRylViHt-WQ>
    <xmx:xplTXFKEqjwBvTOgwxOEEPbNZpXCAPA3nAX5kux4VqRN8wUQgAAVbQ>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 414C31031B;
	Thu, 31 Jan 2019 19:58:43 -0500 (EST)
Date: Fri, 1 Feb 2019 11:58:38 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190201005838.GA8082@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201004242.7659-1-tobin@kernel.org>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
[snip]

This applies on top of Linus' tree

	commit e74c98ca2d6a ('gfs2: Revert "Fix loop in gfs2_rbm_find"')

For this patch I doubt very much that it matters but for the record I
can't find mention in MAINTAINERS which tree to base work on for slab
patches.  Are mm patches usually based of an mm tree or do you guys work
off linux-next?

thanks,
Tobin.

