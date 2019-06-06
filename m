Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA880C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78F7120868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:56:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78F7120868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 116CC6B027C; Thu,  6 Jun 2019 12:56:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C90B6B027D; Thu,  6 Jun 2019 12:56:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF8756B027E; Thu,  6 Jun 2019 12:56:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCF6B6B027C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 12:56:25 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v2so2475209qkd.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 09:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=XanYpsm1CWZYhj0Npx4sX2Z3gqoCjlwfxhEhwKlFCgI=;
        b=YCq8Q5w7O+3L06fge9S8Q8OtdC/8OSvXyixZGzhahWrcJkFsYBxGJZAH8So8GiHm/F
         EdDHutbdbXyfcrNnUYMAUjxOCb6GrFvl3e0i+3AGV8xOlvZDPgWE4J7iG774Kw7PDD7E
         MirhqrwpFMh1Dd7iv4WY4m8nA70kFjtNA5X+lwuQG5IAHfQ3rVv36IXFh2dEVyNnhhHx
         r44lndBx8yXDfhJyKaA+0yHS6rdexleAWBU79H7KE9wY/ItIDDX4dSwE0MGwAlg4DShm
         WyDr+RjYDj/+w0GRugyhcbfNQknQmoZHWIFjnqEgzIFFBn6whi6hLfdKpdGYNf3vniEZ
         i5Ig==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 216.40.44.48 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
X-Gm-Message-State: APjAAAXYZaEYfOV0pPyA1Li/6g+iU+1URtdAqpyrPd9ii7WOaJ+Nqdng
	AZpKdgc0je0z7yO1VwwwYQcvCfkLBan/OsE2BmCuZJlgxB4sXvRU6ckr0yG9uljPXYc8A5OyfqM
	9W8PMI1WzXk2TtzwF/v3DXys7ofw7202uvjaM6O110Fo8SlqLtjl+g+IkxCS9q2I=
X-Received: by 2002:ae9:ec10:: with SMTP id h16mr20814266qkg.215.1559840185609;
        Thu, 06 Jun 2019 09:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkAAvNlXllZTr/Iow1xjeu+S6zMD5AgON4cUJsTiyLAgxJ9dRaRVnQ2B1gbMZj8vUFp9Wk
X-Received: by 2002:ae9:ec10:: with SMTP id h16mr20814225qkg.215.1559840185023;
        Thu, 06 Jun 2019 09:56:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559840185; cv=none;
        d=google.com; s=arc-20160816;
        b=gwTcy3BGf8YnfFKU/2CaQbqTh6H4eQKK8zCoGMEojzYhoiAz9aKnPFNaLOJnoeLqk+
         8Sl4q7pbitnmGNYhMTj/LpYFN7nbnz/Ttm7Tl1EQD7+qz9M3eOeNdjR8xDha+1h2ij7S
         ZMPsJmJ+26SbUm6yDs1dK9vGME8DXJj1S3mhdJQGH4EBUNzSAHGrewe06bzD9u5lolx2
         GS7STA/zo7SoSFGvSEYl8EBZ7F1X6prKdEBIwacBaaCcmkBrdOP1zhCe7J6Lc0MvCyX9
         jfcQNiEcVsJUs7FQj2fD9qURXngCtk7L9E0oenzksmUpmxyT7DnpKw4Sgr/TfzE00DlH
         iBZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=XanYpsm1CWZYhj0Npx4sX2Z3gqoCjlwfxhEhwKlFCgI=;
        b=tBt17H9rDl5AzYqVTAk7MJglOcrQ9IZLkhhtFIu07YVYIt4LTUamOkSDarJr0Pi6SC
         xJIiLFHUaPvy29in8opa+rWBJKGS7E0QTAQzttZNKAoR1XMVDqRiTeYF0ZZn/o4wmDIx
         +CIPKdQggmyR+7f1tW2iBDIWPsr/RmdyE7/IHjVije9I6NhGKBwH17iTtrCFjd0v8TV9
         PvalRQ1U8z0vJB32+GckSmrKtfQ2ACAeF/HQTSJGAdsk/lWuAJ+rLXvzrnu0/KtjBChp
         CjXShyNKVaUy5BFxtfPXnGhxL6+RVxPDUsKKgGBsHTjwdtA+wAqK/pMTu2IdhR8o5fYC
         39hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 216.40.44.48 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from smtprelay.hostedemail.com (smtprelay0048.hostedemail.com. [216.40.44.48])
        by mx.google.com with ESMTPS id p123si1818876qkd.257.2019.06.06.09.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 09:56:24 -0700 (PDT)
Received-SPF: neutral (google.com: 216.40.44.48 is neither permitted nor denied by best guess record for domain of joe@perches.com) client-ip=216.40.44.48;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 216.40.44.48 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay04.hostedemail.com (Postfix) with ESMTP id 58A02180A8CDF;
	Thu,  6 Jun 2019 16:56:24 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: nut86_1a1703edf4d45
X-Filterd-Recvd-Size: 3676
Received: from XPS-9350 (unknown [172.58.75.111])
	(Authenticated sender: joe@perches.com)
	by omf19.hostedemail.com (Postfix) with ESMTPA;
	Thu,  6 Jun 2019 16:56:19 +0000 (UTC)
Message-ID: <8ce6c5322918828db16134b45d7b0d6b208f943d.camel@perches.com>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
From: Joe Perches <joe@perches.com>
To: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
 John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>,  Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
 Matthew Wilcox <willy@infradead.org>, Souptick Joarder
 <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 06 Jun 2019 09:55:49 -0700
In-Reply-To: <20190606155213.GB8053@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
	 <20190506232942.12623-3-rcampbell@nvidia.com>
	 <20190606141644.GA2876@ziepe.ca> <20190606142743.GA8053@redhat.com>
	 <20190606154129.GB17373@ziepe.ca> <20190606155213.GB8053@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-06 at 11:52 -0400, Jerome Glisse wrote:
> On Thu, Jun 06, 2019 at 12:41:29PM -0300, Jason Gunthorpe wrote:
> > On Thu, Jun 06, 2019 at 10:27:43AM -0400, Jerome Glisse wrote:
> > > On Thu, Jun 06, 2019 at 11:16:44AM -0300, Jason Gunthorpe wrote:
> > > > On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> > > > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > > > 
> > > > > There are no functional changes, just some coding style clean ups and
> > > > > minor comment changes.
> > > > > 
> > > > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > > > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > > > Cc: Matthew Wilcox <willy@infradead.org>
> > > > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > >  include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
> > > > >  mm/hmm.c            | 51 ++++++++++++++++----------------
> > > > >  2 files changed, 62 insertions(+), 60 deletions(-)
> > > > 
> > > > Applied to hmm.git, thanks
> > > 
> > > 
> > > Can you hold off, i was already collecting patches and we will
> > > be stepping on each other toe ... for instance i had
> > 
> > I'd really rather not, I have a lot of work to do for this cycle and
> > this part needs to start to move forward now. I can't do everything
> > last minute, sorry.
> > 
> > The patches I picked up all look very safe to move ahead.
> 
> I want to post all the patch you need to apply soon, it is really
> painful because they are lot of different branches i have to work
> with if you start pulling patches that differ from the below branch
> then you are making thing ever more difficult for me.
> 
> If you hold of i will be posting all the patches in one big set so
> that you can apply all of them in one go and it will be a _lot_
> easier for me that way.

Easier for you is not necessarily easier for a community.
Publish early and often.



