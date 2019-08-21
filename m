Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7030C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 11:21:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6556522CE3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 11:21:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6556522CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A953B6B02B8; Wed, 21 Aug 2019 07:21:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45C56B02BB; Wed, 21 Aug 2019 07:21:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95B1F6B02BC; Wed, 21 Aug 2019 07:21:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id 743D06B02B8
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:21:23 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1B6DE8248ABF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:21:23 +0000 (UTC)
X-FDA: 75846194046.27.voice65_463c1769ee94b
X-HE-Tag: voice65_463c1769ee94b
X-Filterd-Recvd-Size: 4152
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:21:22 +0000 (UTC)
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1i0Og0-0002OL-FH; Wed, 21 Aug 2019 13:21:16 +0200
Date: Wed, 21 Aug 2019 13:21:16 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190821112116.d4lejm6nai7uavcy@linutronix.de>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
 <20190211210208.GA9580@cmpxchg.org>
 <20190213092754.baxi5zpe7kdpf3bj@linutronix.de>
 <20190213145656.GA25205@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190213145656.GA25205@cmpxchg.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sorry, I somehow forgot about this=E2=80=A6

On 2019-02-13 09:56:56 [-0500], Johannes Weiner wrote:
> On Wed, Feb 13, 2019 at 10:27:54AM +0100, Sebastian Andrzej Siewior wrote:
> > On 2019-02-11 16:02:08 [-0500], Johannes Weiner wrote:
> > > > how do you define safe? I've been looking for dependencies of
> > > > __mod_lruvec_state() but found only that the lock is held during th=
e RMW
> > > > operation with WORKINGSET_NODES idx.
> > >=20
> > > These stat functions are not allowed to nest, and the executing thread
> > > cannot migrate to another CPU during the operation, otherwise they
> > > corrupt the state they're modifying.
> >=20
> > If everyone is taking the same lock (like i_pages.xa_lock) then there
> > will not be two instances updating the same stat. The owner of the
> > (sleeping)-spinlock will not be migrated to another CPU.
>=20
> This might be true for this particular stat item, but they are general
> VM statistics. They're assuredly not all taking the xa_lock.

This one in particular does and my guess is that the interrupts are
disabled here because of xa_lock. So the question is why should the
interrupts be disabled? Is this due to the lock that should have been
acquired (and as such disable interrupts) _or_ because of the
*_lruvec_slab_state() operation.

> > > They are called from interrupt handlers, such as when NR_WRITEBACK is
> > > decreased. Thus workingset_node_update() must exclude preemption from
> > > irq handlers on the local CPU.
> >=20
> > Do you have an example for a code path to check NR_WRITEBACK?
>=20
> end_page_writeback()
>  test_clear_page_writeback()
>    dec_lruvec_state(lruvec, NR_WRITEBACK)

So with a warning in dec_lruvec_state() I found only a call path from
softirq (like scsi_io_completion() / bio_endio()). Having lockdep
annotation instead "just" preempt_disable() would have helped :)

> > > They rely on IRQ-disabling to also disable CPU migration.
> > The spinlock disables CPU migration.=20
> >=20
> > > > >                                            I'm guessing it's beca=
use
> > > > > preemption is disabled and irq handlers are punted to process con=
text.
> > > > preemption is enabled and IRQ are processed in forced-threaded mode.
> > >=20
> > > That doesn't sound safe.
> >=20
> > Do you have test-case or something I could throw at it and verify that
> > this still works? So far nothing complains=E2=80=A6
>=20
> It's not easy to get the timing right on purpose, but we've seen in
> production what happens when you don't protect these counter updates
> from interrupts. See c3cc39118c36 ("mm: memcontrol: fix NR_WRITEBACK
> leak in memcg and system stats").

Based on the looking code I'm looking at, it looks fine. Should I just
resubmit the patch?

Sebastian

