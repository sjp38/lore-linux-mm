Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 267626B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:02:26 -0400 (EDT)
Received: by widdi4 with SMTP id di4so60164863wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 00:02:25 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id e7si1387827wib.9.2015.04.13.00.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 00:02:23 -0700 (PDT)
Received: by widdi4 with SMTP id di4so60163666wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 00:02:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150307001816.GA2850@udknight>
References: <20150307001816.GA2850@udknight>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 13 Apr 2015 10:02:02 +0300
Message-ID: <CALq1K=KGviHKBAUFMj_QLa4eCRtmQo5NSXbJ+s5sp0tDpvs36Q@mail.gmail.com>
Subject: Re: [PATCH RESEND] block:bounce: fix call inc_|dec_zone_page_state on
 different pages confuse value of NR_BOUNCE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang YanQing <udknight@gmail.com>, axboe@kernel.dk, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sat, Mar 7, 2015 at 2:18 AM, Wang YanQing <udknight@gmail.com> wrote:
>
> Commit d2c5e30c9a1420902262aa923794d2ae4e0bc391
> ("[PATCH] zoned vm counters: conversion of nr_bounce to per zone counter"=
)
> convert statistic of nr_bounce to per zone and one global value in vm_sta=
t,
> but it call call inc_|dec_zone_page_state on different pages, then differ=
ent
Minor typo "call call" =3D> "call"

> zones, and cause we get confusion value of NR_BOUNCE.
I suggest to rephrase the "and cause we get confusion value" to be
"and cause us to get unexpected value".

>
> Below is the result on my machine:
> Mar  2 09:26:08 udknight kernel: [144766.778265] Mem-Info:
> Mar  2 09:26:08 udknight kernel: [144766.778266] DMA per-cpu:
> Mar  2 09:26:08 udknight kernel: [144766.778268] CPU    0: hi:    0, btch=
:   1 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778269] CPU    1: hi:    0, btch=
:   1 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778270] Normal per-cpu:
> Mar  2 09:26:08 udknight kernel: [144766.778271] CPU    0: hi:  186, btch=
:  31 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778273] CPU    1: hi:  186, btch=
:  31 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778274] HighMem per-cpu:
> Mar  2 09:26:08 udknight kernel: [144766.778275] CPU    0: hi:  186, btch=
:  31 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778276] CPU    1: hi:  186, btch=
:  31 usd:   0
> Mar  2 09:26:08 udknight kernel: [144766.778279] active_anon:46926 inacti=
ve_anon:287406 isolated_anon:0
> Mar  2 09:26:08 udknight kernel: [144766.778279]  active_file:105085 inac=
tive_file:139432 isolated_file:0
> Mar  2 09:26:08 udknight kernel: [144766.778279]  unevictable:653 dirty:0=
 writeback:0 unstable:0
> Mar  2 09:26:08 udknight kernel: [144766.778279]  free:178957 slab_reclai=
mable:6419 slab_unreclaimable:9966
> Mar  2 09:26:08 udknight kernel: [144766.778279]  mapped:4426 shmem:30527=
7 pagetables:784 bounce:0
> Mar  2 09:26:08 udknight kernel: [144766.778279]  free_cma:0
> Mar  2 09:26:08 udknight kernel: [144766.778286] DMA free:3324kB min:68kB=
 low:84kB high:100kB active_anon:0kB inactive_anon:0kB active_file:0kB inac=
tive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present=
:15976kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shm=
em:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetab=
les:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanne=
d:0 all_unreclaimable? yes
> Mar  2 09:26:08 udknight kernel: [144766.778287] lowmem_reserve[]: 0 822 =
3754 3754
> Mar  2 09:26:08 udknight kernel: [144766.778293] Normal free:26828kB min:=
3632kB low:4540kB high:5448kB active_anon:4872kB inactive_anon:68kB active_=
file:1796kB inactive_file:1796kB unevictable:0kB isolated(anon):0kB isolate=
d(file):0kB present:892920kB managed:842560kB mlocked:0kB dirty:0kB writeba=
ck:0kB mapped:0kB shmem:4144kB slab_reclaimable:25676kB slab_unreclaimable:=
39864kB kernel_stack:1944kB pagetables:3136kB unstable:0kB bounce:0kB free_=
cma:0kB writeback_tmp:0kB pages_scanned:2412612 all_unreclaimable? yes
> Mar  2 09:26:08 udknight kernel: [144766.778294] lowmem_reserve[]: 0 0 23=
451 23451
> Mar  2 09:26:08 udknight kernel: [144766.778299] HighMem free:685676kB mi=
n:512kB low:3748kB high:6984kB active_anon:182832kB inactive_anon:1149556kB=
 active_file:418544kB inactive_file:555932kB unevictable:2612kB isolated(an=
on):0kB isolated(file):0kB present:3001732kB managed:3001732kB mlocked:0kB =
dirty:0kB writeback:0kB mapped:17704kB shmem:1216964kB slab_reclaimable:0kB=
 slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce=
:75771152kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimabl=
e? no
> Mar  2 09:26:08 udknight kernel: [144766.778300] lowmem_reserve[]: 0 0 0 =
0
>
> You can see bounce:75771152kB for HighMem, but bounce:0 for lowmem and gl=
obal.
>
> This patch fix it.
>
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> ---
>  I find previous email can't be "git am" properly,
>  so resend it.
>
>  Thanks.
>
>  block/bounce.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/block/bounce.c b/block/bounce.c
> index ab21ba2..ed9dd80 100644
> --- a/block/bounce.c
> +++ b/block/bounce.c
> @@ -221,8 +221,8 @@ bounce:
>                 if (page_to_pfn(page) <=3D queue_bounce_pfn(q) && !force)
>                         continue;
>
> -               inc_zone_page_state(to->bv_page, NR_BOUNCE);
>                 to->bv_page =3D mempool_alloc(pool, q->bounce_gfp);
> +               inc_zone_page_state(to->bv_page, NR_BOUNCE);
>
>                 if (rw =3D=3D WRITE) {
>                         char *vto, *vfrom;
> --
> 2.2.2.dirty
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>




--=20
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
