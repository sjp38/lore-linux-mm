Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0E78C31E40
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 00:14:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FA762087C
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 00:14:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lAi4L6Z1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FA762087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADB8D6B0003; Sat,  3 Aug 2019 20:14:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8BCC6B0005; Sat,  3 Aug 2019 20:14:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97B696B0006; Sat,  3 Aug 2019 20:14:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 791C26B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 20:14:04 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id z13so68579656qka.15
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 17:14:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WqP5IEn9c1KXpbjHniLk8HqGR3ikHJzys8MEePZlMFc=;
        b=YeEQAaZN/V841Ppy4q95Idpf4y1NPJwWDawt3GHL7g5qi7U7srveTpj0Rkz98NJImJ
         NK6bbP9PzC+za3miUZP7YUKuoCyXOJmLJ6783ReTEmSDPq4VTW0cTENHWyLuv20xDRvh
         MSMrIa5Y2lDh3HUkInAaF6gkmWmw+mf8xIuWmwoIZn3TEjg4gLHksatXQF7yu8FNiwIM
         cjyIOYn9CDQUW+fEp7ahLvx0Nctgy3HS8PH3sxT0WLNU/oBC+9CrOEexGHkfnZMBreX0
         yFlFPD4MD87bs8XfIsD2CPNQFAn6Q+8EgKeAvw5UWz2FNuU6vAXyX1WsBP77fYzkqqrz
         FIoA==
X-Gm-Message-State: APjAAAW1fg6WXK5ckdGrUHvnC6G8MQSrQ6sBWlxOkRbykTltFAcsnEbG
	dOxAXuwlOBI2wK9bZtMqSw4Ms2ZmX2GcqX3ICSbytd6PDe7j6WWXeOrGULNIb4QGQHs1hQaek5G
	goULfqOvmM4aRHWP6EyBa/CQLvYvU3xPIPyyylyQJWM1jjlFf6nrKC0afCUci2lLCvA==
X-Received: by 2002:a0c:f5cc:: with SMTP id q12mr52243180qvm.79.1564877644215;
        Sat, 03 Aug 2019 17:14:04 -0700 (PDT)
X-Received: by 2002:a0c:f5cc:: with SMTP id q12mr52243160qvm.79.1564877643552;
        Sat, 03 Aug 2019 17:14:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564877643; cv=none;
        d=google.com; s=arc-20160816;
        b=R9xGWozIH9B2PjQT3+0+gHOAOHYlY0PYMR6DBLUZzqEl5bHoQrOtj2LtKQLvgxHLAl
         1Ol6PdvwnTEqkEsNFL0GwDZjHfHP8BLEJb/Z7q1Y4llOgZzVykekZDUXTHMifj+Avjzo
         T+gFTb5zXSUJZztFgs9VVuSTDoTTgr2egilRcVM+ZcAcEBjql8R6UKQ23vQpTnzgrROP
         QzIj45dBn0MuIZuI3bWr9KHuTgwd17zw2QDqXILDvKFV0/+HZ0J8bQ7dg04qJOPd+GDg
         E89o8swBPlHyiYEygRjwh0Wy7JlJYuqXluvCcalCPkv8SlLYQSMT2ZwR6IRLf0Eklzyt
         3JGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WqP5IEn9c1KXpbjHniLk8HqGR3ikHJzys8MEePZlMFc=;
        b=fXMUta+5dP5ay3aP3Qf8iw7F9cx+Usg4zVICSp+jIjj2/2pktojO/DKNpcakqaA8IX
         BUz0RHlZAC9vjGqz5cX+8n9M/VVEteQZAUrCBMAK6dN90dm9W6oKEgBrzTWjz+XkBtc6
         Z+ti0yNoTfMgjaawGFEDOphtAFOalZk1Lhj9R1cgEwBitnWdjxEaspWgBdVkeKl3Xfl+
         P6CfcwnpqWaYKg8tk01dkMC8PZm9Aq7+M0ixbj3xS0dfiPKEUCjSQVL2gW9gl+TQ+UnZ
         3HuvuA+aDkkvAzMpcT4oJL+D4r34mfIwe3ltyTtYnV9NeDUOAB0Yty6PdGMnDyusiP08
         PGOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lAi4L6Z1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g32sor66086342qve.20.2019.08.03.17.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 17:14:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lAi4L6Z1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WqP5IEn9c1KXpbjHniLk8HqGR3ikHJzys8MEePZlMFc=;
        b=lAi4L6Z1XyIiSM5lL1y3xq2yW7AhMhA5cc/2JWhK4Uq58oYTXRY+SEfOyGjKf6kkCb
         EPC9/wo5tKQKNgcCq7J5u94OLKKBkYAT9e7xtRKka5BNmKvZWgWXct5IFZiXhtUBed8m
         rk3hbmVvbY+x2rSZElIcRMSuJak9sbEMLouEsX5kctrioFW3dP5ZTCHUO7a88gwJF86c
         Kw4vjibh/yQ70e+pFUaKMHvh1MOZwG0UveYwUOrZxaDK9+spjQNaOE305bhzgGLhXZaG
         1qCnoPNDxKWD7uKl46B5GsKjuaJdx75qFBHdD8Xa8h8Svul5AL5C3uyvDl1nKlcQKCkP
         pPcQ==
X-Google-Smtp-Source: APXvYqzsyyLWq0jXkEok0bUf3FHiInYAhbn8RrkmZKAfLQFhGrLDITCXgW1cHLxjIP+uPvSHKyq3TA==
X-Received: by 2002:a05:6214:1312:: with SMTP id a18mr103640128qvv.241.1564877642991;
        Sat, 03 Aug 2019 17:14:02 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g35sm42675590qtg.92.2019.08.03.17.14.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 03 Aug 2019 17:14:01 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hu49w-0006gS-Bm; Sat, 03 Aug 2019 21:14:00 -0300
Date: Sat, 3 Aug 2019 21:14:00 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190804001400.GA25543@ziepe.ca>
References: <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190803172944-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 03, 2019 at 05:36:13PM -0400, Michael S. Tsirkin wrote:
> On Fri, Aug 02, 2019 at 02:24:18PM -0300, Jason Gunthorpe wrote:
> > On Fri, Aug 02, 2019 at 10:27:21AM -0400, Michael S. Tsirkin wrote:
> > > On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > > > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > > > synchronize_rcu.
> > > > > 
> > > > > 
> > > > > I start with synchronize_rcu() but both you and Michael raise some
> > > > > concern.
> > > > 
> > > > I've also idly wondered if calling synchronize_rcu() under the various
> > > > mm locks is a deadlock situation.
> > > > 
> > > > > Then I try spinlock and mutex:
> > > > > 
> > > > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > > > improvement.
> > > > 
> > > > I think the topic here is correctness not performance improvement
> > > 
> > > The topic is whether we should revert
> > > commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
> > > 
> > > or keep it in. The only reason to keep it is performance.
> > 
> > Yikes, I'm not sure you can ever win against copy_from_user using
> > mmu_notifiers?
> 
> Ever since copy_from_user started playing with flags (for SMAP) and
> added speculation barriers there's a chance we can win by accessing
> memory through the kernel address.

You think copy_to_user will be more expensive than the minimum two
atomics required to synchronize with another thread?

> > Also, why can't this just permanently GUP the pages? In fact, where
> > does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> > but does not add a put_page??

You didn't answer this.. Why not just use GUP?

Jason

