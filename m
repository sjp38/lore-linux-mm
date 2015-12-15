Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE7A6B025D
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:21:09 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l126so6246962wml.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:21:09 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id fq10si3557401wjc.228.2015.12.15.10.21.07
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 10:21:08 -0800 (PST)
Date: Tue, 15 Dec 2015 19:21:00 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151215182059.GH25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <20151215131135.GE25973@pd.tnic>
 <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Dec 15, 2015 at 05:53:31PM +0000, Luck, Tony wrote:
> My current generation cpu has a bit of an issue with recovering from a
> machine check in a "rep mov" ... so I'm working with a version of memcpy
> that unrolls into individual mov instructions for now.

Ah.

> I can drop the "nti" from the destination moves.  Does "nti" work
> on the load from source address side to avoid cache allocation?

I don't think so:

+1:     movq (%rsi),%r8
+2:     movq 1*8(%rsi),%r9
+3:     movq 2*8(%rsi),%r10
+4:     movq 3*8(%rsi),%r11
...

You need to load the data into registers first because MOVNTI needs them
there as it does reg -> mem movement. That first load from memory into
registers with a normal MOV will pull the data into the cache.

Perhaps the first thing to try would be to see what slowdown normal MOVs
bring and if not really noticeable, use those instead.

> On another topic raised by Boris ... is there some CONFIG_PMEM*
> that I should use as a dependency to enable all this?

I found CONFIG_LIBNVDIMM only today:

drivers/nvdimm/Kconfig:1:menuconfig LIBNVDIMM
drivers/nvdimm/Kconfig:2:       tristate "NVDIMM (Non-Volatile Memory Device) Support"

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
