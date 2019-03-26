Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22705C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 11:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB7862075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 11:37:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pbvPG1TF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB7862075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 384FB6B0005; Tue, 26 Mar 2019 07:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 335E26B0006; Tue, 26 Mar 2019 07:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 200626B0007; Tue, 26 Mar 2019 07:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC2BC6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:37:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b10so1971670plb.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:37:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bv5G3/eS21umtZDY99PXXbaStFpJ80Xzj5R3U428fsc=;
        b=BxRlAZFnFur0s1kSlPy8Zj+ToyYQmcb/95oV/lbmVEczSh7ykDWqNK4L7CiA8a/4P3
         N4OLNKlQzpevts9JtU1TdBjgmrFfo4+gR1+nQik0/R3j5uNAdTmGxgP1gk+s4fr6G3/U
         tRJmRAhdaqyhw1JXKKPi2dO3OPW54YhK1lHDcPled3oKPDQZJozCgerG99oSCSpF6kYI
         nB3z9gM74IGFSi6Z1bgan+tgnV2XENjQUMfZLl2h8+Du+KgZsMmWf4RPGriwxmnoCdme
         DnocwesJPL6V2e1wR2vyelrDd3CZuv4RbXJkaG764RWJv10ffd5E2ra4zAMBBDO51mYb
         ms8Q==
X-Gm-Message-State: APjAAAXl15Ijo0iQGCZaKwP4bAnFfHzl57+f61KlpjozI3FjAAMZyEaU
	8mgDhUIWOSKNM7xndL8oSPstUeKDjJwxZKb7fm8znXC3Z5NxG9Vl1xur4g+Cddzjt7SarMi2X3F
	ss3p3y+NBHwGpZE6V650dQLz+hyqgAQ59SSWU9DSUR16Dog6GlmINXjz+u9e93PQrAw==
X-Received: by 2002:a63:6b89:: with SMTP id g131mr14703125pgc.438.1553600223459;
        Tue, 26 Mar 2019 04:37:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzU1Cwgp4y2Tfqv5+AzjpjbJelFR3KjEXCmiwRQ+T6f6vdZR0D1/0vk3jpP2/iJCqy8USW
X-Received: by 2002:a63:6b89:: with SMTP id g131mr14703060pgc.438.1553600222545;
        Tue, 26 Mar 2019 04:37:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553600222; cv=none;
        d=google.com; s=arc-20160816;
        b=BelQ2ami49FnYcZvnFzPF00NCQzrbB9AG+nv8RZY+SEd3MzsWBMSMWykUcuwgFBbR1
         ODFUo+7RE6yJ9RpjR67CR4aHDFPvzYEKkOiSQMcM8AL2LscX8W1ZYBlVhG3HeP/lacEf
         ZV+4OvPv6t2x9pQNC29nYMvMrrJfRPYOfWrO2nMZPi7hM8HSxxPvNr9BIzjzQe+NzIiC
         5QujsnKRfpxNKM+fx+YXH36P81vyYkC5Fg6yuw9N1XYlnhxgmz9Am/XOzd6//YFjtClX
         lTT9k9WhfywJc++Isl8ts1pgQxAqobpmnYTq6h5gMbwObWCJh/Nm/1H+iX9RuEo0NA/d
         WXZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bv5G3/eS21umtZDY99PXXbaStFpJ80Xzj5R3U428fsc=;
        b=kdW0RLpMnNPwspOWW6iONftXY9ZK+1RyjiUGIoN1FvsnHtlubVLGc5lRKFunQsZrTh
         vQeVJh6Vy5NbYnSjiOX/UYSRhx/G6KZPXX4OMqfAX5X2zECzqZ9ngAHccyQKNZ8PpYNC
         rtnykS9zLNkqfbsqwO7TiuWv9tfKNiB8qhU8j90IUyKR2gUkOouyxCYx9hAQ9JKdaYha
         iYM+zeZvycu1FPYzK1MZuEK/mezSjji8PE+JrB+wVcjOnklnvzYj0cEjM93QOdkDAJXn
         wsUOFOdt1rY3hQzXuEjx6QJkShWcgodSQQanIfMvoSjgUS+wCRtvQqedt/TOK4JERg0U
         aM/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pbvPG1TF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a22si12615119plm.263.2019.03.26.04.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 04:37:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pbvPG1TF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bv5G3/eS21umtZDY99PXXbaStFpJ80Xzj5R3U428fsc=; b=pbvPG1TFAf9dyNpJIgt8xAfrh
	/Jp5p+bEr9ZP/xKdSIYbZGtXXuL2Hd/wDs78rTMcR2beiOKqEY+2qF+fsuixMDsjKP0gOaZEvWTqj
	RXoAEL7hcsC3Ir0HxvJ2HJix2KKgUWWNJnaQTGdqEJAy4radoDP1yxhNaEAuUshBa9D4r758xGGpT
	m2Q3BzSebFUcKC/B2aXXgyRZkx6HyWC0VDRpNSjSC9vmc9TXBESbW5FXClTwzjexbXDXE/1T0ed4K
	QHXaMe3JcNLJ5cvcgh5Jy2f04T47Rk4QHi/wEwNB3TyNYLlOQXJGxwSvGKTxjHPOzsLNFWVzAA++O
	0UuNcj38Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h8kO1-0004SA-8v; Tue, 26 Mar 2019 11:36:57 +0000
Date: Tue, 26 Mar 2019 04:36:57 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Print map for total physical and virtual memory
Message-ID: <20190326113657.GL10344@bombadil.infradead.org>
References: <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000567, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 08:34:20AM +0000, Pankaj Suryawanshi wrote:
> Hello,
> 
> 1. Is there any way to print whole physical and virtual memory map in kernel/user space ?
> 
> 2. Is there any way to print map of cma area reserved memory and movable pages of cma area.
> 
> 3. Is there any way to know who pinned the pages from cma reserved area ?

You probably want tools/vm/page-types.c

