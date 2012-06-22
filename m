Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id CAF3F6B013F
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 23:59:29 -0400 (EDT)
Received: by wibhr4 with SMTP id hr4so168806wib.8
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:59:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwBc=OxwU=qNYQs0rg4dPGBQObqg-EGnDDS-TWWpy0G2A@mail.gmail.com>
References: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
 <20120621164606.4ae1a71d.akpm@linux-foundation.org> <CA+55aFzPXMD3N3Oy-om6utDCQYmrBDnDgdqpVC5cgKe-v6uZ3w@mail.gmail.com>
 <20120621184536.6dd97746.akpm@linux-foundation.org> <CA+55aFwBc=OxwU=qNYQs0rg4dPGBQObqg-EGnDDS-TWWpy0G2A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Jun 2012 20:59:07 -0700
Message-ID: <CA+55aFydstt7+oBy+ABVdkwUmiwDp-3qyAFmZbzi=PYTVyOXLw@mail.gmail.com>
Subject: Re: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous migration
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>

On Thu, Jun 21, 2012 at 8:33 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'll see what it looks like if I only warn about casting *to* an enum.

Hmm. That results in much fewer warnings. Not that I'm sure that my
sparse hack is right. But for my normal build (which is pretty
minimal), I get:

    drivers/ata/libahci.c:1786:16: warning: casting to an enum type
    drivers/ata/libata-sff.c:1662:16: warning: casting to an enum type
    drivers/gpu/drm/i915/i915_irq.c:2300:16: warning: casting to an enum type
    drivers/gpu/drm/i915/i915_irq.c:2544:16: warning: casting to an enum type
    drivers/gpu/drm/i915/i915_irq.c:740:16: warning: casting to an enum type
    drivers/gpu/drm/i915/intel_panel.c:319:50: warning: casting to an enum type
    drivers/input/mouse/lifebook.c:148:59: warning: casting to an enum type
    drivers/input/mouse/lifebook.c:153:80: warning: casting to an enum type
    drivers/input/mouse/lifebook.c:156:59: warning: casting to an enum type
    drivers/input/mouse/lifebook.c:159:73: warning: casting to an enum type
    drivers/input/mouse/synaptics.c:1129:86: warning: casting to an enum type
    drivers/input/serio/i8042.c:533:16: warning: casting to an enum type
    drivers/input/serio/i8042.c:693:16: warning: casting to an enum type
    drivers/net/ethernet/realtek/r8169.c:5860:16: warning: casting to
an enum type
    drivers/pci/probe.c:511:26: warning: casting to an enum type
    drivers/tty/serial/8250/8250.c:1556:16: warning: casting to an enum type
    drivers/usb/host/xhci-ring.c:2419:24: warning: casting to an enum type
    fs/sysfs/sysfs.h:114:51: warning: casting to an enum type
    include/linux/mm.h:660:47: warning: casting to an enum type
    kernel/sched/rt.c:32:21: warning: casting to an enum type
    kernel/time/alarmtimer.c:231:16: warning: casting to an enum type
    kernel/time/alarmtimer.c:439:16: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1035:13: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1041:13: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1044:5: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1045:30: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1138:21: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1140:5: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1141:30: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1233:25: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1262:5: warning: casting to an enum type
    lib/zlib_deflate/deflate.c:1263:30: warning: casting to an enum type
    net/ipv4/ipmr.c:449:24: warning: casting to an enum type
    net/ipv4/netfilter/nf_defrag_ipv4.c:58:47: warning: casting to an enum type
    net/ipv4/netfilter/nf_defrag_ipv4.c:60:48: warning: casting to an enum type
    net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:49:48: warning: casting
to an enum type
    net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:51:49: warning: casting
to an enum type
    sound/pci/intel8x0.c:821:24: warning: casting to an enum type

but the ones I looked at were all ok. Admittedly I only looked at a
few (maybe five), though.

That said, the drivers/pci/probe.c case is actually ugly code. That
"agp_speeds[]" array *could* be an array of the proper enum's, rather
than "unsigned char". I don't know why it isn't (but 'unsigned char'
may be more efficient than a compiler that might make it an 'int').

So the warning *may* be useful. However, to get sparse to give that
warning I had to do some hacks that broke other parts of sparse, so I
don't have a good sparse patch yet. I'll look at it some more
tomorrow.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
