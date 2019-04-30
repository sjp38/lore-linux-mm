Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25558C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 22:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A568720835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 22:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="Ah3bR/1G";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mGuPJmU8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A568720835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F25D36B0003; Tue, 30 Apr 2019 18:55:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5886B0005; Tue, 30 Apr 2019 18:55:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D75676B0006; Tue, 30 Apr 2019 18:55:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B821C6B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 18:55:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k6so13353587qkf.13
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 15:55:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xbt1TKoKoLotpSf2hKRbnmk6MejLdRsCBZ711ujjQ0I=;
        b=tnbHcYJWJtBEGn3NbgzhLQSkcAj4cjp332d0rZU3g2vWw2N2qndzf1CjlawQYR3wBq
         mcos0+U/l64ScFCZIL7LarGf+3Fq3lHAaGjc7DMV0QL7XUm5swaxjp4j+EQi/p+gH9+F
         D6kKUc1VfkLMgaRqzWHO19tDMBVzEuDSLRHUAAdieHW8sb+Xo4k4EKHt/uwboTqtbqJa
         MDIifF4A/xYuynbZUYjOw0etTggAfizJFGkesPMpJssHCwamK4Q3qApQGKvKPEf+4zrw
         tmLHcDFVDhRzpQF6qnwu4MnhTUicrhEM+0iabyUM95cWLSaCHpWgJ4uBoZl+tjCktctV
         ZVPw==
X-Gm-Message-State: APjAAAVtg72kCR7zmXrAETIKI0NNpn7TsS/68Hd0nhbRCDl3g+gQtNPn
	yXuYlABMWVHpXVRoa5kTM/rXhpqbjH/jBO9kQNQiZwkJiANuhZCdY/ByUq85eA07muyl9ai5zsA
	mtG3wi/6at7bh47jqLVuYL/9ZkTa2g/XLe5IqtI0DSmRQzdBvjEUiUwbNibfhk+zD3g==
X-Received: by 2002:ac8:1a72:: with SMTP id q47mr31162184qtk.10.1556664900508;
        Tue, 30 Apr 2019 15:55:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUKob2Qmbb2Izf8nuKsXtB0y4jljybvHdodP6aY4R5JKJ1FLnCvhCB266SFqYvky3JaZ6k
X-Received: by 2002:ac8:1a72:: with SMTP id q47mr31162150qtk.10.1556664899844;
        Tue, 30 Apr 2019 15:54:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556664899; cv=none;
        d=google.com; s=arc-20160816;
        b=TC9Namk88Spdx05huZjmy6HgyW60gdg3tL9MWK6Hq3W0N4jJSfUYgupAOJXMhOMYyS
         NJr8AYl5EUmuepKMbiUNn8etGBISGBzulHtFRfiO9EuZDBj/c9HqxMb3P5Uf8NPgFKJp
         vUOhPB2BC+2dJ0htndo18zu3P7+MfwqwoUFvBfgrInm/IQOZrVTYY1chJq8lflG0YjhY
         CttVxD3r+X/c9YswA3RXn9g4FVnNEHX3qcWIdh5F4yVH33vlJuwryfPibj5bf0t1VrN+
         JyU5mQNpMLpKllA2hy9Sr3SPQhXG3h3Y+uhEeMpa2FA9Lp2Y/JuVUSVxlzIM31owkbXb
         IriQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=xbt1TKoKoLotpSf2hKRbnmk6MejLdRsCBZ711ujjQ0I=;
        b=CcEnOMiYVYyIgjy+tjEocOM606HPvjLii4mumnhHxHro3NNb+k4aPwJinFeDEKStd5
         UzDiTbldKwrlD9RFTKylvsk91v+iwiqLbn0ssXF9GqPdG3Ub3GqqdT0fw+1CenVZjVsW
         779wtEXolOIgfewB2zdSuIDh1imyz0FmCarn4SKDt+kJIxRMwX3HeZ5b2b1kI4zPd8RG
         nap9SHBa9F4YXZisdO/onBCB7xGAIVw06krV5iE7177rxeIKxinYdKwndABR9WDH1/9M
         vYc/mwR1RveK1Ydt1+BXzzo0SLFLEdEyUXfR7Qy9YSlz5KrqPlSCwHKm6VQCSwjiVAcg
         wiuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b="Ah3bR/1G";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mGuPJmU8;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id g58si2910417qtb.41.2019.04.30.15.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 15:54:59 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b="Ah3bR/1G";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mGuPJmU8;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 627B723376;
	Tue, 30 Apr 2019 18:54:59 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Tue, 30 Apr 2019 18:54:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=xbt1TKoKoLotpSf2hKRbnmk6Mej
	LdRsCBZ711ujjQ0I=; b=Ah3bR/1GWrHGRzCJljWDgbZH2sJYUIJuoPQD/WMt+3k
	pSn9PzirnbRj5B6KjHk1c7lc7YpITYSsqfcA+bHdQuyga483ScmGsAOpyXmderLS
	UFNxkcRntk/8RF3Z+rfPwDWGbSbQhpvRsG1I1KE0RnDb5yPWJyfimLUWL7Layinu
	igDt1UA19Uxk951AgX6xFoWNm60nsedcoS+EQxBXS3SFAIEtOu9QGkqxblT053ox
	urZEf2cmNLe3kXvqSlZPAejOjSJwii0df2nPc2JK+d4RzXTVfryFbJNAzmhQ2whp
	vmSbzs6RJF42DdoLAHyAWAnxTaJ3B305TNHJDNs1BfQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=xbt1TK
	oKoLotpSf2hKRbnmk6MejLdRsCBZ711ujjQ0I=; b=mGuPJmU8rWlq5p9iDDswfg
	qb0uyN30bpfJNc69sRApK+Y4e+cNuYLdzQq0G5Zci3r9gxMhtaJtuSiO/aymjR+d
	PhxRnWeqLhrL0edSljJXiOrUv49coIwFnj6E3rHtj/WCGFWhGnfms6DHxUlBoggE
	hkarPWI1mhwaTn2wQy6opz6cTXp3vN4BygzJsOi8sOM39LzYiK1SKy1+L7bOS0sX
	UtVzKR6JwjAOCZ0tFbonCe389e5/tYytuWpvbRnM9FieY9tUs4eVdFTOdf+Rc6/x
	JJrAoa4QgMmPeoTjSzdwErSzG8lo+7Tkp3IU9CyxeaqsNok9Hjf6WnzGaHi1U/zQ
	==
X-ME-Sender: <xms:QtLIXC6uvXn_-MF8jKiJGEFlhq-2y49Xt4wcRzI0lp0Yqxu9yGtbPg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieeigdduiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvuddrgeegrddvtdegrddvfeehnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:QtLIXFOYMuE7jGcijSRcZww1kTaH1gl3ZJMKjSzF-w1AND5tAB9NrQ>
    <xmx:QtLIXN0sL77vbItsrgakOPBgw1VLMzTZOY_GACPhioIwE08fM3-wTw>
    <xmx:QtLIXGvI6PlL7YN0E54D7xDdMMMcUJ3ca1saHAuxtrDjlzOrpAfnRg>
    <xmx:Q9LIXBoh-gllT6pgdki7OJeAxnmhXeoCrxWLNU_f_O-g7jpZ9vV9WQ>
Received: from localhost (ppp121-44-204-235.bras1.syd2.internode.on.net [121.44.204.235])
	by mail.messagingengine.com (Postfix) with ESMTPA id A7F8DE44B6;
	Tue, 30 Apr 2019 18:54:56 -0400 (EDT)
Date: Wed, 1 May 2019 08:54:18 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix kobject memleak in SLUB
Message-ID: <20190430225418.GA10777@eros.localdomain>
References: <20190427234000.32749-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190427234000.32749-1-tobin@kernel.org>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 28, 2019 at 09:40:00AM +1000, Tobin C. Harding wrote:
> Currently error return from kobject_init_and_add() is not followed by a
> call to kobject_put().  This means there is a memory leak.
> 
> Add call to kobject_put() in error path of kobject_init_and_add().
> 
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  mm/slub.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index d30ede89f4a6..84a9d6c06c27 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5756,8 +5756,10 @@ static int sysfs_slab_add(struct kmem_cache *s)
>  
>  	s->kobj.kset = kset;
>  	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
> -	if (err)
> +	if (err) {
> +		kobject_put(&s->kobj);
>  		goto out;
> +	}
>  
>  	err = sysfs_create_group(&s->kobj, &slab_attr_group);
>  	if (err)
> -- 
> 2.21.0
> 

This patch is not _completely_ correct.  Please do not consider for
merge.  There are a bunch of these on various LKML lists, once the
confusion has cleared I'll re-spin v2.

thanks,
Tobin.

