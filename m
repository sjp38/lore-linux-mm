Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D74FC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C78C920693
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="n3J+GAL+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C78C920693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6478A6B000A; Wed, 24 Jul 2019 16:18:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F8E88E0003; Wed, 24 Jul 2019 16:18:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E7678E0002; Wed, 24 Jul 2019 16:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3228A6B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:18:35 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k13so40410865qkj.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:18:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VWJ6DdSzX3UNH5IsBG0QIkcKoVJ3m7vBBB3d3WVZ5uE=;
        b=uSLleXimSq/1iHmCh2ywfaXP5vsmpP6u38KayD7ERWKb2HUCb2LFtzMsw3EsVEYPZe
         v+2XmHekCkyAAuA78NvPVryRCCAcRUOzYQZUnOmBBUH5CZZreIsv0ETpE3OmTVa+F/Qk
         a4epX+mCCT2MADthS5kETrvdU7OZeWe8fqklUJy5EUHljR5UEeES/NgzfN+PT6BWYxoh
         4xGThD6Zzlr/WdxrLMTodU1cpcvxSpagzKBj6DPJ9OVJ6OX8DXB650cSVti88a7raDOH
         nVDfmMJu+hoQh9qvAmufbiJf7Q3wFnnfvbgmkEFBHfUksRtWZnXvJX7MIGoK0JOZzUXX
         aDzw==
X-Gm-Message-State: APjAAAXRg5Uw3d/zRHFyWfaiVBIz0l038mJeDOFLy0Bkpw/rXdNUezPq
	//bMtsTvh2LnL+qmuCTEFGHw/d3yw5GSt/MM5V7/l9N4uiebsCkc4fcjZnOGC7DSOv/he7sOtUu
	JBAafp+z+AHQgiMWEgT3/Z00FrPvcHFpy6T4RxvqLShml1hWjTueY8zTHh2HnxXOM6w==
X-Received: by 2002:a0c:d066:: with SMTP id d35mr59213005qvh.221.1563999514975;
        Wed, 24 Jul 2019 13:18:34 -0700 (PDT)
X-Received: by 2002:a0c:d066:: with SMTP id d35mr59212986qvh.221.1563999514499;
        Wed, 24 Jul 2019 13:18:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999514; cv=none;
        d=google.com; s=arc-20160816;
        b=AkKIU49vgVXblMC/Mvw9OUuT7luche1KdllpKAdq8BvFN/NOb6yr6TfF4riJIUQhMX
         D9dWYpgHyBF6yUUQVjhHHotH10uzgREbnQqiEVD21vo39CGuk0XgoildB4Pu17jtXGM2
         dKOg6aCyD/KQcvXc3xXo8M0SykLzRfY5rOcRUAzBdWg8esoz0+XtDJjHH8ZcUMdUr0t0
         dNwEThRl4G4TdxH1sYUn5yuDxDRHbpheQCF3HTJAqiS9zetQvIl1vyedz0emisxdcelI
         ZnU3WMxxpdEPZ929zlyfstJ4/AClgIzgEpE3pYjT+G5s588YnGk3uKMWk7JIqGTtHh0Q
         S3Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VWJ6DdSzX3UNH5IsBG0QIkcKoVJ3m7vBBB3d3WVZ5uE=;
        b=bhATIRGm27ij+e13tYo1xfAmlR1czphs3+A6dlI1aLx6dxChMT+DMlqNAkUnWfOC8F
         IJajLEWpQfun+qgghurzaPoY/Y6K9pJJ4J/qtJ+6ncInmHVfHRLuI4FcCL0OFkxKyvXk
         iL+L4CmjHhFU1X6OApRhLutVV7FO5xg6JLz+E10LiC4bYwV6SknS1QjOS3CjK2s7Kptj
         M6AhQTaNx8KiVtWQVHSbvDCYieUnGmPX9sVtms86oYl4BGnjsikcQH7/r6nJ0A/oDGxT
         u1o1pUZWrPS5S8IKIIwkIqWWnL+YjQkfpKAIdAbibF76bqFeVkdubjFGjL1fGUodpUvf
         50QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=n3J+GAL+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor61773113qtp.58.2019.07.24.13.18.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:18:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=n3J+GAL+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VWJ6DdSzX3UNH5IsBG0QIkcKoVJ3m7vBBB3d3WVZ5uE=;
        b=n3J+GAL+FB7VbB4RL6GVAirOAzlkzTHdeG1dUMoxA6P765HJ6vilINgoGfg1gmk1C2
         QeSv4gST+tMRdO9dLK69LLxfwyPsmiKfyvs3TUfCoqfmvKURPNG1u5ThxfSfZB/rAVJW
         lzianxfqFVnwvVRML7U80M5T1T+Rvr5AfzzqyvrySHXOSTaI+056H1I+ByDUtnJBhlEg
         xIezRDw+WneukJZqZHL6mhNX2cx/6DDLOuo7f4psXrJoTCceu3eN0GU9eB/Ur5nkuNRK
         9EMn6cOnl72B0kvwpSRZeH//s6PjsHVcKalg1f9Sgc0xqts4GjQ2MeeoyqGPz1aGpEOO
         krHg==
X-Google-Smtp-Source: APXvYqy6Kd2FCXwA5ViOoNdVk66YE8CWdFXTM44KqYbLUvwUjmODvbZbHeyXtq/HnU0w/t05AaFPsA==
X-Received: by 2002:ac8:7b99:: with SMTP id p25mr59513506qtu.243.1563999514197;
        Wed, 24 Jul 2019 13:18:34 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id v1sm21152817qkj.19.2019.07.24.13.18.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 13:18:33 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqNib-0007Qc-5i; Wed, 24 Jul 2019 17:18:33 -0300
Date: Wed, 24 Jul 2019 17:18:33 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724201833.GI28493@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724175858.GC6410@dhcp22.suse.cz>
 <20190724180837.GF28493@ziepe.ca>
 <20190724185617.GE6410@dhcp22.suse.cz>
 <20190724185910.GF6410@dhcp22.suse.cz>
 <20190724192155.GG28493@ziepe.ca>
 <20190724194855.GA15029@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724194855.GA15029@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 09:48:55PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 24, 2019 at 04:21:55PM -0300, Jason Gunthorpe wrote:
> > If we change the register to keep the hlist sorted by address then we
> > can do a targetted 'undo' of past starts terminated by address
> > less-than comparison of the first failing struct mmu_notifier.
> > 
> > It relies on the fact that rcu is only used to remove items, the list
> > adds are all protected by mm locks, and the number of mmu notifiers is
> > very small.
> > 
> > This seems workable and does not need more driver review/update...
> > 
> > However, hmm's implementation still needs more fixing.
> 
> Can we take one step back, please?  The only reason why drivers
> implement both ->invalidate_range_start and ->invalidate_range_end and
> expect them to be called paired is to keep some form of counter of
> active invalidation "sections".  So instead of doctoring around
> undo schemes the only sane answer is to take such a counter into the
> core VM code instead of having each driver struggle with it.

This might work as a hybrid sort of idea, like what HMM tried to do
with the counter and valid together.

If we keep the counter global and then provide an 'all invalidates
finished' callback then the driver could potentially still ignore
invalidates that do not touch its ranges during its page fault path.

I'd have to sketch it..

I agree it would solve this problem as well and better advance the
goal to make mmu notifiers simpler to use.. 

But I didn't audit all the invalidate_end users to be sure :)

Jason

