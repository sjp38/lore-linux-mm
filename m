Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F312C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B855321882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="MGb4X8V0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B855321882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4A48E0014; Wed,  3 Jul 2019 14:15:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57F4A8E0001; Wed,  3 Jul 2019 14:15:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F8618E0014; Wed,  3 Jul 2019 14:15:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0C08E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:15:44 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x17so4130444qkf.14
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:15:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wryDEDMxoF6Vk+K+7duTnFgyottGCGFfZAdbutaWn2g=;
        b=giO6h7jYTE/QfpHfJMRbaE9K0+48cQZGVxc/HxBmUrPjyydX7A385LSiwm5iCwv+ZH
         dXCb6wzqWM77NKOcY7EvI95aEi3SBGlBbOYaHvc7Jvyypq3PRMhBF7aJHeThlX0qI8Yn
         kmSdgQ0Y3Gf73j8nKJK+2ClZVrasWclXLt8IoP4kZ72LkG2hrb10HLtKRTTvGYhKpW0d
         XgaV/iylHlNTVrUX2Eq1kO+B8rTdZDQAp8XihrplfnLuUiTgbpRUpPII4SZs+r3WVKdw
         gPL0eh79xm2kSHBmRx/jBmiYrtL7AepINkjaAWjabYEZT14RX+TZh543ljmesdpalKN1
         E0og==
X-Gm-Message-State: APjAAAUP/7LZRjbd6uBC/KADohcfA6m3wVrfTy3JnKdB/GXcg6M3qv7R
	zqqw9wtLwAUFBp05Q2O18QVKdbIo9mnGBCbA8/2l3kKDmjnCpE8IYff6zIr0HLxGDztNewR/+lv
	0vWHq9MybriHLXV6GOF06XmRrAVcMYJ6PCCHCTFtZd3fiAHKCYvLQVIHJKw50/9svJw==
X-Received: by 2002:a37:a5cb:: with SMTP id o194mr2187344qke.371.1562177743910;
        Wed, 03 Jul 2019 11:15:43 -0700 (PDT)
X-Received: by 2002:a37:a5cb:: with SMTP id o194mr2187300qke.371.1562177743325;
        Wed, 03 Jul 2019 11:15:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562177743; cv=none;
        d=google.com; s=arc-20160816;
        b=uFue45veZTsVd3+1CbsyUgzeF0Fra4HqTVyPqRxSMokR6SXlD7iYEfWG0vK4GndbjI
         jzdW1O9I575BqeHzAArRith0rR0BhCuSjXc6HLKY0DZ6O2RA7Wst4yuV6G6KyV8F+Czs
         witP9gQho3j/6JuGQEwAW2wsIBoU6i4ivOWKx+ULEsTLjX5tzQizzAFlgb2yyjWms8GJ
         +V4TAR3TCReRb7KmFqKLgdSBzT7Xv26147llQyDbrE0nrK2Bdw7B7hQi1jklfKtNQFSb
         ALeW6ua7Qr1BenKbAzVUZnRa7lCFBC5XvHGf9xgrld3/G7Iu7rM4RSef8i2ZK1K4JrW+
         ysVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wryDEDMxoF6Vk+K+7duTnFgyottGCGFfZAdbutaWn2g=;
        b=TRWLSpqQwH7gsqYynNUIJVZXX9Z6aTbIU7UY+sxh+2piAVQnbs0gkz78Md8+QCKDPS
         ffrURBtAXfJWR10ncTrSGcfC0BdqUSmbjAjdSs2BQ01NMJHmDHoC/lMPzKX/p4R/Tw2+
         efKChhcCZ02DCJqGlKhYRZKh/6jLh+uM1XV00vHlHJ6oNytwWY+0CF5MG62P5vql2YCq
         lHlYrmSbgXDZ8w1+LwD6b89n7UNe1QibSRHqnWP9aJehAmGM393Fr2KCSrXYqBTzwm2z
         cq4neViNdXDdmpSHnQfSJiDGFH0FGJ5edsmX/Qxw3DWASO2vdPaGcxMtJiso9S0Xmlrl
         /+Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MGb4X8V0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g10sor1946657qkl.136.2019.07.03.11.15.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 11:15:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MGb4X8V0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wryDEDMxoF6Vk+K+7duTnFgyottGCGFfZAdbutaWn2g=;
        b=MGb4X8V0OjUmCxHXdwat5t//603Imvm3kttDyzPr4B1R8dke3zyk8pDWGq7fzjOf9T
         vhoLDzI6WCU5N4NrK/vZZAt9KDue5n72hIeNC1cz1j/ds592t4xYj0gPc7RQWN5tu3kK
         y/BZeSVV19CFNNBfNU5x0lM9OM/CH02xFeKxUrblZJMqjjhX0l4gjG924KSmb6umCVqY
         q+ZOkych1AFQ/2d82ikRe4cso3C8TVySqyZbPVlAYKLNARrOu29Nsf2uO3Rs45jVcEQb
         PCfasJR/oBWrfsPe016/1vxmUYZfy876Nti6m+RO+WQbCOzAxMa5i5a/ZdgHoU8lAwIn
         KN7g==
X-Google-Smtp-Source: APXvYqx+Obpp289GMjyQScpks1hosaCdzO2IJ2gOygQVUkXAuZU/IoXFFk8Hk2uU2aW+fFE5K61x4g==
X-Received: by 2002:a37:4914:: with SMTP id w20mr31403797qka.156.1562177743091;
        Wed, 03 Jul 2019 11:15:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id j184sm1204269qkc.65.2019.07.03.11.15.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jul 2019 11:15:42 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hijnC-0000Ju-2z; Wed, 03 Jul 2019 15:15:42 -0300
Date: Wed, 3 Jul 2019 15:15:42 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 22/22] mm: remove the legacy hmm_pfn_* APIs
Message-ID: <20190703181542.GD18673@ziepe.ca>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-23-hch@lst.de>
 <20190703180125.GA18673@ziepe.ca>
 <20190703180308.GA13656@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703180308.GA13656@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 08:03:08PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 03, 2019 at 03:01:25PM -0300, Jason Gunthorpe wrote:
> > Christoph, I guess you didn't mean to send this branch to the mailing
> > list?
> > 
> > In any event some of these, like this one, look obvious and I could
> > still grab a few for hmm.git.
> > 
> > Let me know what you'd like please
> > 
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> 
> Thanks.  I was going to send this series out as soon as you had
> applied the previous one.  Now that it leaked I'm happy to collect
> reviews.  But while I've got your attention:  the rdma.git hmm
> branch is still at the -rc7 merge and doen't have my series, is that
> intentional?

Sorry, I rushed it too late at night to do it right apparently. Fixed.

Jason

