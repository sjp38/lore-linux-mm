Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0A3F8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:50:58 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so8014835pfs.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:50:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s36sor3461838pld.52.2019.01.17.10.50.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 10:50:57 -0800 (PST)
MIME-Version: 1.0
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
In-Reply-To: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
From: Oscar Salvador <osalvador.vilardaga@gmail.com>
Date: Thu, 17 Jan 2019 19:50:44 +0100
Message-ID: <CAOXBz7iFz-K-u-K0+YR15OwzMNArOnUJ7PytQ9+2Pm_0WK8=Mg@mail.gmail.com>
Subject: Re: kmemleak scan crash due to invalid PFNs
Content-Type: multipart/alternative; boundary="000000000000f3679e057fabdf20"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Oscar Salvador <osalvador@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>

--000000000000f3679e057fabdf20
Content-Type: text/plain; charset="UTF-8"

On Thu, 17 Jan 2019, 18:36 Qian Cai <cai@lca.pw wrote:

> On an arm64 ThunderX2 server, the first kmemleak scan would crash with
> CONFIG_DEBUG_VM_PGFLAGS=y due to page_to_nid() found a pfn that is not
> directly
> mapped. Hence, the page->flags is not initialized.
>
> Reverted 9f1eb38e0e113 (mm, kmemleak: little optimization while scanning)
> fixed
> the problem.
>

Thanks for reporting it.
I will take a look later.


> [  102.195320] Unable to handle kernel NULL pointer dereference at virtual
> address 0000000000000006
> [  102.204113] Mem abort info:
> [  102.206921]   ESR = 0x96000005
> [  102.209997]   Exception class = DABT (current EL), IL = 32 bits
> [  102.215926]   SET = 0, FnV = 0
> [  102.218993]   EA = 0, S1PTW = 0
> [  102.222150] Data abort info:
> [  102.225047]   ISV = 0, ISS = 0x00000005
> [  102.228887]   CM = 0, WnR = 0
> [  102.231866] user pgtable: 64k pages, 48-bit VAs, pgdp = (____ptrval____)
> [  102.238572] [0000000000000006] pgd=0000000000000000,
> pud=0000000000000000
> [  102.245448] Internal error: Oops: 96000005 [#1] SMP
> [  102.264062] CPU: 60 PID: 1408 Comm: kmemleak Not tainted 5.0.0-rc2+ #8
> [  102.280403] pstate: 60400009 (nZCv daif +PAN -UAO)
> [  102.280409] pc : page_mapping+0x24/0x144
> [  102.280415] lr : __dump_page+0x34/0x3dc
> [  102.292923] sp : ffff00003a5cfd10
> [  102.296229] x29: ffff00003a5cfd10 x28: 000000000000802f
> [  102.301533] x27: 0000000000000000 x26: 0000000000277d00
> [  102.306835] x25: ffff000010791f56 x24: ffff7fe000000000
> [  102.312138] x23: ffff000010772f8b x22: ffff00001125f670
> [  102.317442] x21: ffff000011311000 x20: ffff000010772f8b
> [  102.322747] x19: fffffffffffffffe x18: 0000000000000000
> [  102.328049] x17: 0000000000000000 x16: 0000000000000000
> [  102.333352] x15: 0000000000000000 x14: ffff802698b19600
> [  102.338654] x13: ffff802698b1a200 x12: ffff802698b16f00
> [  102.343956] x11: ffff802698b1a400 x10: 0000000000001400
> [  102.349260] x9 : 0000000000000001 x8 : ffff00001121a000
> [  102.354563] x7 : 0000000000000000 x6 : ffff0000102c53b8
> [  102.359868] x5 : 0000000000000000 x4 : 0000000000000003
> [  102.365173] x3 : 0000000000000100 x2 : 0000000000000000
> [  102.370476] x1 : ffff000010772f8b x0 : ffffffffffffffff
> [  102.375782] Process kmemleak (pid: 1408, stack limit =
> 0x(____ptrval____))
> [  102.382648] Call trace:
> [  102.385091]  page_mapping+0x24/0x144
> [  102.388659]  __dump_page+0x34/0x3dc
> [  102.392140]  dump_page+0x28/0x4c
> [  102.395363]  kmemleak_scan+0x4ac/0x680
> [  102.399106]  kmemleak_scan_thread+0xb4/0xdc
> [  102.403285]  kthread+0x12c/0x13c
> [  102.406509]  ret_from_fork+0x10/0x18
> [  102.410080] Code: d503201f f9400660 36000040 d1000413 (f9400661)
> [  102.416357] ---[ end trace 4d4bd7f573490c8e ]---
> [  102.420966] Kernel panic - not syncing: Fatal exception
> [  102.426293] SMP: stopping secondary CPUs
> [  102.431830] Kernel Offset: disabled
> [  102.435311] CPU features: 0x002,20000c38
> [  102.439223] Memory Limit: none
> [  102.442384] ---[ end Kernel panic - not syncing: Fatal exception ]---
>
>

--000000000000f3679e057fabdf20
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Thu, 17 Jan 2019, 18:36 Qian Cai &lt;<a href=3D"mailto:cai@lca.pw">cai@l=
ca.pw</a> wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On an arm64 Thunde=
rX2 server, the first kmemleak scan would crash with<br>
CONFIG_DEBUG_VM_PGFLAGS=3Dy due to page_to_nid() found a pfn that is not di=
rectly<br>
mapped. Hence, the page-&gt;flags is not initialized.<br>
<br>
Reverted 9f1eb38e0e113 (mm, kmemleak: little optimization while scanning) f=
ixed<br>
the problem.<br></blockquote></div></div><div dir=3D"auto"><br></div><div d=
ir=3D"auto">Thanks for reporting it.</div><div dir=3D"auto">I will take a l=
ook later.</div><div dir=3D"auto"><br></div><div dir=3D"auto"><div class=3D=
"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">
<br>
[=C2=A0 102.195320] Unable to handle kernel NULL pointer dereference at vir=
tual<br>
address 0000000000000006<br>
[=C2=A0 102.204113] Mem abort info:<br>
[=C2=A0 102.206921]=C2=A0 =C2=A0ESR =3D 0x96000005<br>
[=C2=A0 102.209997]=C2=A0 =C2=A0Exception class =3D DABT (current EL), IL =
=3D 32 bits<br>
[=C2=A0 102.215926]=C2=A0 =C2=A0SET =3D 0, FnV =3D 0<br>
[=C2=A0 102.218993]=C2=A0 =C2=A0EA =3D 0, S1PTW =3D 0<br>
[=C2=A0 102.222150] Data abort info:<br>
[=C2=A0 102.225047]=C2=A0 =C2=A0ISV =3D 0, ISS =3D 0x00000005<br>
[=C2=A0 102.228887]=C2=A0 =C2=A0CM =3D 0, WnR =3D 0<br>
[=C2=A0 102.231866] user pgtable: 64k pages, 48-bit VAs, pgdp =3D (____ptrv=
al____)<br>
[=C2=A0 102.238572] [0000000000000006] pgd=3D0000000000000000, pud=3D000000=
0000000000<br>
[=C2=A0 102.245448] Internal error: Oops: 96000005 [#1] SMP<br>
[=C2=A0 102.264062] CPU: 60 PID: 1408 Comm: kmemleak Not tainted 5.0.0-rc2+=
 #8<br>
[=C2=A0 102.280403] pstate: 60400009 (nZCv daif +PAN -UAO)<br>
[=C2=A0 102.280409] pc : page_mapping+0x24/0x144<br>
[=C2=A0 102.280415] lr : __dump_page+0x34/0x3dc<br>
[=C2=A0 102.292923] sp : ffff00003a5cfd10<br>
[=C2=A0 102.296229] x29: ffff00003a5cfd10 x28: 000000000000802f<br>
[=C2=A0 102.301533] x27: 0000000000000000 x26: 0000000000277d00<br>
[=C2=A0 102.306835] x25: ffff000010791f56 x24: ffff7fe000000000<br>
[=C2=A0 102.312138] x23: ffff000010772f8b x22: ffff00001125f670<br>
[=C2=A0 102.317442] x21: ffff000011311000 x20: ffff000010772f8b<br>
[=C2=A0 102.322747] x19: fffffffffffffffe x18: 0000000000000000<br>
[=C2=A0 102.328049] x17: 0000000000000000 x16: 0000000000000000<br>
[=C2=A0 102.333352] x15: 0000000000000000 x14: ffff802698b19600<br>
[=C2=A0 102.338654] x13: ffff802698b1a200 x12: ffff802698b16f00<br>
[=C2=A0 102.343956] x11: ffff802698b1a400 x10: 0000000000001400<br>
[=C2=A0 102.349260] x9 : 0000000000000001 x8 : ffff00001121a000<br>
[=C2=A0 102.354563] x7 : 0000000000000000 x6 : ffff0000102c53b8<br>
[=C2=A0 102.359868] x5 : 0000000000000000 x4 : 0000000000000003<br>
[=C2=A0 102.365173] x3 : 0000000000000100 x2 : 0000000000000000<br>
[=C2=A0 102.370476] x1 : ffff000010772f8b x0 : ffffffffffffffff<br>
[=C2=A0 102.375782] Process kmemleak (pid: 1408, stack limit =3D 0x(____ptr=
val____))<br>
[=C2=A0 102.382648] Call trace:<br>
[=C2=A0 102.385091]=C2=A0 page_mapping+0x24/0x144<br>
[=C2=A0 102.388659]=C2=A0 __dump_page+0x34/0x3dc<br>
[=C2=A0 102.392140]=C2=A0 dump_page+0x28/0x4c<br>
[=C2=A0 102.395363]=C2=A0 kmemleak_scan+0x4ac/0x680<br>
[=C2=A0 102.399106]=C2=A0 kmemleak_scan_thread+0xb4/0xdc<br>
[=C2=A0 102.403285]=C2=A0 kthread+0x12c/0x13c<br>
[=C2=A0 102.406509]=C2=A0 ret_from_fork+0x10/0x18<br>
[=C2=A0 102.410080] Code: d503201f f9400660 36000040 d1000413 (f9400661)<br=
>
[=C2=A0 102.416357] ---[ end trace 4d4bd7f573490c8e ]---<br>
[=C2=A0 102.420966] Kernel panic - not syncing: Fatal exception<br>
[=C2=A0 102.426293] SMP: stopping secondary CPUs<br>
[=C2=A0 102.431830] Kernel Offset: disabled<br>
[=C2=A0 102.435311] CPU features: 0x002,20000c38<br>
[=C2=A0 102.439223] Memory Limit: none<br>
[=C2=A0 102.442384] ---[ end Kernel panic - not syncing: Fatal exception ]-=
--<br>
<br>
</blockquote></div></div></div>

--000000000000f3679e057fabdf20--
