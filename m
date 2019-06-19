Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E575C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:29:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 040372173E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:29:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Mu7sgXi6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 040372173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4538E0007; Wed, 19 Jun 2019 12:29:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A5268E0001; Wed, 19 Jun 2019 12:29:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 894D78E0007; Wed, 19 Jun 2019 12:29:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68A2C8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:29:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v80so16239417qkb.19
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:29:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qnUOwWGBCAXAVLri1Ul0fDjUeERWKjKVp0Rio+t6Mw0=;
        b=b6iwQyDuIcdmXtd5DXOr+EfHxpd66vw5MJthXnzC5jWn/KGehHPghMIdAeU1pO/9yX
         T7DZPTN84zNzXu2RHjEhpyYHOAb4dXuCtbHUYYVNnjg7VWfef2nEe9c3+yXlmaX+jBgl
         K8Zfx3+tqA42Fnvcma6Dn71AZO6gnuQb1J9J8hgdEIraJm4RPW8NHhE5e9bPU3bwyieO
         nqzEkF5TZe1xxN8JadLAQp6yhtDJb9Crlrl3m7Vkd4cPeyXy6E8wig9UxbQrIld4kSsO
         0Y2G8EA04OQQu3aB02rjG4DlYqzkxSYnySd/VH9zwzSzQgCulTFPaho4up9sHonboXH1
         Ik+g==
X-Gm-Message-State: APjAAAWFE4RiqnbanNyTt5hsbwJD2lJLB1THG8qbtGLNUzM3RKT8FNit
	/wUms21MFL53vg866XqPE3c9dmClcvUATrIHz2Rse1z3stUZe1Lo7eZ0i5BXdrL4I6K73hIiT2w
	xWJ1qrW7BDTx3VNGpu89mbk5NfEyNdQMpOYbWjDL/ffu7X3WH9nZH7QdRAEIH5t+Klw==
X-Received: by 2002:a37:9a50:: with SMTP id c77mr100421359qke.12.1560961745229;
        Wed, 19 Jun 2019 09:29:05 -0700 (PDT)
X-Received: by 2002:a37:9a50:: with SMTP id c77mr100421314qke.12.1560961744636;
        Wed, 19 Jun 2019 09:29:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560961744; cv=none;
        d=google.com; s=arc-20160816;
        b=XPU15xsx1jWUqCaUzeFa5XVOp0rTgeoDwd4Mn2MQv6hu8PKfwHlnBcSiwEYkW7LIZy
         uJ2BlR5qToipJB962JOeyTmvyVsvjapO1hGkIddwndn6hmujxZFeC5uWDBco6n4AjSwx
         /0HGJkrXkTr9sBnPV7Q0+1m9gBIVeiDPkMBNdz1jvEOej7x0rlifSRMHvbj76dSYVPnQ
         aJHtMqVN3BaGZr9VDoFcrHb/RvPEWm6jx7rRwfpEnp9hAxROb731ImYIdMYWi+/xIw6E
         XhKCDJAIgksGornx3hobjmR7S/f9FYLXMurUu9MjwaBYXTrtGvPxbkkkmcKUjGJNpcW6
         d4mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qnUOwWGBCAXAVLri1Ul0fDjUeERWKjKVp0Rio+t6Mw0=;
        b=lerZf39U10tNAAQSWMQpDuXjFFOL2koBqhYbTvnSXXKbxlVnkny0R2GHFWw4pm8iJw
         EAsrA/vZSIhm7ajUNZGq4YYd8eykwB74sREDysNv2Xas8uUPU4HD0fzFsRejBCDsQ51c
         PozumdUH4N+r9VH8VMJsgyYSBjCmuRwfsM7Yee5KXUbarWUGsGBtUWPN/2t1b8shQZjN
         nsI6hwvGNHkrCI2tuXwErpUMw+MFjcBs/Z+1JxqjVw5vQvLeOqjWD1xXf3p6cLDsuNQ7
         0YlB1ksJrdznaqnzNiiJdYy6hWL89QHQAGG9jR567me3wKh9Kq8ApGjjp7GFUWwfI/nd
         Ptkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Mu7sgXi6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g64sor10907446qkf.90.2019.06.19.09.29.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 09:29:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Mu7sgXi6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qnUOwWGBCAXAVLri1Ul0fDjUeERWKjKVp0Rio+t6Mw0=;
        b=Mu7sgXi6O1BEfTzeAxDFiZq9WYAU+8GuA+frzMgX9hRk0/2Eo2VPU9VKN7SPqn7GLw
         BMmvCbBlMZt8BrrdyjrzJb5mIwmN+Un5ohC6uh52oLeiu3fM9lYGSfsBxw2N/in8YFn5
         94JBdMTWXqhPkHC5ogDkAk30Vj3tK2OB7FH+D8RuRjkNrh4KSwvNzZkKLQDt1o6UXnKk
         akxzg79p5LQYrNgI6wQWhEDCa4i3Wr2Q3GuDm1M6C6XhuTkbEI5dQ8Rzs09QxzMXG/yv
         86i6u7h1UReQ+1KLg8ARX3o5vtg8COFFdiinD/3xnzFLxOpaxmET6WHLpP1penmwv6Fz
         qw4w==
X-Google-Smtp-Source: APXvYqxI2A2AbFb1+ZoFRIh7H3fg512a+PNV8rhMF80/TQ7Ui3RJ5j2fJJDqC3jWu2+hRHD8V09puw==
X-Received: by 2002:a37:5444:: with SMTP id i65mr23556982qkb.263.1560961744340;
        Wed, 19 Jun 2019 09:29:04 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n5sm11854916qta.29.2019.06.19.09.29.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 09:29:03 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hddSJ-0001sf-Di; Wed, 19 Jun 2019 13:29:03 -0300
Date: Wed, 19 Jun 2019 13:29:03 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>,
	Potnuri Bharat Teja <bharat@chelsio.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190619162903.GF9360@ziepe.ca>
References: <20190614134726.3827-1-hch@lst.de>
 <20190617082148.GF28859@kadam>
 <20190617083342.GA7883@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617083342.GA7883@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 10:33:42AM +0200, Christoph Hellwig wrote:
> > drivers/infiniband/hw/cxgb4/qp.c
> >    129  static int alloc_host_sq(struct c4iw_rdev *rdev, struct t4_sq *sq)
> >    130  {
> >    131          sq->queue = dma_alloc_coherent(&(rdev->lldi.pdev->dev), sq->memsize,
> >    132                                         &(sq->dma_addr), GFP_KERNEL);
> >    133          if (!sq->queue)
> >    134                  return -ENOMEM;
> >    135          sq->phys_addr = virt_to_phys(sq->queue);
> >    136          dma_unmap_addr_set(sq, mapping, sq->dma_addr);
> >    137          return 0;
> >    138  }
> > 
> > Is this a bug?
> 
> Yes.  This will blow up badly on many platforms, as sq->queue
> might be vmapped, ioremapped, come from a pool without page backing.

Gah, this addr gets fed into io_remap_pfn_range/remap_pfn_range too..

Potnuri, you should fix this.. 

You probably need to use dma_mmap_from_dev_coherent() in the mmap ?

Jason

