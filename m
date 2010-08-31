Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 06B2F6B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:41:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V1fgdN008052
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 10:41:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5450A45DE51
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:41:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1423D45DE4E
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:41:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E8F301DB8040
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:41:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 99E871DB8037
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:41:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTi=yeqp=xaXE8Q6_VchqT=4HqCcN=Dr41ea5HbZC@mail.gmail.com>
References: <20100831101456.87D0.A69D9226@jp.fujitsu.com> <AANLkTi=yeqp=xaXE8Q6_VchqT=4HqCcN=Dr41ea5HbZC@mail.gmail.com>
Message-Id: <20100831104014.87D6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 31 Aug 2010 10:41:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Aug 31, 2010 at 10:18 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Hi, KOSAKI.
> >>
> >> On Tue, Aug 31, 2010 at 9:56 AM, KOSAKI Motohiro
> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> >> index 1b145e6..0b8a3ce 100644
> >> >> --- a/mm/vmscan.c
> >> >> +++ b/mm/vmscan.c
> >> >> @@ -1747,7 +1747,7 @@ static void shrink_zone(int priority, struct =
zone *zone,
> >> >> =A0 =A0 =A0 =A0 =A0* Even if we did not try to evict anon pages at =
all, we want to
> >> >> =A0 =A0 =A0 =A0 =A0* rebalance the anon lru active/inactive ratio.
> >> >> =A0 =A0 =A0 =A0 =A0*/
> >> >> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages >=
 0)
> >> >> + =A0 =A0 =A0 if (nr_swap_pges > 0 && inactive_anon_is_low(zone, sc=
))
> >> >
> >> > Sorry, I don't find any difference. What is your intention?
> >> >
> >>
> >> My intention is that smart gcc can compile out inactive_anon_is_low
> >> call in case of non swap configurable system.
> >
> > Do you really check it on your gcc? nr_swap_pages is not file scope var=
iable, it's
> > global variable. afaik, current gcc's link time optimization is not so =
cool.
>=20
> #else /* CONFIG_SWAP */
>=20
> #define nr_swap_pages                           0L
> #define total_swap_pages                        0L
> #define total_swapcache_pages                   0UL

Ahh, I missed, sorry.


> > Do you have a disassemble list?
> >
>=20
> environment for test :
> gcc : arm-none-linux-gnueabi-gcc (Sourcery G++ Lite 2009q3-67) 4.4.1
> kernel : 2.6.28(for test, I used my working kernel version with my patch)
> assembled function is shrink_zone.
> (Please understand web gmail's contents mangling. Google guys! Please
> repair for like me who can't use SMTP in company. :( )
>=20
> 1. swap configurable version
>=20
>     1cd0:       e51b303c        ldr     r3, [fp, #-60]  ; 0x3c
>     1cd4:       e3530000        cmp     r3, #0
>     1cd8:       1affffd1        bne     1c24 <shrink_zone+0x23c>
>     1cdc:       e5879004        str     r9, [r7, #4]
>     1ce0:       e1a00008        mov     r0, r8
>     1ce4:       e1a01007        mov     r1, r7
>     1ce8:       e1a04008        mov     r4, r8
>     1cec:       ebfff8eb        bl      a0 <inactive_anon_is_low>     <=
=3D=3D
>     1cf0:       e1a05007        mov     r5, r7
>     1cf4:       e3500000        cmp     r0, #0
>     1cf8:       0a000006        beq     1d18 <shrink_zone+0x330>
>     1cfc:       e1a01008        mov     r1, r8
>     1d00:       e1a03006        mov     r3, r6
>     1d04:       e3a00020        mov     r0, #32
>     1d08:       e1a02007        mov     r2, r7
>     1d0c:       e3a0c000        mov     ip, #0
>     1d10:       e58dc000        str     ip, [sp]
>     1d14:       ebfffa98        bl      77c <shrink_active_list>
>     1d18:       e5950008        ldr     r0, [r5, #8]
>     1d1c:       ebfffffe        bl      0 <throttle_vm_writeout>
>     1d20:       e24bd028        sub     sp, fp, #40     ; 0x28
>=20
> 2. non swap configurable version
>=20
>     1994:       e3530000        cmp     r3, #0
>     1998:       0a000003        beq     19ac <shrink_zone+0x170>
>     199c:       e598300c        ldr     r3, [r8, #12]
>     19a0:       e593300c        ldr     r3, [r3, #12]
>     19a4:       e3130701        tst     r3, #262144     ; 0x40000
>     19a8:       0a000008        beq     19d0 <shrink_zone+0x194>
>     19ac:       e51b3044        ldr     r3, [fp, #-68]  ; 0x44
>     19b0:       e3530000        cmp     r3, #0
>     19b4:       1affffd7        bne     1918 <shrink_zone+0xdc>
>     19b8:       e51b3038        ldr     r3, [fp, #-56]  ; 0x38
>     19bc:       e3530000        cmp     r3, #0
>     19c0:       1affffd4        bne     1918 <shrink_zone+0xdc>
>     19c4:       e51b303c        ldr     r3, [fp, #-60]  ; 0x3c
>     19c8:       e3530000        cmp     r3, #0
>     19cc:       1affffd1        bne     1918 <shrink_zone+0xdc>
>     19d0:       e586a004        str     sl, [r6, #4]
>     19d4:       e1a04006        mov     r4, r6
>     19d8:       e5960008        ldr     r0, [r6, #8]
>     19dc:       ebfffffe        bl      0 <throttle_vm_writeout>
>     19e0:       e24bd028        sub     sp, fp, #40     ; 0x28

Thanks,  I'm convinced.=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
