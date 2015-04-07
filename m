Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DCE636B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 18:41:37 -0400 (EDT)
Received: by pddn5 with SMTP id n5so93420164pdd.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 15:41:37 -0700 (PDT)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id ck1si13529373pdb.247.2015.04.07.15.41.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 15:41:36 -0700 (PDT)
Received: by pdea3 with SMTP id a3so93441748pde.3
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 15:41:35 -0700 (PDT)
From: Kevin Hilman <khilman@kernel.org>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid ICE in gcc 4.7.3
References: <20150324004537.GA24816@verge.net.au>
	<CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com>
	<20150324161358.GA694@kahuna> <20150326003939.GA25368@verge.net.au>
	<20150326133631.GB2805@arm.com>
	<CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au> <20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
	<20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
	<7hwq1v4iq4.fsf@deeprootsystems.com>
	<CAMAWPa_YEJDQc=_60_sPqzwLYN8Yefzcko_rydxrt8oOCq20gw@mail.gmail.com>
	<20150407131740.ac8a856537fecb1b5d142f5f@linux-foundation.org>
Date: Tue, 07 Apr 2015 15:41:32 -0700
In-Reply-To: <20150407131740.ac8a856537fecb1b5d142f5f@linux-foundation.org>
	(Andrew Morton's message of "Tue, 7 Apr 2015 13:17:40 -0700")
Message-ID: <7hpp7fo92b.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 7 Apr 2015 10:57:52 -0700 Kevin Hilman <khilman@kernel.org> wrote:
>
>> > The diff below[2] on top of yours compiles fine here and at least covers
>> > the compilers I *know* to trigger the ICE.
>> 
>> I see my fix in your mmots since last Thurs (4/2), but it's not in
>> mmotm (last updated today) so today's linux-next still has the ICE for
>> anything other than gcc-4.7.3.   Just checking to see when you plan to
>> update mmotm.
>
> It should all be there today?

Nope.  

In mmotm, only the original patch plus your first fix is there:

$ curl -sO http://www.ozlabs.org/~akpm/mmotm/broken-out.tar.gz
$ tar -tavf broken-out.tar.gz |grep gcc-473
-rw-r----- akpm/eng       1838 2015-04-01 14:41 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473.patch
-rw-r----- akpm/eng       1309 2015-04-01 14:41 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473-fix.patch

but in mmots, the additional ptch from me, plus another comment fixup
from you are also there:

$ curl -sO http://www.ozlabs.org/~akpm/mmots/broken-out.tar.gz
$ tar -tavf broken-out.tar.gz |grep gcc-473
-rw-r----- akpm/eng       1882 2015-04-06 16:24 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473.patch
-rw-r----- akpm/eng       1271 2015-04-06 16:24 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473-fix.patch
-rw-r----- akpm/eng       1382 2015-04-06 16:24 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473-fix-fix.patch
-rw-r----- akpm/eng        968 2015-04-06 16:24 broken-out/mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473-fix-fix-fix.patch


Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
