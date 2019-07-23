Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 318FFC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:02:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C246221738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:02:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ovAbxfUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C246221738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2657E6B0005; Tue, 23 Jul 2019 12:02:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215936B0006; Tue, 23 Jul 2019 12:02:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12C988E0002; Tue, 23 Jul 2019 12:02:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D20116B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:02:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d190so26431283pfa.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:02:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I+4AWJfYixrAYAfDAYQ7YdaozuxSb83KaZ2pWoAh6p0=;
        b=ZT51jj6/9k5c5QDj/hzB7EjVh6D0EeXabQyJla2ol7OcOvG9LkLLYZ8/cYpnMTu9/f
         vmWUhe2TKGjrsmo1GNrR82CBEX0GTmnHyRc0H1eQVp/H0XwCPEZOsdv/XtDIOZngU3xm
         vajZuwYi57pmp/80YI0CYtweP/FWJF+jLsb2mYOkMRYGRliuUarUiF6mYPDQvv0dFXr2
         8wLr8tg0j4j00GFqGi+CTpU6QUdkKhp7Pg4oXN7OWI/9Ga6O0MFBsQm5sFImdh/8YPAR
         C3K8aJJzZ5YqNheamCPeYHKXB1wIxVCgpOvHUPwwytXSGNzLb8XTqOlltZ9djk0d73jy
         uU1w==
X-Gm-Message-State: APjAAAWX+YESD+qafHIrzHIi7sJldDICPsdPLkIIk4yLddzG28czNWtv
	w4lyQZCc7wWDp/pOVxjfbFyMnKsm4mpq2KZ5wvLddSHsOD5XQFf4ZecqjsqoXxgi1dmJoRLhneC
	rljW4NV9mYkls/p8QFb40OqxhJrtCAt8KlgIWsPDkroNbiwNB5IdX7dY0NhHBJ1LdzA==
X-Received: by 2002:a17:90a:6546:: with SMTP id f6mr36979951pjs.11.1563897771284;
        Tue, 23 Jul 2019 09:02:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/GzEh7cZJab9DE08SN+JCG0kn3KCvW/eJkBak7OonzjCP06P831i2ImNfJuPkzqIHPb4X
X-Received: by 2002:a17:90a:6546:: with SMTP id f6mr36979839pjs.11.1563897770055;
        Tue, 23 Jul 2019 09:02:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563897770; cv=none;
        d=google.com; s=arc-20160816;
        b=keEdMVQ/mZAztDt9M/zXA8Io2DuEWSPexc7LbHYHH/H49r3Q3fJmGK2Tk2vsdlTEJi
         2zba33VT8B/fu9XojX7k+ueyBnWDs5AVQlM2nA8UgT+8JNBvGTf2gP0XbTWWgf/YoZW1
         vqlL5+D0c+7om5Cgb+Hh7XQIcNkpBSx4KXAnkn3LLrq0mGH5+EAAKcBExNKBm6pqhK6D
         AvXIJROe3Z2odOg5j8vbp9HPOfi90UCmzZcz+XQGOsQ698IKhpsHOmoqHuh++OEYco/I
         WYHOXsgSMvGMsAL/nmeQZKSHXf7Koqs6NT/qND3KBljSz1HPvsjDddimdkAyXhc3WWu4
         cl8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I+4AWJfYixrAYAfDAYQ7YdaozuxSb83KaZ2pWoAh6p0=;
        b=iyqPh+ELKhBMOlyXIsV3pBVPGdE2YO26mhaocD298Ql9p+4kfoR6qoV51W6QmwndZp
         1477vNsSFI/dn1c8y350pIqt1m/+0AiAw3a5YCBEwRk0lOFKU7wKh7TRaItJeebqd7lw
         Bczv3aq4BFpAGP0ub9tOdDhWxIRy/wQ1wTasOBCBvBd5bnV+/QUSYIXQ5pMEryldy95R
         heh13zpcMG0UWqBHq2x2MwYNaGmYBTUX5xT2Qg70QLICC3I5lKAJonRq6/xssE/7QBy+
         mscZeV3S0hYtHWantDUyvNRUa9C2yDjsS4x3iBotELTRqrR+lAD8d+No5Bmwb788VbQM
         y8ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ovAbxfUA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q23si11587453pff.103.2019.07.23.09.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 09:02:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ovAbxfUA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=I+4AWJfYixrAYAfDAYQ7YdaozuxSb83KaZ2pWoAh6p0=; b=ovAbxfUARIjlcZ/yDUszdNyUS
	k6DImR4clx4Nf4+GGZINvWXJ0yGqy5uq5Dg6cRpcJlCx7HOq5dOH+AqZJA/yjf/f9nNYih/YiirTL
	lEOYrW0wh+0Q2o3Tkb7Or8GWD7j7hhVUFHMFdU5IUWhs0MoV4Kq063FnmqlWHtij+ixK/7/qudcA2
	gfUGSk+Js1dqMY74dNrO2d2wak8DJIhR1iOv1zYjqi6YOtdLT9XTW15ugDA+xXcwG5YhSOsPYcArg
	4lRvwdLU3jZUESgt8gAB0Xu1A03V/ejYz0cIwdljrQtK86YaUacolwLdYt08MslRd+d5IUAdHcw99
	PSLqbjEHA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpxFY-0003pm-LB; Tue, 23 Jul 2019 16:02:48 +0000
Date: Tue, 23 Jul 2019 09:02:48 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Atul Gupta <atul.gupta@chelsio.com>, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723160248.GK363@bombadil.infradead.org>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
 <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 05:43:07PM -0700, Ira Weiny wrote:
> > diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
> > index 551bca6fef24..925be5942895 100644
> > --- a/drivers/crypto/chelsio/chtls/chtls_io.c
> > +++ b/drivers/crypto/chelsio/chtls/chtls_io.c
> > @@ -1078,7 +1078,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >  			bool merge;
> >  
> >  			if (page)
> > -				pg_size <<= compound_order(page);
> > +				pg_size = page_size(page);
> >  			if (off < pg_size &&
> >  			    skb_can_coalesce(skb, i, page, off)) {
> >  				merge = 1;
> > @@ -1105,8 +1105,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >  							   __GFP_NORETRY,
> >  							   order);
> >  					if (page)
> > -						pg_size <<=
> > -							compound_order(page);
> > +						pg_size <<= order;
> 
> Looking at the code I see pg_size should be PAGE_SIZE right before this so why
> not just use the new call and remove the initial assignment?

This driver is really convoluted.  I wasn't certain I wouldn't break it
in some horrid way.  I made larger changes to it originally, then they
touched this part of the driver and I had to rework the patch to apply
on top of their changes.  So I did something more minimal.

This, on top of what's in Andrew's tree, would be my guess, but I don't
have the hardware.

diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
index 925be5942895..d4eb0fcd04c7 100644
--- a/drivers/crypto/chelsio/chtls/chtls_io.c
+++ b/drivers/crypto/chelsio/chtls/chtls_io.c
@@ -1073,7 +1073,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page *page = TCP_PAGE(sk);
-			int pg_size = PAGE_SIZE;
+			unsigned int pg_size = 0;
 			int off = TCP_OFF(sk);
 			bool merge;
 
@@ -1092,7 +1092,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			if (page && off == pg_size) {
 				put_page(page);
 				TCP_PAGE(sk) = page = NULL;
-				pg_size = PAGE_SIZE;
+				pg_size = 0;
 			}
 
 			if (!page) {
@@ -1104,15 +1104,13 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 							   __GFP_NOWARN |
 							   __GFP_NORETRY,
 							   order);
-					if (page)
-						pg_size <<= order;
 				}
 				if (!page) {
 					page = alloc_page(gfp);
-					pg_size = PAGE_SIZE;
 				}
 				if (!page)
 					goto wait_for_memory;
+				pg_size = page_size(page);
 				off = 0;
 			}
 copy:

