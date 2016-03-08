Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BFB436B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:49:59 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 129so11416782pfw.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:49:59 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id kv15si4300015pab.137.2016.03.08.03.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 03:49:58 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id fy10so11215940pac.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:49:58 -0800 (PST)
Date: Tue, 8 Mar 2016 03:49:55 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <1457319627.19197.1.camel@ellerman.id.au>
Message-ID: <alpine.LSU.2.11.1603080239340.7589@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <877fhttmr1.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1602242136270.6876@eggly.anvils> <alpine.LSU.2.11.1602251322130.8063@eggly.anvils> <alpine.LSU.2.11.1602260157430.10399@eggly.anvils>
 <alpine.LSU.2.11.1603021226300.31251@eggly.anvils> <1456984266.28236.1.camel@ellerman.id.au> <alpine.LSU.2.11.1603040948250.5477@eggly.anvils> <1457319627.19197.1.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 7 Mar 2016, Michael Ellerman wrote:
> On Fri, 2016-03-04 at 09:58 -0800, Hugh Dickins wrote:
> > 
> > The alternative bisection was as unsatisfactory as the first:
> > again it fingered an irrelevant merge (rather than any commit
> > pulled in by that merge) as the bad commit.
> > 
> > It seems this issue is too intermittent for bisection to be useful,
> > on my load anyway.
> 
> Darn. Thanks for trying.
> 
> > The best I can do now is try v4.4 for a couple of days, to verify that
> > still comes out good (rather than the machine going bad coincident with
> > v4.5-rc), then try v4.5-rc7 to verify that that still comes out bad.
> 
> Thanks, that would still be helpful.

v4.4 ran under load for 56 hours without any trouble, before I stopped
it to switch kernels.  v4.5-rc7 ran for 19.5 hours, then hit the problem
(sigsegv in "as" on this occasion).

> 
> > I'll report back on those; but beyond that, I'll have to leave it to you.
> 
> I haven't had any luck here :/
> 
> Can you give us a more verbose description of your test setup?

I'll be a lot more terse than you'd like, not much time to spare.
If I had a good reproducer, then of course I should specify it exactly
to you; but no, 19.5 hours or 5 hours or a few minutes, that does not
amount to a good reproducer.

> 
>  - G5, which exact model?

/proc/cpuinfo says:

processor	: 0
cpu		: PPC970MP, altivec supported
clock		: 2500.000000MHz
revision	: 1.1 (pvr 0044 0101)

processor	: 1
cpu		: PPC970MP, altivec supported
clock		: 2500.000000MHz
revision	: 1.1 (pvr 0044 0101)

processor	: 2
cpu		: PPC970MP, altivec supported
clock		: 2500.000000MHz
revision	: 1.1 (pvr 0044 0101)

processor	: 3
cpu		: PPC970MP, altivec supported
clock		: 2500.000000MHz
revision	: 1.1 (pvr 0044 0101)

timebase	: 33333333
platform	: PowerMac
model		: PowerMac11,2
machine		: PowerMac11,2
motherboard	: PowerMac11,2 MacRISC4 Power Macintosh 
detected as	: 337 (PowerMac G5 Dual Core)
pmac flags	: 00000000
L2 cache	: 1024K unified
pmac-generation	: NewWorld

>  - 4k pages, no THP.

Yes.

>  - how much ram & swap?

I boot with mem=700M, and use 1.5G swap.

>  - building linus' tree, make -j ?

Building an old 2.6.24 tree (which had a higher source to built ratio
than nowadays; with patches to get it to build with more recent toolchain,
from openSUSE 13.1); building some config I used to run on that machine.

Building two of them, each make -j20, concurrently: one in tmpfs,
one in 4kB-blocksize ext4 on loop on tmpfs file.  But I doubt that
complication is relevant here: sometimes it's the build in tmpfs
that collapses, sometimes the build in ext4, it's fairly even which.

(Do not bother to attempt such a load on linux-next, only on v4.5:
the OOM rework in mmotm has an unsolved problem with order=2 allocations,
which means that such a load will be OOM-killed very quickly.)

>  - source and output on tmpfs? (how big?)

One source and output in ext4 on loop on file filling 470M tmpfs.
Other source and output in tmpfs on /tmp which I happen to size at 1300M
(but could be half that).  Sizes of course fitted to that source tree
and config I happen to be building.

>  - what device is the swap device? (you said SSD I think?)

Old 75G Intel SSD:
ata2.00: ATA-7: INTEL SSDSA2M080G2GN, 2CV102HD, max UDMA/133

>  - anything else I've forgotten?

I happen to run with /proc/sys/vm/swappiness 100,
merely because it's swapping that I'm trying to exercise.

I doubt that any of the details above are important: plenty of
swapping is probably the only message (and doing everything in
tmpfs in limited memory is a good way to force plenty of swapping).

> 
> Oh and can you send us your bisect logs, we can at least trust the bad results
> I think.

Remember that both of these bisections started from 4.5-rc1 as bad,
and f689b742f217, the powerpc merge, as good - since I didn't see a
problem at that commit in 12 hours.  But we all suspect that in fact
something in that powerpc merge was actually the bad.

git bisect start
# good: [f689b742f217b2ffe7925f8a6521b208ee995309] Merge tag 'powerpc-4.5-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect good f689b742f217b2ffe7925f8a6521b208ee995309
# bad: [92e963f50fc74041b5e9e744c330dca48e04f08d] Linux 4.5-rc1
git bisect bad 92e963f50fc74041b5e9e744c330dca48e04f08d
# bad: [7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide
git bisect bad 7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015
# bad: [6606b342febfd470b4a33acb73e360eeaca1d9bb] Merge git://www.linux-watchdog.org/linux-watchdog
git bisect bad 6606b342febfd470b4a33acb73e360eeaca1d9bb
# good: [d0021d3bdfe9d551859bca1f58da0e6be8e26043] Merge remote-tracking branch 'asoc/topic/wm8960' into asoc-next
git bisect good d0021d3bdfe9d551859bca1f58da0e6be8e26043
# good: [e3315b439c30c208582ac64e58f0c0d36b83181e] ALSA: oxfw: allocate own address region for SCS.1 series
git bisect good e3315b439c30c208582ac64e58f0c0d36b83181e
# good: [3da834e3e5a4a5d26882955298b55a9ed37a00bc] clk: remove duplicated COMMON_CLK_NXP record from clk/Kconfig
git bisect good 3da834e3e5a4a5d26882955298b55a9ed37a00bc
# bad: [e535d74bc50df2357d3253f8f3ca48c66d0d892a] Merge tag 'docs-4.5' of git://git.lwn.net/linux
git bisect bad e535d74bc50df2357d3253f8f3ca48c66d0d892a
# bad: [4e5448a31d73d0e944b7adb9049438a09bc332cb] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 4e5448a31d73d0e944b7adb9049438a09bc332cb
# good: [b70ce2ab41cb67ab3d661eda078f7c4029bbca95] dts: hisi: fixes no syscon fault when init mdio
git bisect good b70ce2ab41cb67ab3d661eda078f7c4029bbca95
# good: [4a658527271bce43afb1cf4feec89afe6716ca59] xen-netback: delete NAPI instance when queue fails to initialize
git bisect good 4a658527271bce43afb1cf4feec89afe6716ca59
# good: [c6894dec8ea9ae05747124dce98b3b5c2e69b168] bridge: fix lockdep addr_list_lock false positive splat
git bisect good c6894dec8ea9ae05747124dce98b3b5c2e69b168
# good: [36beca6571c941b28b0798667608239731f9bc3a] sparc64: Fix numa node distance initialization
git bisect good 36beca6571c941b28b0798667608239731f9bc3a
# good: [750afbf8ee9c6a1c74a1fe5fc9852146b1d72687] bgmac: Fix reversed test of build_skb() return value.
git bisect good 750afbf8ee9c6a1c74a1fe5fc9852146b1d72687
# good: [5a18d263f8d27418c98b8e8551dadfe975c054e3] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
git bisect good 5a18d263f8d27418c98b8e8551dadfe975c054e3
# first bad commit: [4e5448a31d73d0e944b7adb9049438a09bc332cb] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

And then I replayed, taking the davem/net merge as good instead,
on the basis that it had taken longer than usual to hit the issue:

git bisect start
# good: [f689b742f217b2ffe7925f8a6521b208ee995309] Merge tag 'powerpc-4.5-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect good f689b742f217b2ffe7925f8a6521b208ee995309
# bad: [92e963f50fc74041b5e9e744c330dca48e04f08d] Linux 4.5-rc1
git bisect bad 92e963f50fc74041b5e9e744c330dca48e04f08d
# bad: [7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide
git bisect bad 7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015
# bad: [6606b342febfd470b4a33acb73e360eeaca1d9bb] Merge git://www.linux-watchdog.org/linux-watchdog
git bisect bad 6606b342febfd470b4a33acb73e360eeaca1d9bb
# good: [d0021d3bdfe9d551859bca1f58da0e6be8e26043] Merge remote-tracking branch 'asoc/topic/wm8960' into asoc-next
git bisect good d0021d3bdfe9d551859bca1f58da0e6be8e26043
# good: [e3315b439c30c208582ac64e58f0c0d36b83181e] ALSA: oxfw: allocate own address region for SCS.1 series
git bisect good e3315b439c30c208582ac64e58f0c0d36b83181e
# good: [3da834e3e5a4a5d26882955298b55a9ed37a00bc] clk: remove duplicated COMMON_CLK_NXP record from clk/Kconfig
git bisect good 3da834e3e5a4a5d26882955298b55a9ed37a00bc
# bad: [e535d74bc50df2357d3253f8f3ca48c66d0d892a] Merge tag 'docs-4.5' of git://git.lwn.net/linux
git bisect bad e535d74bc50df2357d3253f8f3ca48c66d0d892a
# good: [4e5448a31d73d0e944b7adb9049438a09bc332cb] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good 4e5448a31d73d0e944b7adb9049438a09bc332cb
# good: [aa13a960fc1bd28cfd8b3aef43e523ade1817a2c] Documentation: cpu-hotplug: Fix sysfs mount instructions
git bisect good aa13a960fc1bd28cfd8b3aef43e523ade1817a2c
# good: [afd8c08446d6503adc1ccd2726a8e27f35d95b79] Documentation: Explain pci=conf1,conf2 more verbosely
git bisect good afd8c08446d6503adc1ccd2726a8e27f35d95b79
# good: [e5b6c1518878e157df4121c1caf70d9c470a6d31] firmware: dmi_scan: Save SMBIOS Type 9 System Slots
git bisect good e5b6c1518878e157df4121c1caf70d9c470a6d31
# good: [ec3fc58b1e7a32cc9f552b306f8dbb4454e83798] thermal: add description for integral_cutoff unit
git bisect good ec3fc58b1e7a32cc9f552b306f8dbb4454e83798
# bad: [ece6267878aed4eadff766112f1079984315d8c8] Merge tag 'clk-for-linus-4.5' of git://git.kernel.org/pub/scm/linux/kernel/git/clk/linux
git bisect bad ece6267878aed4eadff766112f1079984315d8c8
# bad: [d45187aaf0e256d23da2f7694a7826524499aa31] Merge branch 'dmi-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jdelvare/staging
git bisect bad d45187aaf0e256d23da2f7694a7826524499aa31
# first bad commit: [d45187aaf0e256d23da2f7694a7826524499aa31] Merge branch 'dmi-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jdelvare/staging

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
