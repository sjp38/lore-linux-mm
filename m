Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800F6C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E58020820
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:54:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E58020820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF54E6B0006; Mon, 12 Aug 2019 11:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA5DC6B0007; Mon, 12 Aug 2019 11:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBB186B0008; Mon, 12 Aug 2019 11:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8676B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:54:15 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 412638248AA2
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:54:15 +0000 (UTC)
X-FDA: 75814222470.14.lead15_25174cf9e292e
X-HE-Tag: lead15_25174cf9e292e
X-Filterd-Recvd-Size: 3170
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:54:14 +0000 (UTC)
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hxCeB-0000RL-D5; Mon, 12 Aug 2019 17:54:11 +0200
Date: Mon, 12 Aug 2019 17:54:11 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yang Shi <shy828301@gmail.com>, Linux MM <linux-mm@kvack.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Memory compaction and mlockall()
Message-ID: <20190812155411.hpfweuao7uudw5my@linutronix.de>
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
 <CAHbLzkpME1oT2=-TNPm9S_iZ2nkGsY6AXo7iVgDUhg8WysDpZw@mail.gmail.com>
 <20190711094324.ninnmarx5r3amz4p@linutronix.de>
 <77c839c3-7d7d-9b98-5c3d-ad5fd65274b1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <77c839c3-7d7d-9b98-5c3d-ad5fd65274b1@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-08-12 16:59:00 [+0200], Vlastimil Babka wrote:
> On 7/11/19 11:43 AM, Sebastian Andrzej Siewior wrote:
> > On 2019-07-10 11:21:19 [-0700], Yang Shi wrote:
> >>
> >> compaction should not isolate unevictable pages unless you have
> >> /proc/sys/vm/compact_unevictable_allowed set.
> >=20
> > Thank you. This is enabled by default. The documentation for this says
> > | =E2=80=A6 compaction is allowed to examine the unevictable lru (mlock=
ed pages) for
> > | pages to compact.=E2=80=A6
> >=20
> > so it is actually clear once you know where to look.
> > If I read this correct, the default behavior was to ignore mlock()ed
> > pages for compaction then commit
> >   5bbe3547aa3ba ("mm: allow compaction of unevictable pages")
> >=20
> > came along in v4.1-rc1 and changed that behaviour. Is it too late to
> > flip it back?
>=20
> I would say that enabled is a better default wrt benefits for the
> majority of systems. This was assuming that mlock() is primarily used to
> prevent sensitive data (crypto keys) from hitting swap, not to give
> latency guarantees. You could perhaps argue that enabling PREEMPT_RT
> might change the default, but it's somewhat subtle.

A different behaviour depending on PREEMPT_RT is bad.=20
=46rom the mlock(2) page:

|NOTES
|
|Memory locking has two main applications: real-time algorithms and
|high-security data processing. Real-time applications require deterministic
|timing, and, like scheduling, paging is one major cause of unexpected prog=
ram
|execution delays. =E2=80=A6
|
|Real-time processes that are using mlockall() to prevent delays on page fa=
ults
|should reserve enough locked stack pages before entering the time-critical
|section, so that no page fault can be caused by function calls. =E2=80=A6

So if we are not going to revert that, then I would need to update man
page to reflect that we now have an additional knob to consider in order
to disable page faults on mlock()ed pages.

Sebastian

