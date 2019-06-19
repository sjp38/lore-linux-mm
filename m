Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E9E7C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:19:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB8A820823
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:19:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tf5cAthD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB8A820823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98F056B0006; Wed, 19 Jun 2019 04:19:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9408E8E0002; Wed, 19 Jun 2019 04:19:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E14B8E0001; Wed, 19 Jun 2019 04:19:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 487606B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:19:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so9410396pld.15
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:19:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Oj2mVxSa+2J+fkcSLZJgmIgirExhWFgh1cb5vCMP3vI=;
        b=EhM1c1y2ESoorC1tBPetW+brGDcOe95yHa553NIX4kjQJtNojnFRpKEfPRT74EXXK8
         Brxc/5V4u+pmjtUt8qJ//f7VK5sfcN2yNFDjxXIDfyQtlTxJv0jJGZ4myAGjmzxCP35A
         Al0y3kxQxW2/yBg5vDCriB8lF9hG8XtmJuMr5Ievs9nzifY1q2BS9Lz+v9m9G/EW6S6g
         VQXiXig1uNe88fOMbrgcF9sBkqpitvKUqqK0eVmTetEZ8hHNqr9IFu9UTRBxJEOYnlPP
         xHOAo12HakRPpqbMeEEjlZmzzPCnZLjdbgEwTn1cX5xgb1kFx+K6PpycIYkE8w+KqoZj
         0dOg==
X-Gm-Message-State: APjAAAWUh3yvD1tMKIjn0BoX36fSl6lE4H8m7wwGuyx4048zQvDJLaXa
	VkuFbG1f1IdXhu/MOOiluvZwIRnstniOhVhMEyq/gYuSH4VspRquVjpc29qzP7HOJ6BiktVQICi
	AuSTuihQFUy6aJlAUv0SOh5uX2uCR5mUqUNCRLlZQ/WUOxE275X5NMxGPAxbDiw6VDQ==
X-Received: by 2002:a17:90a:208d:: with SMTP id f13mr3315227pjg.68.1560932392007;
        Wed, 19 Jun 2019 01:19:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhz0CABSt+wfsAjkhFemywdNMHsanJjZsFBp88VNUEOS04cE6Ge3eAsQTitneubIVymyPY
X-Received: by 2002:a17:90a:208d:: with SMTP id f13mr3315186pjg.68.1560932391367;
        Wed, 19 Jun 2019 01:19:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560932391; cv=none;
        d=google.com; s=arc-20160816;
        b=XC0Gi+jOax8a791jv6JBWtUrvfbSFksr8X4/YIAS/nTNQtdUtyoafbYbkaRluiUWNc
         xmuxp3x3+9HYUMjq3RN1FysM7zEF3dbALgYBOZZWQNYE9AtMT7ARWPQ/P6IqgSBfljCD
         oIFFeHtNrSdiMLjT5WrdJFYOV8sQR2PgKl1ZmQbOZl7zqXnZ+I6agWnTbMILUp9g48ix
         y3CS7aajXd4aYr/X5klIwDXDln+FpIaIwHGsMj/7wnc5dAgC2n4kfMcjqjyRKGitZwI5
         kXd5jJFL2H/5TvXoW2r/nyhWwnECFV+NgsKRD04m0PqY7HjXkFScifHf4Seb5GUOgkHL
         3Viw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Oj2mVxSa+2J+fkcSLZJgmIgirExhWFgh1cb5vCMP3vI=;
        b=kN+5FJqyozcxHvZelc/xXCAb66tKMIEGxRvJ+9C6htgRILNrZwHF13uJDU/jVAdNuf
         AHsP75Jmx2/E5tYJ6H4g3oxRmDzHDv+sEx0ey1TsPJywtEPD+ePh8TB+AE6rF5Ecmn1q
         RJ7RlyOBxzrYBNTlUGdV666I+NRdpmhbsTg7sk/FQFxZIWaISzAnLZ3tJwMt1m1bpMEE
         lNgicrmFwuS+Z5y2cMB01ZRZwJzarwM+wkeRqrOmJOb1DkbtmVg+06UYefy90VjQ7XNo
         DkXFxK4t//vc3fnzNS3M51nogvRwPmw11eacP7myxabVouSXRDQzP0Kplek5KDw4bQOj
         7arA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tf5cAthD;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l2si2447055pgs.315.2019.06.19.01.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:19:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tf5cAthD;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Oj2mVxSa+2J+fkcSLZJgmIgirExhWFgh1cb5vCMP3vI=; b=tf5cAthDjPtD5dgpkrrmWm6iX
	hJT+iCl3LI50nk+ly+ZUajqlu/ZYu5I81HuuxxEoOqgz7cy6G/879N+lqH8TGVpEIzKb8gY3RWEH3
	spycirx2fT31SjuibyhyqizZP8JiXuZ7DC4RaFSjwiDEGgpm42e6/0HTM69qw1BUen2f8789MSOfC
	3BFfTed174q1HfdzIVms/k2iwj1c/fqiYCnF/5TegT2vD/aAyWCTylC372dVxF67j6a4/CwjOm3IO
	/J6MW7+6GXoWPYd0XJsHHz0VI9rAa4XLWjR2isQ4WJ9LmCy9LcN2FEXjp26JXuspZegFhyO4rNb9S
	ZStiJlmvw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdVoq-0000mV-EN; Wed, 19 Jun 2019 08:19:48 +0000
Date: Wed, 19 Jun 2019 01:19:48 -0700
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
Subject: Re: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190619081948.GC24900@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-9-jgg@ziepe.ca>
 <20190615141612.GH17724@infradead.org>
 <20190618131324.GF6961@ziepe.ca>
 <20190618132722.GA1633@infradead.org>
 <20190618185757.GP6961@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618185757.GP6961@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 03:57:57PM -0300, Jason Gunthorpe wrote:
> With the previous loose coupling of the mirror and the range some code
> might rance to try to create a range without a mirror, which will now
> reliably crash with the poison.
> 
> It isn't so much the double unregister that worries me, but racing
> unregister with range functions.

Oh well.  It was just a nitpick for the highly unusual code patterns
in the two unregister routines, probably not worth fighting over even
if I still don't see the point.

