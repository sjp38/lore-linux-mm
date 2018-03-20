Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3336B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:41:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u188so1410862pfb.6
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 11:41:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b9si1748385pff.169.2018.03.20.11.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 11:41:28 -0700 (PDT)
Date: Tue, 20 Mar 2018 11:41:26 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [linux-next:master] BUILD REGRESSION
 a5444cde9dc2120612e50fc5a56c975e67a041fb
Message-ID: <20180320184125.jy4w4cfzgeavwt5p@agluck-desk>
References: <5ab048c0.wmRYTJi5ip8zBzJ4%fengguang.wu@intel.com>
 <d22bd482-2f5b-8c02-4821-9f1b02122b51@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d22bd482-2f5b-8c02-4821-9f1b02122b51@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Mar 19, 2018 at 06:10:13PM -0700, Randy Dunlap wrote:
> On 03/19/2018 04:33 PM, kbuild test robot wrote:
> > tree/branch: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
> > branch HEAD: a5444cde9dc2120612e50fc5a56c975e67a041fb  Add linux-next specific files for 20180319
> > 
> > Regressions in current branch:
> > 
> > ERROR: "__sw_hweight8" [drivers/net/wireless/mediatek/mt76/mt76.ko] undefined!
> 
> Well, the driver could do:
> 
> drivers/net/wireless/mediatek/mt76/Kconfig:
> 
> +	select GENERIC_HWEIGHT
> 
> but maybe arch/ix64/Kconfig (where the build error is) could be asked to do:
> 
> config GENERIC_HWEIGHT
> 	def_bool y
> 
> like 23 other $arch-es do.  Aha, ia64 provides inline functions via some
> a twisty maze of header files.
> 
> Tony, Fengguang, what header(s) should be used to reach __arch_hweight8()?

Looks like a few architectures have their own __arch_hweight8
(alpha, blackfin, ia64, mips, powerpc, sparc, tile and x86)

everyone except x86 puts them in <asm/bitops.h> ... x86 has a
<asm/arch_hweight.h>

Likely that the best solution would be to match how x86 does
this and move the hweight defines out of bitops.h.  But it all
seems very messy :-(

-Tony
