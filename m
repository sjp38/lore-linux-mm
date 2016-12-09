Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4126A6B0267
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 11:09:49 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id j10so8185569wjb.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 08:09:49 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id j4si18692891wmi.102.2016.12.09.08.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 08:09:48 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so3065743wjc.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 08:09:47 -0800 (PST)
Date: Fri, 9 Dec 2016 17:09:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er kernels
Message-ID: <20161209160946.GE4334@dhcp22.suse.cz>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 09-12-16 16:52:07, Gerhard Wiesinger wrote:
> On 09.12.2016 14:40, Michal Hocko wrote:
> > On Fri 09-12-16 08:06:25, Gerhard Wiesinger wrote:
> > > Hello,
> > > 
> > > same with latest kernel rc, dnf still killed with OOM (but sometimes
> > > better).
> > > 
> > > ./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
> > > (does dnf clean all;dnf update)
> > > Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7
> > > 17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> > > 
> > > Updated bug report:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1314697
> > Could you post your oom report please?
> 
> E.g. a new one with more than one included, first one after boot ...
> 
> Just setup a low mem VM under KVM and it is easily triggerable.

What is the workload?

> Still enough virtual memory available ...

Well, you will always have a lot of virtual memory...

> 4.9.0-0.rc8.git2.1.fc26.x86_64
> 
> [  624.862777] ksoftirqd/0: page allocation failure: order:0, mode:0x2080020(GFP_ATOMIC)
[...]
> [95895.765570] kworker/1:1H: page allocation failure: order:0, mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)

These are atomic allocation failures and should be recoverable.
[...]

> [97883.838418] httpd invoked oom-killer:  gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, order=0,  oom_score_adj=0

But this is a real OOM killer invocation because a single page allocation
cannot proceed.

[...]
> [97883.882611] Mem-Info:
> [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
>                 active_file:3902 inactive_file:3639 isolated_file:0
>                 unevictable:0 dirty:205 writeback:0 unstable:0
>                 slab_reclaimable:9856 slab_unreclaimable:9682
>                 mapped:3722 shmem:59 pagetables:2080 bounce:0
>                 free:748 free_pcp:15 free_cma:0

there is still some page cache which doesn't seem to be neither dirty
nor under writeback. So it should be theoretically reclaimable but for
some reason we cannot seem to reclaim that memory.
There is still some anonymous memory and free swap so we could reclaim
it as well but it all seems pretty down and the memory pressure is
really large

> [97883.890766] Node 0 active_anon:11660kB inactive_anon:13504kB
> active_file:15608kB inactive_file:14556kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB mapped:14888kB dirty:820kB writeback:0kB shmem:0kB
> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 236kB writeback_tmp:0kB
> unstable:0kB pages_scanned:168352 all_unreclaimable? yes

all_unreclaimable also agrees that basically nothing is reclaimable.
That was one of the criterion to hit the OOM killer prior to the rewrite
in 4.6 kernel. So I suspect that older kernels would OOM under your
memory pressure as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
