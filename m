Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
Message-ID: <trinity-cbe4d3e0-f780-48ea-af28-ed2813eafaf6-1541871732167@msvc-mesg-gmx021>
From: "Qian Cai" <cai@gmx.us>
Subject: Re: kmemleak: Early log buffer exceeded (525980) during boot
Content-Type: text/plain; charset=UTF-8
Date: Sat, 10 Nov 2018 18:42:12 +0100
In-Reply-To: <20181110165938.lbt6dfamk2ljafcv@localhost>
References: <1541712198.12945.12.camel@gmx.us>
 <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
 <20181110165938.lbt6dfamk2ljafcv@localhost>
Sender: linux-kernel-owner@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 11/10/18 at 11:59 AM, Catalin Marinas wrote:

> On Sat, Nov 10, 2018 at 10:08:10AM -0500, Qian Cai wrote:
> > On Nov 8, 2018, at 4:23 PM, Qian Cai <cai@gmx.us> wrote:
> > > The maximum value for DEBUG_KMEMLEAK_EARLY_LOG_SIZE is only 40000, so it
> > > disables kmemleak every time on this aarch64 server running the latest mainline
> > > (b00d209).
> > > 
> > > # echo scan > /sys/kernel/debug/kmemleak 
> > > -bash: echo: write error: Device or resource busy
> > > 
> > > Any idea on how to enable kmemleak there?
> > 
> > I have managed to hard-code DEBUG_KMEMLEAK_EARLY_LOG_SIZE to 600000,
> 
> That's quite a high number, I wouldn't have thought it is needed.
> Basically the early log buffer is only used until the slub allocator
> gets initialised and kmemleak_init() is called from start_kernel(). I
> don't know what allocates that much memory so early.
> 
> What else is in your .config?
https://c.gmx.com/@642631272677512867/tqD5eulbQAC-1h-fkVe1Iw

Does the dmesg helps? 
https://paste.ubuntu.com/p/BnhvXXhn7k/
> 
> > diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> > index 877de4fa0720..c10119102c10 100644
> > --- a/mm/kmemleak.c
> > +++ b/mm/kmemleak.c
> > @@ -280,7 +280,7 @@ struct early_log {
> >  
> >  /* early logging buffer and current position */
> >  static struct early_log
> > -       early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
> > +       early_log[600000] __initdata;
> 
> You don't need to patch the kernel, the config variable is there to be
> changed.
Right, but the maximum is only 40000 in kconfig, so anything bigger than that will be rejected.
