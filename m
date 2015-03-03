Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E42B16B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:08:05 -0500 (EST)
Received: by wiwh11 with SMTP id h11so20944735wiw.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:08:05 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id bo2si307762wjb.74.2015.03.03.01.08.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 01:08:04 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: PMD update corruption (sync question)
Date: Tue, 03 Mar 2015 10:06:48 +0100
Message-ID: <8866266.2EELEveYhm@wuerfel>
In-Reply-To: <54F4E266.8090709@redhat.com>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org> <20150302105011.GD22541@e104818-lin.cambridge.arm.com> <54F4E266.8090709@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Jon Masters <jcm@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, mark.rutland@arm.com, Steve Capper <steve.capper@linaro.org>, peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, hughd@google.com, christoffer.dall@linaro.org, will.deacon@arm.com, linux-mm@kvack.org, mgorman@suse.de, dann.frazier@canonical.com, linux@arm.linux.org.uk, akpm@linux-foundation.org

On Monday 02 March 2015 17:21:26 Jon Masters wrote:
> On 03/02/2015 05:50 AM, Catalin Marinas wrote:
> > On Mon, Mar 02, 2015 at 12:58:36AM -0500, Jon Masters wrote:
> 
> >> Test kernels running with an explicit DSB in all PTE update cases now
> >> running overnight. Just in case.
> 
> ...and stay up after 19 hours. But that's just timing I'm sure.
> 
> > It could be hiding some other problems.
> 
> I checked my GDB macros and they were correct BUT my debugger went out
> to lunch soon after that dump so I suspect it was just garbage 
> 
> Instead, for my immediate issue, I have a much more likely suspect. For
> anyone interested in the followup, you should know that hardware page
> table walkers generally do respond well when you feed them Makefiles:
> 
> 0x43e81c0000: 20230a23 656b614d 656c6966 726f6620  : #.# Makefile for
> 0x43e81c0010: 65687420 462d4920 6563726f 69726420  :  the I-Force dri
> 0x43e81c0020: 0a726576 20230a23 4a207942 6e61686f  : ver.#.# By Johan
> 0x43e81c0030: 6544206e 7875656e 6f6a3c20 6e6e6168  : n Deneux <johann
> 0x43e81c0040: 6e65642e 40787565 69616d67 6f632e6c  : .deneux@gmail.co
> 0x43e81c0050: 230a3e6d 626f0a0a 28242d6a 464e4f43  : m>.#..obj-$(CONF
> 0x43e81c0060: 4a5f4749 5453594f 5f4b4349 524f4649  : IG_JOYSTICK_IFOR
> 0x43e81c0070: 09294543 69203d2b 63726f66 0a6f2e65  : CE).+= iforce.o.
> 0x43e81c0080: 6f66690a 2d656372 3d3a2079 6f666920  : .iforce-y := ifo
> 0x43e81c0090: 2d656372 6f2e6666 6f666920 2d656372  : rce-ff.o iforce-
> 0x43e81c00a0: 6e69616d 69206f2e 63726f66 61702d65  : main.o iforce-pa
> 0x43e81c00b0: 74656b63 0a6f2e73 726f6669 242d6563  : ckets.o.iforce-$
> 0x43e81c00c0: 4e4f4328 5f474946 53594f4a 4b434954  : (CONFIG_JOYSTICK
> 0x43e81c00d0: 4f46495f 5f454352 29323332 203d2b09  : _IFORCE_232).+=
> 0x43e81c00e0: 726f6669 732d6563 6f697265 690a6f2e  : iforce-serio.o.i
> 0x43e81c00f0: 63726f66 28242d65 464e4f43 4a5f4749  : force-$(CONFIG_J
> 0x43e81c0100: 5453594f 5f4b4349 524f4649 555f4543  : OYSTICK_IFORCE_U
> 0x43e81c0110: 09294253 69203d2b 63726f66 73752d65  : SB).+= iforce-us
> 0x43e81c0120: 0a6f2e62 00000000 00000000 00000000  : b.o.............
> 
> So that explains why things were falling over. It is likely indeed the
> bad DMA I have been craving all along. And this time it was so gracious
> as to give me the answer in plain ASCII  I suspect there will be a
> patch for a certain AHCI driver in the not too distant future.

I hope this kind of problem becomes easier to debug once we have
full iommu support working on arm64. When we had problems like this
on PowerPC, using iommu=force to ensure DMA would only be done to
pages that are currently mapped to the device was really helpful.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
