Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B13CAC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78CCE21841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="YDxsaLxk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78CCE21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A0E66B0007; Wed, 24 Jul 2019 12:53:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02B1A6B0008; Wed, 24 Jul 2019 12:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0BC48E0002; Wed, 24 Jul 2019 12:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BAE986B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:53:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y19so42038835qtm.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N+5GDocIaGJNeeiAfHSOPi2SmVdT4rQLPHKSD9PsZ+I=;
        b=U128Hrp1hsaSo7USYQijfOxuzVyrow6vshwp7s2kyUMOhrcSQ6NUEzLQdbIugcLTVi
         Y+GDHsVH1N/skG5O2IL8KrlfAe+ocm5V9uR+1R0bRluX+VLC5yRkwJUZzcFgUE/lw+nx
         /lzcp7fJ8nQUoPskQjQVErODTiKqph5dAVMFv5aXc1DoBSNI2++Uolx45WRgQr0u1Y92
         RqIr7u3LPkJZ7VekvBIIt5EBjsMGeG/1UD4r5dfqdNoAxrbOVukqdIhDMxgX1dC86NDY
         qN48jnyCd4wm8zOQq8H9MbAalfULTlbqylK1xD2eL4oxc1uhnkE0MvqEHUPGgmVNhiaK
         0mWA==
X-Gm-Message-State: APjAAAUi4dOBvDZty9ehQUxQ4FtkUfan9NP048GJo9MYh9QEJGhMBnHb
	1/mpoZl/4wvdOMjgRbjRAqSgj2HGa4+9qsTF3wvXwI6porZ6UHyRFz47W00r3bbzzuTqs3QnKLW
	tCrfglx3sXeB0+KGjB0E6aGUfkbIkibgbHot04OJFmTauxboEwc+P7DQtMd2iOzIZ4A==
X-Received: by 2002:a37:a7d2:: with SMTP id q201mr54306418qke.150.1563987200518;
        Wed, 24 Jul 2019 09:53:20 -0700 (PDT)
X-Received: by 2002:a37:a7d2:: with SMTP id q201mr54306378qke.150.1563987199843;
        Wed, 24 Jul 2019 09:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563987199; cv=none;
        d=google.com; s=arc-20160816;
        b=dl1+KNHDWMDRBYLyknhLcE5EuhAoKdiMC5uoMRJBkCNBbpFtwm/vd047JlYTTZ8CQx
         RWBtFircEbbpQlYyWcxRxWR4BBx0QJ7xjHYu1SpX2anq6I370e2hNrLOTVwVb+1sosju
         189mv91b4QUkDnW5ChdebK2XkTb+LY0FjxKAQGY6atWzhXWoQWJi07YGcFg7x04M5Jlf
         BFIeYsn8HK55rTqnnk6I1IV3dqT9C8/0Z4rgNKVHxaS2e4wkomfJ4lOV08x+iOkYMN89
         Gj1yYvW48ejN49J4sPWv5LaaX32wvm3MFiZYv3AC7eQVzrXm4eM7YzaDjvvlOheMgxne
         MoBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N+5GDocIaGJNeeiAfHSOPi2SmVdT4rQLPHKSD9PsZ+I=;
        b=ubvOBFLoQmE4spdNxP+ymz7Gu0TIL63GGJvtEuu2w/hXtJzZlKz0S2Ou8bzzv2BU3f
         qjOQczlEge0wccms2AjRELKL0y0b9cmz3v9e6Mks89l2k/Sb5PhEu2Mj5j5IdI6KdiJ6
         M12UZo261HXIeGzBRVMTx7YvF1XslZHxMsK0FmR1Z74IqVdpaZn/mu1L4IvBLbdEChg7
         xR/YZYE2Acalv+BUAUOlCXYJOmXX3My/kmz2z1oRTjMxCPGTxs5uE0ei6RIfz16b8woL
         MLzlzw/s85S4N7zNLY+Dnk8PelsGUywC9rLxRp1KfcirBhUIRdZEMMXnBT0DgrEnl+SJ
         phRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YDxsaLxk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor22051097qkc.70.2019.07.24.09.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 09:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YDxsaLxk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=N+5GDocIaGJNeeiAfHSOPi2SmVdT4rQLPHKSD9PsZ+I=;
        b=YDxsaLxkea1VSwYyvtzIkxG5oCvSkigPxhBkQShb6z3NiUMmOxfDu1eZ6zFkom7daU
         u8h/zoLkQOxwJRbiaCw2/8hNE/Bht5HY3TCoiCttwyptVd1mPoS+GRxRkwK0cCm3iq22
         7qkf+dpbC+KGjNEaO8b5+LWigp5rJLzAXzsj2ylO1gPUf+tQ5JrgQJnV1nENWsjnyYa9
         9VarDOham+q+ATGl5AwzqF39bSfue6F3vqwEURcqG21pxm9lVbVSoUgMl1phRmPztF8C
         CtiYbpiK44hufWFvehcheJDYUXoVOSEOaAY2meip1/99aZ9WTovpxbewVKfaicsyRLaG
         Ke3g==
X-Google-Smtp-Source: APXvYqwTV2my7RFNNmAmi8390juQo6CDY6coH8KBA9OiHHx09ixIjX0uw+ns25AF40VQtymPk2wh6Q==
X-Received: by 2002:a05:620a:232:: with SMTP id u18mr53141490qkm.131.1563987199405;
        Wed, 24 Jul 2019 09:53:19 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q12sm19415581qkm.126.2019.07.24.09.53.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 09:53:18 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqKVx-0002lr-R9; Wed, 24 Jul 2019 13:53:17 -0300
Date: Wed, 24 Jul 2019 13:53:17 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190724165317.GD28493@ziepe.ca>
References: <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
 <20190724040238-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724040238-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:05:17AM -0400, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
> > So even PTE is read speculatively before reading invalidate_count (only in
> > the case of invalidate_count is zero). The spinlock has guaranteed that we
> > won't read any stale PTEs.
> 
> I'm sorry I just do not get the argument.
> If you want to order two reads you need an smp_rmb
> or stronger between them executed on the same CPU.

No, that is only for unlocked algorithms.

In this case the spinlock provides all the 'or stronger' ordering
required.

For invalidate_count going 0->1 the spin_lock ensures that any
following PTE update during invalidation does not order before the
spin_lock()

While holding the lock and observing 1 in invalidate_count the PTE
values might be changing, but are ignored. C's rules about sequencing
make this safe.

For invalidate_count going 1->0 the spin_unlock ensures that any
preceeding PTE update during invalidation does not order after the
spin_unlock

While holding the lock and observing 0 in invalidating_count the PTE
values cannot be changing.

Jason

