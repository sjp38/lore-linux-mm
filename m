Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072A6C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A407C217D7
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:17:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="O0RCPEGv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A407C217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A72D6B02A1; Thu, 23 May 2019 15:17:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457886B02A2; Thu, 23 May 2019 15:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3459F6B02A3; Thu, 23 May 2019 15:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10F846B02A1
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:17:37 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z7so6295062qtb.9
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Pm+Vx0dhObnzybiaJozRDpH0LoNYUiVOhc6EGMjBZwU=;
        b=iqJP6tA/UBE1RzNgbEEPCig7ZC/z3AfQv/RcZsLBhTpKBvbsVrvNYzdf+Q/fqLZ5oI
         iZvvr0XnvKpdc6iS3Y9GIVWWNpp4nAUd3po6Wn+NCNGt+0tR+IvCqk2dyOG07+ps9oI3
         bfewU+kJHz2TKuzlz0C2G1kfm1Md/U35tdjrYvQqwLucnnt2QGyYl3eag6l/Up8dQ3Ox
         iJAmZggJ+TnnDWBpbEqLqo5u5g7iRun+eduIYk4L1HLlwfEvEw2qvK3YqEefVDZK1lCw
         JeLw9LXF+Iu84132f3TCiuXdqJMl9zcgdSQSUZqD2Mo/8I2H9GmTETaRHI2xhCbo5s05
         gdbg==
X-Gm-Message-State: APjAAAWzj14LYnLA2FNM1SWmfUruGSqBuJEXzAjAOYgSc9Lnj5GAuwBo
	SqmAQyf+sxdM2HzPSp0JgkbTttxWfM+CPSjLxafo70FDOgB2towAnBm035W3iGYW8NrCn6z1Kpm
	XvqoydQ6bklSwpqKRpns07kLEVrWyT5UxBKrbdNU/aynCaQxxh9vyFxdFgPb6jbrWLw==
X-Received: by 2002:a0c:8a5c:: with SMTP id 28mr39806546qvu.166.1558639056760;
        Thu, 23 May 2019 12:17:36 -0700 (PDT)
X-Received: by 2002:a0c:8a5c:: with SMTP id 28mr39806496qvu.166.1558639056237;
        Thu, 23 May 2019 12:17:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558639056; cv=none;
        d=google.com; s=arc-20160816;
        b=sNQ08vDK2ZntjN2m13LInUfS4Hgkkn4ReTtPTMIG4U8vN4I9n4zwz8eKo3VGRobplG
         +t49FNHhOBJwgVxyIyZhn3utT8LDbEglf4XOc6jUplLirx07L7lLMVDbjZ70ILRKK+eN
         wcz/EH8qWzwY3puhOEviAhS5Cx0jx9mgUgVvWkdC6d6RomgscLNADyh0rTH75St4eIjd
         F2NlibCbjD+X3a/GxDZWSdsZIBgzm6nNcDIw7sEZXr3cozVLFZj+DF46vjRDtptrVZbW
         aqHRiyFLGOiM+Q3MkH9Q7BSPXn9ZZ6Na+33fPrNalg5bjZFdsmV0ULuDJkYJHZWjxf1c
         Yuhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Pm+Vx0dhObnzybiaJozRDpH0LoNYUiVOhc6EGMjBZwU=;
        b=hACsk35g0Y8K/L3VRITJLeZI4k6t4skzc0cHcG8Xyh2seE1paHVxynwT3OQ6CcgLw9
         YEpn7EmUYGy/GzKGAdxXN8rXojhn0Wfq4tiDgbfchmW27OrHSfqXej81Lw5mgofc2AQS
         DeCX0hmqjmlpP4BUOtOCUxGWkaecLVNHMemq4s7Rs0xBnlrh7NTGPBiiBTML85jW3+Wq
         sFpP6sksjF8NrCaWKBEXxSOtAOzoedjHea/qOv41PQL0GwiLYeyzwxtTRRDsRexPaXoH
         uNRdvd3z1zscxTztJVpKq/dPRxGHDineNoXAbVvp5v1qTlN7metoeSDfVvg3kR3y3rEb
         29/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O0RCPEGv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor346989qvd.32.2019.05.23.12.17.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 12:17:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O0RCPEGv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Pm+Vx0dhObnzybiaJozRDpH0LoNYUiVOhc6EGMjBZwU=;
        b=O0RCPEGvWXVRXRZ7y88skUaFHv3isN4h6Tr6VLsss0em/c8A1IncniPr014w2Ci4io
         9rBOKNHmm68kYI6ygpwlm+QtR16oXFPy2bhxS9CwKHFqrIfMtEWctvqEZ4eVLH4Cn7TJ
         HOeZtmCGjBcvBSU18syidFL3Um1gGyCpWXeJsZC2Nvpz7PwdjRmaH9U2HY3sw2gtM83U
         WGdsqtqNuVbxSdeTfdP4MztNl8z1hsbkujcQdJiIBLEMbySogRMR8przLBmtfBbirVh8
         fc9baIPJgppq8UkcxW/nJPwGb+5dwFFa4fUBYQGfezP1UVVzSkaq/4vRP8kXOph9tKhv
         tF2w==
X-Google-Smtp-Source: APXvYqyby6SPIf9lPMNL5yZPBW7JhGUYjZjNDXWEHEzHk702uXmsFYcPFIXfDXhIH78qusR4hcmSJg==
X-Received: by 2002:a0c:9acb:: with SMTP id k11mr59015856qvf.85.1558639055850;
        Thu, 23 May 2019 12:17:35 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id q24sm139016qtq.58.2019.05.23.12.17.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:17:35 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTtDa-0000kS-RM; Thu, 23 May 2019 16:17:34 -0300
Date: Thu, 23 May 2019 16:17:34 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190523191734.GH12159@ziepe.ca>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
 <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 10:46:38AM -0700, John Hubbard wrote:
> On 5/23/19 10:32 AM, Jason Gunthorpe wrote:
> > On Thu, May 23, 2019 at 10:28:52AM -0700, Ira Weiny wrote:
> > > > @@ -686,8 +686,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
> > > >   			 * ib_umem_odp_map_dma_single_page().
> > > >   			 */
> > > >   			if (npages - (j + 1) > 0)
> > > > -				release_pages(&local_page_list[j+1],
> > > > -					      npages - (j + 1));
> > > > +				put_user_pages(&local_page_list[j+1],
> > > > +					       npages - (j + 1));
> > > 
> > > I don't know if we discussed this before but it looks like the use of
> > > release_pages() was not entirely correct (or at least not necessary) here.  So
> > > I think this is ok.
> > 
> > Oh? John switched it from a put_pages loop to release_pages() here:
> > 
> > commit 75a3e6a3c129cddcc683538d8702c6ef998ec589
> > Author: John Hubbard <jhubbard@nvidia.com>
> > Date:   Mon Mar 4 11:46:45 2019 -0800
> > 
> >      RDMA/umem: minor bug fix in error handling path
> >      1. Bug fix: fix an off by one error in the code that cleans up if it fails
> >         to dma-map a page, after having done a get_user_pages_remote() on a
> >         range of pages.
> >      2. Refinement: for that same cleanup code, release_pages() is better than
> >         put_page() in a loop.
> > 
> > And now we are going to back something called put_pages() that
> > implements the same for loop the above removed?
> > 
> > Seems like we are going in circles?? John?
> > 
> 
> put_user_pages() is meant to be a drop-in replacement for release_pages(),
> so I made the above change as an interim step in moving the callsite from
> a loop, to a single call.
> 
> And at some point, it may be possible to find a way to optimize put_user_pages()
> in a similar way to the batching that release_pages() does, that was part
> of the plan for this.
> 
> But I do see what you mean: in the interim, maybe put_user_pages() should
> just be calling release_pages(), how does that change sound?

It would have made it more consistent.. But it seems this isn't a
functional problem in this patch

Jason

