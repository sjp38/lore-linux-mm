Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D11EC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27A9D20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Z0mI1c0b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27A9D20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6D346B0005; Tue,  6 Aug 2019 07:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFE6D6B0006; Tue,  6 Aug 2019 07:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A70096B0008; Tue,  6 Aug 2019 07:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81C616B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:53:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v68so1551896qkc.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eo4243fxJunv120eldJ+yINhsaoHQ/b07ic+MhyUnUY=;
        b=oNBpSNnuZ9wx52M0gDaWaTERphpaeawwDOxXo9wJfrJ012ZEPYU31QMtitHThIbKUd
         NpeRRmufREsvbSg7o4z0/6bQdshipN+gYUGWRJx3sKZmF95zmD2NQV43BD8+fhJaNgLy
         cgFnxDC5Cr1zSb86yqmmCQl3IVv//y37yzhQJ2xSaTBugCpu2jrTfnTXsU8/hSl36KPW
         HosdDUn5eD8SrlwvMcEWTIHl49BDBSZgZWwODU4IbV4gUnl4qZbylUXGLwkNCr1uj2gl
         FMBXQRmqmCu21MEpYFhyrIKVWSURgyWs9+g07v/COmG8RXfbWJYfIczRlmBQGdTK4z9V
         QziA==
X-Gm-Message-State: APjAAAXpOX3MIKlX11EkABW+fhHOfIcguryYGUdk3PWBr7/FLUtgKmy5
	D6JvVJktYCoI2f0jeMOVdL6BRXp3hwAwoFnCefbZQQjNXyQ5nLzy8+TequjKIx7peUjVGdKKRi0
	UFaEI0R0tpvoRkBQC/we895Q0AJ/OQziXmzS2RKRlYLWNzQ+6pFV1Me7aMgZyECZQEA==
X-Received: by 2002:ae9:e10e:: with SMTP id g14mr2737416qkm.486.1565092400319;
        Tue, 06 Aug 2019 04:53:20 -0700 (PDT)
X-Received: by 2002:ae9:e10e:: with SMTP id g14mr2737372qkm.486.1565092399706;
        Tue, 06 Aug 2019 04:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565092399; cv=none;
        d=google.com; s=arc-20160816;
        b=BphzVJNduTfsCLUG7o8mp5MDElKndJ8+M4olZrkPCnH4v47D802AVFfogMY+dAM/Ea
         5Qnyh9CAOjsx+mlRm8a6wFsuZo7zYLq1v62I0UiXFwiA+UXWjMbNp0mRKdIYoJxcE/u4
         TKUwmT9dhnlBO28tXji7Ck5RZL+AlU1k/ZDHc7hH79/UAu+5Y/UiIyqb8sqVVgT9cNjn
         6YwUX7upPo35LHewKLPf8tVDuodOOIm4cDCuEF4PvvYcvQoFXCr0h5M5Komje51y407c
         Juc8aP1/Pc0AqWvVV+iOCeoEmixFXC+c4jkSo8LoEuAq6BeJGPPl2PZvHOdFD6TgQXZV
         w/8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eo4243fxJunv120eldJ+yINhsaoHQ/b07ic+MhyUnUY=;
        b=r8CThg80p1tsk73aeM7y+ot6upqw++4wij0mdBS1pb3uw9f0ePVrv4WdYfVOJ1lpG2
         MQOiI9nYqQziTvXsI3LDAh6qH1fMpvjMjJWzFAK2tRhurbxBxkYveEb9JArag1aLCkhd
         5YtOtkvQWB7NFQoMZZc+3G/uL1vMWFkaupMqap21zN7mVJLZjdk3JBd+IIWK1u//BhwW
         cCyuDYQzlpoSUe+7sc/eYVNZwsYD3pWHycZ+zewUu6bsgjx/4Q16SJ4yG2XiMqVYowX8
         quvL8CQ/uEbM+MlFwnh+OR+qMuJTqqeoeaCoXNVjLr5dkX2Jyf+cAzBWd129i5BTbltZ
         AOAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z0mI1c0b;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor49195097qkg.86.2019.08.06.04.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z0mI1c0b;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eo4243fxJunv120eldJ+yINhsaoHQ/b07ic+MhyUnUY=;
        b=Z0mI1c0biLAyuHhq5HIH9liJ9V9NmYB6TCZCXG/MS5n6b7MXngGDqXWAvW9Q3wU70f
         Yuj4Gf5hmNpwIefJdv3jpcVqzwrm17rlQpqCpa8h75KznnlVcHW+bOQ8mi52XzW32i5X
         xMyKUlZMHS1zgPqQftCrIwo83eGAnrddpriXhq4ERkbDt3WwCS0upZb4/WtoahuAO8kW
         rLLLe/brCqzVyuGIKUWxPpcJJrKlwgWXPRE3jAKSeJ2mD0cdUXjpM0rJYi2yNTADYoYQ
         aDzSN7ZZQHTrS2/K7nALIkgZpt7+fyciFkxjLncICC8fqlQT1qsJ9jdY2CtN6k6kVuIQ
         kuUg==
X-Google-Smtp-Source: APXvYqw8Kp97Codo4loFeh85jsMCmVqW5Bh1vzUEuORvgfGzgHvIynQzybQA5mb0rqsqpydwn040qg==
X-Received: by 2002:a05:620a:127c:: with SMTP id b28mr2606352qkl.299.1565092399391;
        Tue, 06 Aug 2019 04:53:19 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r14sm40128814qke.47.2019.08.06.04.53.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 04:53:18 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1huy1l-0003cs-Vr; Tue, 06 Aug 2019 08:53:17 -0300
Date: Tue, 6 Aug 2019 08:53:17 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190806115317.GA11627@ziepe.ca>
References: <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
 <20190804001400.GA25543@ziepe.ca>
 <20190804040034-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804040034-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 04:07:17AM -0400, Michael S. Tsirkin wrote:
> > > > Also, why can't this just permanently GUP the pages? In fact, where
> > > > does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> > > > but does not add a put_page??
> > 
> > You didn't answer this.. Why not just use GUP?
> > 
> > Jason
> 
> Sorry I misunderstood the question. Permanent GUP breaks lots of
> functionality we need such as THP and numa balancing.

Really? It doesn't look like that many pages are involved..

Jason

