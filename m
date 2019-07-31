Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E51AAC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:32:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE6C208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:32:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LI2KcArl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE6C208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5925A8E0005; Wed, 31 Jul 2019 15:32:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 543568E0001; Wed, 31 Jul 2019 15:32:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 432028E0005; Wed, 31 Jul 2019 15:32:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 227C68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:32:54 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id w76so18079523vsw.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:32:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=c/NJmknjYXnLTaXRtiFYceCSSkLEpxXu+tMv/jvhB4c=;
        b=uOoTN+zY0enMYTHsNZRMcC6iUux1R5jcjPdjhXVd4+ikI3luIPSuxULQej0zsgfrXS
         230ET+bsaiq1E9Oog9E9V+0Nl8qdsUjqG2sW+jVbJDuW6y6r5v9h67wYf38o+89KrjUJ
         DEMppmeYf/8AreNQrOJrhnKI+g5sMjnHt+z1vxue1L6iAZ8aCSvEevTPzjjgSoyp8oNu
         Rh/UxkVILnL/scZnn4RDBDqk9nPJKXchHGVMmHCS/LS1LeDYTOIpULeoLpqkTkx0RZx/
         2yhHpiku737nz5P7Au3Lemx0vbpVtFxsXLplDlj3IPqOehCBJVjJ0w7RKnJvY93BFEW9
         fquQ==
X-Gm-Message-State: APjAAAVfHghMtNQWbjoJCC5w5pe/niZwSnfWTj+BufJ6QbXTa6aR1e1j
	nwEJtrtHgWnn1Ud8Sg2ou792p9IQvlTvdpK+X9BCR91jYwiVtJrZ5PLXxfjITBTdglXhDY8E+rt
	sNOUuawFu37D05Pc1dNoYVF4s8miBdevVbz19m4fSf7VPUEx+3kU9B7bKe12YotB4wg==
X-Received: by 2002:ab0:7c3:: with SMTP id d3mr33625938uaf.131.1564601573854;
        Wed, 31 Jul 2019 12:32:53 -0700 (PDT)
X-Received: by 2002:ab0:7c3:: with SMTP id d3mr33625888uaf.131.1564601573328;
        Wed, 31 Jul 2019 12:32:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564601573; cv=none;
        d=google.com; s=arc-20160816;
        b=kZ1qwgHgZmNs6R+4jl/vCRgyHpSo9gy+Z2EWGhFDa5OHnRlG9vPpSvtmuMzzud0GD0
         ePnpow88ht1cEXbrWuZRstw9emHSPTNY8WZZVWb0HLNU4jRNWIcsjoLikPaA0OvX9gex
         J1plWQ4kt5uwF5R9RNZElACXRM9HCs37PiU3JHMAEjTQtEZmVolT8Fr8vnQgZIT8TvUk
         eG4ArL56TKhkzyzMBgKb2uXlnTuBK/xdxJ/56pwIqgI46h3XjkdKnIa7NIuoWOrAw5+U
         5cGu6KLzYbkFYJBpdMzNKHa5xPR4yvfEd7KS/lPcB0bQ+DDWO6Dsp4Vk0Q5HNUwwTXF0
         Yp6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=c/NJmknjYXnLTaXRtiFYceCSSkLEpxXu+tMv/jvhB4c=;
        b=XtMEC8ufowWvxTVrK1cFtdXCXxckzqyqCidmhShUzhXNCk9zaW5N+nJhcwPwQth1G5
         BXxTZuFoHeYL2NW2fMZhfiR4XxqkTntkBbrl3BldWL/lUKiBBlB7JH6j2foOZtBMv2Gs
         +UexKWhVPr4bIuiin52bd3KFhuPjty4CFtLbpZyWRn17204bkrilKzgMuIQ3gPfSGuG9
         HROD8q7d9FBr2ZZJN+0Qaze+OYoolJSeNYzQvr/6f5yH76GHREDyvBIEt83/h0WlX2+T
         QRr+5yt14sabrP1xR4iIezfDFB+mv+lL3GdgyJ5qJluo/cGRJdd0YToNq/fFj4MGHXQD
         0koQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LI2KcArl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c23sor34038503uaq.59.2019.07.31.12.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 12:32:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LI2KcArl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=c/NJmknjYXnLTaXRtiFYceCSSkLEpxXu+tMv/jvhB4c=;
        b=LI2KcArlX/KDX2TcyNDMmZ/ZE5cTjMJZAWURsjSV4Imlv9kH1NUViD2h4jhBiochFl
         PcBkIr6h+Ama1aEpsEKY0+YWcr4zGIYiDZeHjfAcoJ7D5bhZGrutuuXh2VyPBF/PGSWj
         rBFxsMepIBDKtn7K+Eb/QauyvOUUPBIaZeWYB7D9OTcRzYVrpta97Tts+NPdJEtxyeZT
         4mnFi5qkP9mb/xCWugLIcKxaQeVkFke1DMMaZqkdopWouBcYnmfoYEzQAihrW4DvwoYG
         gTaz79+pmrgYhwBHdPqps4krBCsM0VZnUBMsMvvHGss/KNwAXa5MNeRXmHLX55kimuyr
         zZ8A==
X-Google-Smtp-Source: APXvYqw7F0dP8sLkKJbAjJz+H7jEhemrR3x/a26pLVHnQrJcxOczpiTadHqsEDo3aJO4KIor71NCpQ==
X-Received: by 2002:ab0:67d6:: with SMTP id w22mr11381723uar.68.1564601573050;
        Wed, 31 Jul 2019 12:32:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g8sm21073143vkf.21.2019.07.31.12.32.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 12:32:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hsuLE-0007bw-8g; Wed, 31 Jul 2019 16:32:52 -0300
Date: Wed, 31 Jul 2019 16:32:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 4/9] vhost: reset invalidate_count in
 vhost_set_vring_num_addr()
Message-ID: <20190731193252.GH3946@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-5-jasowang@redhat.com>
 <20190731124124.GD3946@ziepe.ca>
 <31ef9ed4-d74a-3454-a57d-fa843a3a802b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <31ef9ed4-d74a-3454-a57d-fa843a3a802b@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 09:29:28PM +0800, Jason Wang wrote:
> 
> On 2019/7/31 下午8:41, Jason Gunthorpe wrote:
> > On Wed, Jul 31, 2019 at 04:46:50AM -0400, Jason Wang wrote:
> > > The vhost_set_vring_num_addr() could be called in the middle of
> > > invalidate_range_start() and invalidate_range_end(). If we don't reset
> > > invalidate_count after the un-registering of MMU notifier, the
> > > invalidate_cont will run out of sync (e.g never reach zero). This will
> > > in fact disable the fast accessor path. Fixing by reset the count to
> > > zero.
> > > 
> > > Reported-by: Michael S. Tsirkin <mst@redhat.com>
> > Did Michael report this as well?
> 
> 
> Correct me if I was wrong. I think it's point 4 described in
> https://lkml.org/lkml/2019/7/21/25.

I'm not sure what that is talking about

But this fixes what I described:

https://lkml.org/lkml/2019/7/22/554

Jason

