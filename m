Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F921C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28BF721882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:13:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="BDcvXVU5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28BF721882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15BD6B026A; Wed,  3 Jul 2019 14:13:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C6238E0014; Wed,  3 Jul 2019 14:13:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B42F8E0001; Wed,  3 Jul 2019 14:13:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69ECE6B026A
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:13:30 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z16so3892527qto.10
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:13:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dIkgJeJBuw++uppqsU+TnGBul+EFF40cgrIXzTaEkqk=;
        b=jYKRVkbN/0i/py/A6vxZ7qoZPkqCYnFG6IqeDRMiiFFPay5TisN+iVgNbtTsL+LiYh
         GYy9DZcVdllJxJkxfq/HO5f1JjOf57eTIQNao7xKBLvT3Jy2OxLhu+ViufhP5+43S/mV
         DY7ZxtuwfRYzlsKndIF/WpA2GOPxG684CiU9DbMaUepztpzOyMa7RFcjom3U5YhKbuz8
         b7Wol3ZYO3rLDSmDYEeMDri/fFa8bFuGMZkjhOTVpfw5Ts+VkJ1kKTcNHOt/ECBHIBCR
         DWHKbSV5x76eSrnjFOcJ8nGDv+DlrSknl7nFlBYTG65YhvglmXTP8uLaFnFLXbIQwK3/
         ZbMA==
X-Gm-Message-State: APjAAAUfA26AXkBzbN3OTo5pp5VXVNSqNJHr/uGXwslM2jMaFmFtaVZv
	DJ1uvUJQclZJIv9z/h22j3mP0cmP6y+roLjN7JgQp3enq0KysH5YcB05AUjwcMMjjxyeud1aKS4
	OZEHc4pUQcyagASR1tc4mAue8pQJEy0TcC7OUtr0RM9jSwek+vYnNj8mvvSF9Pamj4A==
X-Received: by 2002:a0c:d4eb:: with SMTP id y40mr33110171qvh.30.1562177610226;
        Wed, 03 Jul 2019 11:13:30 -0700 (PDT)
X-Received: by 2002:a0c:d4eb:: with SMTP id y40mr33110148qvh.30.1562177609787;
        Wed, 03 Jul 2019 11:13:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562177609; cv=none;
        d=google.com; s=arc-20160816;
        b=CeeisIf5ORYQn3w9B1WLQ6RQ+Ga8y17vKoTO5LekTaY2ByZ9IBy9K62rXXiyGNWOe9
         X5Q/bD0O0wD4QxoNgnfuoUWyRPogZz02IsD0Kfv/pH2Mv04wHpPMP4GinKzZrOeYq0r3
         zH4IX8yQLScY6dZoXl96spqk6JWgvswn7xokZ0E+kNtFsQjqtbZz8gGOntwg6Xd8ut1G
         V+evgEjf9VHDktNHFf3Q3fhopcfVLqmb9Xi4K4QUfXxCgiyCParNvqfc61wfVicu0Ekb
         vqkbmT64S2iF7Lvl285Xrze9gh9zleAuhsZeSyP/XzcYScdLSVrrZ4wSaEbw3Zm4xdkt
         W1pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dIkgJeJBuw++uppqsU+TnGBul+EFF40cgrIXzTaEkqk=;
        b=wU3Rg8kmQO7P59Rm+iniBDvSVePmT2bQAsugakg9Hq7EU1BCzVHMXLoLAsgIt96Z5D
         dDu/Q+YWyFFGfXD2TcDpsX5rh4b9TtrIvPhWm9dERESyzONFyy6G2BWyb/j/6GTgR8dK
         On2wkNRs6JZK8bXTsnP0TPqBntizUoN75gkvXBXki+O1/7ZGy0moSxwKTzHWLNJV9bRl
         zeiVnlzIDpMVbZbXooHzgEu1AxpDQ/kXIRyRMZxb7rkXkfk0O8T4odzk/F95fuAruxGx
         kA4iISlIUDxDKO3kbvF2TnIhrYsMm5JQR/jrA45z/wKTnS0KMalQ8m4M+xb3ni/bvCVU
         70+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BDcvXVU5;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a190sor1958924qkf.28.2019.07.03.11.13.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 11:13:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BDcvXVU5;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dIkgJeJBuw++uppqsU+TnGBul+EFF40cgrIXzTaEkqk=;
        b=BDcvXVU5S9Xe6RaZL1d/tzhqXI0ERzROC5Hwy70kI1UbibB5XGc2qktpp6KCRj2eJ8
         Cvf/ZQdisnA3SE13u0kPAYYcxD7/vjlMJCRXFqswT6wm7B/ZH66kJW3+LI/VOPZjovQN
         evL2O/4brhczby9X6zVffdg7OkrHAb/PwnzOSEYjUiLxJrWp9rpmHGHLGRdXBfZRWW4W
         JckFR0Y+fY+7lMoaMBwbiK+8lcXoBeP3tQ697oFwWt03yHVMREfyYMjvXlRNVt9JAfjh
         vs4ZSzvO0c/ohYv6r1U/r7F4radpVLs9xgn1pHEoMnI8AYroHgpDAIAg2e2jlz8s1P1X
         DWuA==
X-Google-Smtp-Source: APXvYqwJ/Yia/+35gou6qrRAmIkzXiI4t3koOKtXe3iAnV4Brg/bboybUghnJVCplNkmCRgecJA4HA==
X-Received: by 2002:a37:ad0:: with SMTP id 199mr2986016qkk.90.1562177609563;
        Wed, 03 Jul 2019 11:13:29 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i17sm1533124qta.6.2019.07.03.11.13.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jul 2019 11:13:29 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hijl2-0000Hu-Jr; Wed, 03 Jul 2019 15:13:28 -0300
Date: Wed, 3 Jul 2019 15:13:28 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: AlexDeucher <alexander.deucher@amd.com>,
	Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 20/22] mm: move hmm_vma_fault to nouveau
Message-ID: <20190703181328.GC18673@ziepe.ca>
References: <20190701062020.19239-21-hch@lst.de>
 <20190703180356.GB18673@ziepe.ca>
 <20190703180525.GA13703@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703180525.GA13703@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 08:05:25PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 03, 2019 at 03:03:56PM -0300, Jason Gunthorpe wrote:
> > I was thinking about doing exactly this too, but amdgpu started using
> > this already obsolete API in their latest driver :(
> > 
> > So, we now need to get both drivers to move to the modern API.
> 
> Actually the AMD folks fixed this up after we pointed it out to them,
> so even in linux-next it just is nouveau that needs fixing.

Oh, I looked at an older -next, my mistake. Lets do it then.

Jason

