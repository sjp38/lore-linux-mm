Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17F516B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 12:11:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a186so6393100wmh.9
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:11:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y196si5797331wme.213.2017.07.24.09.11.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 09:11:50 -0700 (PDT)
Date: Mon, 24 Jul 2017 18:11:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170724161146.GQ25221@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 24-07-17 17:51:42, Kirill A. Shutemov wrote:
> On Mon, Jul 24, 2017 at 04:15:26PM +0200, Michal Hocko wrote:
[...]
> > What kind of scalability implication you have in mind? There is
> > basically a zero contention on the mmap_sem that late in the exit path
> > so this should be pretty much a fast path of the down_write. I agree it
> > is not 0 cost but the cost of the address space freeing should basically
> > make it a noise.
> 
> Even in fast path case, it adds two atomic operation per-process. If the
> cache line is not exclusive to the core by the time of exit(2) it can be
> noticible.
> 
> ... but I guess it's not very hot scenario.
> 
> I guess I'm just too cautious here. :)

I definitely did not want to handwave your concern. I just think we can
rule out the slow path and didn't think about the fast path overhead.

> > > Should we do performance/scalability evaluation of the patch before
> > > getting it applied?
> > 
> > What kind of test(s) would you be interested in?
> 
> Can we at lest check that number of /bin/true we can spawn per second
> wouldn't be harmed by the patch? ;)

OK, so measuring a single /bin/true doesn't tell anything so I've done
root@test1:~# cat a.sh 
#!/bin/sh

NR=$1
for i in $(seq $NR)
do
        /bin/true
done

in my virtual machine (on a otherwise idle host) with 4 cpus and 2GB of
RAM

Unpatched kernel
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 53.57
        System time (seconds): 26.12
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.46
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 53.90
        System time (seconds): 26.23
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.77
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 54.02
        System time (seconds): 26.18
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.92

patched kernel
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 53.81
        System time (seconds): 26.55
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.99
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 53.78
        System time (seconds): 26.15
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.67
root@test1:~# /usr/bin/time -v ./a.sh 100000 
        Command being timed: "./a.sh 100000"
        User time (seconds): 54.08
        System time (seconds): 26.87
        Percent of CPU this job got: 100%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 1:20.52

the results very quite a lot (have a look at the user time which
shouldn't have no reason to vary at all - maybe the virtual machine
aspect?). I would say that we are still reasonably close to a noise
here. Considering that /bin/true would close to the worst case I think
this looks reasonably. What do you think?

If you absolutely insist, I can make the lock conditional only for oom
victims. That would still mean current->signal->oom_mm pointers fetches
and a 2 branches.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
