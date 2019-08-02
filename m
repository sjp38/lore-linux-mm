Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC92CC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:46:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81F422087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:46:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="MRMA2whm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F422087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E80FE6B0003; Fri,  2 Aug 2019 08:46:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1916B0005; Fri,  2 Aug 2019 08:46:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA8E06B0006; Fri,  2 Aug 2019 08:46:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3FD66B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 08:46:15 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id y19so67879895qtm.0
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 05:46:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6ql0O82ncHZU71SnaUyYlbcaPGtvlWm+BrLQDkFEDbY=;
        b=f95dB7JrP9sZoeXcq9mrfw0+Yb4FwTu7xl+iH67Lj1BwpzzYLH5vmI9soChHOyMLkg
         XaPwNIN++OqPefpdpXbc3JFeTjOKzP7tp2NuERsCQ3fG95P9xajTk23JgcDD8T9nCOmq
         R2I3tabrsZbKwPRpXxJgmV2x2X31/0ff6z1EzTlN2+MvrAF1B/TqeuJqJGcjMmwCPMDS
         R6juL2NyKtz97KGGzLXlSpEbxG6kuwKk/ysmHPZvIcBpt2TbIApDSkJdhto3p/0gjDab
         bD5eAySXbTqknIZmR6suRC/gQV6FVt2HW30DQwUmbQPYt5pG6bsUG5iBfumryfQ6+jY0
         L/kg==
X-Gm-Message-State: APjAAAWwl4kfLFgsYoYTykvp6tSTbRQmxXYNJxBl+VueBbkr5ZL+pXmU
	6B8SmtBan7LutrUNECMHCEEe6g7BrNbcjqUDcLggn/S1VF3r6hhDZKWS/qb+GyCoorsZ+O5Y5Jw
	lpKOpEEJ+5t7avCYbJFuucfXZ/ho7vxEv3ulFjJZ5o1IEuMNNOD/EsazsGSuS2waicw==
X-Received: by 2002:a05:620a:1107:: with SMTP id o7mr42651290qkk.324.1564749975319;
        Fri, 02 Aug 2019 05:46:15 -0700 (PDT)
X-Received: by 2002:a05:620a:1107:: with SMTP id o7mr42651235qkk.324.1564749974676;
        Fri, 02 Aug 2019 05:46:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564749974; cv=none;
        d=google.com; s=arc-20160816;
        b=NdglIPyD1hnRsqI9VSETXBySzsGXFrE7niL+TiNnPv9VSX2wX/ZnBtvmBILEv40H2g
         H+wL2Co6/tuWrogTCcI1W4e5d3jp31KScpiGR3ZebcsYBwsRuNmc6J0K3AN3sxgbp4EZ
         xybbl//ztmtBrJLxZHcSVFyx6UcXaX0LDUQJux9RP7Ekq4fY4Yd6JjkGx/5oIZ/pTdD6
         5NzBog3UTdUkbZ+B5auJFDbtyLb//UJ0J3xijtMWY2iSjoJi24Mk7Nmw3VZ+akHt0TX7
         Z0gvF8nn0xWLrGVgBXyvXWGFZoLno03uISbQQIyW8jlZWQf+2hY9d8K8YE2yVioGpPyi
         rUNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6ql0O82ncHZU71SnaUyYlbcaPGtvlWm+BrLQDkFEDbY=;
        b=DhgojS55BGz+2y7jwKEIuCN0r2XUJfLdp2zJny7565xRPgYDzq0kX2dtbG0wAVjREr
         F7Svcc0atxO93Ub3J+E8RBKSDeSPmooHlOgB9s4/y2oHCiHphSyZRo/brTVnFyq9VVl1
         EdQlhRPVtAXD9YmqBcMgUs3gUyPEESrBZuDyJhfVNnAjliB1x7WmyeevL/tmEEvIA1FV
         upTzqRUpG7JmN95SvAXkAr69m1M6Nzoy8mi5i/nnX4hhhXcVTT67kkVV6yZL/V5qHSxj
         TT8TZw1V+Ujoms8xiLRKdX4M2te/4XUKH1B7nV/c96TXzZWU+0Wq/wNm84A/1HSs0euO
         GMbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MRMA2whm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor40688326qkl.129.2019.08.02.05.46.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 05:46:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MRMA2whm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6ql0O82ncHZU71SnaUyYlbcaPGtvlWm+BrLQDkFEDbY=;
        b=MRMA2whmjpLNxlhbDl5mBbGm/wxr+mnLnwdUEiOzNBsQbTy974xui1zcbJXuaVeMgi
         +e6pAPXNKqJ5FLrB5btG3fWEwJOZCNVqx7WhXgNhnlz2EhhnCC/jrtDsn55I0rQrPbEs
         kTXxKo2YuV2bT1/e1Z1A6Wf8qvRURa8Gr3WBc9QO7dijfCQypZgeANqmpaiWdSJoUCtu
         VXKmwcx2rj/qqL+7cWXldCjZ59ch1b87c5iVVd4Ql5AT2hWXZoJ7MKekKjw5eD86xgli
         DTGd7yg7MsSW0a1wLwfpAvBC9sgR49+QmZEGlFoYAgcWlKpxKOv19D6RuAJw4q09e1/M
         Xu1Q==
X-Google-Smtp-Source: APXvYqxtz2vM6y/fN8WSSWPve6vWs8cD8+KUQAMGJTQIxCltGAZYGzTtsZ3uymeGSjZYIgEaLwJYTg==
X-Received: by 2002:a37:bc03:: with SMTP id m3mr89369627qkf.199.1564749974287;
        Fri, 02 Aug 2019 05:46:14 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l19sm41561137qtb.6.2019.08.02.05.46.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Aug 2019 05:46:13 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1htWwn-0003D2-5A; Fri, 02 Aug 2019 09:46:13 -0300
Date: Fri, 2 Aug 2019 09:46:13 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190802124613.GA11245@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > This must be a proper barrier, like a spinlock, mutex, or
> > synchronize_rcu.
> 
> 
> I start with synchronize_rcu() but both you and Michael raise some
> concern.

I've also idly wondered if calling synchronize_rcu() under the various
mm locks is a deadlock situation.

> Then I try spinlock and mutex:
> 
> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> improvement.

I think the topic here is correctness not performance improvement

> 2) SRCU: full memory barrier requires on srcu_read_lock(), which still leads
> little performance improvement
 
> 3) mutex: a possible issue is need to wait for the page to be swapped in (is
> this unacceptable ?), another issue is that we need hold vq lock during
> range overlap check.

I have a feeling that mmu notififers cannot safely become dependent on
progress of swap without causing deadlock. You probably should avoid
this.

> > And, again, you can't re-invent a spinlock with open coding and get
> > something better.
> 
> So the question is if waiting for swap is considered to be unsuitable for
> MMU notifiers. If not, it would simplify codes. If not, we still need to
> figure out a possible solution.
> 
> Btw, I come up another idea, that is to disable preemption when vhost thread
> need to access the memory. Then register preempt notifier and if vhost
> thread is preempted, we're sure no one will access the memory and can do the
> cleanup.

I think you should use the spinlock so at least the code is obviously
functionally correct and worry about designing some properly justified
performance change after.

Jason

