Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D34C6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 03:51:24 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so50555782lab.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 00:51:23 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id r2si5814196lar.102.2015.04.16.00.51.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 00:51:21 -0700 (PDT)
Date: Thu, 16 Apr 2015 15:51:05 +0800
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-Id: <1429170665.19274.0@cpanel21.proisp.no>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=-8GnILWyjjcoTFyBHINwl"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Steffen Persvold <sp@numascale.com>, Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

--=-8GnILWyjjcoTFyBHINwl
Content-Type: text/plain; charset=utf-8; format=flowed

On Monday, April 13, 2015 at 6:20:05 PM UTC+8, Mel Gorman wrote:
 > Memory initialisation had been identified as one of the reasons why 
large
 > machines take a long time to boot. Patches were posted a long time 
ago
 > that attempted to move deferred initialisation into the page 
allocator
 > paths. This was rejected on the grounds it should not be necessary 
to hurt
 > the fast paths to parallelise initialisation. This series reuses 
much of
 > the work from that time but defers the initialisation of memory to 
kswapd
 > so that one thread per node initialises memory local to that node. 
The
 > issue is that on the machines I tested with, memory initialisation 
was not
 > a major contributor to boot times. I'm posting the RFC to both 
review the
 > series and see if it actually helps users of very large machines.
 >
 > After applying the series and setting the appropriate Kconfig 
variable I
 > see this in the boot log on a 64G machine
 >
 > [    7.383764] kswapd 0 initialised deferred memory in 188ms
 > [    7.404253] kswapd 1 initialised deferred memory in 208ms
 > [    7.411044] kswapd 3 initialised deferred memory in 216ms
 > [    7.411551] kswapd 2 initialised deferred memory in 216ms
 >
 > On a 1TB machine, I see
 >
 > [   11.913324] kswapd 0 initialised deferred memory in 1168ms
 > [   12.220011] kswapd 2 initialised deferred memory in 1476ms
 > [   12.245369] kswapd 3 initialised deferred memory in 1500ms
 > [   12.271680] kswapd 1 initialised deferred memory in 1528ms
 >
 > Once booted the machine appears to work as normal. Boot times were 
measured
 > from the time shutdown was called until ssh was available again.  In 
the
 > 64G case, the boot time savings are negligible. On the 1TB machine, 
the
 > savings were 10 seconds (about 8% improvement on kernel times but 
1-2%
 > overall as POST takes so long).
 >
 > It would be nice if the people that have access to really large 
machines
 > would test this series and report back if the complexity is 
justified.

Nice work!

On an older Numascale system with 1TB memory and 256 cores/32 NUMA 
nodes, platform init takes 52s (cold boot), firmware takes 84s 
(includes one warm reboot), stock linux 4.0 then takes 732s to boot [1] 
(due to the 700ns roundtrip, RMW cache-coherent cycles due to the 
temporal writes for pagetable init and per-core store queue limits), so 
there is huge potential.

Alas I ran into crashing during list manipulation [2] which list 
debugging detects [3]; I had started adding some debug [4], but need to 
look a bit deeper into it. I annotated the time of the output from cold 
power on.

Thanks,
  Daniel

[1] https://resources.numascale.com/telemetry/defermem/console-stock.txt
[2] 
https://resources.numascale.com/telemetry/defermem/console-patched.txt
[3] 
https://resources.numascale.com/telemetry/defermem/console-patched-debug.txt

-- [4]

static void free_pcppages_bulk(struct zone *zone, int count,
					struct per_cpu_pages *pcp)
...
		pr_err("migrate_type=%d\n", migratetype);

		/* This is the only non-empty list. Free them all. */
		if (batch_free == MIGRATE_PCPTYPES)
			batch_free = to_free;

		do {
			int mt;	/* migratetype of the to-be-freed page */

			pr_err("list_empty=%d\n", list_empty(list));

--=-8GnILWyjjcoTFyBHINwl
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<div>On Monday, April 13, 2015 at 6:20:05 PM UTC+8, Mel Gorman wrote:</div>=
<div>&gt; Memory initialisation had been identified as one of the reasons w=
hy large</div><div>&gt; machines take a long time to boot. Patches were pos=
ted a long time ago</div><div>&gt; that attempted to move deferred initiali=
sation into the page allocator</div><div>&gt; paths. This was rejected on t=
he grounds it should not be necessary to hurt</div><div>&gt; the fast paths=
 to parallelise initialisation. This series reuses much of</div><div>&gt; t=
he work from that time but defers the initialisation of memory to kswapd</d=
iv><div>&gt; so that one thread per node initialises memory local to that n=
ode. The</div><div>&gt; issue is that on the machines I tested with, memory=
 initialisation was not</div><div>&gt; a major contributor to boot times. I=
'm posting the RFC to both review the</div><div>&gt; series and see if it a=
ctually helps users of very large machines.</div><div>&gt;&nbsp;</div><div>=
&gt; After applying the series and setting the appropriate Kconfig variable=
 I</div><div>&gt; see this in the boot log on a 64G machine</div><div>&gt;&=
nbsp;</div><div>&gt; [ &nbsp; &nbsp;7.383764] kswapd 0 initialised deferred=
 memory in 188ms</div><div>&gt; [ &nbsp; &nbsp;7.404253] kswapd 1 initialis=
ed deferred memory in 208ms</div><div>&gt; [ &nbsp; &nbsp;7.411044] kswapd =
3 initialised deferred memory in 216ms</div><div>&gt; [ &nbsp; &nbsp;7.4115=
51] kswapd 2 initialised deferred memory in 216ms</div><div>&gt;&nbsp;</div=
><div>&gt; On a 1TB machine, I see</div><div>&gt;&nbsp;</div><div>&gt; [ &n=
bsp; 11.913324] kswapd 0 initialised deferred memory in 1168ms</div><div>&g=
t; [ &nbsp; 12.220011] kswapd 2 initialised deferred memory in 1476ms</div>=
<div>&gt; [ &nbsp; 12.245369] kswapd 3 initialised deferred memory in 1500m=
s</div><div>&gt; [ &nbsp; 12.271680] kswapd 1 initialised deferred memory i=
n 1528ms</div><div>&gt;&nbsp;</div><div>&gt; Once booted the machine appear=
s to work as normal. Boot times were measured</div><div>&gt; from the time =
shutdown was called until ssh was available again. &nbsp;In the</div><div>&=
gt; 64G case, the boot time savings are negligible. On the 1TB machine, the=
</div><div>&gt; savings were 10 seconds (about 8% improvement on kernel tim=
es but 1-2%</div><div>&gt; overall as POST takes so long).</div><div>&gt;&n=
bsp;</div><div>&gt; It would be nice if the people that have access to real=
ly large machines</div><div>&gt; would test this series and report back if =
the complexity is justified.</div><div><br></div><div>Nice work!</div><div>=
<br></div><div>On an older Numascale system with 1TB memory and 256 cores/3=
2 NUMA nodes, platform init takes 52s (cold boot), firmware takes 84s (incl=
udes one warm reboot), stock linux 4.0 then takes 732s to boot [1] (due to =
the 700ns roundtrip, RMW cache-coherent cycles due to the temporal writes f=
or pagetable init and per-core store queue limits), so there is huge potent=
ial.</div><div><br></div><div>Alas I ran into crashing during list manipula=
tion [2] which list debugging detects [3]; I had started adding some debug =
[4], but need to look a bit deeper into it. I annotated the time of the out=
put from cold power on.</div><div><br></div><div>Thanks,</div><div>&nbsp; D=
aniel</div><div><br></div><div>[1] <a href=3D"https://resources.numascale.c=
om/telemetry/defermem/console-stock.txt">https://resources.numascale.com/te=
lemetry/defermem/console-stock.txt</a></div><div>[2] <a href=3D"https://res=
ources.numascale.com/telemetry/defermem/console-patched.txt">https://resour=
ces.numascale.com/telemetry/defermem/console-patched.txt</a></div><div><div=
>[3] <a href=3D"https://resources.numascale.com/telemetry/defermem/console-=
patched-debug.txt">https://resources.numascale.com/telemetry/defermem/conso=
le-patched-debug.txt</a></div></div><div><br></div><div>-- [4]</div><div><b=
r></div><div><div>static void free_pcppages_bulk(struct zone *zone, int cou=
nt,</div><div><span class=3D"Apple-tab-span" style=3D"white-space:pre">				=
	</span>struct per_cpu_pages *pcp)</div><div>...</div><div><span class=3D"A=
pple-tab-span" style=3D"white-space: pre;">		</span>pr_err("migrate_type=3D=
%d\n", migratetype);</div><div><br></div><div><span class=3D"Apple-tab-span=
" style=3D"white-space:pre">		</span>/* This is the only non-empty list. Fr=
ee them all. */</div><div><span class=3D"Apple-tab-span" style=3D"white-spa=
ce:pre">		</span>if (batch_free =3D=3D MIGRATE_PCPTYPES)</div><div><span cl=
ass=3D"Apple-tab-span" style=3D"white-space:pre">			</span>batch_free =3D t=
o_free;</div><div><br></div><div><span class=3D"Apple-tab-span" style=3D"wh=
ite-space:pre">		</span>do {</div><div><span class=3D"Apple-tab-span" style=
=3D"white-space:pre">			</span>int mt;<span class=3D"Apple-tab-span" style=
=3D"white-space:pre">	</span>/* migratetype of the to-be-freed page */</div=
><div><br></div><div><span class=3D"Apple-tab-span" style=3D"white-space:pr=
e">			</span>pr_err("list_empty=3D%d\n", list_empty(list));</div></div>=

--=-8GnILWyjjcoTFyBHINwl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
