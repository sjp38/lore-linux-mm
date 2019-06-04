Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5CE5C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 752272498E
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 752272498E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 057ED6B026C; Tue,  4 Jun 2019 10:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02F8D6B026E; Tue,  4 Jun 2019 10:30:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E88E46B0270; Tue,  4 Jun 2019 10:30:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB496B026C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:30:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so696737eda.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:30:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4wAAPBQ4+NpeEXU4lSsSOtb7EcBJAM7FyxCTvNmq6gs=;
        b=dfL+uBSgpa17FxCl21ykQRAcDU3HL1wMwzG/U/6QTQrKILGjw6ZRClSci/U1q6sk6m
         lsmGLJ7AeqgWrUw+sKSvUSWbgq0cN4hwv5/aOs2IXj3ft9wEZcWBglMqlHFnOSzzKhsY
         hrflNnMvAcxmcaZjVcAeo1aj2qSPbMrE4fgTkcR7hBPMc6pKUO9drnH5G9iVFbgpQvog
         Zp2CPBpNb1yPUnLcI5H6FXGNHGhAntOzOQWrSzTi7mK9dlry3ln63iSV9zOmZBju/i8O
         wnOxcaRsnJROcyzg2C0pfRyhMxJ9LWG/i9rK1RKX8HNIgyC9AUemeIWOdPqmqgvZEBtW
         EJqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAV2UtaxRg00TqjrjX5zCoSuM2PA89QIFiaOlD1YHKTXN5gAg5MT
	2/gMoakCHolD/tmO1bXFSyKcN0qpiWd9UmDZSOZYstYZ67ofv7py1bqRDKcr/RUZovajhrEcY03
	i9SzEglx50Ri9EqrbHO2LxHBW7k+YigeT9YnMoRpPJNNLr5mZjWuH1fx38XFBzI1ZkQ==
X-Received: by 2002:a17:906:d549:: with SMTP id gk9mr14023107ejb.268.1559658627213;
        Tue, 04 Jun 2019 07:30:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlMejgtc7ngyw7AA/tX4MJw5O6ADmBb8/M80NxWkQ6BPa2OcmhTleIRo2PlcJtmMWoWb/L
X-Received: by 2002:a17:906:d549:: with SMTP id gk9mr14023002ejb.268.1559658626314;
        Tue, 04 Jun 2019 07:30:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559658626; cv=none;
        d=google.com; s=arc-20160816;
        b=LpUlrvelkhGZVhY3lQQNACNAY8FRYyH5eMgYzVCWjBpEP9cJ/xxR0GWixmd/+o+EZG
         ZHnmMTP1BlFmWa1TQwIBt4eeXbYG5fiEl0eJPuwsYREOWZKxo/D4jJ+QRpZD1R+eVlK+
         hlS5kclg5XbVfgWXoejwfnfkuvaUTfkv5Msm5L6QS1zgrJlzmMvloZH2+1eKAyiB4xJt
         WKSvcyCCs3FuVBZmA0s0dwGM+PjBPJMSwCbJCafUyScwtaDOFXMOEy8wtqhrQlCXP+/j
         0dgT5/uPLXjVUhf054aaHusNfBO29NZOp75b6qL//3yVMZkCLQe83QZlHxspgk01yFJn
         Z/sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4wAAPBQ4+NpeEXU4lSsSOtb7EcBJAM7FyxCTvNmq6gs=;
        b=Ql+f3bRTfANFCPmhKxJxsw5tGBvP7o6R6di0noKjWXkaUyPQXdyA8pR5cjm5s8ZYWk
         x1A4hxM1of+qvjohW/V5YjoRCBeRUONYOCup9M2XyWg39s89H6bTkZZWIu0ZSnnoDwQY
         F1XMPjtnyh5XpWs84XJgHxqEDiSdObmc3TsYEdqObKI6STKvidXTfuBK/UrWskSmpNxO
         3bc7A1dbkBG9bogfUhKZn3HPfyxuHABS9GPSTbdVMw8JU5sXDHLFlhJhWdEzWQbvPjsK
         D2cDYGSPZtt8B8ZV5JfxgkgdkR2IPQ7UyiqQeFxZcR4oZ+9BIn3qL26xP8D6XY37+PZF
         NWQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w15si4010809eji.394.2019.06.04.07.30.26
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 07:30:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 41343341;
	Tue,  4 Jun 2019 07:30:25 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2C5B83F690;
	Tue,  4 Jun 2019 07:30:23 -0700 (PDT)
Date: Tue, 4 Jun 2019 15:30:20 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Qian Cai <cai@lca.pw>, rppt@linux.ibm.com
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org,
	vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190604143020.GD24467@lakrids.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604142338.GC24467@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > The commit "arm64: switch to generic version of pte allocation"
> > introduced endless failures during boot like,
> > 
> > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > -2 parent: cgroup)
> > 
> > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > and then later memcg finds out those don't belong to any cgroup.
> 
> Mike, I understood from [1] that this wasn't expected to be a problem,
> as the accounting should bypass kernel threads.
> 
> Was that assumption wrong, or is something different happening here?
> 
> > backtrace:
> >   kobject_add_internal
> >   kobject_init_and_add
> >   sysfs_slab_add+0x1a8
> >   __kmem_cache_create
> >   create_cache
> >   memcg_create_kmem_cache
> >   memcg_kmem_cache_create_func
> >   process_one_work
> >   worker_thread
> >   kthread
> > 
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> >  arch/arm64/mm/pgd.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > index 769516cb6677..53c48f5c8765 100644
> > --- a/arch/arm64/mm/pgd.c
> > +++ b/arch/arm64/mm/pgd.c
> > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> >  	if (PGD_SIZE == PAGE_SIZE)
> >  		return (pgd_t *)__get_free_page(gfp);
> >  	else
> > -		return kmem_cache_alloc(pgd_cache, gfp);
> > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> 
> This is used to allocate PGDs for both user and kernel pagetables (e.g.
> for the efi runtime services), so while this may fix the regression, I'm
> not sure it's the right fix.

I see that since [1], pgd_alloc() was updated to special-case the
init_mm, which is not sufficient for cases like:

	efi_mm.pgd = pgd_alloc(&efi_mm)

... which occurs in a kthread.

So let's have a pgd_alloc_kernel() to make that explicit.

Thanks,
Mark.

