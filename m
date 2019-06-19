Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B967C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B795E20665
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:54:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k0xGPIpK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B795E20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51D2F6B0003; Wed, 19 Jun 2019 07:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6E68E0002; Wed, 19 Jun 2019 07:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320D28E0001; Wed, 19 Jun 2019 07:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1F756B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:54:28 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i3so9712638plb.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:54:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZMXqazDQazrKKSlfFDYmUFpilZIibnGHtDfXdH5dHKE=;
        b=sKmiCj5RXX5yfDvybqYp/fD8PSu+A/bS1ljaFg7uc253bElWDhfsFMr00GMZw9G2Y3
         2olz0wIDDrwE8ITvDxLRpvYChJaydPo9eR8bSFSeHDa+nn+16dyXS0NK80heBKKbA+2q
         y9ox2Q/tT24EXsM7HNNebgaJ8Zs3FSkYfIms2DUYtpaq0zhdo6ptLNMxI8XWjbWcTGw0
         oQYW8JyFQTC3OMk0MxAzSa2nRgu56gdjDTVUe9yBWAGeqjTgl6J7MRG9EoB2ScBv+/oX
         qTTHGtbhH3CjgPcTmBK0UjMmUEMUNFleTUC1/QbS/+Mwgg94Ea0bSW2PsuHuftSCDpYA
         9oNA==
X-Gm-Message-State: APjAAAX1q/1dgLe0l+PZc9j1kpu8bNnIdRwXSbg4ReBzfIkWh522aavp
	7SWSwhM5V2lfD7sIkKPaAFhS750r5jIJDWz9ow0pEC9swtsWtYFdaKCCZSXqMBH9GH0qGL4Pcd0
	xiCa12fU2u7kjZsbuiHDYr1Oxo8d1280w1uH7L1Bnu99UZptgDg/gW96bTfBjgVwUAw==
X-Received: by 2002:a65:448b:: with SMTP id l11mr7272046pgq.74.1560945268480;
        Wed, 19 Jun 2019 04:54:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPQlgGTEUvqJ9BYT54KiTy86Mxy3gT8nyjbatgt6goUXvVskpOFWg+gSoT/aIz/RelQxXZ
X-Received: by 2002:a65:448b:: with SMTP id l11mr7272013pgq.74.1560945267725;
        Wed, 19 Jun 2019 04:54:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560945267; cv=none;
        d=google.com; s=arc-20160816;
        b=LKJbV9ga+K4S6H9bdS7UT6biRfZy1QDgMHOshXwvqvYvRTauoK0JBq4Iuq0ogOTMXN
         RMconkIowvqv2asNlrTfMQqEhyrrCUk10ifXGKfFpZEB8+en+7sxpEN/uEfhbK2MLfxY
         WeEsU457XTkOm7Y9pB5pY+WnOLfwfhpFx/5ydJbLyBCXp5a8WHBvLqIeILmjVpvONEAx
         s4tWCEVIv5XQRxgotxrdSoBWYp47+qo+EYmnfpyQfiL0lOEx4IVNir+Q8yV6dqzQzEtg
         P2hrxlIZ0F2+T6N3YLQpoWZurZdHYjVUojVXI56P5wG29rGYx3km8SF+jAeP5N7zCrWO
         yxjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZMXqazDQazrKKSlfFDYmUFpilZIibnGHtDfXdH5dHKE=;
        b=PF5Cd4X89uuZRD9AG8NaDiIEmp3wh+v0+UlKehRMeO3IgM0fNluAtTzdaAN03Q+lpX
         JpZnV1E8cnuyUMOOrP3uCqphJisLglXxX5C5MQFB7/x5IqxbtnRJEuiB2QV0taskXR10
         9+ylZklwBs52Azfd7/QsQ9vHzzL9ubXPkBAxHD4TcwEXnezWd6dkHWVK9FdFQgEfy94H
         FP1TnVuVdojyqz7LzXXBVb1147RbOa4QOt5IqgJdIeWI0K3PTVp4ZGOTaDNGSp68KvJi
         AbKl0WJkR2Qta8G7Hh8Bf7q5Yod9TRVTNnjuPUpCSP0zFQIkQOAxQCZQnzOXhDfyUht1
         1MWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k0xGPIpK;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l8si2919740pgk.528.2019.06.19.04.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 04:54:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k0xGPIpK;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ZMXqazDQazrKKSlfFDYmUFpilZIibnGHtDfXdH5dHKE=; b=k0xGPIpKWDBE1uNoMaB6BA8Rj
	J14iEyyGUyAtE4tSq7WhsgKGCuRN9es82gkxyNp9nSgEg7726Fp5Q6j8njKnjZw1TL2kIzgkhhW/B
	KNeWruWnKckQqgS6VEq6LV0yJnSYlTho5MCkjXZAbyoi1aFDSWffvabKy9p1PRMW4YP8nhrqvgXZe
	EB7qiBw+50HfBshE8hvrxSxfpGqjP4LVX2zgDyH8wUfEe3zTn3IN+1WKe21I1yyVcdCz3X5t8c3G0
	chcINAU+cS2mR0PgkXz7kwPZ6jT4aWdw4B+PfSbOUGeJagOxjTH/Ku4GUj/Cvtahzx7Xje2r6IiHm
	EK+xNL6wQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdZAU-0004pM-0A; Wed, 19 Jun 2019 11:54:22 +0000
Date: Wed, 19 Jun 2019 04:54:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the
 lifetime of the range
Message-ID: <20190619115421.GB19138@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-7-jgg@ziepe.ca>
 <20190615141435.GF17724@infradead.org>
 <20190618151100.GI6961@ziepe.ca>
 <20190619081858.GB24900@infradead.org>
 <20190619113452.GB9360@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619113452.GB9360@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 08:34:52AM -0300, Jason Gunthorpe wrote:
> /**
>  * list_empty_careful - tests whether a list is empty and not being modified
>  * @head: the list to test
>  *
>  * Description:
>  * tests whether a list is empty _and_ checks that no other CPU might be
>  * in the process of modifying either member (next or prev)
>  *
>  * NOTE: using list_empty_careful() without synchronization
>  * can only be safe if the only activity that can happen
>  * to the list entry is list_del_init(). Eg. it cannot be used
>  * if another CPU could re-list_add() it.
>  */
> 
> Agree it doesn't seem obvious why this is relevant when checking the
> list head..
> 
> Maybe the comment is a bit misleading?

From looking at the commit log in the history tree list_empty_careful
was initially added by Linus, and then mingo added that comment later.
I don't see how list_del_init would change anything here, so I suspect
list_del_init was just used as a short hand for list_del or
list_del_init.

