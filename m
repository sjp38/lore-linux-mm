Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE7C26B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:18:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so3466750pfg.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:18:00 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k63si5581410pgc.958.2017.07.25.08.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 08:17:59 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 1so5055262pfi.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:17:59 -0700 (PDT)
Date: Tue, 25 Jul 2017 18:17:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725142626.GJ26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 25, 2017 at 04:26:26PM +0200, Michal Hocko wrote:
> On Mon 24-07-17 18:11:46, Michal Hocko wrote:
> > On Mon 24-07-17 17:51:42, Kirill A. Shutemov wrote:
> > > On Mon, Jul 24, 2017 at 04:15:26PM +0200, Michal Hocko wrote:
> > [...]
> > > > What kind of scalability implication you have in mind? There is
> > > > basically a zero contention on the mmap_sem that late in the exit path
> > > > so this should be pretty much a fast path of the down_write. I agree it
> > > > is not 0 cost but the cost of the address space freeing should basically
> > > > make it a noise.
> > > 
> > > Even in fast path case, it adds two atomic operation per-process. If the
> > > cache line is not exclusive to the core by the time of exit(2) it can be
> > > noticible.
> > > 
> > > ... but I guess it's not very hot scenario.
> > > 
> > > I guess I'm just too cautious here. :)
> > 
> > I definitely did not want to handwave your concern. I just think we can
> > rule out the slow path and didn't think about the fast path overhead.
> > 
> > > > > Should we do performance/scalability evaluation of the patch before
> > > > > getting it applied?
> > > > 
> > > > What kind of test(s) would you be interested in?
> > > 
> > > Can we at lest check that number of /bin/true we can spawn per second
> > > wouldn't be harmed by the patch? ;)
> > 
> > OK, so measuring a single /bin/true doesn't tell anything so I've done
> > root@test1:~# cat a.sh 
> > #!/bin/sh
> > 
> > NR=$1
> > for i in $(seq $NR)
> > do
> >         /bin/true
> > done
> 
> I wanted to reduce a potential shell side effects so I've come with a
> simple program which forks and saves the timestamp before child exit and
> right after waitpid (see attached) and then measured it 100k times. Sure
> this still measures waitpid overhead and the signal delivery but this
> should be more or less constant on an idle system, right? See attached.
> 
> before the patch
> min: 306300.00 max: 6731916.00 avg: 437962.07 std: 92898.30 nr: 100000
> 
> after
> min: 303196.00 max: 5728080.00 avg: 436081.87 std: 96165.98 nr: 100000
> 
> The results are well withing noise as I would expect.

I've silightly modified your test case: replaced cpuid + rdtsc with
rdtscp. cpuid overhead is measurable in such tight loop.

3 runs before the patch:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
 177200  205000  212900  217800  223700 2377000
 172400  201700  209700  214300  220600 1343000
 175700  203800  212300  217100  223000 1061000

3 runs after the patch:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
 175900  204800  213000  216400  223600 1989000
 180300  210900  219600  223600  230200 3184000
 182100  212500  222000  226200  232700 1473000

The difference is still measuarble. Around 3%.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
