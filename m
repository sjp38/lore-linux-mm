Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D2F8C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:00:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E102089E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:00:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E102089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614F26B02B0; Thu, 15 Aug 2019 12:00:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C62C6B02B2; Thu, 15 Aug 2019 12:00:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DB7C6B02B3; Thu, 15 Aug 2019 12:00:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3C36B02B0
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:00:45 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C94946408
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:00:44 +0000 (UTC)
X-FDA: 75825125208.06.time57_7adb419d8f738
X-HE-Tag: time57_7adb419d8f738
X-Filterd-Recvd-Size: 7112
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:00:44 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A4EFBAD7C;
	Thu, 15 Aug 2019 16:00:42 +0000 (UTC)
Date: Thu, 15 Aug 2019 18:00:41 +0200
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
Message-ID: <20190815155950.GN9477@dhcp22.suse.cz>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815141219.GF21596@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 11:12:19, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 03:21:27PM +0200, Michal Hocko wrote:
> > On Thu 15-08-19 09:23:44, Jason Gunthorpe wrote:
> > > On Thu, Aug 15, 2019 at 08:58:29AM +0200, Daniel Vetter wrote:
> > > > On Wed, Aug 14, 2019 at 08:58:05PM -0300, Jason Gunthorpe wrote:
> > > > > On Wed, Aug 14, 2019 at 10:20:24PM +0200, Daniel Vetter wrote:
> > > > > > In some special cases we must not block, but there's not a
> > > > > > spinlock, preempt-off, irqs-off or similar critical section already
> > > > > > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > > > > > pair to annotate these.
> > > > > > 
> > > > > > This will be used in the oom paths of mmu-notifiers, where blocking is
> > > > > > not allowed to make sure there's forward progress. Quoting Michal:
> > > > > > 
> > > > > > "The notifier is called from quite a restricted context - oom_reaper -
> > > > > > which shouldn't depend on any locks or sleepable conditionals. The code
> > > > > > should be swift as well but we mostly do care about it to make a forward
> > > > > > progress. Checking for sleepable context is the best thing we could come
> > > > > > up with that would describe these demands at least partially."
> > > > > 
> > > > > But this describes fs_reclaim_acquire() - is there some reason we are
> > > > > conflating fs_reclaim with non-sleeping?
> > > > 
> > > > No idea why you tie this into fs_reclaim. We can definitly sleep in there,
> > > > and for e.g. kswapd (which also wraps everything in fs_reclaim) we're
> > > > event supposed to I thought. To make sure we can get at the last bit of
> > > > memory by flushing all the queues and waiting for everything to be cleaned
> > > > out.
> > > 
> > > AFAIK the point of fs_reclaim is to prevent "indirect dependency upon
> > > the page allocator" ie a justification that was given this !blockable
> > > stuff.
> > > 
> > > For instance:
> > > 
> > >   fs_reclaim_acquire()
> > >   kmalloc(GFP_KERNEL) <- lock dep assertion
> > > 
> > > And further, Michal's concern about indirectness through locks is also
> > > handled by lockdep:
> > > 
> > >        CPU0                                 CPU1
> > >                                         mutex_lock()
> > >                                         kmalloc(GFP_KERNEL)
> > >                                         mutex_unlock()
> > >   fs_reclaim_acquire()
> > >   mutex_lock() <- lock dep assertion
> > > 
> > > In other words, to prevent recursion into the page allocator you use
> > > fs_reclaim_acquire(), and lockdep verfies it in its usual robust way.
> > 
> > fs_reclaim_acquire is about FS/IO recursions IIUC. We are talking about
> > any !GFP_NOWAIT allocation context here and any {in}direct dependency on
> > it. 
> 
> AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> __GFP_DIRECT_RECLAIM..
>
> This matches the existing test in __need_fs_reclaim() - so if you are
> OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(),
> allocations during OOM, then I think fs_reclaim already matches what
> you described?

No GFP_NOFS is equally bad. Please read my other email explaining what
the oom_reaper actually requires. In short no blocking on direct or
indirect dependecy on memory allocation that might sleep. If you can
express that in the existing lockdep machinery. All fine. But then
consider deployments where lockdep is no-no because of the overhead.

> > No, non-blocking is a very coarse approximation of what we really need.
> > But it should give us even a stronger condition. Essentially any sleep
> > other than a preemption shouldn't be allowed in that context.
> 
> But it is a nonsense API to give the driver invalidate_range_start,
> the blocking alternative to the non-blocking invalidate_range and then
> demand it to be non-blocking.
> 
> Inspecting the code, no drivers are actually able to progress their
> side in non-blocking mode.
> 
> The best we got was drivers tested the VA range and returned success
> if they had no interest. Which is a big win to be sure, but it looks
> like getting any more is not really posssible.

And that is already a great win! Because many notifiers only do care
about particular mappings. Please note that backing off unconditioanlly
will simply cause that the oom reaper will have to back off not doing
any tear down anything.

> However, we could (probably even should) make the drivers fs_reclaim
> safe.
> 
> If that is enough to guarantee progress of OOM, then lets consider
> something like using current_gfp_context() to force PF_MEMALLOC_NOFS
> allocation behavior on the driver callback and lockdep to try and keep
> pushing on the the debugging, and dropping !blocking.

How are you going to enforce indirect dependency? E.g. a lock that is
also used in other context which depend on sleepable memory allocation
to move forward.

Really, this was aimed to give a very simple debugging aid. If it is
considered to be so controversial, even though I really do not see why,
then let's just drop it on the floor.
-- 
Michal Hocko
SUSE Labs

