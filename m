Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA2C0C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:40:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CC682086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:40:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CC682086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFBCB6B0003; Mon,  5 Aug 2019 02:40:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C857B6B0005; Mon,  5 Aug 2019 02:40:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C956B0006; Mon,  5 Aug 2019 02:40:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF1D6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 02:40:31 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x1so71584694qkn.6
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 23:40:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=TJherR/Px/4Fbrw9YV+u4NRMIhgPOAQEPfJAeZ4Vfls=;
        b=mhBylAWepspdMlwVyrBkfG8jsVZ6lnGbzEC+vB+H6ApDMtSJB7J4MSvjD8lkOq3jpt
         pAsZXlTkVRrVuG4AO5O6zQSE1oLEe70F9enUbXgC53+anKWerSs9nZYsTXZYKzkeEPoe
         rWSvywqyjKGKUixVlifs/zR5SH58tb364CRrTU0adt2aXXSRX6MY2l7sdNf91z+sGCE6
         MGyxVxo6wnKLO28YrhdHJ7lQbBcaAjJSA3Ds4zxm7Muxqyxo7gNPGeVORsIPFgHFIyNU
         l/Ad3H+OundtMlrbhgorrCdS18rZToaV+s+LuRtQ/1cXTbWgF2d4/HpSO4BT5t18icgv
         jxFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVLd94zTetReWM6W1tfG898lUIqHo2t3r+nrGaBmEDibE4gbMJh
	65NEN15LEo049Rw7OY/PnY1670VW1EsVeZLFcAH3aFZNhkn6PP2fZQnclimmy7rfz9SKWeHdgVu
	CpnVLsoTdu5tXWh3C++im4FZdsgTDBKLytwX7vcV7AvXn6iPYGdisqRQ+DyMpE6Z8Zw==
X-Received: by 2002:a05:620a:16a6:: with SMTP id s6mr16117378qkj.39.1564987231319;
        Sun, 04 Aug 2019 23:40:31 -0700 (PDT)
X-Received: by 2002:a05:620a:16a6:: with SMTP id s6mr16117354qkj.39.1564987230615;
        Sun, 04 Aug 2019 23:40:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564987230; cv=none;
        d=google.com; s=arc-20160816;
        b=U65/oP7PCYf7713mvaVeMB0B+IucV8CZPqTCkN4+jlHZKELJ99WMdFljGPsNuTsSao
         CGHyfFO/w3thyGmDZjYjSileq6fbJwF57dIHktyZ8jQ4AgarRsPaQdRoGDtOEz8a/Sr1
         qvTOWKLgAivHeJl+++h6kqnygQeUmUUi0Yi6oCxv7XLMgQs0spWGmrlB2YCjXnANIE66
         +H+kXjH65ilTEkKkyRJmRfP5CoudcmlYy65/zmkhVMPRMMSEi707b0V+SofifTWVUTL6
         waLBB7D3P9/+j4zgYgk7D81XSV5btjUyEM9noBtebIV+0Tt7vgM+GEjrICnwcYcwr7kz
         Do8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=TJherR/Px/4Fbrw9YV+u4NRMIhgPOAQEPfJAeZ4Vfls=;
        b=t1D/uApAUfO91KDXV3nBlHQAItpoYN9rFZO+ZnFk/HqO6070ssDPWteyD05yRn6y7r
         hC2j01XpWIQWOQ9E5c3sXqU0Uvs49HuyzeuoZBwhctWfzLIlS0FyuEwj1beHGgeBD73K
         gpsqWXQnkrSOFnqWGRfVQoQnZd9TFe6hIz3OTDSv/hlYTNa0//0+b6sJ2k436FV1/WLR
         VhXouqUArvNmoBpV+o+xB5lHPcliRM/e7QwwqrMcDOU8Wg1/uEUjZ+5vjoe+9zuIrDK3
         kyZg0Lhc9j84OGegw78xPPHP/oxlGzGelOjF2mKiMUzzvieKJt9AnrsolwGJWIEt1x1Q
         R9tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor107131575qto.35.2019.08.04.23.40.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 23:40:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqySQxd6FG3GHb6mKg/OD+gospqbuIs1GOIQkfQIZWqsFx5h/wKXKUUrJ/WUSB3S9we9808RDA==
X-Received: by 2002:aed:2dc7:: with SMTP id i65mr87212492qtd.365.1564987230384;
        Sun, 04 Aug 2019 23:40:30 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id 6sm38704287qkp.82.2019.08.04.23.40.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 23:40:29 -0700 (PDT)
Date: Mon, 5 Aug 2019 02:40:24 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190805023106-mutt-send-email-mst@kernel.org>
References: <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
 <494ac30d-b750-52c8-b927-16cd4b9414c4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <494ac30d-b750-52c8-b927-16cd4b9414c4@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 12:41:45PM +0800, Jason Wang wrote:
> 
> On 2019/8/5 下午12:36, Jason Wang wrote:
> > 
> > On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
> > > On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > > > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > > > synchronize_rcu.
> > > > > 
> > > > > I start with synchronize_rcu() but both you and Michael raise some
> > > > > concern.
> > > > I've also idly wondered if calling synchronize_rcu() under the various
> > > > mm locks is a deadlock situation.
> > > > 
> > > > > Then I try spinlock and mutex:
> > > > > 
> > > > > 1) spinlock: add lots of overhead on datapath, this leads 0
> > > > > performance
> > > > > improvement.
> > > > I think the topic here is correctness not performance improvement
> > > The topic is whether we should revert
> > > commit 7f466032dc9 ("vhost: access vq metadata through kernel
> > > virtual address")
> > > 
> > > or keep it in. The only reason to keep it is performance.
> > 
> > 
> > Maybe it's time to introduce the config option?
> 
> 
> Or does it make sense if I post a V3 with:
> 
> - introduce config option and disable the optimization by default
> 
> - switch from synchronize_rcu() to vhost_flush_work(), but the rest are the
> same
> 
> This can give us some breath to decide which way should go for next release?
> 
> Thanks

As is, with preempt enabled?  Nope I don't think blocking an invalidator
on swap IO is ok, so I don't believe this stuff is going into this
release at this point.

So it's more a question of whether it's better to revert and apply a clean
patch on top, or just keep the code around but disabled with an ifdef as is.
I'm open to both options, and would like your opinion on this.

> 
> > 
> > 
> > > 
> > > Now as long as all this code is disabled anyway, we can experiment a
> > > bit.
> > > 
> > > I personally feel we would be best served by having two code paths:
> > > 
> > > - Access to VM memory directly mapped into kernel
> > > - Access to userspace
> > > 
> > > 
> > > Having it all cleanly split will allow a bunch of optimizations, for
> > > example for years now we planned to be able to process an incoming short
> > > packet directly on softirq path, or an outgoing on directly within
> > > eventfd.
> > 
> > 
> > It's not hard consider we've already had our own accssors. But the
> > question is (as asked in another thread), do you want permanent GUP or
> > still use MMU notifiers.
> > 
> > Thanks
> > 
> > _______________________________________________
> > Virtualization mailing list
> > Virtualization@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/virtualization

