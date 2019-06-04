Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0661AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE5962133D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:48:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tTAUwG4D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE5962133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64F516B0273; Tue,  4 Jun 2019 07:48:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D8506B0274; Tue,  4 Jun 2019 07:48:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47A046B0276; Tue,  4 Jun 2019 07:48:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF516B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:48:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d7so15927166pfq.15
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:48:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=usxMrtFKFaWUXsgPZoWK8RLJ7ydXAE8gfK7g1BmfbaI=;
        b=q93cHxgbDZUAR3gET5f2iZUfZhW89xqbPQNksZ2ai6fCdEfGSXa/GyIjhsCSgEpRyh
         /ErFBwAO9V/m6O/DRXwZ9iBxZ3PpaHBQAWWQCHenlJj7H6NriImfiBz/f59ZT6a+pmtl
         VlNtNmvK6tsJwdWb7rYHv9lHx2YVEOsz+3A5jK8QJw4H654LTj4CjA9SYDMdwPmFIkDm
         dezrJxBUYEBp+4R47MNQ2sFm7b8v4xpvyOhfvEYT69js10OzGqyKzutMHw+ZOfb89Vnc
         eNNnN7H+WJ6FBgw2GV88HQAv8AKIQM5HcckTTCCeGcGocymDgB4xqon41qIKrrK2SueI
         2h+A==
X-Gm-Message-State: APjAAAXS6VlgCU7MbvN4phpJbZhVK6Mp6YVS5cRiPXmMaYi/GhL4tg4H
	m3unxEaT9B76DcPmaZkoxIqmroV21peie61TM8Kl139Sp48aJt8fnVeXGlUDcAWQcqOS4jVn3Bn
	8NFcq+y8J3jjLjg2TFJ2mlUe2DwspjIsNqN1O0lRdpVPITZ9DpoW0kepI6g14yhm+Vg==
X-Received: by 2002:a63:ec42:: with SMTP id r2mr35375008pgj.262.1559648917732;
        Tue, 04 Jun 2019 04:48:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaDpbR7LpF2tjx/8zB4tVOoS0G3TnGfkhRNqFCIMfET4Z1ixwrJE9GarbMuUmnh3sE+xgE
X-Received: by 2002:a63:ec42:: with SMTP id r2mr35374928pgj.262.1559648917029;
        Tue, 04 Jun 2019 04:48:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648917; cv=none;
        d=google.com; s=arc-20160816;
        b=soAzeEgk1cqeOwoIAeaJw6GHoDlrtzbEs0KMY52hZ5F+eERmxm0f67psdctylSeSnu
         uBa3eXce0vRnKsezz2WN39nxR3Qcb1GwaO9PExj2dASr6KpxKrpMBYRBWJkOGHztEjqp
         29fTQj6/h8HI6jPVLwCKjZ/M1XZTzRt7PXTIMS77hmMBC7aIjTJQCAAZhrS/PZAcyh7Z
         q5OHH28yxFDno/gaxE5FcsmIJm+lXuemlugVx7gwaoJDap8btPQhv3N4y4jJ/wa7sAUR
         P7FWBWdiJrqK+grrsbDJBbJjEbc45N4+FF3M+C3bypjB0ZyBrv5ZiDOUsnzJecjpe/vL
         DHmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=usxMrtFKFaWUXsgPZoWK8RLJ7ydXAE8gfK7g1BmfbaI=;
        b=ZrrpEk/Bvt29TR3zmjN4VYkH94fgpTri/pAvLZdP7zXGLgE14KBRQxLmkeg8KvTl2d
         9XtazJbPwHeXpAApJwH4/bJTUXdgbQpeZK3aqPjKM5r7s2CfeT9HrIZ7SW5NsSiZPbj4
         rBVQRXo272h1aIYMvDW6YpAfCf6L1+aJDr+5Pnxk8rhla5o8T8f0bo/XV7FrAtu4Jk7g
         sFYrVPsn/6h5iic8pTt7P+5WDCAej+2Y8B0kRzdQGDdG8H+wZPyEgdWi2Tv2fxUB1eVK
         IUrsEm8UlNmb+7AZjR9MmO9BTa878tiOGWq3H7dAMIG5sPH6UJsry/EAfWuP94bDH+6k
         BLtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tTAUwG4D;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g11si20775693pgs.201.2019.06.04.04.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 04:48:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tTAUwG4D;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=usxMrtFKFaWUXsgPZoWK8RLJ7ydXAE8gfK7g1BmfbaI=; b=tTAUwG4DBF+Vm6mOhLulP4xCD
	tCTNc/9te81U59DISPa3PoKxbhzi2AITbza3nx3maKQ15CXqzQUH98JH6n6iwdWHQSpnkC687KlIS
	2MbwTonmdtAniU5NzsslIRarvYArD96eKKf/CT+RgtLB9SD4os/ulsN06qxdPeF5XFZcRvG/NrS6o
	7Tx7kcPnR1TBVZkbSuqBLKRr9qr5Pufk2+YovH7uhvM8ICVWYPLyfgtLjICdS3unvKIQWO3fzp6Ge
	4Aj/6cT23Nm1me+oGR6fRA9uJGtjF+B86vu+rXr1Fw7Lp2KOp6vFm7ayIZ7u4SYJwDEvAU3hfp3bD
	N0A7ZvITA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY7vY-0001TK-Gv; Tue, 04 Jun 2019 11:48:28 +0000
Date: Tue, 4 Jun 2019 04:48:28 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Emmanuel Arias <eamanu@eamanu.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, emmanuelarias30@gmail.com
Subject: Re: [PATCH] Make more redeable the kmalloc function
Message-ID: <20190604114828.GE23346@bombadil.infradead.org>
References: <20190604014454.6652-1-eamanu@eamanu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604014454.6652-1-eamanu@eamanu.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 10:44:54PM -0300, Emmanuel Arias wrote:
> The ``if```check of size > KMALLOC_MAX_CACHE_SIZE was between the same
> preprocessor directive. I join the the directives to be more redeable.

>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  {
>  	if (__builtin_constant_p(size)) {
> -#ifndef CONFIG_SLOB
> -		unsigned int index;
> -#endif
>  		if (size > KMALLOC_MAX_CACHE_SIZE)
>  			return kmalloc_large(size, flags);
>  #ifndef CONFIG_SLOB
> +		unsigned int index;
>  		index = kmalloc_index(size);

You didn't get a new warning from -Wdeclaration-after-statement?

