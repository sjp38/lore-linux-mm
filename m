Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id B8ED26B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:15:20 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so120308670lbb.3
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:15:19 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id xd3si14003871lbb.166.2015.04.19.20.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Apr 2015 20:15:18 -0700 (PDT)
Date: Mon, 20 Apr 2015 11:15:02 +0800
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-Id: <1429499702.19274.3@cpanel21.proisp.no>
In-Reply-To: <1429170665.19274.0@cpanel21.proisp.no>
References: <1429170665.19274.0@cpanel21.proisp.no>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=-DejikgOscgqmSaaDBNGh"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Steffen Persvold <sp@numascale.com>, Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

--=-DejikgOscgqmSaaDBNGh
Content-Type: text/plain; charset=utf-8; format=flowed

On Thu, Apr 16, 2015 at 3:51 PM, Daniel J Blueman 
<daniel@numascale.com> wrote:
> On Monday, April 13, 2015 at 6:20:05 PM UTC+8, Mel Gorman wrote:
> > Memory initialisation had been identified as one of the reasons why 
> large
> > machines take a long time to boot. Patches were posted a long time 
> ago
> > that attempted to move deferred initialisation into the page 
> allocator
> > paths. This was rejected on the grounds it should not be necessary 
> to hurt
> > the fast paths to parallelise initialisation. This series reuses 
> much of
> > the work from that time but defers the initialisation of memory to 
> kswapd
> > so that one thread per node initialises memory local to that node. 
> The
> > issue is that on the machines I tested with, memory initialisation 
> was not
> > a major contributor to boot times. I'm posting the RFC to both 
> review the
> > series and see if it actually helps users of very large machines.
> >
> > After applying the series and setting the appropriate Kconfig 
> variable I
> > see this in the boot log on a 64G machine
> >
> > [    7.383764] kswapd 0 initialised deferred memory in 188ms
> > [    7.404253] kswapd 1 initialised deferred memory in 208ms
> > [    7.411044] kswapd 3 initialised deferred memory in 216ms
> > [    7.411551] kswapd 2 initialised deferred memory in 216ms
> >
> > On a 1TB machine, I see
> >
> > [   11.913324] kswapd 0 initialised deferred memory in 1168ms
> > [   12.220011] kswapd 2 initialised deferred memory in 1476ms
> > [   12.245369] kswapd 3 initialised deferred memory in 1500ms
> > [   12.271680] kswapd 1 initialised deferred memory in 1528ms
> >
> > Once booted the machine appears to work as normal. Boot times were 
> measured
> > from the time shutdown was called until ssh was available again.  
> In the
> > 64G case, the boot time savings are negligible. On the 1TB machine, 
> the
> > savings were 10 seconds (about 8% improvement on kernel times but 
> 1-2%
> > overall as POST takes so long).
> >
> > It would be nice if the people that have access to really large 
> machines
> > would test this series and report back if the complexity is 
> justified.
> 
> Nice work!
> 
> On an older Numascale system with 1TB memory and 256 cores/32 NUMA 
> nodes, platform init takes 52s (cold boot), firmware takes 84s 
> (includes one warm reboot), stock linux 4.0 then takes 732s to boot 
> [1] (due to the 700ns roundtrip, RMW cache-coherent cycles due to the 
> temporal writes for pagetable init and per-core store queue limits), 
> so there is huge potential.

Same 1TB setup (256 cores, 32 NUMA nodes):
unpatched 4.0: 789s [1]
2GB per node up-front: 426s [2]
4GB node 0 up-front, 0GB later nodes: 461s [3]
4GB node 0 up-front, 0.5GB later nodes: 404s [4]

Compelling results at only 1TB! In the last case, we see PMD setup take 
42% (168s) of the time, along with topology_init taking 39% (157s). I 
should be able to get data on a 7TB system this week.

[1] 
https://resources.numascale.com/telemetry/defermem/h8qgl-defer-stock.txt
[2] 
https://resources.numascale.com/telemetry/defermem/h8qgl-defer-2g.txt
[3] 
https://resources.numascale.com/telemetry/defermem/h8qgl-defer-4+0.txt
[4] 
https://resources.numascale.com/telemetry/defermem/h8qgl-defer-4+half.txt

--=-DejikgOscgqmSaaDBNGh
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 16, 2015 at 3:51 PM, Daniel J Blueman &lt;daniel@numascale.com&=
gt; wrote:<br>
<blockquote type=3D"cite"><div>On Monday, April 13, 2015 at 6:20:05 PM UTC+=
8, Mel Gorman wrote:</div><div>&gt; Memory initialisation had been identifi=
ed as one of the reasons why large</div><div>&gt; machines take a long time=
 to boot. Patches were posted a long time ago</div><div>&gt; that attempted=
 to move deferred initialisation into the page allocator</div><div>&gt; pat=
hs. This was rejected on the grounds it should not be necessary to hurt</di=
v><div>&gt; the fast paths to parallelise initialisation. This series reuse=
s much of</div><div>&gt; the work from that time but defers the initialisat=
ion of memory to kswapd</div><div>&gt; so that one thread per node initiali=
ses memory local to that node. The</div><div>&gt; issue is that on the mach=
ines I tested with, memory initialisation was not</div><div>&gt; a major co=
ntributor to boot times. I'm posting the RFC to both review the</div><div>&=
gt; series and see if it actually helps users of very large machines.</div>=
<div>&gt;&nbsp;</div><div>&gt; After applying the series and setting the ap=
propriate Kconfig variable I</div><div>&gt; see this in the boot log on a 6=
4G machine</div><div>&gt;&nbsp;</div><div>&gt; [ &nbsp; &nbsp;7.383764] ksw=
apd 0 initialised deferred memory in 188ms</div><div>&gt; [ &nbsp; &nbsp;7.=
404253] kswapd 1 initialised deferred memory in 208ms</div><div>&gt; [ &nbs=
p; &nbsp;7.411044] kswapd 3 initialised deferred memory in 216ms</div><div>=
&gt; [ &nbsp; &nbsp;7.411551] kswapd 2 initialised deferred memory in 216ms=
</div><div>&gt;&nbsp;</div><div>&gt; On a 1TB machine, I see</div><div>&gt;=
&nbsp;</div><div>&gt; [ &nbsp; 11.913324] kswapd 0 initialised deferred mem=
ory in 1168ms</div><div>&gt; [ &nbsp; 12.220011] kswapd 2 initialised defer=
red memory in 1476ms</div><div>&gt; [ &nbsp; 12.245369] kswapd 3 initialise=
d deferred memory in 1500ms</div><div>&gt; [ &nbsp; 12.271680] kswapd 1 ini=
tialised deferred memory in 1528ms</div><div>&gt;&nbsp;</div><div>&gt; Once=
 booted the machine appears to work as normal. Boot times were measured</di=
v><div>&gt; from the time shutdown was called until ssh was available again=
. &nbsp;In the</div><div>&gt; 64G case, the boot time savings are negligibl=
e. On the 1TB machine, the</div><div>&gt; savings were 10 seconds (about 8%=
 improvement on kernel times but 1-2%</div><div>&gt; overall as POST takes =
so long).</div><div>&gt;&nbsp;</div><div>&gt; It would be nice if the peopl=
e that have access to really large machines</div><div>&gt; would test this =
series and report back if the complexity is justified.</div><div><br></div>=
<div>Nice work!</div><div><br></div><div>On an older Numascale system with =
1TB memory and 256 cores/32 NUMA nodes, platform init takes 52s (cold boot)=
, firmware takes 84s (includes one warm reboot), stock linux 4.0 then takes=
 732s to boot [1] (due to the 700ns roundtrip, RMW cache-coherent cycles du=
e to the temporal writes for pagetable init and per-core store queue limits=
), so there is huge potential.</div></blockquote><br><div>Same 1TB setup (2=
56 cores, 32 NUMA nodes):</div><div>unpatched 4.0: 789s [1]</div><div>2GB p=
er node up-front: 426s [2]</div><div>4GB node 0 up-front, 0GB later nodes: =
461s [3]</div><div>4GB node 0 up-front, 0.5GB later nodes: 404s [4]</div><d=
iv><br></div><div>Compelling results at only 1TB! In the last case, we see =
PMD setup take 42% (168s) of the time, along with topology_init taking 39% =
(157s). I should be able to get data on a 7TB system this week.</div><div><=
br></div><div>[1] h<a href=3D"https://resources.numascale.com/telemetry/def=
ermem/console-stock.txt" style=3D"color: rgb(0, 136, 204);">ttps://resource=
s.numascale.com/telemetry/defermem/h8qgl-defer-stock.txt</a></div><div>[2] =
h<a href=3D"https://resources.numascale.com/telemetry/defermem/console-stoc=
k.txt" style=3D"color: rgb(0, 136, 204);">ttps://resources.numascale.com/te=
lemetry/defermem/h8qgl-defer-2g.txt</a></div><div>[3] h<a href=3D"https://r=
esources.numascale.com/telemetry/defermem/console-stock.txt" style=3D"color=
: rgb(0, 136, 204);">ttps://resources.numascale.com/telemetry/defermem/h8qg=
l-defer-4+0.txt</a></div><div>[4] h<a href=3D"https://resources.numascale.c=
om/telemetry/defermem/console-stock.txt" style=3D"color: rgb(0, 136, 204);"=
>ttps://resources.numascale.com/telemetry/defermem/h8qgl-defer-</a>4+half.t=
xt</div>=

--=-DejikgOscgqmSaaDBNGh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
