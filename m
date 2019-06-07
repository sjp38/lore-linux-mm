Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 083DEC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:50:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C655D2133D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:50:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="oZC9a6nv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C655D2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EDAA6B0005; Fri,  7 Jun 2019 14:50:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49E856B0006; Fri,  7 Jun 2019 14:50:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38EDD6B000A; Fri,  7 Jun 2019 14:50:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16B5B6B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:50:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n77so2348781qke.17
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:50:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=981lOBbF7NntqOPGnU+wDEqlWf7ONqp9B0Ou4FbjqoU=;
        b=VSx5eA2e+WnS6lHzzcNGWh3KLo48GYR/PYYQqnRHbKInDd3G84bdMkGLhNHpVoJ3tK
         5UX0unW4bIRHpYWHszatCLE5jVICidS0GA0xI7tJebw9K38hYdJGzqKd/sbfouQPhn6H
         z69XuIuoLygC1RQ6IzAb/vAvvruwL+jERYhS6J9m2M3/fXgN3KHOXXfZ/3hSPYgDD0gf
         kAWvKFko7naIXOqvBaIxEvN+rsrzsBt10xTRxVAuYye4OLaCAG3A51RdDAjvqdLqnnAW
         jIaWCeQ2sAI858oJ7M8IczFTm1BYQ8gxne4c9p8seGNvSz0WKH4uORiPapjnJiEHwUHp
         IwPQ==
X-Gm-Message-State: APjAAAXY33RR+nVT2mORTADmEL9nnD5TCX02tdKJPKzKAosaGFomwCGf
	c7XrQ2tWQoXHe0ZDbXvoGsVXPKkjBqOMlXtqoGeNHsRCOlQOjY9qqJD1V71QqKw+2E2reg5R9Kp
	GCkJol0JATl1M9lUrpsrVTDYd2GO2Y6n+LEbfpjWEpdWRUsGpyE1xGrzwLJ4fV1eA/Q==
X-Received: by 2002:ac8:38cf:: with SMTP id g15mr40759866qtc.268.1559933421806;
        Fri, 07 Jun 2019 11:50:21 -0700 (PDT)
X-Received: by 2002:ac8:38cf:: with SMTP id g15mr40759810qtc.268.1559933421115;
        Fri, 07 Jun 2019 11:50:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559933421; cv=none;
        d=google.com; s=arc-20160816;
        b=tgQuaHj9xx/NdaUj5W2+qpx0ee/tV106MagJEXUfPgVr2A4XqJeaq+7i+WxqDveGhu
         +RnwqpJqHcwLZAJesbQy+wVzDce0cuNAOkqeWejKmgju6+LEIlUT+k7A28yqaa2WwFJy
         S27LTKOA3Ca0jRnOQz4oQN95rU1mr+BBhjL64O3TixbsY40fgv8JHWdmwxw3aUcADOlc
         AOmh/XveLP9UZ8RZsHXCWXPSUBo0gQPU3yEO9Yhv3Ff/3iWmXPxvHBNLUB1HO5zyvdxT
         TN51D2PMG7Sv9fF5TSZ3rG4GJT7FmMXWhhlI7JaVExHqHyE7g/nPQdmNIkOhEo/WlIU6
         waCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=981lOBbF7NntqOPGnU+wDEqlWf7ONqp9B0Ou4FbjqoU=;
        b=Lr7aoJ8ByUDgQBOlmOqua+usJRy0FV6lx/KDAblcafQ6yzqkXFNLq2mlj4nZvPTu2k
         VxKEMCn+cZ2iDosx3an+kL2D3M3J5FzfBfdCyVS6LfEpUE7Z945o+i0I/R1um4KgQLmA
         LSow7Xr9U5L7clrMytmJn1jGd4W2s+f1xz7YDhbPwnDjA3LZTKZCmFez8hOc24xsb86l
         5/1puPfVNJqk2vrMV+r6bJKa26Fs8pgrhWTo3oRfo0KXTRASzRzsKg4gGnaDJgSbsy5f
         +HvCBgsjy9TcGjTibrF+ZG0YfRX/fLWUn2E/NqycjTE4VbXtxX63Lu12COVCcjGbG+Fs
         woiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oZC9a6nv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor3520859qtr.1.2019.06.07.11.50.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 11:50:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oZC9a6nv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=981lOBbF7NntqOPGnU+wDEqlWf7ONqp9B0Ou4FbjqoU=;
        b=oZC9a6nvcosvTmp2Xz2vW0f9gvXIuh4kitLGI6CjsLXK1+Gnu0mccx6TNO5esZKRWN
         jpusXhxZ6diyXP/2IvDfe4Sozh6aFMls99kKfV0Oh9uEVYvzKsy1COSoqZhzVVpYwP9K
         DlLyyRWwMTfr89qP7WlB75o9IQD+x/cE6xx3qucV0uEUL41Hb7JpWs/wMh4hLxr3HoJx
         fc49CEJVp4R714dI4okPWcziniOd2LBG5fbQY9h/Cjd9k+Pglq+pi5j+zKX1QlmTE64r
         wbxNASKedhU1orq0qO6Me5wbL2KGqE9NauEFAABsOyUfWfONSs2MlnU6mWezKlVjNiry
         8Hvw==
X-Google-Smtp-Source: APXvYqxHzZOVD73PAZq/gC6oUmCxE3JRfnnnGXli2ogTGkWJxAu+ueWdhS//gQBOh+cGCpWnmaBbVg==
X-Received: by 2002:ac8:444c:: with SMTP id m12mr48345365qtn.306.1559933420780;
        Fri, 07 Jun 2019 11:50:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q2sm1527313qkf.44.2019.06.07.11.50.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 11:50:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZJwR-0007vm-HB; Fri, 07 Jun 2019 15:50:19 -0300
Date: Fri, 7 Jun 2019 15:50:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607185019.GP14802@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:

> And I think this is related to what Christoph Hellwig is doing with bio_vec and
> dma.  Really we want drivers out of the page processing business.

At least for RDMA, and a few other places I've noticed, I'd really
like to get totally out of the handling struct pages game.

We are DMA based and really only want DMA addresses for the target
device. I know other places need CPU pages or more complicated
things.. But I also know there are other drivers like RDMA..

So I think it would be very helpful to have a driver API something
like:

int get_user_mem_for_dma(struct device *dma_device,
                void __user *mem, size_t length,
                struct gup_handle *res,
                struct 'bio dma list' *dma_list,
                const struct dma_params *params);
void put_user_mem_for_dma(struct gup_handle *res, 
                 struct 'bio dma list' *dma_list);

And we could hope to put in there all the specialty logic we want to
have for this flow:
 - The weird HMM stuff in hmm_range_dma_map()
 - Interaction with DAX
 - Interaction with DMA BUF
 - Holding file leases
 - PCI peer 2 peer features
 - Optimizations for huge pages
 - Handling page dirtying from DMA
 - etc

I think Matthew was suggesting something like this at LS/MM, so +1
from here..

When Christoph sends his BIO dma work I was thinking of investigating
this avenue, as we already have something quite similiar in RDMA that
could perhaps be hoisted out for re-use into mm/

Jason

