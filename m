Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E246CC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:52:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86DD5207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:52:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86DD5207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA45B6B027A; Thu,  6 Jun 2019 11:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2CAE6B027C; Thu,  6 Jun 2019 11:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1B1B6B027D; Thu,  6 Jun 2019 11:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A03E56B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:52:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i4so2282563qkk.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:52:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jbS+6IWuxg7hsF7ioMC/EL/hX7wZCyx4tzlwgct91Kg=;
        b=cx4TBL4oF/n4JPeulJWY5XcC0H96lx63HPyC6lFAPdt7U20aXfxJumVNEXTgoWtRiw
         SLcZ1tQSc3isQrcLWs1RiNMGzZEGOc8dwnqwLDzY+/NYVcYwU3fd+qWeBJ7JMrjINBvk
         jDUIIP/cwmalCmI6ROg4FZDTOW71AeZnKLKcLMV/x7RpODmxfX1YpZz6OMUPhAMoe2t3
         745IAf/cv4sLWu67q/c+bNbsVuKSF576LTre4UwURmBPZUjXqn7RcFXyEFS8pubDDFk8
         YMthy15sPJ7A5H5GvRJrd1FAZJjUdtmMPv7wXvN6JID8swKV+8W1IHEPAvYKtbtMYC1Q
         +PlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW3xy88XsxSPlYAKA8jWDO0pIJvXBKdlxafziCKCRhtcGOe5F86
	jzjkR/oJXKxhAObFAWMFBTUdBFR563joiQDQI010vDgEtHXCYTtoaP73cI3vaclw+ZwzyhdllgB
	2E8epqb3BbzxsmiRS51c4/UixN0fmPk6X63TaSmI1u8lVXD2sGb5++cJof3gTIZqYAw==
X-Received: by 2002:a37:660b:: with SMTP id a11mr39347312qkc.342.1559836351415;
        Thu, 06 Jun 2019 08:52:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM1iPd5Wr9gEBJqzuMQ36vKFTA1E4GBBNSy/Ltv7+kIz6gbrkxx9r49u+9Ug7JPTc7xScz
X-Received: by 2002:a37:660b:: with SMTP id a11mr39347257qkc.342.1559836350789;
        Thu, 06 Jun 2019 08:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559836350; cv=none;
        d=google.com; s=arc-20160816;
        b=ZU3OfNnxAMhKikqPaa6403R7LyyBbgAr2yZLDulcmIzmFPiZEBvD8Q9sY3zHsSk0zZ
         0CNlaPha3zzcoPjLA/RMrDi4w6DRDl9L9UgC3lwe9pNmL9H4hawPAy3NLe+uZzN9wOxV
         4xLkVjRL2oPFZR6v/LiuE18ChNuwQqQ5DFMuRk8fDaK+0gkQVuDVGOcfBoBRiotPAHuD
         3Je0fHVy6mZwrneosoVJ87JMiC5K849D1VrnpFfRYnsEN555yccbR5mpSQxGYQSw4iLN
         CBPFdAjVbepqGXIz82UzjpnqBU+hvrCRWSeQSYyhMIwEvzn315OjWcNTK/eerWMlU2OP
         +YlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jbS+6IWuxg7hsF7ioMC/EL/hX7wZCyx4tzlwgct91Kg=;
        b=QLky7LimTMX7hKcF/uj3v9MaJer5hMd9bGyFovlu4O6JrkgvtvzNwhcNesbIzPabVA
         qZBWKFZih12hbbQf5hnRd8Mrw8buo5QzhiMAZIdkWnxLPjKNDv5g0aBlDNd3Esq0mEha
         w7D7M/rSo/P7siG3yDZ1cZKkNAQhilsRUpW1MZuNjQ3A3WFMkCoeTGXfjiI2N7dC8lOF
         v9BrmMCK8t8//3r39/hEApWJsaPg+OtrUA21wjr4KfiPmGghwsddvOc5KDLquBdiRSbv
         1pk5dkZYJARxl5uiaAkwPWz39Smk8FZ4TgKVEfc6ozIV/4InZrEUFQVGktw+l4L12oPu
         i76Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j24si2215518qtj.383.2019.06.06.08.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 08:52:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9FBCF88E57;
	Thu,  6 Jun 2019 15:52:21 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 344227BE8E;
	Thu,  6 Jun 2019 15:52:15 +0000 (UTC)
Date: Thu, 6 Jun 2019 11:52:13 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Message-ID: <20190606155213.GB8053@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
 <20190606141644.GA2876@ziepe.ca>
 <20190606142743.GA8053@redhat.com>
 <20190606154129.GB17373@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606154129.GB17373@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 06 Jun 2019 15:52:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:41:29PM -0300, Jason Gunthorpe wrote:
> On Thu, Jun 06, 2019 at 10:27:43AM -0400, Jerome Glisse wrote:
> > On Thu, Jun 06, 2019 at 11:16:44AM -0300, Jason Gunthorpe wrote:
> > > On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> > > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > > 
> > > > There are no functional changes, just some coding style clean ups and
> > > > minor comment changes.
> > > > 
> > > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > > Cc: Matthew Wilcox <willy@infradead.org>
> > > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > >  include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
> > > >  mm/hmm.c            | 51 ++++++++++++++++----------------
> > > >  2 files changed, 62 insertions(+), 60 deletions(-)
> > > 
> > > Applied to hmm.git, thanks
> > 
> > Can you hold off, i was already collecting patches and we will
> > be stepping on each other toe ... for instance i had
> 
> I'd really rather not, I have a lot of work to do for this cycle and
> this part needs to start to move forward now. I can't do everything
> last minute, sorry.
> 
> The patches I picked up all look very safe to move ahead.

I want to post all the patch you need to apply soon, it is really
painful because they are lot of different branches i have to work
with if you start pulling patches that differ from the below branch
then you are making thing ever more difficult for me.

If you hold of i will be posting all the patches in one big set so
that you can apply all of them in one go and it will be a _lot_
easier for me that way.

> 
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.3
> 
> I'm aware, and am referring to this tree. You can trivially rebase it
> on top of hmm.git..
> 
> BTW, what were you planning to do with this git branch anyhow?

This is just something i use to do testing and stack-up all patches.

> 
> As we'd already agreed I will send the hmm patches to Linus on a clean
> git branch so we can properly collaborate between the various involved
> trees.
> 
> As a tree-runner I very much prefer to take patches directly from the
> mailing list where everything is public. This is the standard kernel
> workflow.

Like i said above i want to resend all the patches in one big set.

On process thing it would be easier if we ask Dave/Daniel to merge
hmm within drm this cycle. Merging with Linus will break drm drivers
and it seems easier to me to fix all this within the drm tree.

But if you want to do everything with Linus fine.

Cheers,
Jérôme

