Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F55C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F13E52147A
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:21:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ZyJ3zgq6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F13E52147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90A126B0006; Wed, 24 Jul 2019 15:21:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 893F96B0007; Wed, 24 Jul 2019 15:21:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 733618E0002; Wed, 24 Jul 2019 15:21:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAF36B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:21:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so42405382qtp.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:21:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q7VJ5lbRcag+sb2GFiCBi0ogY7ktByen10i6R5SYdYM=;
        b=KBB5zy8m1K3MzhRgzO4/n5sF0PT8dYiYGILTjFvRjChyFj5Q4yv9x+H0zCMeJl4gl8
         jH/VbwwknpB8xfkv82jDCFZYko1tawWztx5371n+nKahFPZ04PzkJK+1rMbIKI/tIe2K
         T0mL9I8xWEtPCxTGxJlIS78IMsnzmwvGARsMGSpYEaEkZW8/Rfh2e7E5t0tH4xM/q7sm
         uwbR1xJ7PFjvXvPA4PEVIURVrYLKKS5ijDgvcMvC1urj6nRRrvI7VVF8pvU7Gx8nuj63
         K6dlIok9b0AzWyKd5cDHXKYOW6WbFhzepb+dPu5VYBNHUspZDhWFdHfrACHxib/iY9SV
         xhMA==
X-Gm-Message-State: APjAAAXCetQTEfJb1u2deDaAfjXic6y6QsslH3/xzc1Wsqr4tQld1pkH
	JcZJ+wO1TtnxArWkpzuAC/jIITF8JwMDAL0YT7YPJrFqK8g8wD3jFQLxRnFDYw4Z+OXtgMGN51s
	b5ORx0EhFWkYRzKqmVuND55BYpH4ZwFfPLlr4xbDMvlPu5qWWUVb8FeguUKtVilI72w==
X-Received: by 2002:aed:2d83:: with SMTP id i3mr59896336qtd.368.1563996117014;
        Wed, 24 Jul 2019 12:21:57 -0700 (PDT)
X-Received: by 2002:aed:2d83:: with SMTP id i3mr59896312qtd.368.1563996116376;
        Wed, 24 Jul 2019 12:21:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996116; cv=none;
        d=google.com; s=arc-20160816;
        b=RwtqJAM8LqsQ0v11nY4oO0ffPIJiQFR2C5R0eh3xriBLkkMogsJUmzo7fpB55O5wSD
         l1XkVB4sum+hV+jltKyZaJXo1ckbP2cXDV3KKbZRtt0Xwk1bSfzaaSKzrGHorfprCDaQ
         osqExuKlDUzWJVHZjMeqHppGcAqQ3hK/pyldbHJQEhvqiO127QbuXJwsdUszGDyNqgIJ
         E8VayrFxjCfQstE0KPPcVNIyKQCeMXKgJClkKSa4Fi7mS+4HVQ+gTpkJ4TOdTEY5CuIp
         JYYjqihhN3j3NDX5zGk8mlbeZ4voNuxRcSkIValPoV04drj9QTNJHZrnXpUboAKOVXaR
         iShQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q7VJ5lbRcag+sb2GFiCBi0ogY7ktByen10i6R5SYdYM=;
        b=sZ+ErxxYNmH+vePNfkjNn5n38fpOLEsjbTmGQ44PSZPbB98m34V1WKoMq+j+55H5Yz
         dPqpmQU0WomxWzBosFqHXTdp5NDEWr1jq2gYk0A6bXdpXDobg3HzQwpMeHATBpYqO90o
         PIqpQsYUxS71oU6Qf1grmVjCL2eDuKPxUwjh2yiVpbnoFsC6kdQi2szc/lSFWSB3taob
         880wqP+/RH/xTprT1ihbLyQirTV/TChvNnJ8oJO0SHIYR+GplRKdb+wRtIdlqh18EBYY
         T3nB1f++/E6SRsvm+0XW4UEcywe8A6i846g8apmONTaFs0iKeJILg2bve0Qiab8gUcDG
         N9mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZyJ3zgq6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74sor26874488qka.199.2019.07.24.12.21.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:21:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZyJ3zgq6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=q7VJ5lbRcag+sb2GFiCBi0ogY7ktByen10i6R5SYdYM=;
        b=ZyJ3zgq6h4cja/hdaLrA6IkzBFDVRDUJUFtWz1fzLJwFO3+4I4Mk/FCq69MWFKhPkn
         VmJtaQRVCCbTW4B/7vtp3EFV7mKQ0Du9zN1ddOb32MyshNPl6WhBSEDHrm+k6o2CyMMO
         4KyPGLB4T/6MfLf1NsYTF9rAzr1pU8FsMWEvqr8KtU1D2GgXOl729S0aNG0wyoeil1db
         UU7GVtf1oaMsSE860psV8LYDQAfcq3WrN/GcPafu+19PCrIlmB/lcCJJ/hsWVBf9sq/S
         3j9mLwgItOsVezznIUV4U2H56ZO80MnsJTCG1n8+5OJ16YnPZyPc+ck/lacJ5FRZiPcz
         PO7Q==
X-Google-Smtp-Source: APXvYqxIqRA+0VLqS5/ktYsyx1BSHKocPYVvc0BAedibqfRz0wbPwwvU+Y1GIKj2RSb05TRVjFqKEg==
X-Received: by 2002:a05:620a:1425:: with SMTP id k5mr56337391qkj.146.1563996116084;
        Wed, 24 Jul 2019 12:21:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l19sm27634792qtb.6.2019.07.24.12.21.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 12:21:55 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqMpn-0006gr-3W; Wed, 24 Jul 2019 16:21:55 -0300
Date: Wed, 24 Jul 2019 16:21:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724192155.GG28493@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724175858.GC6410@dhcp22.suse.cz>
 <20190724180837.GF28493@ziepe.ca>
 <20190724185617.GE6410@dhcp22.suse.cz>
 <20190724185910.GF6410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724185910.GF6410@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 08:59:10PM +0200, Michal Hocko wrote:
> On Wed 24-07-19 20:56:17, Michal Hocko wrote:
> > On Wed 24-07-19 15:08:37, Jason Gunthorpe wrote:
> > > On Wed, Jul 24, 2019 at 07:58:58PM +0200, Michal Hocko wrote:
> > [...]
> > > > Maybe new users have started relying on a new semantic in the meantime,
> > > > back then, none of the notifier has even started any action in blocking
> > > > mode on a EAGAIN bailout. Most of them simply did trylock early in the
> > > > process and bailed out so there was nothing to do for the range_end
> > > > callback.
> > > 
> > > Single notifiers are not the problem. I tried to make this clear in
> > > the commit message, but lets be more explicit.
> > > 
> > > We have *two* notifiers registered to the mm, A and B:
> > > 
> > > A invalidate_range_start: (has no blocking)
> > >     spin_lock()
> > >     counter++
> > >     spin_unlock()
> > > 
> > > A invalidate_range_end:
> > >     spin_lock()
> > >     counter--
> > >     spin_unlock()
> > > 
> > > And this one:
> > > 
> > > B invalidate_range_start: (has blocking)
> > >     if (!try_mutex_lock())
> > >         return -EAGAIN;
> > >     counter++
> > >     mutex_unlock()
> > > 
> > > B invalidate_range_end:
> > >     spin_lock()
> > >     counter--
> > >     spin_unlock()
> > > 
> > > So now the oom path does:
> > > 
> > > invalidate_range_start_non_blocking:
> > >  for each mn:
> > >    a->invalidate_range_start
> > >    b->invalidate_range_start
> > >    rc = EAGAIN
> > > 
> > > Now we SKIP A's invalidate_range_end even though A had no idea this
> > > would happen has state that needs to be unwound. A is broken.
> > > 
> > > B survived just fine.
> > > 
> > > A and B *alone* work fine, combined they fail.
> > 
> > But that requires that they share some state, right?
> > 
> > > When the commit was landed you can use KVM as an example of A and RDMA
> > > ODP as an example of B
> > 
> > Could you point me where those two share the state please? KVM seems to
> > be using kvm->mmu_notifier_count but I do not know where to look for the
> > RDMA...
> 
> Scratch that. ELONGDAY... I can see your point. It is all or nothing
> that doesn't really work here. Looking back at your patch it seems
> reasonable but I am not sure what is supposed to be a behavior for
> notifiers that failed.

Okay, good to know I'm not missing something. The idea was the failed
notifier would have to handle the mandatory _end callback.

I've reflected on it some more, and I have a scheme to be able to
'undo' that is safe against concurrent hlist_del_rcu.

If we change the register to keep the hlist sorted by address then we
can do a targetted 'undo' of past starts terminated by address
less-than comparison of the first failing struct mmu_notifier.

It relies on the fact that rcu is only used to remove items, the list
adds are all protected by mm locks, and the number of mmu notifiers is
very small.

This seems workable and does not need more driver review/update...

However, hmm's implementation still needs more fixing.

Thanks,
Jason

