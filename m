Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 171F56B0253
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 22:47:17 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id x21so31739393oix.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 19:47:17 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id sd10si4923193obb.48.2016.02.24.19.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 19:47:16 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id ts10so38096464obc.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 19:47:16 -0800 (PST)
Date: Wed, 24 Feb 2016 19:47:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160203132718.GI6757@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 3 Feb 2016, Michal Hocko wrote:
> Hi,
> this thread went mostly quite. Are all the main concerns clarified?
> Are there any new concerns? Are there any objections to targeting
> this for the next merge window?

Sorry to say at this late date, but I do have one concern: hopefully
you can tweak something somewhere, or point me to some tunable that
I can adjust (I've not studied the patches, sorry).

This rework makes it impossible to run my tmpfs swapping loads:
they're soon OOM-killed when they ran forever before, so swapping
does not get the exercise on mmotm that it used to.  (But I'm not
so arrogant as to expect you to optimize for my load!)

Maybe it's just that I'm using tmpfs, and there's code that's conscious
of file and anon, but doesn't cope properly with the awkward shmem case.

(Of course, tmpfs is and always has been a problem for OOM-killing,
given that it takes up memory, but none is freed by killing processes:
but although that is a tiresome problem, it's not what either of us is
attacking here.)

Taking many of the irrelevancies out of my load, here's something you
could try, first on v4.5-rc5 and then on mmotm.

Boot with mem=1G (or boot your usual way, and do something to occupy
most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
way to gobble up most of the memory, though it's not how I've done it).

Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
kernel source tree into a tmpfs: size=2G is more than enough.
make defconfig there, then make -j20.

On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.

Except that you'll probably need to fiddle around with that j20,
it's true for my laptop but not for my workstation.  j20 just happens
to be what I've had there for years, that I now see breaking down
(I can lower to j6 to proceed, perhaps could go a bit higher,
but it still doesn't exercise swap very much).

This OOM detection rework significantly lowers the number of jobs
which can be run in parallel without being OOM-killed.  Which would
be welcome if it were choosing to abort in place of thrashing, but
the system was far from thrashing: j20 took a few seconds more than
j6, and even j30 didn't take 50% longer.

(I have /proc/sys/vm/swappiness 100, if that matters.)

I hope there's an easy answer to this: thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
