Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 248ACC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0075206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:03:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0075206A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5C5B6B0005; Mon, 16 Sep 2019 05:03:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0D246B0006; Mon, 16 Sep 2019 05:03:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22776B0007; Mon, 16 Sep 2019 05:03:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id B1A846B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:03:47 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 55D39AC02
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:03:47 +0000 (UTC)
X-FDA: 75940196094.17.steam28_5b33286d07241
X-HE-Tag: steam28_5b33286d07241
X-Filterd-Recvd-Size: 1827
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:03:46 +0000 (UTC)
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1i9mv2-0003uS-SE; Mon, 16 Sep 2019 11:03:36 +0200
Date: Mon, 16 Sep 2019 11:03:36 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Qian Cai <cai@lca.pw>, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, tglx@linutronix.de, thgarnie@google.com,
	tytso@mit.edu, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, will@kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, keescook@chromium.org
Subject: Re: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
Message-ID: <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
References: <1568392064-3052-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1568392064-3052-1-git-send-email-cai@lca.pw>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000100, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-09-13 12:27:44 [-0400], Qian Cai wrote:
=E2=80=A6
> Chain exists of:
>   random_write_wait.lock --> &rq->lock --> batched_entropy_u32.lock
>=20
>  Possible unsafe locking scenario:
>=20
>        CPU0                    CPU1
>        ----                    ----
>   lock(batched_entropy_u32.lock);
>                                lock(&rq->lock);
>                                lock(batched_entropy_u32.lock);
>   lock(random_write_wait.lock);

would this deadlock still occur if lockdep knew that
batched_entropy_u32.lock on CPU0 could be acquired at the same time
as CPU1 acquired its batched_entropy_u32.lock?

Sebastian

