Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77A08C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C9FB20673
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:11:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="m6czQJ5P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C9FB20673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB3B86B027D; Thu,  6 Jun 2019 11:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A64D56B027E; Thu,  6 Jun 2019 11:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92C286B027F; Thu,  6 Jun 2019 11:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7666F6B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:11:51 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g30so2292904qtm.17
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:11:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nICKSnPmhBfa22i4P79WKNgPDXW8CuF04HSSgn2bQQY=;
        b=fC4r6bBpWHk1Xi2HfukmZexO6nQCr7BcwQW8WEMapEFKK9yrzChC2h/Lh/gBNeljoc
         hDvMlFWr7sY2xvpg/enGctEAx0S8xE00J6sqo8rsDQbybNG84+XvjlCGLieUdKcjbvoX
         2AKO6DFatDxc2zUWDH1rLTnccMgIIvybIQSg8NlQGcH3zKuk2w3C01zqpF5qeYcwlzrR
         yHH05b7bzLKkvC+qpah+UQbVk/Oh4BQHPTCqt1KE0we3IW+aNGLLClL6LA0R865VSky3
         4RJfx0ANmEe3zxrELBgJ+xJiEv6KQnpa2AL6IMO42Q7xvxlBnA+4Zfjoc1z7TIiXX66Z
         jwYg==
X-Gm-Message-State: APjAAAX8cgO94v0quICgeKdY/erCMcGrSy6cYkHIUQllXFnfrIbLVR/z
	T31JDa2nag58oyJQNBo7p1qjB8xfufLR1un0uGNVPUaOdoIVdZ3TAwo/uURlXVsidToGj9udq95
	+xOUWfgEYLlxMALumHuUkqnKK3f+BH2BbqSABvxxSrCzhE98lEgvBW1YkQP06V1SHkw==
X-Received: by 2002:ac8:2e6a:: with SMTP id s39mr39521007qta.201.1559833911224;
        Thu, 06 Jun 2019 08:11:51 -0700 (PDT)
X-Received: by 2002:ac8:2e6a:: with SMTP id s39mr39520936qta.201.1559833910385;
        Thu, 06 Jun 2019 08:11:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559833910; cv=none;
        d=google.com; s=arc-20160816;
        b=isvKVOiLAhdg5UYv4htn+g7MVRzUg7YKjEH8LJaK/zyoP54YPXB39rFWzS87dKdXok
         6UJ/yLeVOLdEZecddqBY7DYtaOiHNiymaBO/YFTT66iW3maChhEAxq2BXU491CinOFkB
         rlZJr5VPStftDaPbJPG1B3XFPf1DtyB2utLB/xCYMda58NZkhB4fKieulET4dfq4VRiT
         zNchhZds4NiHJwXVA0u1zTbFilSCQvbwhdwBcJ67C/V+tnC0oTXLbti6t8xiic2y4L2r
         H4DzgDWHESbUPe3YuYJEqlGZDYHcYeCpq2Tsu8s+9/kpzcExRImHS5kpC6bibna0wKFg
         H+ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nICKSnPmhBfa22i4P79WKNgPDXW8CuF04HSSgn2bQQY=;
        b=Lcp8c5uwXCwqeE8YWtnXipSZMR96RoIj8EkKmeZTlOT4M4VKyhNNIRs4V/XHxHw02p
         oyRoGxKot4SAyD+Ge1VqsbX2s4TqUYzDUu6GLribgfbYlsvmidQ6NwItoiJH/xQWW4tR
         s4BRn2QmsqyqxOWGLwmTm7ol0ls20t1DcQRma33Vr10cqIJdlzrKyFtQvL7uxrJeVmSj
         H56Q/DPx9/tRlG712l9buXiKC0PyO8ahRUAiWB+xId/bnfHmDm6yvGuYn4E70tEHzLaW
         miHHWOk2fNyyjorZHaW32vxP85nGfz3oWK6BH0rAwEMUgIUurgH1c496qSkZAEQbUweH
         fXRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=m6czQJ5P;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q127sor1118249qkf.13.2019.06.06.08.11.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:11:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=m6czQJ5P;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nICKSnPmhBfa22i4P79WKNgPDXW8CuF04HSSgn2bQQY=;
        b=m6czQJ5PAH844WTRtxLEbxKdvBRpUyjJ0AXdDvZR7cSPSTSfR0mirorSbQ39kRU0M0
         dlTKVWQZJRKyKr3r9nSGUcX3MxNMl6r5VZklgbN6Mweyj1EtjYhkSrkr4JxFftGsZpNt
         3ZDbavY5Cs+QqUVJs3M5I+3Lhk0eA9yqm1rccZxh9/BIkQewigTSmoqX1o76zpcZKscf
         KAibnHC/hYQptEH+0I8AS+ZBjoop1mlii54zOfw6YJU/mAfvM08P/0KgEivUYH1Py7hB
         xR+V0om86kGyfHe84fNb6bLkzqCvdC5NAHSrbbH0UaqJbJN6jnwXBXFdjVUXcwOC/QXo
         VNcA==
X-Google-Smtp-Source: APXvYqy5ivrotzxuZe8QOGBrIM3TV0bm3INrqHp1amDu/ICmE/db2M65ncX/se2X7oSEYpSC21pIxQ==
X-Received: by 2002:a05:620a:142:: with SMTP id e2mr22505206qkn.191.1559833910114;
        Thu, 06 Jun 2019 08:11:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 39sm1244005qtx.71.2019.06.06.08.11.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 08:11:49 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYu3R-0003Bi-8D; Thu, 06 Jun 2019 12:11:49 -0300
Date: Thu, 6 Jun 2019 12:11:49 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "jglisse@redhat.com" <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 0/2] Two bug-fixes for HMM
Message-ID: <20190606151149.GA5506@ziepe.ca>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510195258.9930-1-Felix.Kuehling@amd.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 07:53:21PM +0000, Kuehling, Felix wrote:
> These problems were found in AMD-internal testing as we're working on
> adopting HMM. They are rebased against glisse/hmm-5.2-v3. We'd like to get
> them applied to a mainline Linux kernel as well as drm-next and
> amd-staging-drm-next sooner rather than later.
> 
> Currently the HMM in amd-staging-drm-next is quite far behind hmm-5.2-v3,
> but the driver changes for HMM are expected to land in 5.2 and will need to
> be rebased on those HMM changes.
>
> I'd like to work out a flow between Jerome, Dave, Alex and myself that
> allows us to test the latest version of HMM on amd-staging-drm-next so
> that ideally everything comes together in master without much need for
> rebasing and retesting.

I think we have that now, I'm running a hmm.git that is clean and can
be used for merging into DRM related trees (and RDMA). I've commited
to send this tree to Linus at the start of the merge window.

See here:

 https://lore.kernel.org/lkml/20190524124455.GB16845@ziepe.ca/

The tree is here:

 https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm

However please consult with me before making a merge commit to be
co-ordinated. Thanks

I see in this thread that AMDGPU missed 5.2 beacause of the
co-ordination problems this tree is intended to solve, so I'm very
hopeful this will help your work move into 5.3!

> Maybe having Jerome's latest HMM changes in drm-next. However, that may
> create dependencies where Jerome and Dave need to coordinate their pull-
> requests for master.
> 
> Felix Kuehling (1):
>   mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for non-blocking
> 
> Philip Yang (1):
>   mm/hmm: support automatic NUMA balancing

I've applied both of these patches with Jerome's Reviewed-by to
hmm.git and added the missed Signed-off-by

If you test and confirm I think this branch would be ready for merging
toward the AMD tree.

Regards,
Jason

