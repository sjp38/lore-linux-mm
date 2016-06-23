Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6B9828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:18:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so19586628wme.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:18:36 -0700 (PDT)
Received: from mail.sig21.net (mail.sig21.net. [80.244.240.74])
        by mx.google.com with ESMTPS id g135si5208375wme.57.2016.06.23.02.18.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 02:18:35 -0700 (PDT)
Date: Thu, 23 Jun 2016 11:18:30 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
Message-ID: <20160623091830.GA32535@sig21.net>
References: <20160616212641.GA3308@sig21.net>
 <c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Tue, Jun 21, 2016 at 08:47:51PM +0900, Tetsuo Handa wrote:
> Johannes Stezenbach wrote:
> > 
> > a man's got to have a hobby, thus I'm running Android AOSP
> > builds on my home PC which has 4GB of RAM, 4GB swap.
> > Apparently it is not really adequate for the job but used to
> > work with a 4.4.10 kernel.  Now I upgraded to 4.6.2
> > and it crashes usually within 30mins during compilation.
> 
> Such reproducer is welcomed.
> You might be hitting OOM livelock using innocent workload.
> 
> > The crash is a hard hang, mouse doesn't move, no reaction
> > to keyboard, nothing in logs (systemd journal) after reboot.
> 
> Yes, it seems to me that your system is OOM livelocked.

I got from my crash log that X is hanging in
i915_gem_object_get_pages_gtt, and network is dead
due to order 0 allocation errors causing a series of
"ath9k_htc: RX memory allocation error", which is
what makes the issue so unpleasant.

The particular command which triggers it seems to be
Jill from the Android Java toolchain
(http://tools.android.com/tech-docs/jackandjill),
which runs as "java -Xmx3500m -jar $(JILL_JAR)", i.e.
potentially eating all my available RAM when linking
the Android framework.

Meanwhile I found some RAM and linux-4.6.2 runs stable
with 8GB for this workload.  The build time (for the
partial AOSP rebuild that fairly reliably triggered the hangup)
dropped from ~20min to ~17min (so it wasn't trashing too
badly), swap usage dropped from ~50% (of 4GB) to <5%.

> It is sad that we haven't merged kmallocwd which will report
> which memory allocations are stalling
>  ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

Would you like me to try it?  It wouldn't prevent the hang, though,
just print better debug ouptut to serial console, right?
Or would it OOM kill some process?

> > Then I tried 4.5.7, it seems to be stable so far.
> > 
> > I'm using dm-crypt + lvm + ext4 (swap also in lvm).
> > 
> > Now I hooked up a laptop to the serial port and captured
> > some logs of the crash which seems to be repeating
> > 
> > [ 2240.842567] swapper/3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
> > or
> > [ 2241.167986] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
> > 
> > over and over.  Based on the backtraces in the log I decided
> > to hot-unplug USB devices, and twice the kernel came
> > back to live, but on the 3rd crash it was dead for good.
> 
> The values
> 
>   DMA free:12kB min:32kB
>   DMA32 free:2268kB min:6724kB
>   Normal free:84kB min:928kB 
> 
> suggest that memory reserves are spent for pointless purpose. Maybe your system is
> falling into situation which was mitigated by commit 78ebc2f7146156f4 ("mm,writeback:
> don't use memory reserves for wb_start_writeback"). Thus, applying that commit to
> your 4.6.2 kernel might help avoiding flood of these allocation failure messages.

I could try.  Could you let me know if booting with mem=4G
is equivalent, or do I need to use memmap= or physically remove
the RAM (which is not so easy since the CPU fan is in the way).

> > Before I pressed the reset button I used SysRq-W.  At the bottom
> > is a "BUG: workqueue lockup", it could be the result of
> > the log spew on serial console taking so long but it looks
> > like some IO is never completing.
> 
> But even after you apply that commit, I guess you will still see silent hang up
> because the page allocator would think there is still reclaimable memory. So, is
> it possible to also try current linux.git kernels? I'd like to know whether
> "OOM detection rework" (which went to 4.7) helps giving up reclaiming and
> invoking the OOM killer with your workload.
> 
> Maybe __GFP_FS allocations start invoking the OOM killer. But maybe __GFP_FS
> allocations still remain stuck waiting for !__GFP_FS allocations whereas !__GFP_FS
> allocations gives up without invoking the OOM killer (i.e. effectively no "give up").

I could also try.  Same question about mem= though.

What is your opinion about older kernels (4.4, 4.5) working?
I think I've seen some OOM messages with the older kernels,
Jill was killed and I restarted the build to complete it.
A full bisect would take more than a day, I don't think
I have the time for it.
Since I use dm-crypt + lvm, should we add more Cc or do
you think it is an mm issue?


> > Below I'm pasting some log snippets, let me know if you like
> > it so much you want more of it ;-/  The total log is about 1.7MB.
> 
> Yes, I'd like to browse it. Could you send it to me?

Did you get any additional insights from it?


Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
