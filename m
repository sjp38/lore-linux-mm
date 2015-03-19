Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id D83C76B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 20:21:39 -0400 (EDT)
Received: by lagg8 with SMTP id g8so49705022lag.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:21:39 -0700 (PDT)
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com. [209.85.215.43])
        by mx.google.com with ESMTPS id r4si14008832lar.124.2015.03.18.17.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 17:21:37 -0700 (PDT)
Received: by ladw1 with SMTP id w1so49660702lad.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:21:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426291715-16242-1-git-send-email-lauraa@codeaurora.org>
References: <1426291715-16242-1-git-send-email-lauraa@codeaurora.org>
Date: Wed, 18 Mar 2015 17:21:36 -0700
Message-ID: <CAJAp7OhebH088EjXxo0tG__p8m11FiNw8qqG6k8eAky6cg2P8g@mail.gmail.com>
Subject: Re: [PATCHv3] mm: Don't offset memmap for flatmem
From: Bjorn Andersson <bjorn@kryo.se>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Kumar Gala <galak@codeaurora.org>

On Fri, Mar 13, 2015 at 5:08 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
> Srinivas Kandagatla reported bad page messages when trying to
> remove the bottom 2MB on an ARM based IFC6410 board
>
> BUG: Bad page state in process swapper  pfn:fffa8
> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> bad because of flags:
> flags: 0x200041(locked|active|mlocked)
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
> Hardware name: Qualcomm (Flattened Device Tree)
> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
> Disabling lock debugging due to kernel taint
>
> Removing the lower 2MB made the start of the lowmem zone to no longer
> be page block aligned. IFC6410 uses CONFIG_FLATMEM where
> alloc_node_mem_map allocates memory for the mem_map. alloc_node_mem_map
> will offset for unaligned nodes with the assumption the pfn/page
> translation functions will account for the offset. The functions for
> CONFIG_FLATMEM do not offset however, resulting in overrunning
> the memmap array. Just use the allocated memmap without any offset
> when running with CONFIG_FLATMEM to avoid the overrun.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> Reported-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
> ---

With this I can boot 8960 and 8064 without patching up the MEM ATAGs
from the bootloader (as well as "reserving" smem).

Tested-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>

Thanks,
Bjorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
