Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 782076B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 01:17:40 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n9-v6so3201700otk.23
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 22:17:40 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e22-v6si8664245otj.69.2018.06.05.22.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 22:17:38 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel panic in reading /proc/kpageflags when enabling
 RAM-simulated PMEM
Date: Wed, 6 Jun 2018 05:16:24 +0000
Message-ID: <20180606051624.GA16021@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605005402.GA22975@hori1.linux.bs1.fc.nec.co.jp>
 <20180605011836.GA32444@bombadil.infradead.org>
 <20180605073500.GA23766@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20180605073500.GA23766@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <16AC92DDD1A22A4BB5F9C91E5137C92B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Tue, Jun 05, 2018 at 07:35:01AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
> On Mon, Jun 04, 2018 at 06:18:36PM -0700, Matthew Wilcox wrote:
> > On Tue, Jun 05, 2018 at 12:54:03AM +0000, Naoya Horiguchi wrote:
> > > Reproduction precedure is like this:
> > >  - enable RAM based PMEM (with a kernel boot parameter like memmap=3D=
1G!4G)
> > >  - read /proc/kpageflags (or call tools/vm/page-types with no argumen=
ts)
> > >  (- my kernel config is attached)
> > >=20
> > > I spent a few days on this, but didn't reach any solutions.
> > > So let me report this with some details below ...
> > >=20
> > > In the critial page request, stable_page_flags() is called with an ar=
gument
> > > page whose ->compound_head was somehow filled with '0xfffffffffffffff=
f'.
> > > And compound_head() returns (struct page *)(head - 1), which explains=
 the
> > > address 0xfffffffffffffffe in the above message.
> >=20
> > Hm.  compound_head shares with:
> >=20
> >                         struct list_head lru;
> >                                 struct list_head slab_list;     /* uses=
 lru */
> >                                 struct {        /* Partial pages */
> >                                         struct page *next;
> >                         unsigned long _compound_pad_1;  /* compound_hea=
d */
> >                         unsigned long _pt_pad_1;        /* compound_hea=
d */
> >                         struct dev_pagemap *pgmap;
> >                 struct rcu_head rcu_head;
> >=20
> > None of them should be -1.
> >=20
> > > It seems that this kernel panic happens when reading kpageflags of pf=
n range
> > > [0xbffd7, 0xc0000), which coresponds to a 'reserved' range.
> > >=20
> > > [    0.000000] user-defined physical RAM map:
> > > [    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff] usab=
le
> > > [    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff] rese=
rved
> > > [    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff] rese=
rved
> > > [    0.000000] user: [mem 0x0000000000100000-0x00000000bffd6fff] usab=
le
> > > [    0.000000] user: [mem 0x00000000bffd7000-0x00000000bfffffff] rese=
rved
> > > [    0.000000] user: [mem 0x00000000feffc000-0x00000000feffffff] rese=
rved
> > > [    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff] rese=
rved
> > > [    0.000000] user: [mem 0x0000000100000000-0x000000013fffffff] pers=
istent (type 12)
> > >=20
> > > So I guess 'memmap=3D' parameter might badly affect the memory initia=
lization process.
> > >=20
> > > This problem doesn't reproduce on v4.17, so some pre-released patch i=
ntroduces it.
> > > I hope this info helps you find the solution/workaround.
> >=20
> > Can you try bisecting this?  It could be one of my patches to reorder s=
truct
> > page, or it could be one of Pavel's deferred page initialisation patche=
s.
> > Or something else ;-)
>=20
> Thank you for the comment. I'm trying bisecting now, let you know the res=
ult later.
>=20
> And I found that my statement "not reproduce on v4.17" was wrong (I used
> different kvm guests, which made some different test condition and misgui=
ded me),
> this seems an older (at least < 4.15) bug.

(Cc: Pavel)

Bisection showed that the following commit introduced this issue:

  commit f7f99100d8d95dbcf09e0216a143211e79418b9f
  Author: Pavel Tatashin <pasha.tatashin@oracle.com>
  Date:   Wed Nov 15 17:36:44 2017 -0800
 =20
      mm: stop zeroing memory during allocation in vmemmap

This patch postpones struct page zeroing to later stage of memory initializ=
ation.
My kernel config disabled CONFIG_DEFERRED_STRUCT_PAGE_INIT so two callsites=
 of
__init_single_page() were never reached. So in such case, struct pages popu=
lated
by vmemmap_pte_populate() could be left uninitialized?
And I'm not sure yet how this issue becomes visible with memmap=3D setting.

Thanks,
Naoya Horiguchi=
