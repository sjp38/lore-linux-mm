Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 417546B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 09:22:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 65so8010934wrn.7
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 06:22:39 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id x77si3982618wrb.209.2018.03.18.06.22.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Mar 2018 06:22:37 -0700 (PDT)
Date: Sun, 18 Mar 2018 13:21:27 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 1/7] 2 1-byte checks more safer for memory_is_poisoned_16
Message-ID: <20180318132126.GA565@n2100.armlinux.org.uk>
References: <20180318125342.4278-1-liuwenliang@huawei.com>
 <20180318125342.4278-2-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180318125342.4278-2-liuwenliang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: aryabinin@virtuozzo.com, marc.zyngier@arm.com, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, akpm@linux-foundation.org, afzal.mohd.ma@gmail.com, alexander.levin@verizon.com, glider@google.com, dvyukov@google.com, christoffer.dall@linaro.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

On Sun, Mar 18, 2018 at 08:53:36PM +0800, Abbott Liu wrote:
> Because in some architecture(eg. arm) instruction set, non-aligned
> access support is not very well, so 2 1-byte checks is more
> safer than 1 2-byte check. The impact on performance is small
> because 16-byte accesses are not too common.

This is unnecessary:

1. a load of a 16-bit quantity will work as desired on modern ARMs.
2. Networking already relies on unaligned loads to work as per x86
   (iow, an unaligned 32-bit load loads the 32-bits at the address
   even if it's not naturally aligned, and that also goes for 16-bit
   accesses.)

If these are rare (which you say above - "not too common") then it's
much better to leave the code as-is, because it will most likely be
faster on modern CPUs, and the impact for older generation CPUs is
likely to be low.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
