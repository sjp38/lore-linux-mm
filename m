Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id BDD0A6B00A9
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:05:46 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id x48so11132659wes.24
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:05:46 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id oq8si23843105wjc.167.2014.03.12.07.05.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 07:05:44 -0700 (PDT)
Date: Wed, 12 Mar 2014 14:05:22 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
Message-ID: <20140312140522.GI21483@n2100.arm.linux.org.uk>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org> <20140312085401.GB21483@n2100.arm.linux.org.uk> <53205CA1.1090502@ti.com> <20140312133806.GH21483@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140312133806.GH21483@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Lunn <andrew@lunn.ch>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Daniel Walker <dwalker@fifo99.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, David Brown <davidb@codeaurora.org>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Laura Abbott <lauraa@codeaurora.org>, Jason Cooper <jason@lakedaemon.net>, linux-arm-msm@vger.kernel.org, Haojian Zhuang <haojian.zhuang@gmail.com>, Leif Lindholm <leif.lindholm@linaro.org>, Ben Dooks <ben-linux@fluff.org>, linux-arm-kernel@lists.infradead.org, Courtney Cavin <courtney.cavin@sonymobile.com>, Eric Miao <eric.y.miao@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 12, 2014 at 01:38:06PM +0000, Russell King - ARM Linux wrote:
> Try booting a machine with 2G of RAM with page offset set to 3GB and
> highmem enabled - it will fail as per the above.

BTW, simple way to test this on any ARM platform:

Build with PAGE_OFFSET=3GB and highmem enabled.  Pass vmalloc=1G on the
kernel command line to force maximal vmalloc region (which should push
lowmem down to the minimum of 32MB.)  The remainder will be highmem.

Now, with Laura's patch applied, some platforms do boot but the result
is rather odd:

vmalloc area is too big, limiting to 976MB

So, the vmalloc=1G has done the right thing here, but:

Memory: 507404K/523264K available (3839K kernel code, 230K rwdata, 1388K rodata, 211K init, 5266K bss, 15860K reserved, 0K highmem)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
    vmalloc : 0xe0800000 - 0xff000000   ( 488 MB)
    lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
    pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
    modules : 0xbf000000 - 0xbfe00000   (  14 MB)
      .text : 0xc0008000 - 0xc0522f34   (5228 kB)
      .init : 0xc0523000 - 0xc0557fc0   ( 212 kB)
      .data : 0xc0558000 - 0xc0591980   ( 231 kB)
       .bss : 0xc0591988 - 0xc0ab6220   (5267 kB)

something has overriden it, and we end up with no highmem.  Without
Laura's patch, it all behaves correctly:

vmalloc area is too big, limiting to 976MB
...
Memory: 507932K/523264K available (3839K kernel code, 230K rwdata, 1388K rodata, 211K init, 5266K bss, 15332K reserved, 490496K highmem)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
    vmalloc : 0xc2800000 - 0xff000000   ( 968 MB)
    lowmem  : 0xc0000000 - 0xc2000000   (  32 MB)
    pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
    modules : 0xbf000000 - 0xbfe00000   (  14 MB)
      .text : 0xc0008000 - 0xc0522f34   (5228 kB)
      .init : 0xc0523000 - 0xc0557fc0   ( 212 kB)
      .data : 0xc0558000 - 0xc0591980   ( 231 kB)
       .bss : 0xc0591988 - 0xc0ab6260   (5267 kB)

So... the more I look at the boot results from last night's autobuild,
the more stuff appears to be broken with this meminfo removal.

Therefore, I have to wonder what kind of testing was done with these
patches - I suspect the test consisted of "does it boot" without looking
at any of the details about what memory was where.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
