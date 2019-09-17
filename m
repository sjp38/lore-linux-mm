Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0072C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:16:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EA0521670
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:16:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EA0521670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4820C6B0006; Tue, 17 Sep 2019 03:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4320E6B0008; Tue, 17 Sep 2019 03:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346C56B000A; Tue, 17 Sep 2019 03:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 0C27C6B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:16:45 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B7E722C12
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:16:44 +0000 (UTC)
X-FDA: 75943555128.06.laugh15_57f32b134ad5f
X-HE-Tag: laugh15_57f32b134ad5f
X-Filterd-Recvd-Size: 2878
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:16:44 +0000 (UTC)
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1iA7j1-0004ha-7O; Tue, 17 Sep 2019 09:16:35 +0200
Date: Tue, 17 Sep 2019 09:16:35 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Qian Cai <cai@lca.pw>
Cc: peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org,
	tglx@linutronix.de, thgarnie@google.com, tytso@mit.edu,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	will@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	keescook@chromium.org
Subject: Re: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
Message-ID: <20190917071634.c7i3i6jg676ejiw5@linutronix.de>
References: <1568392064-3052-1-git-send-email-cai@lca.pw>
 <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
 <1568642487.5576.152.camel@lca.pw>
 <20190916195115.g4hj3j3wstofpsdr@linutronix.de>
 <1568669494.5576.157.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1568669494.5576.157.camel@lca.pw>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000664, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-09-16 17:31:34 [-0400], Qian Cai wrote:
=E2=80=A6
> get_random_u64() is also busted.
=E2=80=A6
> [=C2=A0=C2=A0753.486588]=C2=A0=C2=A0Possible unsafe locking scenario:
>=20
> [=C2=A0=C2=A0753.493890]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0C=
PU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
> [=C2=A0=C2=A0753.499108]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-=
---=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
> [=C2=A0=C2=A0753.504324]=C2=A0=C2=A0=C2=A0lock(batched_entropy_u64.lock);
> [=C2=A0=C2=A0753.509372]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&=
(&zone->lock)->rlock);
> [=C2=A0=C2=A0753.516675]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(b=
atched_entropy_u64.lock);
> [=C2=A0=C2=A0753.524238]=C2=A0=C2=A0=C2=A0lock(random_write_wait.lock);
> [=C2=A0=C2=A0753.529113]=C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0*** DEADLOCK ***

This is the same scenario as the previous one in regard to the
batched_entropy_=E2=80=A6.lock.

Sebastian

