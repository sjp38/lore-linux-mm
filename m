Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 609DDC282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:04:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27D3C217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:04:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ji/F2CZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27D3C217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9C766B0005; Fri, 24 May 2019 12:04:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4CA86B0006; Fri, 24 May 2019 12:04:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EE026B000C; Fri, 24 May 2019 12:04:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52EA36B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:04:20 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e16so6577601pga.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:04:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=udHsjQBKP68t9TZ4H27l2j3R7dmm1NcGJYaKWehd8PE=;
        b=r78Vskr0CTnfmo/0uMlAmfOtJmnWfwV552yReKFtX2+H3TH1Fa7NBDkBXO31yz8yId
         SCcORvl2CAJOL3jwBiXm6RPOPf6yxghAWr+0iurkUwygi6D9/jVBRg0JzFcc4zNZl+Z6
         I3WqWK6wF/o1MxjNv1ny5wZ4jXcl2bpOKysbHQIZmuL018heZogucH1ICBv3Zfif460a
         XX9Km4UvwwC5tsvVeXfpPR0Dsf4vlBOSk6Qfjp8gz/0mTMCuY2ZwncizCyUT/BuiVyz3
         fGY+R3Njp3RxNMNrKq7RICpS1f/u8N7d3h+8wiIjiZdHm77wv9g1zVD828xQS9WejTtF
         4vxA==
X-Gm-Message-State: APjAAAXLcQgSXN+6kwITul6YDQPN8OcA0JWsZyy66Ex1ceHdde/fo5/n
	HGDiVF4q4fdf2gr/qW8HB66Y+tu2kkDj5unG42BECOll++ntFsDXhGIJmcfDbrjg9S5SQkj2t9D
	0SA1NTdwobawsSJcH2YoCzraVpNhYTBQ0oeQls4i1llm+jjxas9U0PddB141ustkaXg==
X-Received: by 2002:a17:902:24e:: with SMTP id 72mr61441625plc.168.1558713859962;
        Fri, 24 May 2019 09:04:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzW2cvMO1trRsXOImuqChtRPo7APuF6Dqt4NwB1lihVxaq/QTW2APcwJZ1Bc3N4Adrmdpb
X-Received: by 2002:a17:902:24e:: with SMTP id 72mr61441540plc.168.1558713859121;
        Fri, 24 May 2019 09:04:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558713859; cv=none;
        d=google.com; s=arc-20160816;
        b=UC2Ni6UCGhnRSacui0Au0+10gEIbU8Y/+UfxMbdvnp+2X0hnUQGm5Pgzf51sElYbvD
         cgWkLdj7vkNkeK+mh/FS27UzYlxyY2DAwCtZYXr/KMN9crMAjFzeXjj/fAceKcfpcaWe
         dQ3wbUdkaqKz5WrbXxnZaXJ1ZTk0PjwUZIaA4z81079Yk3d9yOOZcfqmCI7OLlh+epqp
         2Sy/BxbTOdrVQiB9QsDN2ipZI/7oPE4TnBs9eDX2r5Ke9/a05O1b7HuXpj4ZhCZ5QYx8
         R68dq/hCXI4Q7Fm68x0BKhIw7A5VHVU/Nh8tnD7B6PxIbUh2bh7029MvHbLtgC1Txxbg
         qS7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=udHsjQBKP68t9TZ4H27l2j3R7dmm1NcGJYaKWehd8PE=;
        b=TcKgY4QFgBA4pfoL0Hz+O0aWswL/9/DJbsOIyybB9mOYD2e1uhz5lajGNTf4yG2u0t
         pzSKppwlST8vk94QNpIHVFl4sY6d98/YSShDydEdm5g4sVXMlVNLINFVQPpXgV65tMc5
         W4Eeww/JFsomhypvZAT2zsHq8/ubeTXcGMWj3u5da0e9XCC6LzpaWfmPGqzlgj0ItKn5
         vs4Bgrm9MIFm9ZdarS7jxDdH0Z6tYMHhYP0i2+Sb0W4Ist8ILDKXwNr/yIQbayPbOwlR
         Lx//k/hilax65CeHUxlNLi5rFyRK+ifI8sKCNnEU7mb9+UiccIpjAcVaNpjM5Lkr3hSI
         ha5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ji/F2CZo";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1si4741805pjb.34.2019.05.24.09.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 09:04:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ji/F2CZo";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=udHsjQBKP68t9TZ4H27l2j3R7dmm1NcGJYaKWehd8PE=; b=Ji/F2CZobt5eaIwXFU270PPtZ
	lWbro9qD58JzH3u5iSrGABrhavNQGlQG9qOowF/I85/KPNwLZ/LLPJ3k03wbqOSNrdWu7Vcl8p4KU
	bUFsA2uPdJWh2n12f6c/VJBEQA2R1g88Oc8wLksp4s/GZSbW6SV1861BU2uUfdKtbl1HxRwp8L6yb
	SFtMKbaNlRT/dD+kfvCgm+8cbrjk3onqOCJChb5H0SKJuXWv8jpQrNEtNSZGLej37oK//Zql4ElqN
	XfEldQJv31OFhsagwQYQolonLFHt5VjX4CxLIAY99YW1Ib0FJB/8j9g29HrB6scmWY36BOpf2/h1Q
	4/QI6Oc/w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUCg6-0000DK-3y; Fri, 24 May 2019 16:04:18 +0000
Date: Fri, 24 May 2019 09:04:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190524160417.GB1075@bombadil.infradead.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524153148.18481-1-hannes@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 11:31:48AM -0400, Johannes Weiner wrote:
> diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> index 0e01e6129145..cbbf76e4c973 100644
> --- a/include/linux/xarray.h
> +++ b/include/linux/xarray.h
> @@ -292,6 +292,7 @@ struct xarray {
>  	spinlock_t	xa_lock;
>  /* private: The rest of the data structure is not to be used directly. */
>  	gfp_t		xa_flags;
> +	gfp_t		xa_gfp;
>  	void __rcu *	xa_head;
>  };

No.  I'm willing to go for a xa_flag which says to use __GFP_ACCOUNT, but
you can't add another element to the struct xarray.

We haven't even finished the discussion from yesterday.  I'm going to
go back to that thread and keep discussing there.

