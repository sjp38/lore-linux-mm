Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5E11E6B0032
	for <linux-mm@kvack.org>; Sat,  3 Jan 2015 11:00:00 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so16171986lab.40
        for <linux-mm@kvack.org>; Sat, 03 Jan 2015 07:59:59 -0800 (PST)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id js7si55390126lbc.58.2015.01.03.07.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 03 Jan 2015 07:59:59 -0800 (PST)
Received: by mail-la0-f46.google.com with SMTP id q1so16871022lam.33
        for <linux-mm@kvack.org>; Sat, 03 Jan 2015 07:59:58 -0800 (PST)
Date: Sat, 3 Jan 2015 18:59:46 +0300
From: Sergey Dyasly <dserrg@gmail.com>
Subject: Re: [RFC][PATCH RESEND] mm: vmalloc: remove ioremap align
 constraint
Message-Id: <20150103185946.1d4fad32bb3de9ac9bdcfb88@gmail.com>
In-Reply-To: <11656044.WGcPr1b8t8@wuerfel>
References: <1419328813-2211-1-git-send-email-d.safonov@partner.samsung.com>
	<11656044.WGcPr1b8t8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Dmitry Safonov <d.safonov@partner.samsung.com>, linux-mm@kvack.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Russell King <linux@arm.linux.org.uk>, Dyasly Sergey <s.dyasly@samsung.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, James Bottomley <JBottomley@parallels.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

Hi Arnd,

First, some background information. We originally encountered high fragmentation
issue in vmalloc area:

	1. Total size of vmalloc area was 400 MB.
	2. 200 MB of vmalloc area was consumed by ioremaps of various sizes.
	3. Largest contiguous chunk of vmalloc area was 12 MB.
	4. ioremap of 10 MB failed due to 8 MB alignment requirement.

It was decided to further increase the size of vmalloc area to resolve the above
issue. And I don't like that solution because it decreases the amount of lowmem.

Now let's see how ioremap uses supersections. Judging from current implementation
of __arm_ioremap_pfn_caller:

	#if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
		if (pfn >= 0x100000 && !((paddr | size | addr) & ~SUPERSECTION_MASK)) {
			remap_area_supersections();
		} else if (!((paddr | size | addr) & ~PMD_MASK)) {
			remap_area_sections();
		} else
	#endif
			err = ioremap_page_range();

supersections and sections mappings are used only in !SMP && !LPAE case.
Otherwise, mapping is created using the usual 4K pages (and we are using SMP).
The suggested patch removes alignment requirements for ioremap but it means that
sections will not be used in !SMP case. So another solution is required.

__get_vm_area_node has align parameter, maybe it can be used to specify the
required alignment of ioremap operation? Because I find current generic fls
algorithm to be very restrictive in cases when it's not necessary to use such
a big alignment.


On Tue, 23 Dec 2014 21:58:49 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 23 December 2014 13:00:13 Dmitry Safonov wrote:
> > ioremap uses __get_vm_area_node which sets alignment to fls of requested size.
> > I couldn't find any reason for such big align. Does it decrease TLB misses?
> > I tested it on custom ARM board with 200+ Mb of ioremap and it works.
> > What am I missing?
> 
> The alignment was originally introduced in this commit:
> 
> commit ff0daca525dde796382b9ccd563f169df2571211
> Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
> Date:   Thu Jun 29 20:17:15 2006 +0100
> 
>     [ARM] Add section support to ioremap
>     
>     Allow section mappings to be setup using ioremap() and torn down
>     with iounmap().  This requires additional support in the MM
>     context switch to ensure that mappings are properly synchronised
>     when mapped in.
>     
>     Based an original implementation by Deepak Saxena, reworked and
>     ARMv6 support added by rmk.
>     
>     Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> and then later extended to 16MB supersection mappings, which indeed
> is used to reduce TLB pressure.
> 
> I don't see any downsides to it, why change it?
> 
> 	Arnd

-- 
Sergey Dyasly <dserrg@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
