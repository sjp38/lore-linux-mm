Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DBEAC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:22:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD2222CF7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="uKOlsetG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD2222CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60F866B02EB; Wed, 21 Aug 2019 11:22:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5986F6B02EC; Wed, 21 Aug 2019 11:22:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 486B06B02ED; Wed, 21 Aug 2019 11:22:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id 22BAC6B02EB
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:22:03 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 141656D75
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:22:02 +0000 (UTC)
X-FDA: 75846800484.18.apple43_861747febf11e
X-HE-Tag: apple43_861747febf11e
X-Filterd-Recvd-Size: 7454
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:22:01 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id r21so2170309qke.2
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:22:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=DJP9o3D2XKjZ9zx1n9koRzC4+CIYZA/B6naX4USuzLY=;
        b=uKOlsetGup4P09xBmTYtmL4N66UYWlLwhp+nt/eBTuaBtmBdhE2uRPkYWwp3xjfhq6
         Xh4DxXEjgBjvK4eU9miLWeaX9/kzOYncIx8LEavIJbk8VCTXeTjVG14NObLRh/Ii8N0Y
         WP+usnf5g4T4AGcCOqodvXDuv5ukXefo5S/IZy2L3/YfE7Enu5g8PNzzg2NWorDvqhuZ
         OcErmFSGonG83/DRQfAYXdcZLLSzFF9wgEnq0TwwwjO4w8VrVqv5Ex5j92QeCvK1Uf1w
         BXh3LJZ80YOOGLwbVTE0oKMtIDwFfjil2OG+3CmB80TF/9Ji8BnwLSiVyPhfX889yrVQ
         +e3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=DJP9o3D2XKjZ9zx1n9koRzC4+CIYZA/B6naX4USuzLY=;
        b=H2/8X80doIsn43VMEQLbnBlS7aTb5itTWrcmVprWY+4Yzke0YefP6BL8HWrCwIIAAi
         5/t2FB7aRO8oNSLvouOUeZtp16TKWHiv0WLidqyfepnZkgTpNWfF3Yxx2Qmhf6449a61
         kAhDkA6RG9QubJEI96ltwr7b36iqlLx8oGNh6ClQcpQ8bT2Xp9yoaGa51eQdHJ4rpun0
         qSa78BH6YJkk6gr2D9iwEH0XKvanSo3v3acCwwlK4B1ploNSvFCquGs2qd8SOvKooOW4
         AOfn4ZgMXCF2Yfgdg9GzFk9EsZHQXvhJZrGtVHWn0nrITZfnb2x6kyK+Yd+RF2MUmzjy
         R8TA==
X-Gm-Message-State: APjAAAXQn60qSxO3IgByb12A8SuiobAtb7lD+nlmQtNCoylFYVszjSmB
	wsQDymwRySxn0zot5b3cZJYFtQ==
X-Google-Smtp-Source: APXvYqwG0gtW2RBRk91XdVj701QibuiKZ2usnxOKR1o3578YmlTLfe3kr2yHyIgWOSGcA0dke7xhaw==
X-Received: by 2002:ae9:eb8f:: with SMTP id b137mr30261614qkg.136.1566400920481;
        Wed, 21 Aug 2019 08:22:00 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:c265])
        by smtp.gmail.com with ESMTPSA id f27sm10388259qkl.25.2019.08.21.08.21.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 08:21:59 -0700 (PDT)
Date: Wed, 21 Aug 2019 11:21:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190821152158.GA12901@cmpxchg.org>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
 <20190211210208.GA9580@cmpxchg.org>
 <20190213092754.baxi5zpe7kdpf3bj@linutronix.de>
 <20190213145656.GA25205@cmpxchg.org>
 <20190821112116.d4lejm6nai7uavcy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190821112116.d4lejm6nai7uavcy@linutronix.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 01:21:16PM +0200, Sebastian Andrzej Siewior wrote=
:
> sorry, I somehow forgot about this=E2=80=A6
>=20
> On 2019-02-13 09:56:56 [-0500], Johannes Weiner wrote:
> > On Wed, Feb 13, 2019 at 10:27:54AM +0100, Sebastian Andrzej Siewior w=
rote:
> > > On 2019-02-11 16:02:08 [-0500], Johannes Weiner wrote:
> > > > > how do you define safe? I've been looking for dependencies of
> > > > > __mod_lruvec_state() but found only that the lock is held durin=
g the RMW
> > > > > operation with WORKINGSET_NODES idx.
> > > >=20
> > > > These stat functions are not allowed to nest, and the executing t=
hread
> > > > cannot migrate to another CPU during the operation, otherwise the=
y
> > > > corrupt the state they're modifying.
> > >=20
> > > If everyone is taking the same lock (like i_pages.xa_lock) then the=
re
> > > will not be two instances updating the same stat. The owner of the
> > > (sleeping)-spinlock will not be migrated to another CPU.
> >=20
> > This might be true for this particular stat item, but they are genera=
l
> > VM statistics. They're assuredly not all taking the xa_lock.
>=20
> This one in particular does and my guess is that the interrupts are
> disabled here because of xa_lock. So the question is why should the
> interrupts be disabled? Is this due to the lock that should have been
> acquired (and as such disable interrupts) _or_ because of the
> *_lruvec_slab_state() operation.
>=20
> > > > They are called from interrupt handlers, such as when NR_WRITEBAC=
K is
> > > > decreased. Thus workingset_node_update() must exclude preemption =
from
> > > > irq handlers on the local CPU.
> > >=20
> > > Do you have an example for a code path to check NR_WRITEBACK?
> >=20
> > end_page_writeback()
> >  test_clear_page_writeback()
> >    dec_lruvec_state(lruvec, NR_WRITEBACK)
>=20
> So with a warning in dec_lruvec_state() I found only a call path from
> softirq (like scsi_io_completion() / bio_endio()). Having lockdep
> annotation instead "just" preempt_disable() would have helped :)
>=20
> > > > They rely on IRQ-disabling to also disable CPU migration.
> > > The spinlock disables CPU migration.=20
> > >=20
> > > > > >                                            I'm guessing it's =
because
> > > > > > preemption is disabled and irq handlers are punted to process=
 context.
> > > > > preemption is enabled and IRQ are processed in forced-threaded =
mode.
> > > >=20
> > > > That doesn't sound safe.
> > >=20
> > > Do you have test-case or something I could throw at it and verify t=
hat
> > > this still works? So far nothing complains=E2=80=A6
> >=20
> > It's not easy to get the timing right on purpose, but we've seen in
> > production what happens when you don't protect these counter updates
> > from interrupts. See c3cc39118c36 ("mm: memcontrol: fix NR_WRITEBACK
> > leak in memcg and system stats").
>=20
> Based on the looking code I'm looking at, it looks fine. Should I just
> resubmit the patch?

No, NAK to this patch and others like it for the mm code.

The serialization scheme for the vmstats facilty is that stats can be
modified from interrupt context, and so they rely on interrupts being
disabled. This check is correct.

If you want to comprehensively change the scheme, you're of course
welcome to propose that, and I won't be in your way. But that includes
review and update of *all* participants, from the mutation points that
disable irqs (mod_zone_page_state() and friends) to the execution
context of all callstacks, including the full block layer.

What we are NOT doing is eliminating checks that correctly verify the
current locking scheme. We've seen race conditions in this code that
took millions of machine hours to trigger when the rules were broken,
so we rely on explicit checks during code development. It's also not
surprising that they're the only thing that triggers in your testing.

Making this work correctly for RT needs a more thoughtful approach.

