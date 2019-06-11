Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8499C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:03:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A8B92089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:03:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A8B92089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 049596B0005; Tue, 11 Jun 2019 06:03:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F39DC6B0006; Tue, 11 Jun 2019 06:03:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E28C46B0007; Tue, 11 Jun 2019 06:03:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9327E6B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:03:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so19986497edb.1
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:03:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=V4QlTEw+q36zIvVdvDv50lMJ/H3OlbUBfwqyh+5MN8Q=;
        b=nxOMyjPYDu5rD054h2JH8suIdyNgJMqxifAK5jQpGizBDOWhj9kV7qaaezGb4266sj
         GONV5RWj2/plMyM151Mi9eWdxhiusfT5RvzzhtPAabrfd2YpMNE3IdCSUIHCfDRiOQGb
         y/vo7HOgGRWFYstfT+OX9H2zFcoq/Gi77YWteZmYTUOJETlYHb22towmuIoHTkXrbBq+
         qS7NLcQb+ckNESeeS9tsB35qUnJsmrOYTvpJ11MYFEdbuF6761O2hIWC+3kXktJqnP+j
         tCjHafHRQz2Hcm9zt4xhCWtap4l3Z/VY5LqsENvjSb9Adb9RH1DWJM/NiGp3vqVT6110
         +zcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWkH7mhOdCZmuzhT+HOjwz0Yr7pY8PTP2HqWDKBUNZnKhUjz2PA
	t1M+OgcT0eH3/9mqWEXpgKlrsHY6bvnI+T+AL//9ThLGBzc9f5UgsMXEGxEvwoRJ9MPkWGxSj+Z
	RX98SC7tA2/D8dnglZ+ei1XVGxI6c2Kx/2tmMOEXHMtlqjTWcHWzDETQUFW6lS3Qb1w==
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr40209216ejv.106.1560247435097;
        Tue, 11 Jun 2019 03:03:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyotY2RLfv+EevrgJcte0kzZ0V2pVTxRPY2fGoVgGQtNbXlbI2u8EWakgZnCh5oGhKuSCA3
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr40209159ejv.106.1560247434250;
        Tue, 11 Jun 2019 03:03:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560247434; cv=none;
        d=google.com; s=arc-20160816;
        b=HPB7JU5ZfIjaXG890geLLAUrfrw3vAS2ojtl+bfsTTptRK1PEzdyIn9kzXu3+wT8oX
         IvSwQiqiOIAPZsTBQYDUgUrzS/LrcumCW/IgApZeFvGmRVbMdfNirqUPSCiuLCmCDJjj
         f8a4M+0YmAKLsDLOJ2M+an5d1PnHyONAUztb5l1sA0Kk1BuBGGdww3NtuljvOA1xnWDp
         809zRTkFpDHCGddyrYKQuVUAOwAepA7+Zj2a7U3arpQKIzw1oLb6/TNoVWX6Qc9VnJxr
         kI0f+QTKC7QRNrQos/g/Ew6Aax9K2FFt9FwlM1S8iEUcKgWJCzGJyW1D51ce69NUbsN5
         C7LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=V4QlTEw+q36zIvVdvDv50lMJ/H3OlbUBfwqyh+5MN8Q=;
        b=K4RNJMf1A2qBEJHXjMq29y0WOUF8qxxiWEyC3H0USgfF5jGd9WzcYjahEr0+qGDO5z
         Q6Ta7SMHGlrUoiXBT3xOwODKMRTcSS6//LEiBTwec8uHOVKfTV4oEk2xdRJCJFY6cPZj
         9XJOxyy9EpyhwF8HnHCvV1EhRPkFwqpN5aZ3ycEU2sjGyTxYEcHd0SuMUVDOXXxSaDLt
         /dCee9tnkGtiy/YNVtxJzXXUBzHQ0R0he6Fx7bdoTCqfBizJCxgpy+JiekbHLKJC72hs
         yqpYgLWH8za2B05SyZH7BJ3LHjJfLmI3Uf35GEacBnhrtA+PmxCHGU0D4hm/mCdugfZL
         0xjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d21si88630ejk.284.2019.06.11.03.03.53
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 03:03:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3292A337;
	Tue, 11 Jun 2019 03:03:53 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F1B7C3F73C;
	Tue, 11 Jun 2019 03:05:33 -0700 (PDT)
Date: Tue, 11 Jun 2019 11:03:49 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Qian Cai <cai@lca.pw>, rppt@linux.ibm.com
Cc: Will Deacon <will.deacon@arm.com>, akpm@linux-foundation.org,
	catalin.marinas@arm.com, linux-kernel@vger.kernel.org,
	mhocko@kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com,
	hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190611100348.GB26409@lakrids.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1560187575.6132.70.camel@lca.pw>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 01:26:15PM -0400, Qian Cai wrote:
> On Mon, 2019-06-10 at 12:43 +0100, Will Deacon wrote:
> > On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> > > On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > > > The commit "arm64: switch to generic version of pte allocation"
> > > > introduced endless failures during boot like,
> > > > 
> > > > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > > > -2 parent: cgroup)
> > > > 
> > > > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > > > and then later memcg finds out those don't belong to any cgroup.
> > > 
> > > Mike, I understood from [1] that this wasn't expected to be a problem,
> > > as the accounting should bypass kernel threads.
> > > 
> > > Was that assumption wrong, or is something different happening here?
> > > 
> > > > 
> > > > backtrace:
> > > >   kobject_add_internal
> > > >   kobject_init_and_add
> > > >   sysfs_slab_add+0x1a8
> > > >   __kmem_cache_create
> > > >   create_cache
> > > >   memcg_create_kmem_cache
> > > >   memcg_kmem_cache_create_func
> > > >   process_one_work
> > > >   worker_thread
> > > >   kthread
> > > > 
> > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > ---
> > > >  arch/arm64/mm/pgd.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > > > index 769516cb6677..53c48f5c8765 100644
> > > > --- a/arch/arm64/mm/pgd.c
> > > > +++ b/arch/arm64/mm/pgd.c
> > > > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> > > >  	if (PGD_SIZE == PAGE_SIZE)
> > > >  		return (pgd_t *)__get_free_page(gfp);
> > > >  	else
> > > > -		return kmem_cache_alloc(pgd_cache, gfp);
> > > > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> > > 
> > > This is used to allocate PGDs for both user and kernel pagetables (e.g.
> > > for the efi runtime services), so while this may fix the regression, I'm
> > > not sure it's the right fix.
> > > 
> > > Do we need a separate pgd_alloc_kernel()?
> > 
> > So can I take the above for -rc5, or is somebody else working on a different
> > fix to implement pgd_alloc_kernel()?
> 
> The offensive commit "arm64: switch to generic version of pte allocation" is not
> yet in the mainline, but only in the Andrew's tree and linux-next, and I doubt
> Andrew will push this out any time sooner given it is broken.

I'd assumed that Mike would respin these patches to implement and use
pgd_alloc_kernel() (or take gfp flags) and the updated patches would
replace these in akpm's tree.

Mike, could you confirm what your plan is? I'm happy to review/test
updated patches for arm64.

Thanks,
Mark.

