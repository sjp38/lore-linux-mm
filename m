Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21BD1C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE63621907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="LdZ3+5kZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE63621907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CDA26B02CA; Wed, 18 Sep 2019 10:39:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256AB6B02CC; Wed, 18 Sep 2019 10:39:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11EAA6B02CD; Wed, 18 Sep 2019 10:39:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id D4F256B02CA
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:39:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 61C8ABF00
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:44 +0000 (UTC)
X-FDA: 75948300288.15.join57_54f4e37e4703c
X-HE-Tag: join57_54f4e37e4703c
X-Filterd-Recvd-Size: 17167
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:43 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id h126so8242451qke.10
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:39:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=39TMjm09PPJULcfPTY3RKiwrDA/uqRh1/RHxmc+MCjU=;
        b=LdZ3+5kZOiOmJf6GE1ZAenwp5s+4qnyzmsIkBEdjFlOYGofFjpbVt8QybKV34iB80P
         WyWA+SmuwEL5SOTnWswld1djbBOEoZaHy833XFAXPzDOPro49K72ZFXRhZA6UX+IwvAd
         AdoeU2qt8hGjP08J/LavkZNVkn+bKq7QQevtzf3OFcH4JJ6GR/1fNk9zXGtAictc3hX3
         dJRzA2/hzQ93xh+eM2JndWf9OdeRSpi30U0rWjI3NfWcW9UWMah5uCV6mQyqF/UHxu0w
         dhJ6y397/EW3/TWDkAl1LYfiT9b5b11uQB6bzp5b6NvejgnRznFB59pTdPUflnDuWT4L
         IMxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=39TMjm09PPJULcfPTY3RKiwrDA/uqRh1/RHxmc+MCjU=;
        b=aIrFbWBEel6NaU3xsZbr5RqySpeMzC6hyRlYpzh2rKp0wbOPi2wMCcgniA6YKixtjT
         WxkYdEryc5whJX8BoNKJqnE+6/dUk7hqFpAueWpBhn83TXLSlMr3k1AHzjKe6gysODrA
         FmMWVBZ0UnUAHsHsCaHCyTK3+Pw1lW5v/DuQ50YY6DYbN/6WEMMExIqfsnyWl9857Pcr
         xD6X0Hm7S7gRVoQ2Oc1RxEOoAiqQed+iQFn5//yCsTyikloc67vfnp9ZN91KIdJhrVl6
         K+aexZAGctSCeGy/wXMK/fVD+DQnj6awwacW7EScIm+CpPD/uDhs+ZaEMk3/W9F3B/1R
         ZfOw==
X-Gm-Message-State: APjAAAVXVeWV+XL7rt8lKyjQyClC+UpxU5L2qtt6NeY0J8jUZ3SqKGE5
	zc7wqioYxTVL8rDwup4ULpf/ow==
X-Google-Smtp-Source: APXvYqw/cj5A7F5rE9ZMYQX2wevZPwfA+g2UL1gtiJk/hkM8gBbrP5EeLce9Y0kR+BLXeJyPa0+G+A==
X-Received: by 2002:a37:a03:: with SMTP id 3mr4052297qkk.405.1568817582926;
        Wed, 18 Sep 2019 07:39:42 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g33sm2681351qtd.12.2019.09.18.07.39.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 07:39:42 -0700 (PDT)
Message-ID: <1568817579.5576.172.camel@lca.pw>
Subject: printk() + memory offline deadlock (WAS Re: page_alloc.shuffle=1 +
 CONFIG_PROVE_LOCKING=y = arm64 hang)
From: Qian Cai <cai@lca.pw>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek
 <pmladek@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will@kernel.org>, Dan Williams <dan.j.williams@intel.com>,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Peter Zijlstra
 <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Thomas Gleixner
 <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann
 <arnd@arndb.de>,  Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 18 Sep 2019 10:39:39 -0400
In-Reply-To: <20190916104239.124fc2e5@gandalf.local.home>
References: <1566509603.5576.10.camel@lca.pw>
	 <1567717680.5576.104.camel@lca.pw> <1568128954.5576.129.camel@lca.pw>
	 <20190911011008.GA4420@jagdpanzerIV> <1568289941.5576.140.camel@lca.pw>
	 <20190916104239.124fc2e5@gandalf.local.home>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-16 at 10:42 -0400, Steven Rostedt wrote:
> On Thu, 12 Sep 2019 08:05:41 -0400
> Qian Cai <cai@lca.pw> wrote:
>=20
> > >  drivers/char/random.c | 7 ++++---
> > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > >=20
> > > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > > index 9b54cdb301d3..975015857200 100644
> > > --- a/drivers/char/random.c
> > > +++ b/drivers/char/random.c
> > > @@ -1687,8 +1687,9 @@ static void _warn_unseeded_randomness(const c=
har *func_name, void *caller,
> > >  	print_once =3D true;
> > >  #endif
> > >  	if (__ratelimit(&unseeded_warning))
> > > -		pr_notice("random: %s called from %pS with crng_init=3D%d\n",
> > > -			  func_name, caller, crng_init);
> > > +		printk_deferred(KERN_NOTICE "random: %s called from %pS "
> > > +				"with crng_init=3D%d\n", func_name, caller,
> > > +				crng_init);
> > >  }
> > > =20
> > >  /*
> > > @@ -2462,4 +2463,4 @@ void add_bootloader_randomness(const void *bu=
f, unsigned int size)
> > >  	else
> > >  		add_device_randomness(buf, size);
> > >  }
> > > -EXPORT_SYMBOL_GPL(add_bootloader_randomness);
> > > \ No newline at end of file
> > > +EXPORT_SYMBOL_GPL(add_bootloader_randomness); =20
> >=20
> > This will also fix the hang.
> >=20
> > Sergey, do you plan to submit this Ted?
>=20
> Perhaps for a quick fix (and a comment that says this needs to be fixed
> properly). I think the changes to printk() that was discussed at
> Plumbers may also solve this properly.

I assume that the new printk() stuff will also fix this deadlock between
printk() and memory offline.

[=C2=A0=C2=A0317.337595] WARNING: possible circular locking dependency de=
tected
[=C2=A0=C2=A0317.337596] 5.3.0-next-20190917+ #9 Not tainted
[=C2=A0=C2=A0317.337597] ------------------------------------------------=
------
[=C2=A0=C2=A0317.337597] test.sh/8738 is trying to acquire lock:
[=C2=A0=C2=A0317.337598] ffffffffb33a4978 ((console_sem).lock){-.-.}, at:
down_trylock+0x16/0x50

[=C2=A0=C2=A0317.337602] but task is already holding lock:
[=C2=A0=C2=A0317.337602] ffff88883fff4318 (&(&zone->lock)->rlock){-.-.}, =
at:
start_isolate_page_range+0x1f7/0x570

[=C2=A0=C2=A0317.337606] which lock already depends on the new lock.


[=C2=A0=C2=A0317.337608] the existing dependency chain (in reverse order)=
 is:

[=C2=A0=C2=A0317.337609] -> #3 (&(&zone->lock)->rlock){-.-.}:
[=C2=A0=C2=A0317.337612]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0317.337613]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337613]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x2f/0x40
[=C2=A0=C2=A0317.337614]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
mqueue_bulk.constprop.21+0xb6/0x1160
[=C2=A0=C2=A0317.337615]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_page_from_freelist+0x898/0x22c0
[=C2=A0=C2=A0317.337616]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_alloc_pages_nodemask+0x2f3/0x1cd0
[=C2=A0=C2=A0317.337617]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_page_interleave+0x18/0x130
[=C2=A0=C2=A0317.337618]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_pages_current+0xf6/0x110
[=C2=A0=C2=A0317.337619]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
llocate_slab+0x4c6/0x19c0
[=C2=A0=C2=A0317.337620]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
ew_slab+0x46/0x70
[=C2=A0=C2=A0317.337621]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
__slab_alloc+0x58b/0x960
[=C2=A0=C2=A0317.337621]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_slab_alloc+0x43/0x70
[=C2=A0=C2=A0317.337622]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
mem_cache_alloc+0x354/0x460
[=C2=A0=C2=A0317.337623]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0f=
ill_pool+0x272/0x4b0
[=C2=A0=C2=A0317.337624]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_debug_object_init+0x86/0x790
[=C2=A0=C2=A0317.337624]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
ebug_object_init+0x16/0x20
[=C2=A0=C2=A0317.337625]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
rtimer_init+0x27/0x1e0
[=C2=A0=C2=A0317.337626]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
nit_dl_task_timer+0x20/0x40
[=C2=A0=C2=A0317.337627]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_sched_fork+0x10b/0x1f0
[=C2=A0=C2=A0317.337627]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
nit_idle+0xac/0x520
[=C2=A0=C2=A0317.337628]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
dle_thread_get+0x7c/0xc0
[=C2=A0=C2=A0317.337629]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0b=
ringup_cpu+0x1a/0x1e0
[=C2=A0=C2=A0317.337630]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
puhp_invoke_callback+0x197/0x1120
[=C2=A0=C2=A0317.337630]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
cpu_up+0x171/0x280
[=C2=A0=C2=A0317.337631]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_cpu_up+0xb1/0x120
[=C2=A0=C2=A0317.337632]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
pu_up+0x13/0x20
[=C2=A0=C2=A0317.337632]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
mp_init+0xa4/0x12d
[=C2=A0=C2=A0317.337633]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init_freeable+0x37e/0x76e
[=C2=A0=C2=A0317.337634]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init+0x11/0x12f
[=C2=A0=C2=A0317.337635]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
et_from_fork+0x3a/0x50

[=C2=A0=C2=A0317.337635] -> #2 (&rq->lock){-.-.}:
[=C2=A0=C2=A0317.337638]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0317.337639]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337639]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x2f/0x40
[=C2=A0=C2=A0317.337640]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ask_fork_fair+0x43/0x200
[=C2=A0=C2=A0317.337641]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
ched_fork+0x29b/0x420
[=C2=A0=C2=A0317.337642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
opy_process+0xf3c/0x2fd0
[=C2=A0=C2=A0317.337642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
do_fork+0xef/0x950
[=C2=A0=C2=A0317.337643]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_thread+0xa8/0xe0
[=C2=A0=C2=A0317.337644]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
est_init+0x28/0x311
[=C2=A0=C2=A0317.337645]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
rch_call_rest_init+0xe/0x1b
[=C2=A0=C2=A0317.337645]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_kernel+0x6eb/0x724
[=C2=A0=C2=A0317.337646]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0x=
86_64_start_reservations+0x24/0x26
[=C2=A0=C2=A0317.337647]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0x=
86_64_start_kernel+0xf4/0xfb
[=C2=A0=C2=A0317.337648]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
econdary_startup_64+0xb6/0xc0

[=C2=A0=C2=A0317.337649] -> #1 (&p->pi_lock){-.-.}:
[=C2=A0=C2=A0317.337651]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0317.337652]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337653]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0317.337653]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ry_to_wake_up+0xb4/0x1030
[=C2=A0=C2=A0317.337654]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0w=
ake_up_process+0x15/0x20
[=C2=A0=C2=A0317.337655]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_up+0xaa/0xc0
[=C2=A0=C2=A0317.337655]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
p+0x55/0x60
[=C2=A0=C2=A0317.337656]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_up_console_sem+0x37/0x60
[=C2=A0=C2=A0317.337657]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_unlock+0x3a0/0x750
[=C2=A0=C2=A0317.337658]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x10d/0x340
[=C2=A0=C2=A0317.337658]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x1f/0x30
[=C2=A0=C2=A0317.337659]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x44/0xd4
[=C2=A0=C2=A0317.337660]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0x9f/0xc5
[=C2=A0=C2=A0317.337660]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
rng_reseed+0x3cc/0x440
[=C2=A0=C2=A0317.337661]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
redit_entropy_bits+0x3e8/0x4f0
[=C2=A0=C2=A0317.337662]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
andom_ioctl+0x1eb/0x250
[=C2=A0=C2=A0317.337663]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_vfs_ioctl+0x13e/0xa70
[=C2=A0=C2=A0317.337663]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
sys_ioctl+0x41/0x80
[=C2=A0=C2=A0317.337664]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_x64_sys_ioctl+0x43/0x4c
[=C2=A0=C2=A0317.337665]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0317.337666]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
ntry_SYSCALL_64_after_hwframe+0x49/0xbe

[=C2=A0=C2=A0317.337667] -> #0 ((console_sem).lock){-.-.}:
[=C2=A0=C2=A0317.337669]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
heck_prev_add+0x107/0xea0
[=C2=A0=C2=A0317.337670]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
alidate_chain+0x8fc/0x1200
[=C2=A0=C2=A0317.337671]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0317.337671]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337672]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0317.337673]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
own_trylock+0x16/0x50
[=C2=A0=C2=A0317.337674]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_down_trylock_console_sem+0x2b/0xa0
[=C2=A0=C2=A0317.337675]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_trylock+0x16/0x60
[=C2=A0=C2=A0317.337676]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x100/0x340
[=C2=A0=C2=A0317.337677]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x1f/0x30
[=C2=A0=C2=A0317.337678]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x44/0xd4
[=C2=A0=C2=A0317.337678]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0x9f/0xc5
[=C2=A0=C2=A0317.337679]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_dump_page.cold.2+0x73/0x210
[=C2=A0=C2=A0317.337680]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
ump_page+0x12/0x50
[=C2=A0=C2=A0317.337680]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
as_unmovable_pages+0x3e9/0x4b0
[=C2=A0=C2=A0317.337681]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_isolate_page_range+0x3b4/0x570
[=C2=A0=C2=A0317.337682]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_offline_pages+0x1ad/0xa10
[=C2=A0=C2=A0317.337683]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0o=
ffline_pages+0x11/0x20
[=C2=A0=C2=A0317.337683]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emory_subsys_offline+0x7e/0xc0
[=C2=A0=C2=A0317.337684]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
evice_offline+0xd5/0x110
[=C2=A0=C2=A0317.337685]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tate_store+0xc6/0xe0
[=C2=A0=C2=A0317.337686]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
ev_attr_store+0x3f/0x60
[=C2=A0=C2=A0317.337686]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
ysfs_kf_write+0x89/0xb0
[=C2=A0=C2=A0317.337687]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernfs_fop_write+0x188/0x240
[=C2=A0=C2=A0317.337688]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_vfs_write+0x50/0xa0
[=C2=A0=C2=A0317.337688]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_write+0x105/0x290
[=C2=A0=C2=A0317.337689]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
sys_write+0xc6/0x160
[=C2=A0=C2=A0317.337690]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_x64_sys_write+0x43/0x50
[=C2=A0=C2=A0317.337691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0317.337691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
ntry_SYSCALL_64_after_hwframe+0x49/0xbe

[=C2=A0=C2=A0317.337693] other info that might help us debug this:

[=C2=A0=C2=A0317.337694] Chain exists of:
[=C2=A0=C2=A0317.337694]=C2=A0=C2=A0=C2=A0(console_sem).lock --> &rq->loc=
k --> &(&zone->lock)->rlock

[=C2=A0=C2=A0317.337699]=C2=A0=C2=A0Possible unsafe locking scenario:

[=C2=A0=C2=A0317.337700]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0C=
PU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
[=C2=A0=C2=A0317.337701]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-=
---=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
[=C2=A0=C2=A0317.337701]=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)->rlock);
[=C2=A0=C2=A0317.337703]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&r=
q->lock);
[=C2=A0=C2=A0317.337705]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&zone->lock)->rlock);
[=C2=A0=C2=A0317.337706]=C2=A0=C2=A0=C2=A0lock((console_sem).lock);

[=C2=A0=C2=A0317.337708]=C2=A0=C2=A0*** DEADLOCK ***

[=C2=A0=C2=A0317.337710] 8 locks held by test.sh/8738:
[=C2=A0=C2=A0317.337710]=C2=A0=C2=A0#0: ffff8883940b5408 (sb_writers#4){.=
+.+}, at:
vfs_write+0x25f/0x290
[=C2=A0=C2=A0317.337713]=C2=A0=C2=A0#1: ffff889fce310280 (&of->mutex){+.+=
.}, at:
kernfs_fop_write+0x128/0x240
[=C2=A0=C2=A0317.337716]=C2=A0=C2=A0#2: ffff889feb6d4830 (kn->count#115){=
.+.+}, at:
kernfs_fop_write+0x138/0x240
[=C2=A0=C2=A0317.337720]=C2=A0=C2=A0#3: ffffffffb3762d40 (device_hotplug_=
lock){+.+.}, at:
lock_device_hotplug_sysfs+0x16/0x50
[=C2=A0=C2=A0317.337723]=C2=A0=C2=A0#4: ffff88981f0dc990 (&dev->mutex){..=
..}, at:
device_offline+0x70/0x110
[=C2=A0=C2=A0317.337726]=C2=A0=C2=A0#5: ffffffffb3315250 (cpu_hotplug_loc=
k.rw_sem){++++}, at:
__offline_pages+0xbf/0xa10
[=C2=A0=C2=A0317.337729]=C2=A0=C2=A0#6: ffffffffb35408b0 (mem_hotplug_loc=
k.rw_sem){++++}, at:
percpu_down_write+0x87/0x2f0
[=C2=A0=C2=A0317.337732]=C2=A0=C2=A0#7: ffff88883fff4318 (&(&zone->lock)-=
>rlock){-.-.}, at:
start_isolate_page_range+0x1f7/0x570
[=C2=A0=C2=A0317.337736] stack backtrace:
[=C2=A0=C2=A0317.337737] CPU: 58 PID: 8738 Comm: test.sh Not tainted 5.3.=
0-next-20190917+
#9
[=C2=A0=C2=A0317.337738] Hardware name: HPE ProLiant DL560 Gen10/ProLiant=
 DL560 Gen10,
BIOS U34 05/21/2019
[=C2=A0=C2=A0317.337739] Call Trace:
[=C2=A0=C2=A0317.337739]=C2=A0=C2=A0dump_stack+0x86/0xca
[=C2=A0=C2=A0317.337740]=C2=A0=C2=A0print_circular_bug.cold.31+0x243/0x26=
e
[=C2=A0=C2=A0317.337741]=C2=A0=C2=A0check_noncircular+0x29e/0x2e0
[=C2=A0=C2=A0317.337742]=C2=A0=C2=A0? debug_lockdep_rcu_enabled+0x4b/0x60
[=C2=A0=C2=A0317.337742]=C2=A0=C2=A0? print_circular_bug+0x120/0x120
[=C2=A0=C2=A0317.337743]=C2=A0=C2=A0? is_ftrace_trampoline+0x9/0x20
[=C2=A0=C2=A0317.337744]=C2=A0=C2=A0? kernel_text_address+0x59/0xc0
[=C2=A0=C2=A0317.337744]=C2=A0=C2=A0? __kernel_text_address+0x12/0x40
[=C2=A0=C2=A0317.337745]=C2=A0=C2=A0check_prev_add+0x107/0xea0
[=C2=A0=C2=A0317.337746]=C2=A0=C2=A0validate_chain+0x8fc/0x1200
[=C2=A0=C2=A0317.337746]=C2=A0=C2=A0? check_prev_add+0xea0/0xea0
[=C2=A0=C2=A0317.337747]=C2=A0=C2=A0? format_decode+0xd6/0x600
[=C2=A0=C2=A0317.337748]=C2=A0=C2=A0? file_dentry_name+0xe0/0xe0
[=C2=A0=C2=A0317.337749]=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0317.337749]=C2=A0=C2=A0lock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337750]=C2=A0=C2=A0? down_trylock+0x16/0x50
[=C2=A0=C2=A0317.337751]=C2=A0=C2=A0? vprintk_emit+0x100/0x340
[=C2=A0=C2=A0317.337752]=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0317.337753]=C2=A0=C2=A0? down_trylock+0x16/0x50
[=C2=A0=C2=A0317.337753]=C2=A0=C2=A0down_trylock+0x16/0x50
[=C2=A0=C2=A0317.337754]=C2=A0=C2=A0? vprintk_emit+0x100/0x340
[=C2=A0=C2=A0317.337755]=C2=A0=C2=A0__down_trylock_console_sem+0x2b/0xa0
[=C2=A0=C2=A0317.337756]=C2=A0=C2=A0console_trylock+0x16/0x60
[=C2=A0=C2=A0317.337756]=C2=A0=C2=A0vprintk_emit+0x100/0x340
[=C2=A0=C2=A0317.337757]=C2=A0=C2=A0vprintk_default+0x1f/0x30
[=C2=A0=C2=A0317.337758]=C2=A0=C2=A0vprintk_func+0x44/0xd4
[=C2=A0=C2=A0317.337758]=C2=A0=C2=A0printk+0x9f/0xc5
[=C2=A0=C2=A0317.337759]=C2=A0=C2=A0? kmsg_dump_rewind_nolock+0x64/0x64
[=C2=A0=C2=A0317.337760]=C2=A0=C2=A0? __dump_page+0x1d7/0x430
[=C2=A0=C2=A0317.337760]=C2=A0=C2=A0__dump_page.cold.2+0x73/0x210
[=C2=A0=C2=A0317.337761]=C2=A0=C2=A0dump_page+0x12/0x50
[=C2=A0=C2=A0317.337762]=C2=A0=C2=A0has_unmovable_pages+0x3e9/0x4b0
[=C2=A0=C2=A0317.337763]=C2=A0=C2=A0start_isolate_page_range+0x3b4/0x570
[=C2=A0=C2=A0317.337763]=C2=A0=C2=A0? unset_migratetype_isolate+0x280/0x2=
80
[=C2=A0=C2=A0317.337764]=C2=A0=C2=A0? rcu_read_lock_bh_held+0xc0/0xc0
[=C2=A0=C2=A0317.337765]=C2=A0=C2=A0__offline_pages+0x1ad/0xa10
[=C2=A0=C2=A0317.337765]=C2=A0=C2=A0? lock_acquire+0x126/0x280
[=C2=A0=C2=A0317.337766]=C2=A0=C2=A0? __add_memory+0xc0/0xc0
[=C2=A0=C2=A0317.337767]=C2=A0=C2=A0? __kasan_check_write+0x14/0x20
[=C2=A0=C2=A0317.337767]=C2=A0=C2=A0? __mutex_lock+0x344/0xcd0
[=C2=A0=C2=A0317.337768]=C2=A0=C2=A0? _raw_spin_unlock_irqrestore+0x49/0x=
50
[=C2=A0=C2=A0317.337769]=C2=A0=C2=A0? device_offline+0x70/0x110
[=C2=A0=C2=A0317.337770]=C2=A0=C2=A0? klist_next+0x1c1/0x1e0
[=C2=A0=C2=A0317.337770]=C2=A0=C2=A0? __mutex_add_waiter+0xc0/0xc0
[=C2=A0=C2=A0317.337771]=C2=A0=C2=A0? klist_next+0x10b/0x1e0
[=C2=A0=C2=A0317.337772]=C2=A0=C2=A0? klist_iter_exit+0x16/0x40
[=C2=A0=C2=A0317.337772]=C2=A0=C2=A0? device_for_each_child+0xd0/0x110
[=C2=A0=C2=A0317.337773]=C2=A0=C2=A0offline_pages+0x11/0x20
[=C2=A0=C2=A0317.337774]=C2=A0=C2=A0memory_subsys_offline+0x7e/0xc0
[=C2=A0=C2=A0317.337774]=C2=A0=C2=A0device_offline+0xd5/0x110
[=C2=A0=C2=A0317.337775]=C2=A0=C2=A0? auto_online_blocks_show+0x70/0x70
[=C2=A0=C2=A0317.337776]=C2=A0=C2=A0state_store+0xc6/0xe0
[=C2=A0=C2=A0317.337776]=C2=A0=C2=A0dev_attr_store+0x3f/0x60
[=C2=A0=C2=A0317.337777]=C2=A0=C2=A0? device_match_name+0x40/0x40
[=C2=A0=C2=A0317.337778]=C2=A0=C2=A0sysfs_kf_write+0x89/0xb0
[=C2=A0=C2=A0317.337778]=C2=A0=C2=A0? sysfs_file_ops+0xa0/0xa0
[=C2=A0=C2=A0317.337779]=C2=A0=C2=A0kernfs_fop_write+0x188/0x240
[=C2=A0=C2=A0317.337780]=C2=A0=C2=A0__vfs_write+0x50/0xa0
[=C2=A0=C2=A0317.337780]=C2=A0=C2=A0vfs_write+0x105/0x290
[=C2=A0=C2=A0317.337781]=C2=A0=C2=A0ksys_write+0xc6/0x160
[=C2=A0=C2=A0317.337782]=C2=A0=C2=A0? __x64_sys_read+0x50/0x50
[=C2=A0=C2=A0317.337782]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
[=C2=A0=C2=A0317.337783]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
[=C2=A0=C2=A0317.337784]=C2=A0=C2=A0__x64_sys_write+0x43/0x50
[=C2=A0=C2=A0317.337784]=C2=A0=C2=A0do_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0317.337785]=C2=A0=C2=A0? trace_hardirqs_on_thunk+0x1a/0x20
[=C2=A0=C2=A0317.337786]=C2=A0=C2=A0? syscall_return_slowpath+0x210/0x210
[=C2=A0=C2=A0317.337787]=C2=A0=C2=A0? entry_SYSCALL_64_after_hwframe+0x3e=
/0xbe
[=C2=A0=C2=A0317.337787]=C2=A0=C2=A0? trace_hardirqs_off_caller+0x3a/0x15=
0
[=C2=A0=C2=A0317.337788]=C2=A0=C2=A0? trace_hardirqs_off_thunk+0x1a/0x20
[=C2=A0=C2=A0317.337789]=C2=A0=C2=A0entry_SYSCALL_64_after_hwframe+0x49/0=
xbe

