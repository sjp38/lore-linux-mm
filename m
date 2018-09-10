Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C32C8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:05:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a10-v6so10361540pls.23
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:05:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j61-v6sor1968734plb.68.2018.09.10.13.05.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 13:05:45 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: How to handle PTE tables with non contiguous entries ?
From: Dan Malek <dan.malek@konsulko.com>
In-Reply-To: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr>
Date: Mon, 10 Sep 2018 13:05:41 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <98C61C92-0D24-41C6-B9DA-8335B34D3B07@konsulko.com>
References: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com, Nicholas Piggin <npiggin@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>


Hello Cristophe.

> On Sep 10, 2018, at 7:34 AM, Christophe Leroy =
<christophe.leroy@c-s.fr> wrote:
>=20
> On the powerpc8xx, handling 16k size pages requires to have page =
tables with 4 identical entries.

Do you think a 16k page is useful?  Back in the day, the goal was to =
keep the fault handling and management overhead as simple and generic as =
possible, as you know this affects the system performance.  I understand =
there would be fewer page faults and more efficient use of the MMU =
resources with 16k, but if this comes at an overhead cost, is it really =
worth it?

In addition to the normal 4k mapping, I had thought about using 512k =
mapping, which could be easily detected at level 2 (PMD), with a single =
entry loaded into the MMU.  We would need an aux header or something =
from the executable/library to assist with knowing when this could be =
done.  I never got around to it. :)

The 8xx platforms tended to have smaller memory resources, so the 4k =
granularity was also useful in making better use of the available space.

> Would someone have an idea of an elegent way to handle that ?

My suggestion would be to not change the PTE table, but have the fault =
handler detect a 16k page and load any one of the four entries based =
upon miss offset.  Kinda use the same 4k miss hander, but with 16k =
knowledge.  You wouldn=E2=80=99t save any PTE table space, but the MMU =
efficiency may be worth it.  As I recall, the hardware may ignore/mask =
any LS bits, and there is PMD level information to utilize as well.

It=E2=80=99s been a long time since I=E2=80=99ve investigated how things =
have evolved, glad it=E2=80=99s still in use, and I hope you at least =
have some fun with the development :)

Thanks.

	=E2=80=94 Dan
