Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E24A96B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:17:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u7so141128752pgo.6
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:17:30 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id h4si6481870pfe.672.2017.07.25.07.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 07:17:29 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 123so4015040pgj.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:17:29 -0700 (PDT)
Date: Tue, 25 Jul 2017 17:17:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725141723.ivukwhddk2voyhuc@node.shutemov.name>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724161146.GQ25221@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 24, 2017 at 06:11:47PM +0200, Michal Hocko wrote:
> On Mon 24-07-17 17:51:42, Kirill A. Shutemov wrote:
> > On Mon, Jul 24, 2017 at 04:15:26PM +0200, Michal Hocko wrote:
> [...]
> > > What kind of scalability implication you have in mind? There is
> > > basically a zero contention on the mmap_sem that late in the exit path
> > > so this should be pretty much a fast path of the down_write. I agree it
> > > is not 0 cost but the cost of the address space freeing should basically
> > > make it a noise.
> > 
> > Even in fast path case, it adds two atomic operation per-process. If the
> > cache line is not exclusive to the core by the time of exit(2) it can be
> > noticible.
> > 
> > ... but I guess it's not very hot scenario.
> > 
> > I guess I'm just too cautious here. :)
> 
> I definitely did not want to handwave your concern. I just think we can
> rule out the slow path and didn't think about the fast path overhead.
> 
> > > > Should we do performance/scalability evaluation of the patch before
> > > > getting it applied?
> > > 
> > > What kind of test(s) would you be interested in?
> > 
> > Can we at lest check that number of /bin/true we can spawn per second
> > wouldn't be harmed by the patch? ;)
> 
> OK, so measuring a single /bin/true doesn't tell anything so I've done
> root@test1:~# cat a.sh 
> #!/bin/sh
> 
> NR=$1
> for i in $(seq $NR)
> do
>         /bin/true
> done
> 
> in my virtual machine (on a otherwise idle host) with 4 cpus and 2GB of
> RAM
> 
> Unpatched kernel
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 53.57
>         System time (seconds): 26.12
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.46
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 53.90
>         System time (seconds): 26.23
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.77
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 54.02
>         System time (seconds): 26.18
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.92
> 
> patched kernel
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 53.81
>         System time (seconds): 26.55
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.99
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 53.78
>         System time (seconds): 26.15
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:19.67
> root@test1:~# /usr/bin/time -v ./a.sh 100000 
>         Command being timed: "./a.sh 100000"
>         User time (seconds): 54.08
>         System time (seconds): 26.87
>         Percent of CPU this job got: 100%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 1:20.52
> 
> the results very quite a lot (have a look at the user time which
> shouldn't have no reason to vary at all - maybe the virtual machine
> aspect?). I would say that we are still reasonably close to a noise
> here. Considering that /bin/true would close to the worst case I think
> this looks reasonably. What do you think?
> 
> If you absolutely insist, I can make the lock conditional only for oom
> victims. That would still mean current->signal->oom_mm pointers fetches
> and a 2 branches.


Below are numbers for the same test case, but from bigger machine (48
threads, 64GiB of RAM).

v4.13-rc2:

 Performance counter stats for './a.sh 100000' (5 runs):

     159857.233790      task-clock:u (msec)       #    1.000 CPUs utilized            ( +-  3.21% )
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
         8,761,843      page-faults:u             #    0.055 M/sec                    ( +-  0.64% )
    38,725,763,026      cycles:u                  #    0.242 GHz                      ( +-  0.18% )
   272,691,643,016      stalled-cycles-frontend:u #  704.16% frontend cycles idle     ( +-  3.16% )
    22,221,416,575      instructions:u            #    0.57  insn per cycle
                                                  #   12.27  stalled cycles per insn  ( +-  0.00% )
     5,306,829,649      branches:u                #   33.197 M/sec                    ( +-  0.00% )
       240,783,599      branch-misses:u           #    4.54% of all branches          ( +-  0.15% )

     159.808721098 seconds time elapsed                                          ( +-  3.15% )

v4.13-rc2 + the patch:

 Performance counter stats for './a.sh 100000' (5 runs):

     167628.094556      task-clock:u (msec)       #    1.007 CPUs utilized            ( +-  1.63% )
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
         8,838,314      page-faults:u             #    0.053 M/sec                    ( +-  0.26% )
    38,862,240,137      cycles:u                  #    0.232 GHz                      ( +-  0.10% )
   282,105,057,553      stalled-cycles-frontend:u #  725.91% frontend cycles idle     ( +-  1.64% )
    22,219,273,623      instructions:u            #    0.57  insn per cycle
                                                  #   12.70  stalled cycles per insn  ( +-  0.00% )
     5,306,165,194      branches:u                #   31.654 M/sec                    ( +-  0.00% )
       240,473,075      branch-misses:u           #    4.53% of all branches          ( +-  0.07% )

     166.497005412 seconds time elapsed                                          ( +-  1.61% )

IMO, there is something to think about. ~4% slowdown is not insignificant.
I expect effect to be bigger for larger machines.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
