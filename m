Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C874E6B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 05:39:45 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u70-v6so1112452wrc.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 02:39:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5-v6sor6626841wmb.17.2018.10.02.02.39.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 02:39:44 -0700 (PDT)
Date: Tue, 2 Oct 2018 11:39:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 1/3] Revert "x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved"
Message-ID: <20181002093940.GA98058@gmail.com>
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
 <20180925153532.6206-2-msys.mizuma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925153532.6206-2-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, x86@kernel.org


* Masayoshi Mizuma <msys.mizuma@gmail.com> wrote:

> From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> 
> commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
> memblock.reserved") breaks movable_node kernel option because it
> changed the memory gap range to reserved memblock. So, the node
> is marked as Normal zone even if the SRAT has Hot plaggable affinity.
> 
>     =====================================================================
>     kernel: BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usable
>     kernel: BIOS-e820: [mem 0x00001c0000000000-0x00001c0fffffffff] usable
>     ...
>     kernel: reserved[0x12]#011[0x0000181000000000-0x00001bffffffffff], 0x000003f000000000 bytes flags: 0x0
>     ...
>     kernel: ACPI: SRAT: Node 2 PXM 6 [mem 0x180000000000-0x1bffffffffff] hotplug
>     kernel: ACPI: SRAT: Node 3 PXM 7 [mem 0x1c0000000000-0x1fffffffffff] hotplug
>     ...
>     kernel: Movable zone start for each node
>     kernel:  Node 3: 0x00001c0000000000
>     kernel: Early memory node ranges
>     ...
>     =====================================================================
> 
> Naoya's v1 patch [*] fixes the original issue and this movable_node
> issue doesn't occur.
> Let's revert commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM
> regions into memblock.reserved") and apply the v1 patch.
> 
> [*] https://lkml.org/lkml/2018/6/13/27
> 
> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> ---
>  arch/x86/kernel/e820.c | 15 +++------------
>  1 file changed, 3 insertions(+), 12 deletions(-)

Bad ordering which introduces the bug and thus breaks bisection of related issues: the fixes 
should come first, then the revert of the unnecessary or bad fix.

Thanks,

	Ingo
