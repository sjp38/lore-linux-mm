Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E2B056B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 16:46:14 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id wy17so150747pbc.0
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 13:46:14 -0700 (PDT)
Received: from psmtp.com ([74.125.245.159])
        by mx.google.com with SMTP id kg8si3150730pad.299.2013.10.31.13.46.12
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 13:46:13 -0700 (PDT)
Date: Thu, 31 Oct 2013 13:46:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 64121] New: [BISECTED] "mm" performance regression
 updating from 3.2 to 3.3
Message-Id: <20131031134610.30d4c0e98e58fb0484e988c1@linux-foundation.org>
In-Reply-To: <bug-64121-27@https.bugzilla.kernel.org/>
References: <bug-64121-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: thomas.jarosch@intra2net.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 31 Oct 2013 10:53:47 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=64121
> 
>             Bug ID: 64121
>            Summary: [BISECTED] "mm" performance regression updating from
>                     3.2 to 3.3
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.3
>           Hardware: i386
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: thomas.jarosch@intra2net.com
>         Regression: No
> 
> Created attachment 112881
>   --> https://bugzilla.kernel.org/attachment.cgi?id=112881&action=edit
> Dmesg output
> 
> Hi,
> 
> I've updated a productive box running kernel 3.0.x to 3.4.67.
> This caused a severe I/O performance regression.
> 
> After some hours I've bisected it down to this commit:
> 
> ---------------------------
> # git bisect good
> ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d is the first bad commit
> commit ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d
> Author: Johannes Weiner <jweiner@redhat.com>
> Date:   Tue Jan 10 15:07:42 2012 -0800
> 
>     mm: exclude reserved pages from dirtyable memory
> 
>     Per-zone dirty limits try to distribute page cache pages allocated for
>     writing across zones in proportion to the individual zone sizes, to reduce
>     the likelihood of reclaim having to write back individual pages from the
>     LRU lists in order to make progress.
> 
>     ...
> ---------------------------
> 
> With the "problematic" patch:
> # dd_rescue -A /dev/zero img.disk
> dd_rescue: (info): ipos:     15296.0k, opos:     15296.0k, xferd:     15296.0k
>                    errs:      0, errxfer:         0.0k, succxfer:     15296.0k
>              +curr.rate:      681kB/s, avg.rate:      681kB/s, avg.load:  0.3%
> 
> 
> Without the patch (using 25bd91bd27820d5971258cecd1c0e64b0e485144):
> # dd_rescue -A /dev/zero img.disk
> dd_rescue: (info): ipos:    293888.0k, opos:    293888.0k, xferd:    293888.0k
>                    errs:      0, errxfer:         0.0k, succxfer:    293888.0k
>              +curr.rate:    99935kB/s, avg.rate:    51625kB/s, avg.load:  3.3%
> 
> 
> 
> The kernel is 32bit using PAE mode. The system has 32GB of RAM.
> (compiled with "gcc (GCC) 4.4.4 20100630 (Red Hat 4.4.4-10)")
> 
> Interestingly: If I limit the amount of RAM to roughly 20GB
> via the "mem=20000m" boot parameter, the performance is fine.
> When I increase it to f.e. "mem=23000m", performance is bad.
> 
> Also tested kernel 3.10.17 in 32bit + PAE mode,
> it was fine out of the box.
> 
> 
> So basically we need a fix for the LTS kernel 3.4, I can work around
> this issue with "mem=20000m" until I upgrade to 3.10.
> 
> I'll probably have access to the hardware for one more week
> to test patches, it was lent to me to debug this specific problem.
> 
> The same issue appeared on a complete different machine in July
> using the same 3.4.x kernel. The box had 16GB of RAM.
> I didn't get a chance to access the hardware back then.
> 
> Attached is the dmesg output and my kernel config.

32GB of memory on a highmem machine just isn't going to work well,
sorry.  Our rule of thumb is that 16G is the max.  If it was previously
working OK with 32G then you were very lucky!

That being said, we should try to work out exactly why that commit
caused the big slowdown - perhaps there is something we can do to
restore things.  It appears that the (small?) increase in the per-zone
dirty limit is what kicked things over - perhaps we can permit that to
be tuned back again.  Or something.  Johannes, could you please have a
think about it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
