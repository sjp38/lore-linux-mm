Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AEDB76B0242
	for <linux-mm@kvack.org>; Mon, 10 May 2010 19:37:07 -0400 (EDT)
Received: by pwi10 with SMTP id 10so1864695pwi.14
        for <linux-mm@kvack.org>; Mon, 10 May 2010 16:37:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
Date: Mon, 10 May 2010 16:37:05 -0700
Message-ID: <AANLkTimhvJUX2S2eIY8rpw4TnUrDUFicMxEZkLK3hu1N@mail.gmail.com>
Subject: Re: [PATCH 21/25] lmb: Add "start" argument to lmb_find_base()
From: Yinghai Lu <yhlu.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 2:38 AM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> To constraint the search of a region between two boundaries,
> which will be used by the new NUMA aware allocator among others.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> =A0lib/lmb.c | =A0 27 ++++++++++++++++-----------
> =A01 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/lib/lmb.c b/lib/lmb.c
> index 84ac3a9..848f908 100644
> --- a/lib/lmb.c
> +++ b/lib/lmb.c
> @@ -117,19 +117,18 @@ static phys_addr_t __init lmb_find_region(phys_addr=
_t start, phys_addr_t end,
> =A0 =A0 =A0 =A0return LMB_ERROR;
> =A0}
>
> -static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t al=
ign, phys_addr_t max_addr)
> +static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t al=
ign,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 phys_addr_t start, phys_addr_t end)
> =A0{
> =A0 =A0 =A0 =A0long i;
> - =A0 =A0 =A0 phys_addr_t base =3D 0;
> - =A0 =A0 =A0 phys_addr_t res_base;
>
> =A0 =A0 =A0 =A0BUG_ON(0 =3D=3D size);
>
> =A0 =A0 =A0 =A0size =3D lmb_align_up(size, align);
>
> =A0 =A0 =A0 =A0/* Pump up max_addr */
> - =A0 =A0 =A0 if (max_addr =3D=3D LMB_ALLOC_ACCESSIBLE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_addr =3D lmb.current_limit;
> + =A0 =A0 =A0 if (end =3D=3D LMB_ALLOC_ACCESSIBLE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D lmb.current_limit;
>
> =A0 =A0 =A0 =A0/* We do a top-down search, this tends to limit memory
> =A0 =A0 =A0 =A0 * fragmentation by keeping early boot allocs near the
> @@ -138,13 +137,19 @@ static phys_addr_t __init lmb_find_base(phys_addr_t=
 size, phys_addr_t align, phy
> =A0 =A0 =A0 =A0for (i =3D lmb.memory.cnt - 1; i >=3D 0; i--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phys_addr_t lmbbase =3D lmb.memory.regions=
[i].base;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phys_addr_t lmbsize =3D lmb.memory.regions=
[i].size;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t bottom, top, found;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (lmbsize < size)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 base =3D min(lmbbase + lmbsize, max_addr);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_base =3D lmb_find_region(lmbbase, base,=
 size, align);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_base !=3D LMB_ERROR)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return res_base;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((lmbbase + lmbsize) <=3D start)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bottom =3D max(lmbbase, start);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 top =3D min(lmbbase + lmbsize, end);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bottom >=3D top)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 found =3D lmb_find_region(lmbbase, top, siz=
e, align);
                                                               ^^^^^^^^^
should use bottom  here

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
