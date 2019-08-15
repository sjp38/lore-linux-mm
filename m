Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B5BC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:42:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 388602084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:42:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 388602084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2CEF6B02FA; Thu, 15 Aug 2019 13:42:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB6226B02FB; Thu, 15 Aug 2019 13:42:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7D7F6B02FC; Thu, 15 Aug 2019 13:42:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 9EACD6B02FA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:42:12 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3E2E27597
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:42:12 +0000 (UTC)
X-FDA: 75825380904.09.cream78_8797d0120a040
X-HE-Tag: cream78_8797d0120a040
X-Filterd-Recvd-Size: 6228
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:42:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF351ACA5;
	Thu, 15 Aug 2019 17:42:09 +0000 (UTC)
Date: Thu, 15 Aug 2019 19:42:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815174207.GR9477@dhcp22.suse.cz>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815165631.GK21596@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 13:56:31, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 06:00:41PM +0200, Michal Hocko wrote:
> 
> > > AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> > > __GFP_DIRECT_RECLAIM..
> > >
> > > This matches the existing test in __need_fs_reclaim() - so if you are
> > > OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(),
> > > allocations during OOM, then I think fs_reclaim already matches what
> > > you described?
> > 
> > No GFP_NOFS is equally bad. Please read my other email explaining what
> > the oom_reaper actually requires. In short no blocking on direct or
> > indirect dependecy on memory allocation that might sleep.
> 
> It is much easier to follow with some hints on code, so the true
> requirement is that the OOM repear not block on GFP_FS and GFP_IO
> allocations, great, that constraint is now clear.

I still do not get why do you put FS/IO into the picture. This is really
about __GFP_DIRECT_RECLAIM.

> 
> > If you can express that in the existing lockdep machinery. All
> > fine. But then consider deployments where lockdep is no-no because
> > of the overhead.
> 
> This is all for driver debugging. The point of lockdep is to find all
> these paths without have to hit them as actual races, using debug
> kernels.
> 
> I don't think we need this kind of debugging on production kernels?

Again, the primary motivation was a simple debugging aid that could be
used without worrying about overhead. So lockdep is very often out of
the question.

> > > The best we got was drivers tested the VA range and returned success
> > > if they had no interest. Which is a big win to be sure, but it looks
> > > like getting any more is not really posssible.
> > 
> > And that is already a great win! Because many notifiers only do care
> > about particular mappings. Please note that backing off unconditioanlly
> > will simply cause that the oom reaper will have to back off not doing
> > any tear down anything.
> 
> Well, I'm working to propose that we do the VA range test under core
> mmu notifier code that cannot block and then we simply remove the idea
> of blockable from drivers using this new 'range notifier'. 
> 
> I think this pretty much solves the concern?

Well, my idea was that a range check and early bail out was a first step
and then each specific notifier would be able to do a more specific
check. I was not able to do the second step because that requires a deep
understanding of the respective subsystem.

Really all I do care about is to reclaim as much memory from the
oom_reaper context as possible. And that cannot really be an unbounded
process. Quite contrary it should be as swift as possible. From my
cursory look some notifiers are able to achieve their task without
blocking or depending on memory just fine. So bailing out
unconditionally on the range of interest would just put us back.

> > > However, we could (probably even should) make the drivers fs_reclaim
> > > safe.
> > > 
> > > If that is enough to guarantee progress of OOM, then lets consider
> > > something like using current_gfp_context() to force PF_MEMALLOC_NOFS
> > > allocation behavior on the driver callback and lockdep to try and keep
> > > pushing on the the debugging, and dropping !blocking.
> > 
> > How are you going to enforce indirect dependency? E.g. a lock that is
> > also used in other context which depend on sleepable memory allocation
> > to move forward.
> 
> You mean like this:
> 
>        CPU0                                 CPU1
>                                         mutex_lock()
>                                         kmalloc(GFP_KERNEL)

no I mean __GFP_DIRECT_RECLAIM here.

>                                         mutex_unlock()
>   fs_reclaim_acquire()
>   mutex_lock() <- illegal: lock dep assertion

I cannot really comment on how that is achieveable by lockdep. I managed
to forget details about FS/IO reclaim recursion tracking already and I
do not have time to learn it again. It was quite a hack. Anyway, let me
repeat that the primary motivation was a simple aid. Not something as
poverful as lockdep.
-- 
Michal Hocko
SUSE Labs

