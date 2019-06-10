Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24840C28D16
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EABA720859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:43:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EABA720859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 805B16B026A; Mon, 10 Jun 2019 07:43:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B4C86B026B; Mon, 10 Jun 2019 07:43:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67CC56B026C; Mon, 10 Jun 2019 07:43:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE9F6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:43:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so7700785eds.14
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:43:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5VIeso6hwJNuty1r//SJjvfOEHsobEFFJKwVeeFiYqM=;
        b=C3bWI16BHEXyv0kQkoTSN8QOxb08+Ha0lR/gbcXc29JRGZq+PSUV76PpjjbwHstvOa
         7n/CB70HJpDR4hl/H4aqcGo9KhdWuhcXzXOart3/H5j9izP8BlP0M1fcj6RXCP5M7MGR
         vxaxbDaVu5ApyEFfTQDd3Pvsc7qzZXOiSpX6fDlTiwvcEAoRT+mWoo8sY8jcuvqYBxDV
         +EfIYEyUu+akeVQfY23qN4Olik24G2PbaSaM8ID9BNDIxyCOOrzWvEX7G9Mn5a+0F1/C
         gtxqHEdbCiAoHUGkaPYVYA1sPz3Sf4y+rsVbyImE99miC0+z1bloJIyAGivELCe2IlkJ
         MCQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAUI6KPyR8hF60gKgm3Te+Ab/FxCkveH4Be2DghGW4X9KcI8UoUL
	RSxQMsoYkYwVZLQas5inGdx0kXoUcdzyTNciz9fjCL4wJNK0Q+Z9bz/ZfU9wSY3Jhl96V9PNKDz
	/Hdr8xVwCOT0OZnmDuRqND77H0091X3P3sGEZiTKrcgzVLrLb0xiLnNJIuS1ruYk0iQ==
X-Received: by 2002:a17:906:546:: with SMTP id k6mr54670443eja.53.1560167012558;
        Mon, 10 Jun 2019 04:43:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZkYRwI4eJudmoeNhz/mlCdYG+mfyl1J/ZEN8fl0B/rt4fPCXZ+3LRem7xdA+vF8SMIpjL
X-Received: by 2002:a17:906:546:: with SMTP id k6mr54670380eja.53.1560167011483;
        Mon, 10 Jun 2019 04:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560167011; cv=none;
        d=google.com; s=arc-20160816;
        b=K6Ingq/oLMNewRVA+KT9Tgzd/TKN1g5oLuQ/GW4bJZch0XEjitfwkGLuR9VmkiCT/w
         YVqQC3DCD0JNvMJfCxQ9FseGqAKrLtcKHPj5KIHWd64G20RE6Ufb+K/5BnVkFAIyB/BH
         Rjoz4iyxvpho3zTTmlGvOHlujkufJyZqVe7xdskg9xmwcLLyE9TLkp85URXrnmSsKny7
         EWU21KIhPGAdrKpxgSBke3hYJjzTj807AIN7oIDXb2E9+m+F/6v12RhVjSdjj1f4fobi
         dMue4vMmjL+v3YbDp67f6SVhlo7NLGJGHviK1+JMp9jiNOVTdzDWHM/H/s9rEuKbDdU2
         0q8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5VIeso6hwJNuty1r//SJjvfOEHsobEFFJKwVeeFiYqM=;
        b=CqdfUJ7fQFPBGS9lWCNjm+F7lobOzVfddklVGYzV1HeSxjhFomib+ZV9V7NJRwT0Au
         oZlgzSZwDh2XKiTycE61ZEW9BQoQGUk4IAf1/Fem/OHGkXqJIvREPiEywQVzJuGWZKAT
         s5jBgVWZpuAtedCJJiDWNs3+D55aZlYuUSctsRxEJgQ4FoVfM5CNDidUY+ENjrLF0s0D
         SasXgB8ORnt56cwBIEJZ6fbkx/y3ULTPBDc1PrhRur6kJUA3Y3AniqLjZJEILrDmOK/B
         Zz15HAhpBTIL0iDz3xvGac+c5Knf2RcpXKsgZjKGcearbtUY7IdfK6f9S6v064gdY+33
         a8DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l20si4987401edc.154.2019.06.10.04.43.31
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 04:43:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7FE98337;
	Mon, 10 Jun 2019 04:43:30 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C6AD23F557;
	Mon, 10 Jun 2019 04:45:10 -0700 (PDT)
Date: Mon, 10 Jun 2019 12:43:26 +0100
From: Will Deacon <will.deacon@arm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Qian Cai <cai@lca.pw>, rppt@linux.ibm.com, akpm@linux-foundation.org,
	catalin.marinas@arm.com, linux-kernel@vger.kernel.org,
	mhocko@kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com,
	hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190610114326.GF15979@fuggles.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604142338.GC24467@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
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
> > 
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
> 
> Do we need a separate pgd_alloc_kernel()?

So can I take the above for -rc5, or is somebody else working on a different
fix to implement pgd_alloc_kernel()?

/confused

Will

