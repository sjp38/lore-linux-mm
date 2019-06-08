Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC46C2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1BB2208C3
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:35:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CdkBfA/6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1BB2208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89D876B0271; Fri,  7 Jun 2019 21:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84EBD6B0273; Fri,  7 Jun 2019 21:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764276B0276; Fri,  7 Jun 2019 21:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5654B6B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:35:32 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v4so3144796qkj.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:35:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UGOATcTaOKAluhrvGNEt0YBuzCUm7BqI1RnepYlBC8A=;
        b=Qv1SzcEW9QPZiCuCby73ck0xCxPWRWy286UGlPSeDVzA05vLw/RZPJl2VlW+cRs5g2
         p8EMH8rKccZspwLezREOAqd/Bd5JgXlMPaIS2VjiaKl8JGI5ziNZcUHACY0nTLFjt8C5
         Yyp/OsBr+ZHVmMJexWjqnYSWNFHcDUi8AZiMnzd3lFWo5kc6sM7sO5QxpzvZENZMgl/G
         ldU4chALVNGm/xmrmGk2hycr0fQowtQoZzXa8qU3AbiO7zEM2RLrrTcQSftyGlRtKwo4
         neWDyd5ELsGxSHpt+Ppen+veMf0aIxlGi556GRVVXvhSnOM3B7so/Ymdh/kqtaqVuG8w
         8chw==
X-Gm-Message-State: APjAAAXRhKdVeKIIuBRBTEB/d0LmrJUJCruvn7KdPaouOy8d+p1lpOlA
	WVfDjAgdj9rP+MD/dgcIpbto60HpKur4NOLL5kk91Es0/IGRfkxwms4LCTInr5QYqbs8GvNjPEJ
	mP6NptAwA64Ru0CZi8FVfbeQKDTd+Bv3XcnrFVHBcMHpmHLRFSVplyOe71nsAKPfynw==
X-Received: by 2002:a0c:b786:: with SMTP id l6mr21782374qve.148.1559957732090;
        Fri, 07 Jun 2019 18:35:32 -0700 (PDT)
X-Received: by 2002:a0c:b786:: with SMTP id l6mr21782342qve.148.1559957731543;
        Fri, 07 Jun 2019 18:35:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559957731; cv=none;
        d=google.com; s=arc-20160816;
        b=RROsJqnc4A7iUTllMYAbTZ9soUGOi0obomgMmrY4en7ydRYUkT9VDLxFwSfV+7ak2z
         eFZI7p8nFdJOcbsaic7/SX/iqiN058YqsUPdQSa82g8uMFsuuhnSTHJsmxfvKECliZET
         Hn+XEg/MUHjSUwQDRTUvSeGAow+3PL+zqq/A0P3RqBp4CeN0SboK38irktEg3fuxvx1H
         PiQHUBR6GxJtDuyyF6f6CrOqUanQMqIPuhzGa6Wz/A+UpmV0jRfc3lxSIjpGRUeI9fhR
         dNrhNrSbsPJzK2oHpkaL01WTfISoFcxUgw/N5phMzx1rMMXcQEL/ewhqFf3JlpyVXAfu
         lwfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UGOATcTaOKAluhrvGNEt0YBuzCUm7BqI1RnepYlBC8A=;
        b=oADjhqJZoDBBCIjfApL2MZQjSn8LvzfLdU6wLfeh2yZCUj2qEVAab94P+kqTuIiSKY
         RGl4zUR7KXUx1a5Lg1qt4gCjgduJPwNopCAN0ibZzg2WgUBTU0qTfNjUNs2cUjY5Ixor
         d5Ov2wQjN9oclcNvb4cc7evtlrWhsMaBzIHgxZrXtSXpWIifvhMlFLqzvKaMkT68isMD
         lqp5vBDf832l6eqswgVMBS7sdCBNONu6uk4sgTSS9rxsUXDSH2of3e0uMIV0qKZ0hQVO
         s5/OdNXtdHPYN6pvbjJv5/h7b9br0Qea4HZcu7KHtCxj93UZoYAB6LgcDlr/HnCOPVhe
         RYVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="CdkBfA/6";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u39sor4579188qte.45.2019.06.07.18.35.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 18:35:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="CdkBfA/6";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UGOATcTaOKAluhrvGNEt0YBuzCUm7BqI1RnepYlBC8A=;
        b=CdkBfA/6OXeGxOQDEpRrnGbh+YU1WVUIiGmE6ObF1BdvREX2rE28bzeff0LPskY6K4
         gH8oEUMS2jzBTG9XsYBCIU0vO1Ux0uZft+Dls2FU0cg84J1T5cWuvC3xVzcnYykyxzb2
         9Sn1gVGHLQLuaEUN/pivXD8Iv84MG+tX2OGN7ZFtplU058T10fMBEfPmBpaRj27D/szU
         6bOagpwU7gtPX7gLQVwEwO3C+KMvBhxC228Opejk20nbMWBEmUpgwzYLo64TfpaORJxD
         zwMpYHDMyYQ27YdaZMzdhHhTd5Jjv2muJmE75OMWYHj+iRrQByu7sYb/LL1vDmWqUmv6
         tinw==
X-Google-Smtp-Source: APXvYqz4alB0pyXNzkKNUcsple2Jn80UBKfD2EM61r0Pq/XpSZdlSRxzdhI0YfjDFU7DVO4hGnKzdw==
X-Received: by 2002:ac8:644:: with SMTP id e4mr41209859qth.173.1559957731168;
        Fri, 07 Jun 2019 18:35:31 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i55sm2718956qtc.21.2019.06.07.18.35.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 18:35:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZQGY-0002CD-9G; Fri, 07 Jun 2019 22:35:30 -0300
Date: Fri, 7 Jun 2019 22:35:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 12/11] mm/hmm: Fix error flows in
 hmm_invalidate_range_start
Message-ID: <20190608013530.GB7844@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190607160557.GA335@ziepe.ca>
 <439b5731-0b7e-b25b-ce1a-74b34e1f9bf5@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <439b5731-0b7e-b25b-ce1a-74b34e1f9bf5@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 04:52:58PM -0700, Ralph Campbell wrote:
> > @@ -141,6 +142,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> >   	hmm_put(hmm);
> >   }
> > +static void notifiers_decrement(struct hmm *hmm)
> > +{
> > +	lockdep_assert_held(&hmm->ranges_lock);
> > +
> > +	hmm->notifiers--;
> > +	if (!hmm->notifiers) {
> > +		struct hmm_range *range;
> > +
> > +		list_for_each_entry(range, &hmm->ranges, list) {
> > +			if (range->valid)
> > +				continue;
> > +			range->valid = true;
> > +		}
> 
> This just effectively sets all ranges to valid.
> I'm not sure that is best.

This is a trade off, it would be much more expensive to have a precise
'valid = true' - instead this algorithm is precise about 'valid =
false' and lazy about 'valid = true' which is much less costly to
calculate.

> Shouldn't hmm_range_register() start with range.valid = true and
> then hmm_invalidate_range_start() set affected ranges to false?

It kind of does, expect when it doesn't, right? :)

> Then this becomes just wake_up_all() if --notifiers == 0 and
> hmm_range_wait_until_valid() should wait for notifiers == 0.

Almost.. but it is more tricky than that.

This scheme is a collision-retry algorithm. The pagefault side runs to
completion if no parallel invalidate start/end happens.

If a parallel invalidation happens then the pagefault retries.

Seeing notifiers == 0 means there is absolutely no current parallel
invalidation.

Seeing range->valid == true (under the device lock)
means this range doesn't intersect with a parallel invalidate.

So.. hmm_range_wait_until_valid() checks the per-range valid because
it doesn't want to sleep if *this range* is not involved in a parallel
invalidation - but once it becomes involved, then yes, valid == true
implies notifiers == 0.

It is easier/safer to use unlocked variable reads if there is only one
variable, thus the weird construction.

It is unclear to me if this micro optimization is really
worthwhile. It is very expensive to manage all this tracking, and no
other mmu notifier implementation really does something like
this. Eliminating the per-range tracking and using the notifier count
as a global lock would be much simpler...

> Otherwise, range.valid doesn't really mean it's valid.

Right, it doesn't really mean 'valid'

It is tracking possible colliding invalidates such that valid == true
(under the device lock) means that there was no colliding invalidate.

I still think this implementation doesn't quite work, as I described
here:

https://lore.kernel.org/linux-mm/20190527195829.GB18019@mellanox.com/

But the idea is basically sound and matches what other mmu notifier
users do, just using a seqcount like scheme, not a boolean.

Jason

