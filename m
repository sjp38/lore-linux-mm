Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F82F8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 14:34:25 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id s140so6804244oih.4
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:34:25 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n63si4692402oih.141.2018.12.10.11.34.24
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 11:34:24 -0800 (PST)
Date: Mon, 10 Dec 2018 19:34:46 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V5 0/7] 52-bit userspace VAs
Message-ID: <20181210193445.GB8923@edgewater-inn.cambridge.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206225042.11548-1-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, jcm@redhat.com

On Thu, Dec 06, 2018 at 10:50:35PM +0000, Steve Capper wrote:
> This patch series brings support for 52-bit userspace VAs to systems that
> have ARMv8.2-LVA and are running with a 48-bit VA_BITS and a 64KB
> PAGE_SIZE.
> 
> If no hardware support is present, the kernel runs with a 48-bit VA space
> for userspace.
> 
> Userspace can exploit this feature by providing an address hint to mmap
> where addr[51:48] != 0. Otherwise all the VA mappings will behave in the
> same way as a 48-bit VA system (this is to maintain compatibility with
> software that assumes the maximum VA size on arm64 is 48-bit).
> 
> This patch series applies to 4.20-rc1.
> 
> Testing was in a model with Trusted Firmware and UEFI for boot.
> 
> Changed in V5, ttbr1 offsetting code simplified. Extra patch added to
> check for VA space support mismatch between CPUs.

I was all ready to push this out, but I spotted a build failure with
allmodconfig because TASK_SIZE refers to the non-EXPORTed symbol
vabits_user:

ERROR: "vabits_user" [lib/test_user_copy.ko] undefined!
ERROR: "vabits_user" [drivers/misc/lkdtm/lkdtm.ko] undefined!
ERROR: "vabits_user" [drivers/infiniband/hw/mlx5/mlx5_ib.ko] undefined!

So I've pushed an extra patch on top to fix that by exporting the symbol.

Will
