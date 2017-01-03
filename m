Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3FC36B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 17:44:17 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so755188627pfy.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 14:44:17 -0800 (PST)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id h16si70395448pli.122.2017.01.03.14.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 14:44:16 -0800 (PST)
Received: by mail-pg0-x22e.google.com with SMTP id y62so167348436pgy.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 14:44:16 -0800 (PST)
Date: Tue, 3 Jan 2017 14:44:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz>
Message-ID: <alpine.DEB.2.10.1701031431120.139238@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2 Jan 2017, Vlastimil Babka wrote:

> I'm late to the thread (I did read it fully though), so instead of
> multiple responses, I'll just list my observations here:
> 
> - "defer", e.g. background kswapd+compaction is not a silver bullet, it
> will also affect the system. Mel already mentioned extra reclaim.
> Compaction also has CPU costs, just hides the accounting to a kernel
> thread so it's not visible as latency. It also increases zone/node
> lru_lock and lock pressure.
> 
> For the same reasons, admin might want to limit direct compaction for
> THP, even for madvise() apps. It's also likely that "defer" might have
> lower system overhead than "madvise", as with "defer",
> reclaim/compaction is done by one per-node thread at a time, but there
> might be multiple madvise() threads. So there might be sense in not
> allowing madvise() apps to do direct reclaim/compaction on "defer".
> 

Hmm, is there a significant benefit to setting "defer" rather than "never" 
if you can rely on khugepaged to trigger compaction when it tries to 
allocate.  I suppose if there is nothing to collapse that this won't do 
compaction, but is this not intended for users who always want to defer 
when not immediately available?

"Defer" in it's current setting is useless, in my opinion, other than 
providing it as a simple workaround to users when their applications are 
doing MADV_HUGEPAGE without allowing them to configure it.  We would love 
to use "defer" if it didn't completely break MADV_HUGEPAGE, though.

> - for overriding specific apps such as QEMU (including their madvise()
> usage, AFAICS), we have PR_SET_THP_DISABLE prctl(), so no need to
> LD_PRELOAD stuff IMO.
> 

Very good point, and I think it's also worthwhile to allow users to 
suppress the MADV_HUGEPAGE when allocating a translation buffer in qemu if 
they choose to do so; it's a very trivial patch to qemu to allow this to 
be configurable.  I haven't proposed it because I don't personally have a 
need for it, and haven't been pointed to anyone who has a need for it.

> - I have wondered about exactly the issue here when Mel proposed the
> defer option [1]. Mel responded that it doesn't seem needed at that
> point. Now it seems it is. Too bad you didn't raise it then, but to be
> fair you were not CC'd.
> 

My understanding is that the defer option is available to users who cannot 
modify their binary to suppress an madvise(MADV_HUGEPAGE) and are unaware 
that PR_SET_THP_DISABLE exists.  The prctl was added specifically when you 
cannot control your binary.

> So would something like this be possible?
> 
> > echo "defer madvise" > /sys/kernel/mm/transparent_hugepage/defrag
> > cat /sys/kernel/mm/transparent_hugepage/defrag
> always [defer] [madvise] never
> 
> I'm not sure about the analogous kernel boot option though, I guess
> those can't use spaces, so maybe comma-separated?
> 
> If that's not acceptable, then I would probably rather be for changing
> "madvise" to include "defer", than the other way around. When we augment
> kcompactd to be more proactive, it might easily be that it will
> effectively act as "defer", even when defrag=none is set, anyway.
> 

The concern I have with changing the behavior of "madvise" is that it 
changes long standing behavior that people have correctly implemented 
userspace applications with.  I suggest doing this only with "defer" since 
it's an option that is new, nobody appears to be deploying with, and makes 
it much more powerful.  I think we could make the kernel default as 
"defer" later as well and not break userspace that has been setting 
"madvise" ever since the 2.6 kernel.

My position is this: userspace that does MADV_HUGEPAGES knows what it's 
doing.  Let it stall if it wants to stall.  If users don't want it to be 
done, allow them to configure it.  If a binary has forced you into using 
it, use the prctl.  Otherwise, I think "defer" doing background compaction 
for everybody and direct compaction for users who really want hugepages is 
appropriate and is precisely what I need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
