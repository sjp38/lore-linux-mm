Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id CC6856B0100
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 09:11:27 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i11so6998699oag.6
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 06:11:27 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id ku4si17850116obc.106.2014.03.18.06.11.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 06:11:27 -0700 (PDT)
From: "Zuckerman, Boris" <borisz@hp.com>
Subject: RE: [RFC PATCH] Support map_pages() for DAX
Date: Tue, 18 Mar 2014 13:10:44 +0000
Message-ID: <4C30833E5CDF444D84D942543DF65BDA625BD721@G4W3303.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kani, Toshimitsu" <toshi.kani@hp.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Matthew,

First of all, thank you for doing this job!=20
Supporting persistent memory for any OS is bit more than adding "just anoth=
er device".
There are some thoughts and questions below. Perhaps, you discussed those a=
lready. If so, please point me to that discussion!

> > Few questions:
> >  - why would you need Dirty for DAX?
>=20
> One of the areas ignored by the original XIP code was CPU caches.  Maybe
> s390 has write-through caches or something, but on x86 we need to write b=
ack the
> lines from the CPU cache to the memory on an msync().  We'll also need to=
 do this for
> a write(), although that's a SMOP.
>=20

X86 cache lines are much smaller than a page. Cache lined are flushed "natu=
rally", but we do not know about that.
How many Dirty pages do we anticipate? What is the performance cost of msyn=
c()? Is that higher, if we do page-based accounting?

Reasons and frequency of msync():
Atomicity: needs barriers, happens frequently, leaves relatively small numb=
er of Dirty pages. Here the cost is probably smaller.=20
Durability of application updates: issued infrequently, leaves many Dirty p=
ages. The cost could be high, right?

Let's assume that at some point we get CPU/Persistent Memory Controller com=
binations that support atomicity of multiple updates in hardware. Would you=
 need to mark pages Dirty in such cases? If not, what is the right layer bu=
ild that support for x86?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
