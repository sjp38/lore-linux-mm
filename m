Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id C266B6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 04:19:49 -0500 (EST)
Received: by labhv19 with SMTP id hv19so1707502lab.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 01:19:49 -0800 (PST)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id cf4si25731832lbb.33.2015.02.24.01.19.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 01:19:48 -0800 (PST)
Received: by labgq15 with SMTP id gq15so24514261lab.3
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 01:19:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150221023754.GT29656@ZenIV.linux.org.uk>
References: <20150219171934.20458.30175.stgit@buzz>
	<20150221023754.GT29656@ZenIV.linux.org.uk>
Date: Tue, 24 Feb 2015 13:19:47 +0400
Message-ID: <CALYGNiPCndnuJpfROdeP=a2cWofG5R1nXPPRegc8UYL=Jc1qZA@mail.gmail.com>
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Feb 21, 2015 at 5:37 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Feb 19, 2015 at 08:19:35PM +0300, Konstantin Khlebnikov wrote:
>> I've noticed significant locking contention in memory reclaimer around
>> sb_lock inside grab_super_passive(). Grab_super_passive() is called from
>> two places: in icache/dcache shrinkers (function super_cache_scan) and
>> from writeback (function __writeback_inodes_wb). Both are required for
>> progress in memory reclaimer.
>>
>> Also this lock isn't irq-safe. And I've seen suspicious livelock under
>> serious memory pressure where reclaimer was called from interrupt which
>> have happened right in place where sb_lock is held in normal context,
>> so all other cpus were stuck on that lock too.
>
> Excuse me, but this part is BS - its call is immediately preceded by
>         if (!(sc->gfp_mask & __GFP_FS))
>                 return SHRINK_STOP;
> and if we *ever* hit GFP_FS allocation from interrupt, we are really
> screwed.  If nothing else, both prune_dcache_sb() and prune_icache_sb()
> can wait for all kinds of IO; you really don't want that called in an
> interrupt context.  The same goes for writeback_sb_inodes(), while we
> are at it.
>
> If you ever see that in an interrupt context, you have a very bad problem
> on hands.
>
> Said that, not bothering with sb_lock (and ->s_count) in those two callers
> makes sense.  Applied, with name changed to trylock_super().

Ok, thanks. I'll pull this into our kernel and try to catch livelock again.

It seems sb_lock becomes hottest lock by accident: system has no swap
and all page-cache is gone thus all cpus stuck at reclaiming inodes and
dentries. For some reason OOM killer wasn't invoked for hour or so.

Part about reclaimer called from interrupt context was BS for sure
I've mixed up some stacks from that 30Mb log of kernel's suffering.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
