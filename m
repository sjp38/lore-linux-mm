Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE905C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E19A208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nc3ULfAx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E19A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DEB76B0003; Tue,  6 Aug 2019 09:40:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3901C6B0006; Tue,  6 Aug 2019 09:40:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A4F46B0007; Tue,  6 Aug 2019 09:40:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08DCF6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 09:40:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 5so75809134qki.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 06:40:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dNzsOgLAi4DpECpGRrewtthquhRyGxeGVQXq8haedDU=;
        b=TJ1rLcw/7SUOX2u2OaKrsTttCW2CeLFbTSF8uDb7txKr5Qwy1l+LRNzHS+MTIVPhg4
         JPiaZSIqxBCqZS62JDdZRHr2EVHBuJu5AG/yoY6ETD4DOCH6/06xIDLTRi0zyHH7EFKg
         To6SEgYcUzQJeFdQijX297auWXL9Y3GvAbAB4MMt9sNPycqwbMogUwMz1EEsTknMr8Z1
         UXc+WPZOiAalaxGDIZVD57dWEK79sFUHOJAsRjp90lj4KunO09SIVrlVe1SAYCmQovRT
         EUINnoOKZYowygE3bF7Ext88mZjAc9XbaGtlBPtdXtT5BXvrl3Y/TPrK/lofwKZsP3kJ
         woVg==
X-Gm-Message-State: APjAAAWgOnn1CudXV4XEl+aMYdUMZQ3O+VCMusIIb27em0swhwxAYxZN
	3VCinQPtbMIvXUQ49JlA+Cjqj3jR/XPtief4X+GB2If9Xahft4mJLDt5Z+pczRRSPjy84y4gwTp
	zJurciCMa0VQgY6RG0As+vxAU5LZU+5Df68Qf9OjJSkAb2lvgqomD+KvNCBKBbrI+Rg==
X-Received: by 2002:aed:3f29:: with SMTP id p38mr3030967qtf.126.1565098833793;
        Tue, 06 Aug 2019 06:40:33 -0700 (PDT)
X-Received: by 2002:aed:3f29:: with SMTP id p38mr3030922qtf.126.1565098833288;
        Tue, 06 Aug 2019 06:40:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565098833; cv=none;
        d=google.com; s=arc-20160816;
        b=guvv7LuP4xAUu5dDq+yzIBt5Kxt+FYPlEUMLLPZnNZosGyimwYLoG732lOAWe/b85T
         IYKiMewy7GBIQ2gcPLERlUL1jRWM7CghXGNN4K7cEvdZgm98jUyAkohxOo/wa0Hwptkm
         ewgFzqxGr1SFi34uN4PDOEAm8u6p31pBEVC4FjM4wSvv1wSLM5lGCg7XH0aaFDEA5zxy
         RsnGpcy7toA5u+2ezr+JFURd2aUcoQaz9d7xbBG7uHSV4e2oC+0W29LMphBUCev0rSa5
         yD6IU40K5OUzQg93yuQ7y/4YXuZ1fX5qRMiwLDXIacwFTtMnWZHambVB7+4uuOv1UVkt
         zf4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dNzsOgLAi4DpECpGRrewtthquhRyGxeGVQXq8haedDU=;
        b=LhLxxhL81sJ3e+9R4CjaS1C372aFhdvpWJF98abopSGZPjia5uSclOY7I76fh7sT2i
         K3HqF9O40NTlEvstKjvl+It1NXYtvlesHtuzGNf8kJOJKezFxfCqvdPAB0l+F/SmKGC8
         P0XNhp9ZfvEv9ZSM6lA6yIHo9cZ0pBXwzeTlZ1MEpFcrqv9Gzz6ND42wO9y2iS0hMbmi
         93Vbmlv3dsppEW4swbozYzpK+KVYpUBcAknX0WapGadAIb/UfkAq1u16V8B5wXrOFH9W
         n8GUmi68S9MxIAV9n+BSIGQdMEewbjOYHI7AStuPnDbZoqEjj/1JtKhJqAsne+CuhHlF
         rP0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nc3ULfAx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a17sor49710740qkb.116.2019.08.06.06.40.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 06:40:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nc3ULfAx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dNzsOgLAi4DpECpGRrewtthquhRyGxeGVQXq8haedDU=;
        b=nc3ULfAxivmoeOVWtx4pEkcKqWu7gMWhZ1T9c67WVWKwR/tqg4tjz06IHSiy7/T1mM
         1Q9OgN3SKGqoN0fTofviJhtk+Y8Fnu6Rb9wlYk2j8XzfT49iKaQgZskM/1nQuoKXVyrg
         x7tKm90nh5lvD0if38GgDipFfBZn9HvMJg3lzYCC5JZp61ytJWsdqe/KqqgbJCT1alsH
         YRrG5mFigDCgWFVNUPK0RWvRiPVQp4r15i+HE+vsy+0UofzeByMFI318I8OMNMaejIys
         JaRCTgreBgdiEAQrQGSv5kop0m94iD49e5Xbjmt0OHKcuev72yVdTxaI38Rng+Q3PBaC
         NvAA==
X-Google-Smtp-Source: APXvYqxMfwBB47axCWNEJctHilcnayHipqGXZY261+EFRwNZ/6dzvsnkK6i+idF6ma2zmUwEOo/rBA==
X-Received: by 2002:a05:620a:31b:: with SMTP id s27mr3219001qkm.264.1565098832774;
        Tue, 06 Aug 2019 06:40:32 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u18sm36087109qkj.98.2019.08.06.06.40.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 06:40:32 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1huzhW-0004zI-Ru; Tue, 06 Aug 2019 10:40:30 -0300
Date: Tue, 6 Aug 2019 10:40:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190806134030.GD11627@ziepe.ca>
References: <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
 <20190804001400.GA25543@ziepe.ca>
 <20190804040034-mutt-send-email-mst@kernel.org>
 <20190806115317.GA11627@ziepe.ca>
 <20190806093633-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806093633-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:36:58AM -0400, Michael S. Tsirkin wrote:
> On Tue, Aug 06, 2019 at 08:53:17AM -0300, Jason Gunthorpe wrote:
> > On Sun, Aug 04, 2019 at 04:07:17AM -0400, Michael S. Tsirkin wrote:
> > > > > > Also, why can't this just permanently GUP the pages? In fact, where
> > > > > > does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> > > > > > but does not add a put_page??
> > > > 
> > > > You didn't answer this.. Why not just use GUP?
> > > > 
> > > > Jason
> > > 
> > > Sorry I misunderstood the question. Permanent GUP breaks lots of
> > > functionality we need such as THP and numa balancing.
> > 
> > Really? It doesn't look like that many pages are involved..
> > 
> > Jason
> 
> Yea. But they just might happen to be heavily accessed ones....

Maybe you can solve the numa balance problem some other way and use
normal GUP..

Jason 

