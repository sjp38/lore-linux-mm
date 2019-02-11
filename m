Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 322C1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:07:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC9A218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="VeVuItjI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC9A218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 501EE8E0179; Mon, 11 Feb 2019 17:07:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B0BD8E0176; Mon, 11 Feb 2019 17:07:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 352B98E0179; Mon, 11 Feb 2019 17:07:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E12E78E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:07:01 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so425851pfk.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:07:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=frvaZOEeTzFuUHcq938YEPXksp5CEcnni8x382y8wmo=;
        b=o+6c2u4CD9HJgvxiXa7LA6oPFuIIwYtK1mMdWMrdcCZqogc9BrX/Uoc/2esvSHV/b9
         dhIRFEzPHVvv4Sbr6YM8dQD2zkDz7SzGS7qSDminL1cspKi9O6J/uZJdrf2VW6NQN3Oy
         yGahKhd0UyxDai529WPebj0n8pr3I8uiLUWYvLqM0RSSMhlqo9T5JnguL2k1x0uGCb7R
         JPuYLVStzsJFQ35ehvMP0oDZUzkuRuqwhegpauoEyvjtFQYY0HZSN8PP/GaATdTRzxBt
         430pOEB27yhDUAVZ9QC9CLxZIj+JXuagHqxRkA0lXv14RvJWLBqHkuLZV7DLvn5QWxKW
         j7oQ==
X-Gm-Message-State: AHQUAub6gNRQY0NRozuu4uxceMkAASi1R2rf+YfyU4gtaf+AiAfshIhp
	jLeq0NvxvcD3jf6yGcdSJQifRPjsBs4XPyLzcsUgg4FyP4TMFVQ63Q935iGKY/b93rtRNSzk11+
	7L9Rilm0jtK2i2M8CP0h9NMYCoNrCmoBsT1130uChfzjylRpoU67u46/tmtHIpkoyKyXpUEpobx
	ZZB0LCr/zWwT4it68XASokDxeEd46qZWI/Bs3F/C8jRLqo+RLWP1erZMUh5qiDHlQdXT76X8+Lh
	vphsJAXbYTyuNImEs6PQkutNtSvFIv3ACm+1OblhtWhLDkm54Rm1kC5wlfU+9HwaVgu+NJb3yjP
	kNems+TxwjXBiu/yHxkTz7nwnOrLPNbVjdei65UhoAi5QQ9H06b5Lhl1pJJ7budAIxHmZTvaOTY
	W
X-Received: by 2002:a62:57dd:: with SMTP id i90mr495324pfj.154.1549922821493;
        Mon, 11 Feb 2019 14:07:01 -0800 (PST)
X-Received: by 2002:a62:57dd:: with SMTP id i90mr495253pfj.154.1549922820766;
        Mon, 11 Feb 2019 14:07:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922820; cv=none;
        d=google.com; s=arc-20160816;
        b=RnXUXW2mw0gL9lNq4E8u5OmbEbGpaS8KxGTmezEQDQZhRZcB7hM0tqdcJF14HDXaI5
         p+k0ZLvQhU1g2TpQCtc5/lDSDWiJ/YGEUm7PG1gWEKrhleOSXdE566LQEzuf/iw5+9V1
         ike/sdd1P1I9l0D+jdcES8gEgwvqwgVZQXuDIm1RmZN7Wdl+j9bh+ADN6j50h+lddLQb
         FMrRuny9gh5ZpKAu9vdoDTRz3Fr1Ng7gdvH9lvTQF8unyC1F0gBOTa79gF1LAgJ6ZgoV
         wxs9Mjil5NSITcl2L+2IbPq+XYOG2gNaRWz/Sr7ly8yPAYyeU+e8ox8X3QG5ns7QmuaV
         YaBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=frvaZOEeTzFuUHcq938YEPXksp5CEcnni8x382y8wmo=;
        b=d5HihrPTNPWykVyLJq/4rDpOC76xWx4tcJq/UhRX6HyrQsiyuy2oCJNjLBwoM36qUK
         wZPkZa8hOQIW5t+QqM/8eRyrUf1sqFyVpr+wJ1RJWW1g51qI14R0wvQXYPAExTKyBL6d
         ajMzlWgaCJKBNn0SDXZ/qEB7rj5LP7zuDisePwU/JGaD/8fklQvCfI+G6wcGeAi0GFu8
         qr2ts0Eu6UzpZUM02qJPrRNwpq8Iukb0GLL4EqHExQ/e+Vks3bwGikfc3PGXjJCBynU7
         Ai24/JcyFQvpfdzrmasAgqPRNGf+doB3k+DXoXaxQSSEGCs6E0qv0FzbY7a2s4rt9yGn
         uTxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VeVuItjI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q18sor1405963pgj.18.2019.02.11.14.07.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:07:00 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VeVuItjI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=frvaZOEeTzFuUHcq938YEPXksp5CEcnni8x382y8wmo=;
        b=VeVuItjIXy0SQn0doHT9YkJkE9sUtF19qBoE66CnyZni8a5cGpjbAptQy9ocKu4A3m
         Fgsu6EgfA2a4TJxbZ3JWW3pB+5oj0uyCpY501ALmg9VU4+Bq3AOTNkG4q9M+rYLgYoum
         +V1r7iebpLzVSn5SYfREG8dQsv0Nsn7/VD/H1AAqH+NkzioQd5IVPeBvpn2qDBdQY7Cd
         tX8YFEgpWe1W4pWOMz/jMxIeikOWw7YBmURN1ECN8arFMhkURlAdpfl2ldv76kTrMc00
         BSvxZNrjNw0iwuuJpIffV6ocmxLki6iaDZgBd1jmm5kxbOMo44i7a5hjiqWG8LZnWXB6
         zqig==
X-Google-Smtp-Source: AHgI3IZ3Sg2dYwry0xnVd2kkIyO7BtojbITxcGUNeN+yUGMttFQ5WIUzBHvDRJs1jhkxC23VOVoJ0Q==
X-Received: by 2002:a63:1408:: with SMTP id u8mr414287pgl.271.1549922820192;
        Mon, 11 Feb 2019 14:07:00 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id w185sm16408609pfb.135.2019.02.11.14.06.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:06:59 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtJj8-0003Pd-P2; Mon, 11 Feb 2019 15:06:58 -0700
Date: Mon, 11 Feb 2019 15:06:58 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190211220658.GH24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:52:38PM -0800, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 01:39:12PM -0800, John Hubbard wrote:
> > On 2/11/19 1:26 PM, Ira Weiny wrote:
> > > On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
> > >> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> > >>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> > >>>> From: Ira Weiny <ira.weiny@intel.com>
> > >> [...]
> > >> It seems to me that the longterm vs. short-term is of questionable value.
> > > 
> > > This is exactly why I did not post this before.  I've been waiting our other
> > > discussions on how GUP pins are going to be handled to play out.  But with the
> > > netdev thread today[1] it seems like we need to make sure we have a "safe" fast
> > > variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
> > > do that even if we will not need the distinction in the future...  :-(
> > 
> > Yes, I agree. Below...
> > 
> > > [...]
> > > This is also why I did not change the get_user_pages_longterm because we could
> > > be ripping this all out by the end of the year...  (I hope. :-)
> > > 
> > > So while this does "pollute" the GUP family of calls I'm hoping it is not
> > > forever.
> > > 
> > > Ira
> > > 
> > > [1] https://lkml.org/lkml/2019/2/11/1789
> > > 
> > 
> > Yes, and to be clear, I think your patchset here is fine. It is easy to find
> > the FOLL_LONGTERM callers if and when we want to change anything. I just think
> > also it's appopriate to go a bit further, and use FOLL_LONGTERM all by itself.
> > 
> > That's because in either design outcome, it's better that way:
> > 
> > is just right. The gup API already has _fast and non-fast variants, and once
> > you get past a couple, you end up with a multiplication of names that really
> > work better as flags. We're there.
> > 
> > the _longterm API variants.
> 
> Fair enough.   But to do that correctly I think we will need to convert
> get_user_pages_fast() to use flags as well.  I have a version of this series
> which includes a patch does this, but the patch touched a lot of subsystems and
> a couple of different architectures...[1]

I think this should be done anyhow, it is trouble the two basically
identical interfaces have different signatures. This already caused a
bug in vfio..

I also wonder if someone should think about making fast into a flag
too..

But I'm not sure when fast should be used vs when it shouldn't :(

Jason

