Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48F036B0795
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 11:59:43 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id y6so3279936oty.23
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 08:59:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b69-v6si1260095oih.266.2018.11.10.08.59.41
        for <linux-mm@kvack.org>;
        Sat, 10 Nov 2018 08:59:41 -0800 (PST)
Date: Sat, 10 Nov 2018 16:59:38 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Early log buffer exceeded (525980) during boot
Message-ID: <20181110165938.lbt6dfamk2ljafcv@localhost>
References: <1541712198.12945.12.camel@gmx.us>
 <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@gmx.us>
Cc: open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, Nov 10, 2018 at 10:08:10AM -0500, Qian Cai wrote:
> On Nov 8, 2018, at 4:23 PM, Qian Cai <cai@gmx.us> wrote:
> > The maximum value for DEBUG_KMEMLEAK_EARLY_LOG_SIZE is only 40000, so it
> > disables kmemleak every time on this aarch64 server running the latest mainline
> > (b00d209).
> > 
> > # echo scan > /sys/kernel/debug/kmemleak 
> > -bash: echo: write error: Device or resource busy
> > 
> > Any idea on how to enable kmemleak there?
> 
> I have managed to hard-code DEBUG_KMEMLEAK_EARLY_LOG_SIZE to 600000,

That's quite a high number, I wouldn't have thought it is needed.
Basically the early log buffer is only used until the slub allocator
gets initialised and kmemleak_init() is called from start_kernel(). I
don't know what allocates that much memory so early.

What else is in your .config?

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 877de4fa0720..c10119102c10 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -280,7 +280,7 @@ struct early_log {
>  
>  /* early logging buffer and current position */
>  static struct early_log
> -       early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
> +       early_log[600000] __initdata;

You don't need to patch the kernel, the config variable is there to be
changed.

> Even though kmemleak is enabled, there are continuous soft-lockups and eventually
> a kernel panic. Is it normal that kmemleak not going to work with large systems (this
> aarch64 server has 64-CPU and 100G memory)?

I only tried 4.20-rc1 with 64 CPUs in a guest under KVM and with only
16GB of RAM (I can try on a ThunderX2 host in about 10 days as I'm away
next week at Linux Plumbers). But it works fine for me, no soft lockups.
Maybe something different in your .config or something else goes
completely wrong (e.g. memory corruption) and kmemleak trips over it.

-- 
Catalin
