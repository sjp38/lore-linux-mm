Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 9FA186B0033
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 13:07:48 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id en1so1014402wid.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:07:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130808041623.GL1845@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
	<1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
	<20130807145828.GQ2296@suse.de>
	<20130807153743.GH715@cmpxchg.org>
	<20130808041623.GL1845@cmpxchg.org>
Date: Fri, 16 Aug 2013 10:07:46 -0700
Message-ID: <CAGa+x84MHrD=PXqK5tj0+gQyefyrpn6HR+-9XkDa20FeKMxt5g@mail.gmail.com>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
From: Kevin Hilman <khilman@linaro.org>
Content-Type: multipart/alternative; boundary=001a11c3893a31a02404e413a1b6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>

--001a11c3893a31a02404e413a1b6
Content-Type: text/plain; charset=ISO-8859-1

Hi Johannes,

On Wed, Aug 7, 2013 at 9:16 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>
> Patch on top of mmotm:
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation
> batching
>
> Avoid dirtying the same cache line with every single page allocation
> by making the fair per-zone allocation batch a vmstat item, which will
> turn it into batched percpu counters on SMP.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>


I bisected several boot failures on various ARM platform in next-20130816
down to this patch (commit 67131f9837 in linux-next.)  Simply reverting it
got things booting again on top of -next.  Example boot crash below.

Kevin


[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.11.0-rc5-next-20130816 (khilman@paris) (gcc
version 4.7.2 (Ubuntu/Linaro 4.7.2-1ubuntu1) ) #30 SMP Fri Aug 16 09:47:32
PDT 2013
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7),
cr=10c53c7d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing
instruction cache
[    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: TI
AM335x BeagleBone
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] On node 0 totalpages: 130816
[    0.000000] free_area_init_node: node 0, pgdat c081d400, node_mem_map
c12fc000
[    0.000000]   Normal zone: 1024 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000] Unable to handle kernel NULL pointer dereference at virtual
address 00000026
[    0.000000] pgd = c0004000
[    0.000000] [00000026] *pgd=00000000
[    0.000000] Internal error: Oops: 5 [#1] SMP ARM
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted
3.11.0-rc5-next-20130816 #30
[    0.000000] task: c0793c70 ti: c0788000 task.ti: c0788000
[    0.000000] PC is at __mod_zone_page_state+0x2c/0xb4
[    0.000000] LR is at mod_zone_page_state+0x2c/0x4c
[    0.000000] pc : [<c00eb628>]    lr : [<c00ebbf0>]    psr: 60000193
[    0.000000] sp : c0789e84  ip : 00000026  fp : c0789ef8
[    0.000000] r10: c0789f04  r9 : c05149dc  r8 : 00000000
[    0.000000] r7 : 00000026  r6 : 00000000  r5 : c0791770  r4 : c0788000
[    0.000000] r3 : 00000000  r2 : 0001fb00  r1 : 00000001  r0 : c081d400
[    0.000000] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
 Segment kernel
[    0.000000] Control: 10c5387d  Table: 80004019  DAC: 00000017
[    0>.000000] Process swapper (pid: 0, stack limit = 0xc0788240)
[    0.000000] Stack: (0xc0789e84 to 0xc078a000)
[    0.000000] 9e80:          60000193 0001fb00 00000001 c081d400 c0781570
c081d400 c081d400
[    0.000000] 9ea0: 00000000 0001fb00 00020000 c0747dd4 c077c5f4 00000001
0009ff00 0001fb00
[    0.000000] 9ec0: 00000400 00080000 00000000 bfffffff c07ebfb0 000a0000
c0789ef8 00080000
[    0.000000] 9ee0: 000a0000 00020000 000001cf c07ec188 000000cf c072ef2c
00020000 00000000
[    0.000000] 9f00: 00000000 00000100 00000000 00000000 00000000 00000000
c0821d0c dfefa000
[    0.000000] 9f20: c07ebfb0 00000001 00000001 c073080c c0789fdc c076abd4
ffff1000 0009feff
[    0.000000] 9f40: 00001000 00000007 c0734a14 c076abd4 c0821ca0 c0008000
c076c8f0 c07ec188
[    0.000000] 9f60: 413fc082 c0789fdc c064b328 c072cc3c 00000000 10c53c7d
c0d5e448 00000001
[    0.000000] 9f80: 00000000 c076c8ec c079542c 80004059 413fc082 00000000
00000000 c04f6298
[    0.000000] 9fa0: c064989c 00000001 00000000 c076c8ec c079542c 80004059
413fc082 00000000
[    0.000000] 9fc0: 00000000 c07297ec 00000000 00000000 00000000 00000000
00000000 c076c8f0
[    0.000000] 9fe0: 00000000 10c53c7d c07908e8 c076c8ec c079542c 80008074
00000000 00000000
[    0.000000] [<c00eb628>] (__mod_zone_page_state+0x2c/0xb4) from
[<c081d400>] (contig_page_data+0x0/0xd80)
[    0.000000] Code: e7958103 e0867001 e2877025 e1a0c007 (e19cc0d8)
[    0.000000] ---[ end trace 1b75b31a2719ed1c ]---

--001a11c3893a31a02404e413a1b6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Johannes,<div><br><div class=3D"gmail_extra"><div class=
=3D"gmail_quote">On Wed, Aug 7, 2013 at 9:16 PM, Johannes Weiner <span dir=
=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_blank">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(20=
4,204,204);border-left-style:solid;padding-left:1ex">

<br>
Patch on top of mmotm:<br>
<br>
---<br>
From: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpx=
chg.org</a>&gt;<br>
Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batch=
ing<br>
<br>
Avoid dirtying the same cache line with every single page allocation<br>
by making the fair per-zone allocation batch a vmstat item, which will<br>
turn it into batched percpu counters on SMP.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;</blockquote><div><br></div><div>I bisected several=
 boot failures on various ARM platform in next-20130816 down to this patch =
(commit 67131f9837 in linux-next.) =A0Simply reverting it got things bootin=
g again on top of -next. =A0Example boot crash below.</div>
<div><br></div><div>Kevin</div><div><br></div><div><br></div><div><div>[ =
=A0 =A00.000000] Booting Linux on physical CPU 0x0</div><div>[ =A0 =A00.000=
000] Linux version 3.11.0-rc5-next-20130816 (khilman@paris) (gcc version 4.=
7.2 (Ubuntu/Linaro 4.7.2-1ubuntu1) ) #30 SMP Fri Aug 16 09:47:32 PDT 2013</=
div>
<div>[ =A0 =A00.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7),=
 cr=3D10c53c7d</div><div>[ =A0 =A00.000000] CPU: PIPT / VIPT nonaliasing da=
ta cache, VIPT aliasing instruction cache</div><div>[ =A0 =A00.000000] Mach=
ine: Generic AM33XX (Flattened Device Tree), model: TI AM335x BeagleBone</d=
iv>
<div>[ =A0 =A00.000000] bootconsole [earlycon0] enabled</div><div>[ =A0 =A0=
0.000000] Memory policy: ECC disabled, Data cache writeback</div><div>[ =A0=
 =A00.000000] On node 0 totalpages: 130816</div><div>[ =A0 =A00.000000] fre=
e_area_init_node: node 0, pgdat c081d400, node_mem_map c12fc000</div>
<div>[ =A0 =A00.000000] =A0 Normal zone: 1024 pages used for memmap</div><d=
iv>[ =A0 =A00.000000] =A0 Normal zone: 0 pages reserved</div><div>[ =A0 =A0=
0.000000] Unable to handle kernel NULL pointer dereference at virtual addre=
ss 00000026</div>
<div>[ =A0 =A00.000000] pgd =3D c0004000</div><div>[ =A0 =A00.000000] [0000=
0026] *pgd=3D00000000</div><div>[ =A0 =A00.000000] Internal error: Oops: 5 =
[#1] SMP ARM</div><div>[ =A0 =A00.000000] Modules linked in:</div><div>[ =
=A0 =A00.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc5-next-20=
130816 #30</div>
<div>[ =A0 =A00.000000] task: c0793c70 ti: c0788000 task.ti: c0788000</div>=
<div>[ =A0 =A00.000000] PC is at __mod_zone_page_state+0x2c/0xb4</div><div>=
[ =A0 =A00.000000] LR is at mod_zone_page_state+0x2c/0x4c</div><div>[ =A0 =
=A00.000000] pc : [&lt;c00eb628&gt;] =A0 =A0lr : [&lt;c00ebbf0&gt;] =A0 =A0=
psr: 60000193</div>
<div>[ =A0 =A00.000000] sp : c0789e84 =A0ip : 00000026 =A0fp : c0789ef8</di=
v><div>[ =A0 =A00.000000] r10: c0789f04 =A0r9 : c05149dc =A0r8 : 00000000</=
div><div>[ =A0 =A00.000000] r7 : 00000026 =A0r6 : 00000000 =A0r5 : c0791770=
 =A0r4 : c0788000</div>
<div>[ =A0 =A00.000000] r3 : 00000000 =A0r2 : 0001fb00 =A0r1 : 00000001 =A0=
r0 : c081d400</div><div>[ =A0 =A00.000000] Flags: nZCv =A0IRQs off =A0FIQs =
on =A0Mode SVC_32 =A0ISA ARM =A0Segment kernel</div><div>[ =A0 =A00.000000]=
 Control: 10c5387d =A0Table: 80004019 =A0DAC: 00000017</div>
<div>[ =A0 =A00&gt;.000000] Process swapper (pid: 0, stack limit =3D 0xc078=
8240)</div><div>[ =A0 =A00.000000] Stack: (0xc0789e84 to 0xc078a000)</div><=
div>[ =A0 =A00.000000] 9e80: =A0 =A0 =A0 =A0 =A060000193 0001fb00 00000001 =
c081d400 c0781570 c081d400 c081d400</div>
<div>[ =A0 =A00.000000] 9ea0: 00000000 0001fb00 00020000 c0747dd4 c077c5f4 =
00000001 0009ff00 0001fb00</div><div>[ =A0 =A00.000000] 9ec0: 00000400 0008=
0000 00000000 bfffffff c07ebfb0 000a0000 c0789ef8 00080000</div><div>[ =A0 =
=A00.000000] 9ee0: 000a0000 00020000 000001cf c07ec188 000000cf c072ef2c 00=
020000 00000000</div>
<div>[ =A0 =A00.000000] 9f00: 00000000 00000100 00000000 00000000 00000000 =
00000000 c0821d0c dfefa000</div><div>[ =A0 =A00.000000] 9f20: c07ebfb0 0000=
0001 00000001 c073080c c0789fdc c076abd4 ffff1000 0009feff</div><div>[ =A0 =
=A00.000000] 9f40: 00001000 00000007 c0734a14 c076abd4 c0821ca0 c0008000 c0=
76c8f0 c07ec188</div>
<div>[ =A0 =A00.000000] 9f60: 413fc082 c0789fdc c064b328 c072cc3c 00000000 =
10c53c7d c0d5e448 00000001</div><div>[ =A0 =A00.000000] 9f80: 00000000 c076=
c8ec c079542c 80004059 413fc082 00000000 00000000 c04f6298</div><div>[ =A0 =
=A00.000000] 9fa0: c064989c 00000001 00000000 c076c8ec c079542c 80004059 41=
3fc082 00000000</div>
<div>[ =A0 =A00.000000] 9fc0: 00000000 c07297ec 00000000 00000000 00000000 =
00000000 00000000 c076c8f0</div><div>[ =A0 =A00.000000] 9fe0: 00000000 10c5=
3c7d c07908e8 c076c8ec c079542c 80008074 00000000 00000000</div><div>[ =A0 =
=A00.000000] [&lt;c00eb628&gt;] (__mod_zone_page_state+0x2c/0xb4) from [&lt=
;c081d400&gt;] (contig_page_data+0x0/0xd80)</div>
<div>[ =A0 =A00.000000] Code: e7958103 e0867001 e2877025 e1a0c007 (e19cc0d8=
)=A0</div><div>[ =A0 =A00.000000] ---[ end trace 1b75b31a2719ed1c ]---</div=
></div><div><br></div></div></div></div></div>

--001a11c3893a31a02404e413a1b6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
