Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EB70C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED4E926E2B
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SXC/obm2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED4E926E2B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5463F6B0272; Fri, 31 May 2019 15:04:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F6956B0274; Fri, 31 May 2019 15:04:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40CAD6B0278; Fri, 31 May 2019 15:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE5F6B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 15:04:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v62so750992pgb.0
        for <linux-mm@kvack.org>; Fri, 31 May 2019 12:04:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NWnciIQmcX/RIrj96k1+DBuHYUzEX7IuVbdRGUQXjfg=;
        b=VLu8K/k0uZ02iARfyIwDWqHtxkccnt8qPslEEKNZJ0nuWMPmDkJVjGktTLHW50nuGg
         G3wW1sGL+g9DvWxUOa2on0ieiIeVGV40KRBpjLyQvvVGZHopvDPNvLJXvNcATDdOmS+s
         vT3E28RWHuU8qns0T5/GoK9pdhltiwfKRhmcnOXoIP4HDzs41Cyq/H17uT+lqNpqfDLt
         ybiuwQF8RcWMw6gmpjhpPRLgZCkxGkIVWoDS+pw+zhqaPLt5L0W8kMxQtbszrs8+2LPI
         pZvQjbqClV1HBrhFT8ZBUzZ4K0YE/6TU8REWm9kB7KuRSIjAfMWAgidviqsGTQHcwS9r
         zyNg==
X-Gm-Message-State: APjAAAU3wYnBW0xY0HCdflgpO9SREwrFFlzAW3/n6RSWtbYX+tyN+BJm
	Wrz6fXQetW0ij9updVSLu+3e1ZXQB35qqfEmUQV0ffuq9kE5F8xqcQ7HBwpeHdXobd+xwiNnBDY
	jmPXsz4p+FP48Ucl2GbEjxwbYstDPo071C3Zcwmr2zQpU+MIf6AYHx9F91vJFrTkIxQ==
X-Received: by 2002:a63:246:: with SMTP id 67mr11267556pgc.145.1559329473584;
        Fri, 31 May 2019 12:04:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiTJESxUyz5EvKZjvS+toi5CdHbo9VKJ4e9+CYCR0CMISZBzHfKiRs7gmhX+1dlhSiTpT0
X-Received: by 2002:a63:246:: with SMTP id 67mr11267484pgc.145.1559329472441;
        Fri, 31 May 2019 12:04:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559329472; cv=none;
        d=google.com; s=arc-20160816;
        b=eEvW44lbmOc53AupkdwT6rJZ9aZbMAkMxeb3ucYKsdae5pt36F/UQJCiQJVc/cAMsW
         rUK27uwV2xgTpkQiFPbvA8oQxKFWSXOAkH8WoPWArvZErcXDb1tI+9iNrnPpOgz8J1VO
         ZHQk28C+rZUhnyzPEOXf2n7pf8yCz9gPKwOU5BeND5t83fvjCl0SEcBrgjaj2ErS/duw
         WX6auiABKSkfjsgD7EdMkOMUYIPS/jFXtigJ0yBeboN9WEGU1FUPSOMzi5u4c2ZQSye1
         6bue2pNpDDLVlDsaScOi7jFZacr8tfHLrcQVbSQ3puKbZ+HMVc9OK6VO1DNwZpBzdMR1
         JI4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NWnciIQmcX/RIrj96k1+DBuHYUzEX7IuVbdRGUQXjfg=;
        b=AjvkMRiO7mC+tYMT4R9ZcCAGe8wW96YUnye5J/uFuUNlEoz5dlFQ+ICXNsMGb++cur
         VpZ0mK/RBYzL8iPIOZnVaD3k1Xe1OF+uZfx26T6+GV+C2sbN5v1XX0aT28WSTfhsceHV
         GWqdq8Qlz3KRx859rYMJy6XCWDZWAhN0mw2dNdn0s/p22yaLXuBmkmLQffnMpfNJECMm
         TT7viNSW3ysskaIkBC5tjw2WA/ZIzCLopkkhtB+CdSNZa7kg2NXKsq96GQJF3DAmvOWM
         qPaQzQvrcsFiD+qLwwP1gWSucNLjwAag8gmwMMuVT/Vp8TZ+LzpMwtkZ/28jqZHaJR1c
         84cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SXC/obm2";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h40si7395126plb.243.2019.05.31.12.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 May 2019 12:04:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SXC/obm2";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NWnciIQmcX/RIrj96k1+DBuHYUzEX7IuVbdRGUQXjfg=; b=SXC/obm2/ef8YkQPySFL09sMX
	irbJrFjXVmZ0KrDh//8KnUnmAxU0FjSyTaFg4sdSuRHman2YPJfNwt6Jzmi4+sHe6nhvndSA1Zswh
	XTXKKJyHhR1ykC08tsX1P8WJ97us9YcyCe/g9lcJrCsmh2UB9LT3DE+e85iQwrR4cildxwhFXUstU
	0p0nbHAB+stAhu1qCen+InGMz69ZeV5S8HyapHYBYRd8YYdJHxpSJxJQJfW8tu7NzMtpowEKSZj04
	rgZ/NtNfYGNKMpSTZOeJzDp6omm/Wl7P6+2aBVFoXky21NZa07tYdsB77k0NAGmA9AmULl6vejkC+
	mRTlZ6OjQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWmpL-00069r-O9; Fri, 31 May 2019 19:04:31 +0000
Date: Fri, 31 May 2019 12:04:31 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190531190431.GA15496@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
 <20190227122451.GJ11592@bombadil.infradead.org>
 <20190227165538.GD27119@quack2.suse.cz>
 <20190228225317.GM11592@bombadil.infradead.org>
 <20190314111012.GG16658@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314111012.GG16658@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 12:10:12PM +0100, Jan Kara wrote:
> On Thu 28-02-19 14:53:17, Matthew Wilcox wrote:
> > Here's what I'm currently looking at.  xas_store() becomes a wrapper
> > around xas_replace() and xas_replace() avoids the xas_init_marks() and
> > xas_load() calls:
> 
> This looks reasonable to me. Do you have some official series I could test
> or where do we stand?

Hi Jan,

Sorry for the delay; I've put this into the xarray tree:

http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray

I'm planning to ask Linus to pull it in about a week.

