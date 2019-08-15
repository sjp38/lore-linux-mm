Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65291C3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32630205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32630205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B362E6B02D9; Thu, 15 Aug 2019 13:12:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8276B02DA; Thu, 15 Aug 2019 13:12:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FC136B02DB; Thu, 15 Aug 2019 13:12:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7C46B02D9
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:12:03 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 367068248AA5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:12:03 +0000 (UTC)
X-FDA: 75825304926.21.slave87_11cd38ee4c13d
X-HE-Tag: slave87_11cd38ee4c13d
X-Filterd-Recvd-Size: 4812
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:12:02 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 732FD30832E1;
	Thu, 15 Aug 2019 17:12:00 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9562687A9;
	Thu, 15 Aug 2019 17:11:58 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:11:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
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
Message-ID: <20190815171156.GB30916@redhat.com>
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
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815165631.GK21596@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 15 Aug 2019 17:12:00 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 01:56:31PM -0300, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 06:00:41PM +0200, Michal Hocko wrote:
>=20
> > > AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> > > __GFP_DIRECT_RECLAIM..
> > >
> > > This matches the existing test in __need_fs_reclaim() - so if you a=
re
> > > OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(=
),
> > > allocations during OOM, then I think fs_reclaim already matches wha=
t
> > > you described?
> >=20
> > No GFP_NOFS is equally bad. Please read my other email explaining wha=
t
> > the oom_reaper actually requires. In short no blocking on direct or
> > indirect dependecy on memory allocation that might sleep.
>=20
> It is much easier to follow with some hints on code, so the true
> requirement is that the OOM repear not block on GFP_FS and GFP_IO
> allocations, great, that constraint is now clear.
>=20
> > If you can express that in the existing lockdep machinery. All
> > fine. But then consider deployments where lockdep is no-no because
> > of the overhead.
>=20
> This is all for driver debugging. The point of lockdep is to find all
> these paths without have to hit them as actual races, using debug
> kernels.
>=20
> I don't think we need this kind of debugging on production kernels?
>=20
> > > The best we got was drivers tested the VA range and returned succes=
s
> > > if they had no interest. Which is a big win to be sure, but it look=
s
> > > like getting any more is not really posssible.
> >=20
> > And that is already a great win! Because many notifiers only do care
> > about particular mappings. Please note that backing off unconditioanl=
ly
> > will simply cause that the oom reaper will have to back off not doing
> > any tear down anything.
>=20
> Well, I'm working to propose that we do the VA range test under core
> mmu notifier code that cannot block and then we simply remove the idea
> of blockable from drivers using this new 'range notifier'.=20
>=20
> I think this pretty much solves the concern?

I am not sure i follow what you propose here ? Like i pointed out in
another email for GPU we do need to be able to sleep (we might get
lucky and not need too but this is runtime thing) within notifier
range_start callback. This has been something allow by notifier since
it has been introduced in the kernel.

Cheers,
J=E9r=F4me

