Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19BF3C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3617206A2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:59:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3617206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E6C58E0007; Wed, 24 Jul 2019 14:59:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 596D38E0003; Wed, 24 Jul 2019 14:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AD3E8E0007; Wed, 24 Jul 2019 14:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F27E28E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:59:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20so30755039edr.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:59:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=b0XO25dTeIVLUe5LFpL0rTb2bvBuDnyq2pFxVT/CAhk=;
        b=msqEd4leBXW825P+sbjZnFJ5GsUKZ7vzeJbWeN+Ad0dEE01pgNVxwifzwOFnW2bKt4
         78cbXqP9Hk3T7c2ozxgYYUIpPwOCmqSsQ5/F1NyNGXOevYkjl2WodOWYOrm58YQUNky9
         GpFCmC4m8jUqY1CnO8vldPqFPZ/wbVQBVwOAjsRDYPK7+983Isu9+BL7q1uR/BBBqlm8
         qNgxMDOZcJNl8GfEJK/PdBrvQFy0/weQsYTm44t64rbYM8p/9Rb159hzchKe5FEvlcJM
         3fINsjs0/2Eaf+AMLI/pA0KpSgdK6z221QOsm1UJElBntF4SgcPQ9VJ0q4SEE8PseBYP
         P0Fw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX3h/UVmXblSXMOonOGVDTlUQyReN5zcpUnYE5heO8gdisLrxil
	nBdwvC8XIgL9L1A5jCLKYAm0Mb32+cFA1jttVimOnwgHq1zU+BRh6v/N0WWwMWa+GfdlUG8fcm9
	xS9FiL0myxWF3i8trqXdSSr8eBz/RIFWxqUgPnKwmDHSQIWZih4fS5ZQ2xWmZ6yI=
X-Received: by 2002:a17:906:4717:: with SMTP id y23mr63787216ejq.150.1563994755457;
        Wed, 24 Jul 2019 11:59:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE0LWzcewxcAPLrom6X6SBgfU2iVXseMY/oGmVfWGIdr6qzI/dWth0E5I68o0AqUMREXqz
X-Received: by 2002:a17:906:4717:: with SMTP id y23mr63787190ejq.150.1563994754805;
        Wed, 24 Jul 2019 11:59:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563994754; cv=none;
        d=google.com; s=arc-20160816;
        b=kboesjjo6MFIZkM6xgIOnSeM8QKMdwQRXbxknfmHhxLGD71pitXj3xaKweQoW3yjba
         jeX7H18ssEWGIYgDHx1rSqI5l4iow4fEJ2Rrj3hfe3P/toWCVVVUdp3TBO4JCW93CwCR
         Tr396lMgyWHnkJ55fTQfKIclL6u01TN1Mj3p9chLkeK+NbNZIIeub7b7APqslvXRE0Q5
         X457QWvK0SVmsCM22z5zqfl9YJSwYumFKuXPdQIcQbsm+e2QH8pqCXJl2U1Daad8YH1G
         3R5nUqK29SL2Lc/60rEmyMELW1vJdz/pbQIPposaa+gwG8Uc8lHl3EQmcKKIuvri61BT
         hZNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=b0XO25dTeIVLUe5LFpL0rTb2bvBuDnyq2pFxVT/CAhk=;
        b=uA+lwgxQACbRF+6uqlAQvjaR/kyvMD+S14uReX3jTSuzH4IKJhIWpIgY1NI7LhIJng
         gIdsbn2oz/xOxrdsmZnFi1DYq/XBpouaarTr9pBtPAhzQOCApC4cMCWFxAeXNluCtv3C
         x7l0wmCbxsiJAzC+FSzRGToEqqXoIwqeRONFcJ/p0uibBM+gQn10TWzHJbaMXjQEzOXH
         rwhAV9nWk+O+wD4pm+ZW9Ap8kTM7KAXUgQctAtytFLntxAFyPNF0JpAxYyXWH1kHA4VI
         iqgBV0gXps9Zs2p6496Aoo45L80zuLOrv1AYxrOGH6x0tE3avbAp9MSCYOeS2if1J1sq
         JSJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w27si8183652eje.261.2019.07.24.11.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:59:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 170CCADC1;
	Wed, 24 Jul 2019 18:59:14 +0000 (UTC)
Date: Wed, 24 Jul 2019 20:59:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724185910.GF6410@dhcp22.suse.cz>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724175858.GC6410@dhcp22.suse.cz>
 <20190724180837.GF28493@ziepe.ca>
 <20190724185617.GE6410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724185617.GE6410@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 20:56:17, Michal Hocko wrote:
> On Wed 24-07-19 15:08:37, Jason Gunthorpe wrote:
> > On Wed, Jul 24, 2019 at 07:58:58PM +0200, Michal Hocko wrote:
> [...]
> > > Maybe new users have started relying on a new semantic in the meantime,
> > > back then, none of the notifier has even started any action in blocking
> > > mode on a EAGAIN bailout. Most of them simply did trylock early in the
> > > process and bailed out so there was nothing to do for the range_end
> > > callback.
> > 
> > Single notifiers are not the problem. I tried to make this clear in
> > the commit message, but lets be more explicit.
> > 
> > We have *two* notifiers registered to the mm, A and B:
> > 
> > A invalidate_range_start: (has no blocking)
> >     spin_lock()
> >     counter++
> >     spin_unlock()
> > 
> > A invalidate_range_end:
> >     spin_lock()
> >     counter--
> >     spin_unlock()
> > 
> > And this one:
> > 
> > B invalidate_range_start: (has blocking)
> >     if (!try_mutex_lock())
> >         return -EAGAIN;
> >     counter++
> >     mutex_unlock()
> > 
> > B invalidate_range_end:
> >     spin_lock()
> >     counter--
> >     spin_unlock()
> > 
> > So now the oom path does:
> > 
> > invalidate_range_start_non_blocking:
> >  for each mn:
> >    a->invalidate_range_start
> >    b->invalidate_range_start
> >    rc = EAGAIN
> > 
> > Now we SKIP A's invalidate_range_end even though A had no idea this
> > would happen has state that needs to be unwound. A is broken.
> > 
> > B survived just fine.
> > 
> > A and B *alone* work fine, combined they fail.
> 
> But that requires that they share some state, right?
> 
> > When the commit was landed you can use KVM as an example of A and RDMA
> > ODP as an example of B
> 
> Could you point me where those two share the state please? KVM seems to
> be using kvm->mmu_notifier_count but I do not know where to look for the
> RDMA...

Scratch that. ELONGDAY... I can see your point. It is all or nothing
that doesn't really work here. Looking back at your patch it seems
reasonable but I am not sure what is supposed to be a behavior for
notifiers that failed.
-- 
Michal Hocko
SUSE Labs

