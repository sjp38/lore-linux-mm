Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0AA8C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:40:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 927DE2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:40:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="B1ITolKJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 927DE2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 457598E015B; Mon, 11 Feb 2019 15:40:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 405A28E0155; Mon, 11 Feb 2019 15:40:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D4F8E015B; Mon, 11 Feb 2019 15:40:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0E7D8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:40:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so182454plp.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:40:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nmT5nD2I7+KtQoUhHdkWUj1QqpObX7iHadIUM12uKwc=;
        b=oHi8wuVSDJKhV+ydvdi2VdTeZH7t/GTygY5oBzMn7U7lCK0FnDfOMs0sFym4rixOWW
         jvmODEBAyq04aELm318pY4LPvKQBUa7jzY256S8izMkmX3D6gmdfmQGnIIkd0g6/FwzQ
         CSTVd4b3K+dloBJp/E6rKQ0Ru5Qm6HDnD43WgD/0Jk6gmMHkSHnuI4fqDCOM7T2miP7g
         onM1xWpHPkZtvgIne+jqBYHF5RQEHuKbN2Uu7ZqExk2teO3QywqdSM4bsaI71ITY+gZy
         YtlSTxnxNr+whOZZpoRevSdCicPRZsTTTnLd5zu0P2dLkcY+lv1D05Uhk4DDGNIR7yOX
         KpeQ==
X-Gm-Message-State: AHQUAua51RYsaokFto5U2rTUmsoEACGUhKRVnzrkSg+6NopwxwWBQvsL
	Q0eL7MSSiRsUS+y4l0HJOkD7/mTGP3wXsots3OHgWZyuXeqoM+6a86h036vAtHLdCxlFE0XD0Xf
	U/u7SrgWwRE0mJbUE+cVeam1025hX3CXu+890flXw3OregPbifB7XA7Jdj8DE9WQ3eGjeXiNnfD
	fCNlU7KeAgqHvpiKcXABkmKVHtinm/WoPflk41ryiLIzx+8TTnXFkaapZ4aEkmEqES2Ts+L312i
	lN9+CGTqnjAUjhtzG8ULhBLL299Vv2fsZIVwYj9hEHYcMEJAvYK7b1Kt6iVP5n1ci5Fu5Cl99j3
	DvaHjMDpk+fNQgSWn4jXfct99rcmaPNuvS0TC2/DlNaIAqBiYBvAWN6lOLg1mXT/OyEDhODZrR9
	J
X-Received: by 2002:a62:4181:: with SMTP id g1mr105162pfd.45.1549917651599;
        Mon, 11 Feb 2019 12:40:51 -0800 (PST)
X-Received: by 2002:a62:4181:: with SMTP id g1mr105111pfd.45.1549917650975;
        Mon, 11 Feb 2019 12:40:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917650; cv=none;
        d=google.com; s=arc-20160816;
        b=k3cvqb+K8MuSPWDKFdPHyBy9cgGQsaV0q91bOwFMzerc/ZuJf5DiIKYMSkqSf2c50T
         hC1E717oHLE1aIimTo8dX5tXJbAfO+9KTAv37MucUbQn90FhtCfyuP8imQWKava/WBPs
         vol/7PwZolgCj+pTnZezMIIMypmTbNuYMT5cy1r9U7la2P83WumxzMQo4g+nrMg2VQl/
         PquJJR3eU4j8EQtZKu/lkaBGnP1P30RGLUmjmM6FZKPGbR/ryUEqsVLeCWSAdfo/IFHV
         TYSXFjMxNqmb5DfTflfxPhiCfS1BFO9BIBsWfxlonoBUraFonUon/W20ZmyEYV4xbYlU
         EtVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nmT5nD2I7+KtQoUhHdkWUj1QqpObX7iHadIUM12uKwc=;
        b=zqOgc49d1VDqB1tC1pgJCokUoIRBOOwwa/p6+TPLQky80740F0jF3HyvIWAKXFEVOy
         5I7j2FaKy4WDxp7Jj6Hvp1n89NYL/lNIn3D9wDRa6N+g00o0JE1PZOCYnhIIf8y33LcR
         4MUMJO7By2Ny/6G5YsOrGjRc8JnlXmSyNPFzpT/pa0XAdD6eTtqVturUrCPXL0UNB/wa
         A5y89/zX8YfC7MHL9JI85zcXxPJKtwHMA1hz9NLmiFhGR0TsX38Bczl6gAj1VbdTP4bH
         WPJrl1PftlF40MDRHlfssLOKwlw6GIZOS4Kly9vPYI5iZGOY0wUYtfSYNNREfXo7CErw
         woVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=B1ITolKJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w31sor1315120pgl.85.2019.02.11.12.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:40:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=B1ITolKJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nmT5nD2I7+KtQoUhHdkWUj1QqpObX7iHadIUM12uKwc=;
        b=B1ITolKJ1NS4xWfX0ir0qavniH14XixPsbTXipQBHAPuub4IrbOyhFf0bD4uP6LHdP
         yS1+dqUDzMVRvcvJyextDm7A370NcmuJxo2Gaef7ePt0XpBqOhxFxX2iUaAV1qVgKD0x
         8m6rTHR7HFmADoOKyZvx1yyE1yoP+SI6StmEGtj2HeWi9jPom6Dy0b1cc6gXri860E8S
         kQHnEctpa1aRKDiRprtEqWIL+49NLbsmfIpDYRnY35OR5Uu8inRWQLauyDfY8jHwPyGK
         jQ5I0OxQrq32U5sCooP0X45Cvj7bJfLsaMeLrt/1ey7bbz7qywYulUwwn2Yi6R+AfX6q
         36Uw==
X-Google-Smtp-Source: AHgI3IarME8mMwsDqp9azcXs3o7IJfhcXGKpA1KdQX8w0bLUJH9217uYklkSnkg2apnHfTrwcJGclg==
X-Received: by 2002:a65:5243:: with SMTP id q3mr66002pgp.385.1549917650694;
        Mon, 11 Feb 2019 12:40:50 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id m67sm19694020pfm.73.2019.02.11.12.40.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 12:40:50 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtINl-0000l1-L6; Mon, 11 Feb 2019 13:40:49 -0700
Date: Mon, 11 Feb 2019 13:40:49 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211204049.GB2771@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:16:40PM -0800, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> NOTE: This series depends on my clean up patch to remove the write parameter
> from gup_fast_permitted()[1]
> 
> HFI1 uses get_user_pages_fast() due to it performance advantages.  Like RDMA,
> HFI1 pages can be held for a significant time.  But get_user_pages_fast() does
> not protect against mapping of FS DAX pages.

If HFI1 can use the _fast varient, can't all the general RDMA stuff
use it too? 

What is the guidance on when fast vs not fast should be use?

Jason

