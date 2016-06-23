Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0BA828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:26:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so137022269pac.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:26:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h2si4308965pax.194.2016.06.23.04.26.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 04:26:42 -0700 (PDT)
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160616212641.GA3308@sig21.net>
	<c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
	<20160623091830.GA32535@sig21.net>
In-Reply-To: <20160623091830.GA32535@sig21.net>
Message-Id: <201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
Date: Thu, 23 Jun 2016 20:26:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js@sig21.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

Johannes Stezenbach wrote:
> What is your opinion about older kernels (4.4, 4.5) working?
> I think I've seen some OOM messages with the older kernels,
> Jill was killed and I restarted the build to complete it.
> A full bisect would take more than a day, I don't think
> I have the time for it.
> Since I use dm-crypt + lvm, should we add more Cc or do
> you think it is an mm issue?

I have no idea.

> > > Below I'm pasting some log snippets, let me know if you like
> > > it so much you want more of it ;-/  The total log is about 1.7MB.
> > 
> > Yes, I'd like to browse it. Could you send it to me?
> 
> Did you get any additional insights from it?

I found

[ 2245.660712] DMA free:4kB min:32kB
[ 2245.707031] DMA32 free:0kB min:6724kB
[ 2245.757597] Normal free:24kB min:928kB
[ 2245.806515] DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[ 2245.816359] DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[ 2245.826378] Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB

[ 2317.853951] DMA free:0kB min:32kB
[ 2317.900460] DMA32 free:0kB min:6724kB
[ 2317.951574] Normal free:0kB min:928kB
[ 2318.000808] DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[ 2318.010713] DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[ 2318.020767] Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB

which completely depleted memory reserves. So, please try commit 78ebc2f7146156f4
("mm,writeback: don't use memory reserves for wb_start_writeback") on your 4.6.2
kernel. As far as I know, passing mem=4G option will do equivalent thing.

Since you think you saw OOM messages with the older kernels, I assume that the OOM
killer was invoked on your 4.6.2 kernel. The OOM reaper in Linux 4.6 and Linux 4.7
will not help if the OOM killed process was between down_write(&mm->mmap_sem) and
up_write(&mm->mmap_sem).

I was not able to confirm whether the OOM killed process (I guess it was java)
was holding mm->mmap_sem for write, for /proc/sys/kernel/hung_task_warnings
dropped to 0 before traces of java threads are printed or console became
unusable due to the "delayed: kcryptd_crypt, ..." line. Anyway, I think that
kmallocwd will report it.

> > It is sad that we haven't merged kmallocwd which will report
> > which memory allocations are stalling
> >  ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).
> 
> Would you like me to try it?  It wouldn't prevent the hang, though,
> just print better debug ouptut to serial console, right?
> Or would it OOM kill some process?

Yes, but for bisection purpose, please try commit 78ebc2f7146156f4 without
applying kmallocwd. If that commit helps avoiding flood of the allocation
failure warnings, we can consider backporting it. If that commit does not
help, I think you are reporting a new location which we should not use
memory reserves.

kmallocwd will not OOM kill some process. kmallocwd will not prevent the hang.
kmallocwd just prints information of threads which are stalling inside memory
allocation request.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
