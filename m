Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE3A3C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD71F20665
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:47:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KEjL99Iz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD71F20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ACC06B0003; Wed, 12 Jun 2019 07:47:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 536816B0005; Wed, 12 Jun 2019 07:47:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF666B0006; Wed, 12 Jun 2019 07:47:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1874F6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:47:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s67so13520067qkc.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:47:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=doRL6xBFBed4pJcj6qEQTvbXU3ur3CIYrFA1lN8ah30=;
        b=LH3VkLR0Bkb0dOVVc902sl8dV5qLl5/Svj2ZoVleS3tFIkJprLBzzLXd+GsF+eiISo
         8XiH77RhD5aqAAc6+oVy5JxVeg/E4YNjB21awWsZNir3IDfyvPUNG/+saps9L7sUIuVg
         TDdAFXr4poJaWzuYaLcGpOvdbV73Z2PZrbbIlcY2B6FNi2PM5MSTMeskPC6ADY5WWc7P
         KCptjf0pvuk+dyBPyAhWK4+o5jVDRuMDVPaMPVX6xytSNKqqfBuG4lrSAyiu1srd/LRC
         FwlMo6Su7FVNSaujv6Jeb3ORHleqKuMgWTJlRlB+N4Eb5Z7uxmZOXVYln0C2jFyaIrZC
         F4Zw==
X-Gm-Message-State: APjAAAVAgf+2K4ZB2ofc4I+kUHlQmavZ68wbD7LFRRmeGQ7d/7ZgRDcN
	n/6n/g9Hhzusefiz5b9DQLLLN++r8CYlJ+rLLDTms+iS+oVcR4blOS1/WjbF1pCpP8QN5a2tjt/
	3WqDuI0ovEMuyK83Yj16lV3aBYhIZI5ZvIrQ9pqX09KnIrt3+BETHu+lQz2PzaeuR7w==
X-Received: by 2002:ac8:32e9:: with SMTP id a38mr71567845qtb.245.1560340043883;
        Wed, 12 Jun 2019 04:47:23 -0700 (PDT)
X-Received: by 2002:ac8:32e9:: with SMTP id a38mr71567798qtb.245.1560340043292;
        Wed, 12 Jun 2019 04:47:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560340043; cv=none;
        d=google.com; s=arc-20160816;
        b=WC2nj6t9Bb1TFURjyA0y8x8QCMJL1w6d3+zXkHWrJlW6OKP87zVzdwR5RQPMWdgDvM
         68wrB9Is6jHVyozFsMSq/fybTOlUCz7ddK4P8cV4+DVvyaai9Vpy+ZIVIIqVt3DL7CWb
         BnwcZ1bYJWxYQM9gAVqg15yUm/eZQDlF6lk89sEPFlWDPYJQCHNTkNAzOcLsI9qUKDzp
         nAOQ7ketKn+OkTLSK1cV4ZUMug+xFOWk+PmHUlpKe+YtdWz28p6HD4ZZcrCcCnLrwB7q
         C2VEwfAQ/N+tK8J7YgAeOBuLMGQg91TrQihbKo+pXqt77ILvd0mbto4ftbvcJLsIUh20
         yBrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=doRL6xBFBed4pJcj6qEQTvbXU3ur3CIYrFA1lN8ah30=;
        b=TqoDOQi56YCU1agL5zgT+DOlQx/1cb5hK9SnSmdeBQGUx2LA7LFiazja0eVpT2g1qC
         Rc8s3B7PPwAo+9QAcLovPHioBW1MWK7woRBjzRxCJFoBSzqNb11gxxoADI0UZq+OTPfU
         5kwgrsu44bIAju2XOMTOh4WPZXR8tYBX+Zqr2wmPjBlgSWw9paUWwpV1s/AwyQTqtF41
         Bwx6TPoB2jrFJzCXqQdglgZZQY6H2ieCb+SbGAioSJdnJgukyGwOXZSxBLfUgDGshF8D
         Qq5470Sqt6bhzd83YY4r0XYBfhyobNaN4u6+MS8f2kpBKRRddJgpWqnCet7mUFS0wxI7
         jhQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KEjL99Iz;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor21638551qth.14.2019.06.12.04.47.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:47:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KEjL99Iz;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=doRL6xBFBed4pJcj6qEQTvbXU3ur3CIYrFA1lN8ah30=;
        b=KEjL99IzABO4E8zOpgtHyEE7fDCc4xx1ObR/IKbq+ZUDqR6OX5HnV4sIUZFTf7RnZt
         b2Ynd/zlz64GKX5T4XDhbfMlrndVetU9EumvX37IkUOWJMmaxMkt+vAcxu1CdZPoc7EU
         ab05F8Xpa83TYkV6OHDY0iY2sudedN7HpmLMnCVeAmqMtt9fy753PUDc6q2lXgRHWuNb
         WbanwUiNhr0RXy5e3mIuwzswALCs1rX2s+SZhewD51kCAtF+shTYjgGV9IGTi7j7s9Wy
         MYyHNmVkN91noui2Vnp7/PPo2P6dBu6nZ6qFP8tAHWsLEKkJnaOd1W/VqIrOF8KjgmmJ
         M41A==
X-Google-Smtp-Source: APXvYqycHb6gvBCa/U7QXKWMgTojD1Kl8PmNQRXZ9Diy9dAscbbAdH3XTO8f9by4yoHhgJdAhCfOmQ==
X-Received: by 2002:ac8:2eb9:: with SMTP id h54mr69874544qta.381.1560340042946;
        Wed, 12 Jun 2019 04:47:22 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id v17sm10366715qtc.23.2019.06.12.04.47.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 04:47:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hb1is-0002JC-07; Wed, 12 Jun 2019 08:47:22 -0300
Date: Wed, 12 Jun 2019 08:47:21 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612114721.GB3876@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612102917.GB14578@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:

> > > The main objection to the current ODP & DAX solution is that very
> > > little HW can actually implement it, having the alternative still
> > > require HW support doesn't seem like progress.
> > > 
> > > I think we will eventually start seein some HW be able to do this
> > > invalidation, but it won't be universal, and I'd rather leave it
> > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > on fire, I need to unplug it).
> > 
> > Agreed.  I think software wise there is not much some of the devices can do
> > with such an "invalidate".
> 
> So out of curiosity: What does RDMA driver do when userspace just closes
> the file pointing to RDMA object? It has to handle that somehow by aborting
> everything that's going on... And I wanted similar behavior here.

It aborts *everything* connected to that file descriptor. Destroying
everything avoids creating inconsistencies that destroying a subset
would create.

What has been talked about for lease break is not destroying anything
but very selectively saying that one memory region linked to the GUP
is no longer functional.

Jason

