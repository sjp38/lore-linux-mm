Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 527C9900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 05:48:22 -0500 (EST)
Received: by pdno5 with SMTP id o5so8027055pdn.8
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 02:48:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 4si25502947pdi.235.2015.02.19.02.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 02:48:21 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150218084842.GB4478@dhcp22.suse.cz>
	<201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
	<20150218122903.GD4478@dhcp22.suse.cz>
	<201502182306.HAB60908.MVQFOHJSOOFLFt@I-love.SAKURA.ne.jp>
	<20150218142557.GE4478@dhcp22.suse.cz>
In-Reply-To: <20150218142557.GE4478@dhcp22.suse.cz>
Message-Id: <201502191948.JHA41792.OLQtSOOJVHMFFF@I-love.SAKURA.ne.jp>
Date: Thu, 19 Feb 2015 19:48:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

Michal Hocko wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > Because they cannot perform any IO/FS transactions and that would lead
> > > > > to a premature OOM conditions way too easily. OOM killer is a _last
> > > > > resort_ reclaim opportunity not something that would happen just because
> > > > > you happen to be not able to flush dirty pages. 
> > > > 
> > > > But you should not have applied such change without making necessary
> > > > changes to GFP_NOFS / GFP_NOIO users with such expectation and testing
> > > > at linux-next.git . Applying such change after 3.19-rc6 is a sucker punch.
> > > 
> > > This is a nonsense. OOM was disbaled for !__GFP_FS for ages (since
> > > before git era).
> > >  
> > Then, at least I expect that filesystem error actions will not be taken so
> > trivially. Can we apply http://marc.info/?l=linux-mm&m=142418465615672&w=2 for
> > Linux 3.19-stable?
> 
> I do not understand. What kind of bug would be fixed by that change?

That change fixes significant loss of file I/O reliability under extreme
memory pressure.

Today I tested how frequent filesystem errors occurs using scripted environment.
( Source code of a.out is http://marc.info/?l=linux-fsdevel&m=142425860904849&w=2 )

----------
#!/bin/sh
: > ~/trial.log
for i in `seq 1 100`
do
    mkfs.ext4 -q /dev/sdb1 || exit 1
    mount -o errors=remount-ro /dev/sdb1 /tmp || exit 2
    chmod 1777 /tmp
    su - demo -c ~demo/a.out
    if [ -w /tmp/ ]
    then
        echo -n "S" >> ~/trial.log
    else
        echo -n "F" >> ~/trial.log
    fi
    umount /tmp
done
----------

We can see that filesystem errors are occurring frequently if GFP_NOFS / GFP_NOIO
allocations give up without retrying. On the other hand, as far as these trials,
TIF_MEMDIE stall was not observed if GFP_NOFS / GFP_NOIO allocations give up
without retrying. Maybe giving up without retrying is keeping away from hitting
stalls for this test case?

  Linux 3.19-rc6 (Console log is http://I-love.SAKURA.ne.jp/tmp/serial-20150219-3.19-rc6.txt.xz )

    0 filesystem errors out of 100 trials. 2 stalls.
    SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

  Linux 3.19 (Console log is http://I-love.SAKURA.ne.jp/tmp/serial-20150219-3.19.txt.xz )

    44 filesystem errors out of 100 trials. 0 stalls.
    SSFFSSSFSSSFSFFFFSSFSSFSSSSSSFFFSFSFFSSSSSSFFFFSFSSFFFSSSSFSSFFFFFSSSSSFSSFSFSSFSFFFSFFFFFFFSSSSSSSS

  Linux 3.19 with http://marc.info/?l=linux-mm&m=142418465615672&w=2 applied.
  (Console log is http://I-love.SAKURA.ne.jp/tmp/serial-20150219-3.19-patched.txt.xz )

    0 filesystem errors out of 100 trials. 2 stalls.
    SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

If result of Linux 3.19 is what you wanted, we should chime fs developers
for immediate action. (But __GFP_NOFAIL discussion between you and Dave
is in progress. I don't know whether ext4 and underlying subsystems should
start using __GFP_NOFAIL.)

P.S. Just for experimental purpose, Linux 3.19 with below change applied
gave better result than retrying GFP_NOFS / GFP_NOIO allocations without
invoking the OOM killer. Short-lived small GFP_NOFS / GFP_NOIO allocations
can use GFP_ATOMIC instead? How many bytes does blk_rq_map_kern() want?

  --- a/mm/page_alloc.c
  +++ b/mm/page_alloc.c
  @@ -2867,6 +2867,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
           int classzone_idx;

           gfp_mask &= gfp_allowed_mask;
  +        if (gfp_mask == GFP_NOFS || gfp_mask == GFP_NOIO)
  +                gfp_mask = GFP_ATOMIC;

           lockdep_trace_alloc(gfp_mask);

    0 filesystem errors out of 100 trials. 0 stalls.
    SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
