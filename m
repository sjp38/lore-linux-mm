Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 502766B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 06:39:02 -0400 (EDT)
Date: Thu, 12 Mar 2009 18:38:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090312103847.GA20210@localhost>
References: <20090311114353.GA759@localhost> <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com> <20090311121123.GA7656@localhost> <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com> <20090311122611.GA8804@localhost> <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com> <20090312075952.GA19331@localhost> <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com> <20090312081113.GA19506@localhost> <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 10:17:44AM +0200, jack marrow wrote:
> 2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> > On Thu, Mar 12, 2009 at 10:04:17AM +0200, jack marrow wrote:
> >> 2009/3/12 Wu Fengguang <fengguang.wu@intel.com>:
> >> > On Thu, Mar 12, 2009 at 09:53:27AM +0200, jack marrow wrote:
> >> >> > Can you paste /proc/vmstat, /proc/meminfo, /proc/zoneinfo and
> >> >> > /proc/slabinfo? Thank you.
> >> >>
> >> >> Sure, but I don't know if it will help.
> >> >>
> >> >> The oom info was from in the night, the rest is from now. I have no zoneinfo.
> >> >>
> >> >> http://pastebin.com/m67409bc0
> >> >
> >> > Thank you! So you are running a pretty old kernel?
> >> >
> >>
> >> Yes. Kernel.2.6.9-78.
> >>
> >> Added more output from the other oom kills here:
> >> A http://pastebin.com/m76fc473d
> >>
> >> If I could just find a way to find out what is using up all the memory
> >> in a zone I could go away happy :)
> >
> > But the highmem zone wont help you much, since you have a large 900M
> > normal zone and a tiny 100M highmem zone ;)
> >
> > The cached files seem to be the memory killer:
> 
> I ran an echo 3 > drop_caches yesterday, I was hoping to come in and
> find no oom kill. Oh well :)

Can you paste the /proc/meminfo after doing 'echo 3 > drop_caches'?

> I thought the kernel dropped caches if a program needs the ram?

Sure, but something is unreclaimable... Maybe some process is taking a
lot of shared memory(shm)? What's the output of `lsof`?

> >
> > MemTotal: A  A  A 1034496 kB
> > MemFree: A  A  A  A  95600 kB
> > Buffers: A  A  A  A  49916 kB
> > Cached: A  A  A  A  761544 kB
> > SwapCached: A  A  A  A  A 0 kB
> > Active: A  A  A  A  A 80484 kB
> > Inactive: A  A  A  749960 kB
> > HighTotal: A  A  A 131008 kB
> > HighFree: A  A  A  A 68480 kB
> > LowTotal: A  A  A  903488 kB
> > LowFree: A  A  A  A  27120 kB
> > SwapTotal: A  A  2040212 kB
> > SwapFree: A  A  A 2039780 kB
> > Dirty: A  A  A  A  A  A  A  4 kB
> > Writeback: A  A  A  A  A  0 kB
> > Mapped: A  A  A  A  A 32636 kB
> > Slab: A  A  A  A  A  A 93856 kB
> > CommitLimit: A  2557460 kB
> > Committed_AS: A  129980 kB
> > PageTables: A  A  A  1800 kB
> > VmallocTotal: A  106488 kB
> > VmallocUsed: A  A  A 3372 kB
> > VmallocChunk: A  102616 kB
> > HugePages_Total: A  A  0
> > HugePages_Free: A  A  A 0
> > Hugepagesize: A  A  2048 kB
> >
> > Is upgrading the kernel an option for you?
> 
> No :(
> 
> I think shoving some more ram in the box is the best doable option.
> Would this help here?

There have been huge amounts of change sets in mm area since 2.6.9...

> To do that I need to say "look at how much cache we are using for
> files, that cache is in the high mem zone (look here) so let's put
> some more ram in". Does the cache always live in the high mem zone?

Both highmem and normal zones will be used for caches.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
