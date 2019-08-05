Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D95CDC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A94D120B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A94D120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 477CB6B0003; Mon,  5 Aug 2019 02:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 401926B0005; Mon,  5 Aug 2019 02:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C8496B0006; Mon,  5 Aug 2019 02:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 072CA6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 02:30:41 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so74898177qtp.1
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 23:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=PVqIsmchklCTrdzugsyQL+AeUL8kmqaAFQiz9HKaITE=;
        b=PAqpoHBPjFF1w7O9dQkB7UxVR7EOnupYnOiqdbHN7UTMrNZzp+Cni/ayWAjTNiXzeh
         DgJF/pxTOl+VseDhWv1HU4XLPcVcYygwKWt5DpVRiwSbJYTahimshYZNB2JGovC7lSX1
         XTFj2R9fz/9noe0lONQhc3kCaKuKZmt8e1eUhJ5H0dX5ftOjrl+pgqeHwzcYvvdtkS+n
         M2EweGIHxgahsdyWyUc06sGjx6CFigrgC9KLajbHt/eTC1dNEGRGeGLApizlPkG8TVto
         EJCFiZTBghzsgWev8uXruYwx0D620BWV4k2wl3AImHNmTZG/N0rxCyqPTbAIefWhOHvt
         xO4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/K7eRX4w2ykp5RzukvbS+3LRZk5Ye+yYIJ0IkFbiwJGvbH+gi
	xjxEkCwVIS+On1ZMOuBS61HlzJXX7XCHay4bT8YO03dQ7l44YkkLfC2zIdEaqNk0zaUTM8//lap
	qpXs5e6jGWEljYSlS0WEpzjVDaMPN2mcew8b7buRVxWBSLSDmDsn6VhNnNy1excJogA==
X-Received: by 2002:a05:620a:16b2:: with SMTP id s18mr97928739qkj.323.1564986640818;
        Sun, 04 Aug 2019 23:30:40 -0700 (PDT)
X-Received: by 2002:a05:620a:16b2:: with SMTP id s18mr97928705qkj.323.1564986640271;
        Sun, 04 Aug 2019 23:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564986640; cv=none;
        d=google.com; s=arc-20160816;
        b=nihtOeR6cUCd6t3ONz72MoJ0myP1pLXQWrhLEdHrPCiNof7H+HWgOGZ8hLld0y+1RQ
         Vv6vmStpyZR3SNn2Kpuro6CVow8nGZlSm68BnPio4yo8VHqzrHXZV010CLr7Ke9OcmLN
         C1thiAWr69AHqU7r1hjCDeTX1CDHEyq2h8/F9KUqYK4rulwjdUZVab0ICBO4JQ2vYyTD
         j8xlaXfgHXS2JfsXQ8/jF1n4d+TxzClj4j/QRZqJy1ZjqeKps9pVu418/1WfqcF2XASV
         p+ypOxnW1FU+SvKVrhkO4lLP+c6w6A8ZfI2sElfgBNW8Aodg4G/rdk0OS5R7w6bToYNC
         zGkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=PVqIsmchklCTrdzugsyQL+AeUL8kmqaAFQiz9HKaITE=;
        b=dvJ+uWpdvl95vHyA29U2mbaEouYdYI9wDlfdsAyuGoTsv/f670YeLv1g3opuW2d4lR
         WGI2n6xgYbg1k1E/OGxVbhTrD0WKSR27PfsmuTTXHpW6PbnzqpeozICBrsAihJhxRyRZ
         OLJJSc3XmB/G3x/TfpXsmYq+w+xFBDIjIV+vCwXG4y5cQKMKzrrqVZ2YhYTbVhItJRyG
         d8iDr5V1IGBay8AKl8iOK0ViHo+GmAMNNw794degZq2naPjoHzi3AXt2LT4UnWMcCEca
         IAOPcCx7ghOywf9M9eFel+qGM8uowteVd1jNRH/Zh5CvHuJPVoyg9NJGQHn2zF4+px9S
         dWQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d15sor48312034qkk.175.2019.08.04.23.30.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 23:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwS0Eo1lXfnBu6u3xqFFZLty3hYj+avFeIYmNSdIaVzfHVVLe9QhqalA5xTV3YZrONCooErvg==
X-Received: by 2002:a37:86c4:: with SMTP id i187mr100882695qkd.464.1564986640071;
        Sun, 04 Aug 2019 23:30:40 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id n3sm34029874qkk.54.2019.08.04.23.30.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 23:30:39 -0700 (PDT)
Date: Mon, 5 Aug 2019 02:30:34 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190805022833-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 12:36:40PM +0800, Jason Wang wrote:
> 
> On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
> > On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > > synchronize_rcu.
> > > > 
> > > > I start with synchronize_rcu() but both you and Michael raise some
> > > > concern.
> > > I've also idly wondered if calling synchronize_rcu() under the various
> > > mm locks is a deadlock situation.
> > > 
> > > > Then I try spinlock and mutex:
> > > > 
> > > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > > improvement.
> > > I think the topic here is correctness not performance improvement
> > The topic is whether we should revert
> > commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
> > 
> > or keep it in. The only reason to keep it is performance.
> 
> 
> Maybe it's time to introduce the config option?

Depending on CONFIG_BROKEN? I'm not sure it's a good idea.

> 
> > 
> > Now as long as all this code is disabled anyway, we can experiment a
> > bit.
> > 
> > I personally feel we would be best served by having two code paths:
> > 
> > - Access to VM memory directly mapped into kernel
> > - Access to userspace
> > 
> > 
> > Having it all cleanly split will allow a bunch of optimizations, for
> > example for years now we planned to be able to process an incoming short
> > packet directly on softirq path, or an outgoing on directly within
> > eventfd.
> 
> 
> It's not hard consider we've already had our own accssors. But the question
> is (as asked in another thread), do you want permanent GUP or still use MMU
> notifiers.
> 
> Thanks

We want THP and NUMA to work. Both are important for performance.

-- 
MST

