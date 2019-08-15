Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6A37C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75B262083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:57:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75B262083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1026F6B02FF; Thu, 15 Aug 2019 13:57:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B2D26B0300; Thu, 15 Aug 2019 13:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F03AC6B0301; Thu, 15 Aug 2019 13:57:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6166B02FF
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:57:25 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6FB9C181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:57:25 +0000 (UTC)
X-FDA: 75825419250.28.rate32_7af6d6867c751
X-HE-Tag: rate32_7af6d6867c751
X-Filterd-Recvd-Size: 7690
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:57:24 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B3C0D3083363;
	Thu, 15 Aug 2019 17:57:23 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E61018CBB9;
	Thu, 15 Aug 2019 17:57:21 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:57:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815175720.GJ30916@redhat.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815174207.GR9477@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 15 Aug 2019 17:57:24 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 07:42:07PM +0200, Michal Hocko wrote:
> On Thu 15-08-19 13:56:31, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 06:00:41PM +0200, Michal Hocko wrote:
> >=20
> > > > AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> > > > __GFP_DIRECT_RECLAIM..
> > > >
> > > > This matches the existing test in __need_fs_reclaim() - so if you=
 are
> > > > OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_page=
s(),
> > > > allocations during OOM, then I think fs_reclaim already matches w=
hat
> > > > you described?
> > >=20
> > > No GFP_NOFS is equally bad. Please read my other email explaining w=
hat
> > > the oom_reaper actually requires. In short no blocking on direct or
> > > indirect dependecy on memory allocation that might sleep.
> >=20
> > It is much easier to follow with some hints on code, so the true
> > requirement is that the OOM repear not block on GFP_FS and GFP_IO
> > allocations, great, that constraint is now clear.
>=20
> I still do not get why do you put FS/IO into the picture. This is reall=
y
> about __GFP_DIRECT_RECLAIM.
>=20
> >=20
> > > If you can express that in the existing lockdep machinery. All
> > > fine. But then consider deployments where lockdep is no-no because
> > > of the overhead.
> >=20
> > This is all for driver debugging. The point of lockdep is to find all
> > these paths without have to hit them as actual races, using debug
> > kernels.
> >=20
> > I don't think we need this kind of debugging on production kernels?
>=20
> Again, the primary motivation was a simple debugging aid that could be
> used without worrying about overhead. So lockdep is very often out of
> the question.
>=20
> > > > The best we got was drivers tested the VA range and returned succ=
ess
> > > > if they had no interest. Which is a big win to be sure, but it lo=
oks
> > > > like getting any more is not really posssible.
> > >=20
> > > And that is already a great win! Because many notifiers only do car=
e
> > > about particular mappings. Please note that backing off unconditioa=
nlly
> > > will simply cause that the oom reaper will have to back off not doi=
ng
> > > any tear down anything.
> >=20
> > Well, I'm working to propose that we do the VA range test under core
> > mmu notifier code that cannot block and then we simply remove the ide=
a
> > of blockable from drivers using this new 'range notifier'.=20
> >=20
> > I think this pretty much solves the concern?
>=20
> Well, my idea was that a range check and early bail out was a first ste=
p
> and then each specific notifier would be able to do a more specific
> check. I was not able to do the second step because that requires a dee=
p
> understanding of the respective subsystem.
>=20
> Really all I do care about is to reclaim as much memory from the
> oom_reaper context as possible. And that cannot really be an unbounded
> process. Quite contrary it should be as swift as possible. From my
> cursory look some notifiers are able to achieve their task without
> blocking or depending on memory just fine. So bailing out
> unconditionally on the range of interest would just put us back.

Agree, OOM just asking the question: can i unmap that page quickly ?
so that me (OOM) can swap it out. In many cases the driver need to
lookup something to see if at the time the memory is just not in use
and can be reclaim right away. So driver should have a path to
optimistically update its state to allow quick reclaim.


> > > > However, we could (probably even should) make the drivers fs_recl=
aim
> > > > safe.
> > > >=20
> > > > If that is enough to guarantee progress of OOM, then lets conside=
r
> > > > something like using current_gfp_context() to force PF_MEMALLOC_N=
OFS
> > > > allocation behavior on the driver callback and lockdep to try and=
 keep
> > > > pushing on the the debugging, and dropping !blocking.
> > >=20
> > > How are you going to enforce indirect dependency? E.g. a lock that =
is
> > > also used in other context which depend on sleepable memory allocat=
ion
> > > to move forward.
> >=20
> > You mean like this:
> >=20
> >        CPU0                                 CPU1
> >                                         mutex_lock()
> >                                         kmalloc(GFP_KERNEL)
>=20
> no I mean __GFP_DIRECT_RECLAIM here.
>=20
> >                                         mutex_unlock()
> >   fs_reclaim_acquire()
> >   mutex_lock() <- illegal: lock dep assertion
>=20
> I cannot really comment on how that is achieveable by lockdep. I manage=
d
> to forget details about FS/IO reclaim recursion tracking already and I
> do not have time to learn it again. It was quite a hack. Anyway, let me
> repeat that the primary motivation was a simple aid. Not something as
> poverful as lockdep.

I feel that the fs_reclaim_acquire() is just too heavy weight here. I
do think that Daniel patches improve the debugging situation without
burdening anything so i am in favor or merging that.

I do not think we should devote too much time into fs_reclaim(), our
time would be better spend in improving the driver shrinker for instance
after all OOM is all about trying to free-up memory.

Cheers,
J=E9r=F4me

