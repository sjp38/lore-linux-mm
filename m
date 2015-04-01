Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 677166B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 15:27:08 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so64448426pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 12:27:08 -0700 (PDT)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id l3si4222802pdr.51.2015.04.01.12.27.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 12:27:07 -0700 (PDT)
Received: by pdrw1 with SMTP id w1so56171217pdr.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 12:27:07 -0700 (PDT)
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
Date: Wed, 01 Apr 2015 12:27:04 -0700
In-Reply-To: <alpine.DEB.2.10.1504011130030.14762@ayla.of.borg> (Geert
	Uytterhoeven's message of "Wed, 1 Apr 2015 11:37:13 +0200 (CEST)")
Message-ID: <7hh9sz6453.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Marc Zyngier <Marc.Zyngier@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

[...]

>> build bisect points to commit 21f992084aeb[3], but that doesn't revert
>> cleanly so I haven't got any further than that yet.
>
> I installed gcc-arm-linux-gnueabi (4:4.7.2-1 from Ubuntu 14.04 LTS) and c=
ould
> reproduce the ICE. I came up with the workaround below.

Awesome, thanks!

> Does this work for you?

Yes, that patch works well and fixes the regression. Build results for
all the defconfigs here:

   http://kernelci.org/build/khilman/kernel/v4.0-rc6-8294-g2ef3958cc27e/

and the remaining issues arent' realted to this ICE.

> From 7ebe83316eaf1952e55a76754ce7a5832e461b8c Mon Sep 17 00:00:00 2001
> From: Geert Uytterhoeven <geert+renesas@glider.be>
> Date: Wed, 1 Apr 2015 11:22:51 +0200
> Subject: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid IC=
E in
>  gcc 4.7.3
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>
> With gcc version 4.7.3 (Ubuntu/Linaro 4.7.3-12ubuntu1) :
>
>     mm/migrate.c: In function =E2=80=98migrate_pages=E2=80=99:
>     mm/migrate.c:1148:1: internal compiler error: in push_minipool_fix, a=
t config/arm/arm.c:13500
>     Please submit a full bug report,
>     with preprocessed source if appropriate.
>     See <file:///usr/share/doc/gcc-4.7/README.Bugs> for instructions.
>     Preprocessed source stored into /tmp/ccPoM1tr.out file, please attach=
 this to your bugreport.
>     make[1]: *** [mm/migrate.o] Error 1
>     make: *** [mm/migrate.o] Error 2
>
> Mark unmap_and_move() (which is used in a single place only) "noinline"
> to work around this compiler bug.
>
> Reported-by: Kevin Hilman <khilman@kernel.org>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Tested-by: Kevin Hilman <khilman@linaro.org>

> ---
>  mm/migrate.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 114602a68111d809..98f8574456c2010c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -904,9 +904,10 @@ out:
>   * Obtain the lock on page, remove all ptes and migrate the page
>   * to the newly allocated page in newpage.
>   */
> -static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_p=
age,
> -			unsigned long private, struct page *page, int force,
> -			enum migrate_mode mode)
> +static noinline int unmap_and_move(new_page_t get_new_page,
> +				   free_page_t put_new_page,
> +				   unsigned long private, struct page *page,
> +				   int force, enum migrate_mode mode)
>  {
>  	int rc =3D 0;
>  	int *result =3D NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
