Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88096C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:34:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48DD0233A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:34:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PrkJUu0e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48DD0233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7AB96B0311; Wed, 21 Aug 2019 12:34:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51BF6B0312; Wed, 21 Aug 2019 12:34:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C67896B0313; Wed, 21 Aug 2019 12:34:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0249.hostedemail.com [216.40.44.249])
	by kanga.kvack.org (Postfix) with ESMTP id A74486B0311
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:34:32 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4A8848248AC2
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:34:32 +0000 (UTC)
X-FDA: 75846983184.08.nest75_2790410385212
X-HE-Tag: nest75_2790410385212
X-Filterd-Recvd-Size: 3131
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:34:31 +0000 (UTC)
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 341A4216F4;
	Wed, 21 Aug 2019 16:34:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566405270;
	bh=5Wgi6CnBitr8ACVrtl4JVmT0TPh0c47DtZIL3lbp9vU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=PrkJUu0etYaUGZS+v8/uAltPsgcPd9gxnCWBiNdyLS5S1qhXPBBVz3rpEtQM+aBsC
	 Vi8RarU3iehaMSrpbMB4Bhl9++Ge014SO+azWllZkJaMBTpMG62XQp2xWyZbjNL4LX
	 DLh5DKpl+roNAw2AHV6bYv4FTlRnhyu1T9ymt9+k=
Date: Wed, 21 Aug 2019 17:34:26 +0100
From: Will Deacon <will@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: consolidate pgtable_cache_init() and pgd_cache_init()
Message-ID: <20190821163425.6jwxbvspjzqxysxc@willie-the-truck>
References: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
 <20190821154942.js4u466rolnekwmq@willie-the-truck>
 <20190821160159.GG26713@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821160159.GG26713@rapoport-lnx>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 07:01:59PM +0300, Mike Rapoport wrote:
> On Wed, Aug 21, 2019 at 04:49:42PM +0100, Will Deacon wrote:
> > On Wed, Aug 21, 2019 at 06:06:58PM +0300, Mike Rapoport wrote:
> > > diff --git a/init/main.c b/init/main.c
> > > index b90cb5f..2fa8038 100644
> > > --- a/init/main.c
> > > +++ b/init/main.c
> > > @@ -507,7 +507,7 @@ void __init __weak mem_encrypt_init(void) { }
> > >  
> > >  void __init __weak poking_init(void) { }
> > >  
> > > -void __init __weak pgd_cache_init(void) { }
> > > +void __init __weak pgtable_cache_init(void) { }
> > >  
> > >  bool initcall_debug;
> > >  core_param(initcall_debug, initcall_debug, bool, 0644);
> > > @@ -565,7 +565,6 @@ static void __init mm_init(void)
> > >  	init_espfix_bsp();
> > >  	/* Should be run after espfix64 is set up. */
> > >  	pti_init();
> > > -	pgd_cache_init();
> > >  }
> > 
> > AFAICT, this change means we now initialise our pgd cache before
> > debug_objects_mem_init() has run.
> 
> Right.
> 
> > Is that going to cause fireworks with CONFIG_DEBUG_OBJECTS when we later
> > free a pgd?
> 
> We don't allocate a pgd at that time, we only create the kmem cache for the
> future allocations. And that cache is never destroyed anyway.

Thanks for the explanation. In which case, for arm64:

Acked-by: Will Deacon <will@kernel.org>

Will

