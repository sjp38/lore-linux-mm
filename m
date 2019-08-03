Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1598DC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 21:36:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3ACC2073D
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 21:36:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3ACC2073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166F16B0003; Sat,  3 Aug 2019 17:36:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 118376B0005; Sat,  3 Aug 2019 17:36:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005F26B0006; Sat,  3 Aug 2019 17:36:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D37FE6B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 17:36:20 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so71529298qtu.12
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 14:36:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=EkifmyHxwnsPs8regEBTA5tK93nCtmZrIpRMe8ScOn4=;
        b=f3ByO5wV7eQSViqzVgks87nMU36D1XS8roTIuSJW8qkg4vn0BefkWZKXHMp/Y6b3Rs
         C5/T8mshPv5sWmmDhiQhsWEW8WwOvSii8xqw1qcF80C5dPo/zFDeiedKFMtrCFGmRVHI
         uP70x9tsIRfS0llKtmNmPuttofZO0uN2Zj1AW7qAQSfPRJXhpvm6kkCovk5vC8RoCw+W
         3PGnF7n5b30G+jZ7PRVdc2AjDupsUgS+i6E6+EhdRixJDWB0CYsaBlIw9D/L7EjAwbdG
         XxRr1CIpSzqxzOlAIeld5l4pxRa/EHo/c0GhUL6KmY8AldGvxVatWltJMPDpw/6N6vPE
         Wpjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXy+Zds7Ew52dfQnxXFfhdrsyL6VyCXCGWxE1caoTds5lWZowSd
	Xtk+UjCB96hQkUHJi8tFFu38dfx6e1XOry/+BLiYoNT+ZNW6QnqW5F/HyHmS6RUjCRKTLEVJmfy
	qLe9hOBHtXAFAuVQ7ZChHS/Il3xzS2pJQTdds3uxIBivLH6A1lk62jkuNxoeDvy/9Iw==
X-Received: by 2002:aed:3987:: with SMTP id m7mr96852717qte.56.1564868180635;
        Sat, 03 Aug 2019 14:36:20 -0700 (PDT)
X-Received: by 2002:aed:3987:: with SMTP id m7mr96852677qte.56.1564868179791;
        Sat, 03 Aug 2019 14:36:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564868179; cv=none;
        d=google.com; s=arc-20160816;
        b=lwVZJD/+dXi0eqzGWJXsBHSlTgxu3DZVtjZ+og7LGqgzAwXfYLr8sM7K8JQ9ePyety
         DIJSlUtmShz45b6EgXckC5Gc8JodwqJ0J2ZBO6c+VQhyfEiUcBJ/a16mv75lkax6KsbD
         lht5TQQw1yT4GTQqLVSchAS1DTzf5Ckar9WfNz4xh3nGy1tjfYSrPX/1hS4ihR+yd1Wh
         lG/mCYa8FrY1fAa8kH7niXdR3+kznfgH23aX1zAex0Pla5bpNxLi93HPVEdlVp2IWlZr
         brPWpl8em+naOmf2ERqhJ/uoXS376k9xkMbl53DhNd/6jqUu1gZEW7pB8mx8HaFJox/1
         Cdvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=EkifmyHxwnsPs8regEBTA5tK93nCtmZrIpRMe8ScOn4=;
        b=bW7x1Yj4qh5DqSiexJscHmAqXyZ2WvXapcLZJlx+z12rW9SBj21yb4K5cnvt6et9nJ
         aTEKelEQHHH9W+wHBvnfX9/L7ooSW9TbdwfPb49bZt3KZDrk4XiBD96n5i7A8OKt+6dj
         OvhQw1+55WN2zDEbWOKCGNZkF7rOsidhM0J4Zo5Q/PlpQytLj6SfFNCO2YIVdiHLJXa6
         JadWfc+vbMjwfbtoP75pZOZLQFlqtVf1ri4e4/a8p312GqNVbb1F7ji9y5CAvzrMXv5k
         Ky2IxBmNFxGjhPRCrHlA6PrAwXOjsd6RgkACTSqr0uD8/QQ72rSGPnddHuRszi1vePZE
         D9fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u33sor103516027qtj.25.2019.08.03.14.36.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 14:36:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyFdgNs0jCQVpmdi8dR64CNPy6wD73snHAaLEfC40B+RZ0ZopacAYTEXjRinq1ReEeoFWNEuA==
X-Received: by 2002:ac8:32ec:: with SMTP id a41mr103176717qtb.375.1564868179417;
        Sat, 03 Aug 2019 14:36:19 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id g3sm33648801qke.105.2019.08.03.14.36.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 14:36:18 -0700 (PDT)
Date: Sat, 3 Aug 2019 17:36:13 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190803172944-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802172418.GB11245@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 02:24:18PM -0300, Jason Gunthorpe wrote:
> On Fri, Aug 02, 2019 at 10:27:21AM -0400, Michael S. Tsirkin wrote:
> > On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > > synchronize_rcu.
> > > > 
> > > > 
> > > > I start with synchronize_rcu() but both you and Michael raise some
> > > > concern.
> > > 
> > > I've also idly wondered if calling synchronize_rcu() under the various
> > > mm locks is a deadlock situation.
> > > 
> > > > Then I try spinlock and mutex:
> > > > 
> > > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > > improvement.
> > > 
> > > I think the topic here is correctness not performance improvement
> > 
> > The topic is whether we should revert
> > commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
> > 
> > or keep it in. The only reason to keep it is performance.
> 
> Yikes, I'm not sure you can ever win against copy_from_user using
> mmu_notifiers?

Ever since copy_from_user started playing with flags (for SMAP) and
added speculation barriers there's a chance we can win by accessing
memory through the kernel address.


Another reason would be to access it from e.g. softirq
context. copy_from_user will only work if the
correct mmu is active.


> The synchronization requirements are likely always
> more expensive unless large and scattered copies are being done..
> 
> The rcu is about the only simple approach that could be less
> expensive, and that gets back to the question if you can block an
> invalidate_start_range in synchronize_rcu or not..
> 
> So, frankly, I'd revert it until someone could prove the rcu solution is
> OK..

I have it all disabled at compile time, so reverting isn't urgent
anymore. I'll wait a couple more days to decide what's cleanest.

> BTW, how do you get copy_from_user to work outside a syscall?

By switching to the correct mm.

> 
> Also, why can't this just permanently GUP the pages? In fact, where
> does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> but does not add a put_page??
> 
> Jason

