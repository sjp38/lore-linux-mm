Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55CA96B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 03:38:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n21-v6so1407698iob.19
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 00:38:02 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id q68-v6si925166itq.120.2018.06.05.00.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 00:38:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel panic in reading /proc/kpageflags when enabling
 RAM-simulated PMEM
Date: Tue, 5 Jun 2018 07:35:01 +0000
Message-ID: <20180605073500.GA23766@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605005402.GA22975@hori1.linux.bs1.fc.nec.co.jp>
 <20180605011836.GA32444@bombadil.infradead.org>
In-Reply-To: <20180605011836.GA32444@bombadil.infradead.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6DF55117BC2F334FAC63EA0F79B38338@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Mon, Jun 04, 2018 at 06:18:36PM -0700, Matthew Wilcox wrote:
> On Tue, Jun 05, 2018 at 12:54:03AM +0000, Naoya Horiguchi wrote:
> > Reproduction precedure is like this:
> >  - enable RAM based PMEM (with a kernel boot parameter like memmap=3D1G=
!4G)
> >  - read /proc/kpageflags (or call tools/vm/page-types with no arguments=
)
> >  (- my kernel config is attached)
> >=20
> > I spent a few days on this, but didn't reach any solutions.
> > So let me report this with some details below ...
> >=20
> > In the critial page request, stable_page_flags() is called with an argu=
ment
> > page whose ->compound_head was somehow filled with '0xffffffffffffffff'=
.
> > And compound_head() returns (struct page *)(head - 1), which explains t=
he
> > address 0xfffffffffffffffe in the above message.
>=20
> Hm.  compound_head shares with:
>=20
>                         struct list_head lru;
>                                 struct list_head slab_list;     /* uses l=
ru */
>                                 struct {        /* Partial pages */
>                                         struct page *next;
>                         unsigned long _compound_pad_1;  /* compound_head =
*/
>                         unsigned long _pt_pad_1;        /* compound_head =
*/
>                         struct dev_pagemap *pgmap;
>                 struct rcu_head rcu_head;
>=20
> None of them should be -1.
>=20
> > It seems that this kernel panic happens when reading kpageflags of pfn =
range
> > [0xbffd7, 0xc0000), which coresponds to a 'reserved' range.
> >=20
> > [    0.000000] user-defined physical RAM map:
> > [    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff] usable
> > [    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff] reserv=
ed
> > [    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff] reserv=
ed
> > [    0.000000] user: [mem 0x0000000000100000-0x00000000bffd6fff] usable
> > [    0.000000] user: [mem 0x00000000bffd7000-0x00000000bfffffff] reserv=
ed
> > [    0.000000] user: [mem 0x00000000feffc000-0x00000000feffffff] reserv=
ed
> > [    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff] reserv=
ed
> > [    0.000000] user: [mem 0x0000000100000000-0x000000013fffffff] persis=
tent (type 12)
> >=20
> > So I guess 'memmap=3D' parameter might badly affect the memory initiali=
zation process.
> >=20
> > This problem doesn't reproduce on v4.17, so some pre-released patch int=
roduces it.
> > I hope this info helps you find the solution/workaround.
>=20
> Can you try bisecting this?  It could be one of my patches to reorder str=
uct
> page, or it could be one of Pavel's deferred page initialisation patches.
> Or something else ;-)

Thank you for the comment. I'm trying bisecting now, let you know the resul=
t later.

And I found that my statement "not reproduce on v4.17" was wrong (I used
different kvm guests, which made some different test condition and misguide=
d me),
this seems an older (at least < 4.15) bug.

Thanks,
Naoya Horiguchi=
