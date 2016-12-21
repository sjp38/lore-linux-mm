Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 340DF6B0393
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 06:00:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a190so275140036pgc.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:00:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d85si26209305pfb.163.2016.12.21.03.00.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 03:00:53 -0800 (PST)
Subject: Re: OOM: Better, but still there on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
	<20161217210646.GA11358@boerne.fritz.box>
	<20161219134534.GC5164@dhcp22.suse.cz>
	<20161220020829.GA5449@boerne.fritz.box>
	<20161221073658.GC16502@dhcp22.suse.cz>
In-Reply-To: <20161221073658.GC16502@dhcp22.suse.cz>
Message-Id: <201612212000.EJJ21327.SFHOLQOtVFMOFJ@I-love.SAKURA.ne.jp>
Date: Wed, 21 Dec 2016 20:00:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, nholland@tisys.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, dsterba@suse.cz, linux-btrfs@vger.kernel.org

Michal Hocko wrote:
> TL;DR
> there is another version of the debugging patch. Just revert the
> previous one and apply this one instead. It's still not clear what
> is going on but I suspect either some misaccounting or unexpeted
> pages on the LRU lists. I have added one more tracepoint, so please
> enable also mm_vmscan_inactive_list_is_low.
> 
> Hopefully the additional data will tell us more.
> 
> On Tue 20-12-16 03:08:29, Nils Holland wrote:
> > On Mon, Dec 19, 2016 at 02:45:34PM +0100, Michal Hocko wrote:
> > 
> > > Unfortunatelly shrink_active_list doesn't have any tracepoint so we do
> > > not know whether we managed to rotate those pages. If they are referenced
> > > quickly enough we might just keep refaulting them... Could you try to apply
> > > the followin diff on top what you have currently. It should add some more
> > > tracepoint data which might tell us more. We can reduce the amount of
> > > tracing data by enabling only mm_vmscan_lru_isolate,
> > > mm_vmscan_lru_shrink_inactive and mm_vmscan_lru_shrink_active.
> > 
> > So, the results are in! I applied your patch and rebuild the kernel,
> > then I rebooted the machine, set up tracing so that only the three
> > events you mentioned were being traced, and captured the output over
> > the network.
> > 
> > Things went a bit different this time: The trace events started to
> > appear after a while and a whole lot of them were generated, but
> > suddenly they stopped. A short while later, we get

"cat /debug/trace/trace_pipe > /dev/udp/$ip/$port" stops reporting if
/bin/cat is disturbed by page fault and/or memory allocation needed for
sending UDP packets. Since netconsole can send UDP packets without involving
memory allocation, printk() is preferable than tracing under OOM.

> 
> It is possible that you are hitting multiple issues so it would be
> great to focus at one at the time. The underlying problem might be
> same/similar in the end but this is hard to tell now. Could you try to
> reproduce and provide data for the OOM killer situation as well?
>  
> > [ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)
> > 
> > along with a backtrace and memory information, and then there was
> > silence.
> 
> > When I walked up to the machine, it had completely died; it
> > wouldn't turn on its screen on key press any more, blindly trying to
> > reboot via SysRequest had no effect, but the caps lock LED also wasn't
> > blinking, like it normally does when a kernel panic occurs. Good
> > question what state it was in. The OOM reaper didn't really seem to
> > kick in and kill processes this time, it seems.
> > 
> > The complete capture is up at:
> > 
> > http://ftp.tisys.org/pub/misc/teela_2016-12-20.log.xz
> 
> This is the stall report:
> [ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)
> [ 1661.485859] CPU: 1 PID: 1950 Comm: btrfs-transacti Not tainted 4.9.0-gentoo #4
> 
> pid 1950 is trying to allocate for a _long_ time. Considering that this
> is the only stall report, this means that reclaim took really long so we
> didn't get to the page allocator for that long. It sounds really crazy!

warn_alloc() reports only if !__GFP_NOWARN.

We can report where they were looping using kmallocwd at
http://lkml.kernel.org/r/1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
(and extend it to call printk() for reporting values using SystemTap which your
trace hooks would report, only during memory allocations are stalling, without
delay caused by page fault and/or memory allocation needed for sending UDP packets).

But if trying to reboot via SysRq-b did not work, I think that the system
was in hard lockup state. That would be a different problem.

By the way, Michal, I'm feeling strange because it seems to me that your
analysis does not refer to the implications of "x86_32 kernel". Maybe
you already referred x86_32 by "they are from the highmem zone" though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
