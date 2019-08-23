Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 342B5C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 08:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8F5C206BA
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 08:48:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P6eKagAL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8F5C206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 380F96B0389; Fri, 23 Aug 2019 04:48:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30A696B038A; Fri, 23 Aug 2019 04:48:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D23B6B038B; Fri, 23 Aug 2019 04:48:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0193.hostedemail.com [216.40.44.193])
	by kanga.kvack.org (Postfix) with ESMTP id E94A06B0389
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:48:24 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8FD4B180AD7C1
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:48:24 +0000 (UTC)
X-FDA: 75853066128.09.fuel29_f22320114a36
X-HE-Tag: fuel29_f22320114a36
X-Filterd-Recvd-Size: 6542
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:48:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:To:From:Date:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7s9/nci+zKyvrE92H9Lp/Liq0lrM5HNKhcwL7sRJw+4=; b=P6eKagALn8nMspRlT5ktoTdyRi
	EJMa61U6Y0iSY8RaLjdPRr77ly3h6vUScMsTZrWkUBrBqE3vXFEvaoagy2NMYcOpOJHcslrk5VKn2
	2nroaMZss/Rv2u5Qaqh9AWTDRg0zOg4sqb3QW4/JUaO1luNcGy8Yt345WcvQIpkHW5/NBWKLbpfwW
	nsdaqhbiKoEyLRU4OzJeYFwB8Udi0RSzefldCm1Fhc/tVL9iYpB2NCqtJjhHL3Pi939WHS/qV1XN9
	2lCLbOBIjA9+feGg4R8SM6OQa6s8WpBgzTEydowrpjEApaqiiLp6b/5ELAhy9r3SIMP+RjfnF9XaV
	UbGf8VRQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i15Et-0002rs-2t; Fri, 23 Aug 2019 08:48:07 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id B3CE3307764;
	Fri, 23 Aug 2019 10:47:31 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DD53F20A21FCF; Fri, 23 Aug 2019 10:48:03 +0200 (CEST)
Date: Fri, 23 Aug 2019 10:48:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
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
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
Message-ID: <20190823084803.GD2369@hirez.programming.kicks-ass.net>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch>
 <20190820202440.GH11147@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190820202440.GH11147@phenom.ffwll.local>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:24:40PM +0200, Daniel Vetter wrote:
> On Tue, Aug 20, 2019 at 10:19:01AM +0200, Daniel Vetter wrote:
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> >=20
> > This will be used in the oom paths of mmu-notifiers, where blocking i=
s
> > not allowed to make sure there's forward progress. Quoting Michal:
> >=20
> > "The notifier is called from quite a restricted context - oom_reaper =
-
> > which shouldn't depend on any locks or sleepable conditionals. The co=
de
> > should be swift as well but we mostly do care about it to make a forw=
ard
> > progress. Checking for sleepable context is the best thing we could c=
ome
> > up with that would describe these demands at least partially."
> >=20
> > Peter also asked whether we want to catch spinlocks on top, but Micha=
l
> > said those are less of a problem because spinlocks can't have an
> > indirect dependency upon the page allocator and hence close the loop
> > with the oom reaper.
> >=20
> > Suggested by Michal Hocko.
> >=20
> > v2:
> > - Improve commit message (Michal)
> > - Also check in schedule, not just might_sleep (Peter)
> >=20
> > v3: It works better when I actually squash in the fixup I had lying
> > around :-/
> >=20
> > v4: Pick the suggestion from Andrew Morton to give non_block_start/en=
d
> > some good kerneldoc comments. I added that other blocking calls like
> > wait_event pose similar issues, since that's the other example we
> > discussed.
> >=20
> > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: "Christian K=F6nig" <christian.koenig@amd.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Cc: Wei Wang <wvw@google.com>
> > Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Jann Horn <jannh@google.com>
> > Cc: Feng Tang <feng.tang@intel.com>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: linux-kernel@vger.kernel.org
> > Acked-by: Christian K=F6nig <christian.koenig@amd.com> (v1)
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>=20
> Hi Peter,
>=20
> Iirc you've been involved at least somewhat in discussing this. -mm fol=
ks
> are a bit undecided whether these new non_block semantics are a good id=
ea.
> Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
> are less enthusiastic. Jason said he's ok with merging the hmm side of
> this if scheduler folks ack. If not, then I'll respin with the
> preempt_disable/enable instead like in v1.
>=20
> So ack/nack for this from the scheduler side?

Right, I had memories of seeing this before, and I just found a fairly
long discussion on this elsewhere in the vacation inbox (*groan*).

Yeah, this is something I can live with,

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

