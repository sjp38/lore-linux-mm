Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 522DF6B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 20:09:29 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so1983913qcq.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 17:09:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9SpFLzGjXgCgRORo61_XXk9tUiNVpES8ux5aHUc33J80Q@mail.gmail.com>
References: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
	<20121102225341.GC2070@barrios>
	<CAA25o9SXNHFgQmVMNmGNwPDCRpRTsRDW8oRvnLyofGrVo6bnNQ@mail.gmail.com>
	<CAA25o9SpFLzGjXgCgRORo61_XXk9tUiNVpES8ux5aHUc33J80Q@mail.gmail.com>
Date: Fri, 2 Nov 2012 17:09:28 -0700
Message-ID: <CAA25o9T1uuE020t2k56gYb30zYZiceFa9rQjA1DTObLQsTUoBQ@mail.gmail.com>
Subject: Re: zram on ARM
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

I forgot to say, I also applied David's patch that prevents the
deadlock I was seeing earlier on x86.

On Fri, Nov 2, 2012 at 5:04 PM, Luigi Semenzato <semenzato@google.com> wrote:
> I have better results now from using zram on ARM.
>
> For those who followed my previous thread (zram OOM behavior), this is
> a different problem, not connected with OOM.  (At least i don't think
> so.)
>
> I am running a large instance of the Chrome browser on an ARM platform
> with 2 GB of RAM.  I create a zram swap device with 3 GB.  On x86, we
> have measured a compression ratio of about 3:1, so this leaves roughly
> half the RAM for compressed swap use.
>
> I am running kernel 3.4 on these platforms.  To be able to run on ARM,
> I applied a recent patch which removes the x86 dependency from
> zsmalloc.
>
> This identical setup works fine on x86.
>
> On ARM, the system starts swapping to RAM (at about 20MB/second), but
> when it still has between 1 to 2 GB of swap space available (zram
> device about 1/2 full), it stops swapping (si = so = 0 from "vmstat
> 1"), and most processes stop responding.  As in my previous situation,
> some processes keep running, and they appear to be those that don't
> try to allocate memory.
>
> I can rely on SysRQ and preserved memory in this situation, but the
> buffer size is 128k and not large enough for a full dump of all
> stacks.  I am attaching the (truncated) log for this case.
>
> Many processes are waiting for memory on a page fault, for instance these:
>
> [  273.434964] chrome          R running      0  4279   1175 0x00200000
> [  273.441393] [<804e98d4>] (__schedule+0x66c/0x738) from [<804e9d2c>]
> (schedule+0x8c/0x90)
> [  273.449551] [<804e9d2c>] (schedule+0x8c/0x90) from [<804e7ef0>]
> (schedule_timeout+0x278/0x2d4)
> [  273.458232] [<804e7ef0>] (schedule_timeout+0x278/0x2d4) from
> [<804e7f7c>] (schedule_timeout_uninterruptible+0x30/0x34)
> [  273.468995] [<804e7f7c>]
> (schedule_timeout_uninterruptible+0x30/0x34) from [<800bb898>]
> (__alloc_pages_nodemask+0x5d4/0x7a8)
> [  273.480280] [<800bb898>] (__alloc_pages_nodemask+0x5d4/0x7a8) from
> [<800e2fe0>] (read_swap_cache_async+0x54/0x11c)
> [  273.490695] [<800e2fe0>] (read_swap_cache_async+0x54/0x11c) from
> [<800e310c>] (swapin_readahead+0x64/0x9c)
> [  273.500418] [<800e310c>] (swapin_readahead+0x64/0x9c) from
> [<800d5acc>] (handle_pte_fault+0x2d8/0x668)
> [  273.509791] [<800d5acc>] (handle_pte_fault+0x2d8/0x668) from
> [<800d5f20>] (handle_mm_fault+0xc4/0xdc)
> [  273.519079] [<800d5f20>] (handle_mm_fault+0xc4/0xdc) from
> [<8001b080>] (do_page_fault+0x114/0x354)
> [  273.528105] [<8001b080>] (do_page_fault+0x114/0x354) from
> [<800083d8>] (do_DataAbort+0x44/0xa8)
> [  273.536871] [<800083d8>] (do_DataAbort+0x44/0xa8) from [<8000dc78>]
> (__dabt_usr+0x38/0x40)
>
> [  270.435243] Chrome_ChildIOT R running      0  3166   1175 0x00200000
> [  270.441673] [<804e98d4>] (__schedule+0x66c/0x738) from [<8005696c>]
> (__cond_resched+0x30/0x40)
> [  270.450352] [<8005696c>] (__cond_resched+0x30/0x40) from
> [<804e9a44>] (_cond_resched+0x40/0x50)
> [  270.459118] [<804e9a44>] (_cond_resched+0x40/0x50) from
> [<800bb798>] (__alloc_pages_nodemask+0x4d4/0x7a8)
> [  270.468755] [<800bb798>] (__alloc_pages_nodemask+0x4d4/0x7a8) from
> [<800e2fe0>] (read_swap_cache_async+0x54/0x11c)
> [  270.479170] [<800e2fe0>] (read_swap_cache_async+0x54/0x11c) from
> [<800e310c>] (swapin_readahead+0x64/0x9c)
> [  270.488892] [<800e310c>] (swapin_readahead+0x64/0x9c) from
> [<800d5acc>] (handle_pte_fault+0x2d8/0x668)
> [  270.498265] [<800d5acc>] (handle_pte_fault+0x2d8/0x668) from
> [<800d5f20>] (handle_mm_fault+0xc4/0xdc)
> [  270.507554] [<800d5f20>] (handle_mm_fault+0xc4/0xdc) from
> [<8001b080>] (do_page_fault+0x114/0x354)
> [  270.516580] [<8001b080>] (do_page_fault+0x114/0x354) from
> [<800083d8>] (do_DataAbort+0x44/0xa8)
> [  270.525346] [<800083d8>] (do_DataAbort+0x44/0xa8) from [<8000dc78>]
> (__dabt_usr+0x38/0x40)
>
> A lot of processes are in futex_wait(), probably for legitimate reasons:
>
> [  265.650220] VC manager      S 804e98d4     0  2662   1175 0x00200000
> [  265.656648] [<804e98d4>] (__schedule+0x66c/0x738) from [<804e9d2c>]
> (schedule+0x8c/0x90)
> [  265.664807] [<804e9d2c>] (schedule+0x8c/0x90) from [<8006f25c>]
> (futex_wait_queue_me+0xf0/0x110)
> [  265.673661] [<8006f25c>] (futex_wait_queue_me+0xf0/0x110) from
> [<8006fea8>] (futex_wait+0x110/0x254)
> [  265.682861] [<8006fea8>] (futex_wait+0x110/0x254) from [<80071440>]
> (do_futex+0xd4/0x97c)
> [  265.691107] [<80071440>] (do_futex+0xd4/0x97c) from [<80071e38>]
> (sys_futex+0x150/0x170)
> [  265.699266] [<80071e38>] (sys_futex+0x150/0x170) from [<8000e140>]
> (__sys_trace_return+0x0/0x20)
>
> A few processes are waiting on select() or other things.
>
> Can you see anything suspicious?
>
> Thanks!
> Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
