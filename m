Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB2756B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 12:30:21 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id he10so8565677wjc.6
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 09:30:21 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n70si18895053wmd.139.2016.12.09.09.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 09:30:20 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so5063927wma.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 09:30:20 -0800 (PST)
Date: Fri, 9 Dec 2016 18:30:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er kernels
Message-ID: <20161209173018.GA31809@dhcp22.suse.cz>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161209160946.GE4334@dhcp22.suse.cz>
 <fd029311-f0fe-3d1f-26d2-1f87576b14da@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fd029311-f0fe-3d1f-26d2-1f87576b14da@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 09-12-16 17:58:14, Gerhard Wiesinger wrote:
> On 09.12.2016 17:09, Michal Hocko wrote:
[...]
> > > [97883.882611] Mem-Info:
> > > [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
> > >                  active_file:3902 inactive_file:3639 isolated_file:0
> > >                  unevictable:0 dirty:205 writeback:0 unstable:0
> > >                  slab_reclaimable:9856 slab_unreclaimable:9682
> > >                  mapped:3722 shmem:59 pagetables:2080 bounce:0
> > >                  free:748 free_pcp:15 free_cma:0
> > there is still some page cache which doesn't seem to be neither dirty
> > nor under writeback. So it should be theoretically reclaimable but for
> > some reason we cannot seem to reclaim that memory.
> > There is still some anonymous memory and free swap so we could reclaim
> > it as well but it all seems pretty down and the memory pressure is
> > really large
> 
> Yes, it might be large on the update situation, but that should be handled
> by a virtual memory system by the kernel, right?

Well this is what we try and call it memory reclaim. But if we are not
able to reclaim anything then we eventually have to give up and trigger
the OOM killer. Now the information that 4.4 made a difference is
interesting. I do not really see any major differences in the reclaim
between 4.3 and 4.4 kernels. The reason might be somewhere else as well.
E.g. some of the subsystem consumes much more memory than before.

Just curious, what kind of filesystem are you using? Could you try some
additional debugging. Enabling reclaim related tracepoints might tell us
more. The following should tell us more
mount -t tracefs none /trace
echo 1 > /trace/events/vmscan/enable
echo 1 > /trace/events/writeback/writeback_congestion_wait/enable
cat /trace/trace_pipe > trace.log

Collecting /proc/vmstat over time might be helpful as well
mkdir logs
while true
do
	cp /proc/vmstat vmstat.$(date +%s)
	sleep 1s
done
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
