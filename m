Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC3CE6B02F4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:07:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q15so13774947pgc.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:07:26 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r19si8330267pgj.246.2017.07.25.08.07.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 08:07:25 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id g14so10076819pgu.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:07:25 -0700 (PDT)
Date: Tue, 25 Jul 2017 18:07:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725150719.74j7fbfzagrn7olb@node.shutemov.name>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725141723.ivukwhddk2voyhuc@node.shutemov.name>
 <20170725142617.GI26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725142617.GI26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 25, 2017 at 04:26:17PM +0200, Michal Hocko wrote:
> On Tue 25-07-17 17:17:23, Kirill A. Shutemov wrote:
> [...]
> > Below are numbers for the same test case, but from bigger machine (48
> > threads, 64GiB of RAM).
> > 
> > v4.13-rc2:
> > 
> >  Performance counter stats for './a.sh 100000' (5 runs):
> > 
> >      159857.233790      task-clock:u (msec)       #    1.000 CPUs utilized            ( +-  3.21% )
> >                  0      context-switches:u        #    0.000 K/sec
> >                  0      cpu-migrations:u          #    0.000 K/sec
> >          8,761,843      page-faults:u             #    0.055 M/sec                    ( +-  0.64% )
> >     38,725,763,026      cycles:u                  #    0.242 GHz                      ( +-  0.18% )
> >    272,691,643,016      stalled-cycles-frontend:u #  704.16% frontend cycles idle     ( +-  3.16% )
> >     22,221,416,575      instructions:u            #    0.57  insn per cycle
> >                                                   #   12.27  stalled cycles per insn  ( +-  0.00% )
> >      5,306,829,649      branches:u                #   33.197 M/sec                    ( +-  0.00% )
> >        240,783,599      branch-misses:u           #    4.54% of all branches          ( +-  0.15% )
> > 
> >      159.808721098 seconds time elapsed                                          ( +-  3.15% )
> > 
> > v4.13-rc2 + the patch:
> > 
> >  Performance counter stats for './a.sh 100000' (5 runs):
> > 
> >      167628.094556      task-clock:u (msec)       #    1.007 CPUs utilized            ( +-  1.63% )
> >                  0      context-switches:u        #    0.000 K/sec
> >                  0      cpu-migrations:u          #    0.000 K/sec
> >          8,838,314      page-faults:u             #    0.053 M/sec                    ( +-  0.26% )
> >     38,862,240,137      cycles:u                  #    0.232 GHz                      ( +-  0.10% )
> >    282,105,057,553      stalled-cycles-frontend:u #  725.91% frontend cycles idle     ( +-  1.64% )
> >     22,219,273,623      instructions:u            #    0.57  insn per cycle
> >                                                   #   12.70  stalled cycles per insn  ( +-  0.00% )
> >      5,306,165,194      branches:u                #   31.654 M/sec                    ( +-  0.00% )
> >        240,473,075      branch-misses:u           #    4.53% of all branches          ( +-  0.07% )
> > 
> >      166.497005412 seconds time elapsed                                          ( +-  1.61% )
> > 
> > IMO, there is something to think about. ~4% slowdown is not insignificant.
> > I expect effect to be bigger for larger machines.
> 
> Thanks for retesting Kirill. Are those numbers stable over runs? E.g.
> the run without the patch has ~3% variance while the one with the patch
> has it smaller. This sounds suspicious to me. There shouldn't be any
> lock contention (except for the oom killer) so the lock shouldn't make
> any difference wrt. variability.

There's run-to-tun variability. I'll post new numbers for your new test.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
