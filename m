Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4282F6B02A5
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 11:31:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y23-v6so9195866eds.12
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 08:31:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8-v6si4377240ejg.260.2018.10.30.08.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 08:31:00 -0700 (PDT)
Date: Tue, 30 Oct 2018 16:30:45 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181030152632.GG32673@dhcp22.suse.cz>
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Tue 30-10-18 14:44:27, Vlastimil Babka wrote:
> On 10/22/18 3:19 AM, Marinko Catovic wrote:
> > Am Mi., 29. Aug. 2018 um 18:44 Uhr schrieb Marinko Catovic
[...]
> >> here you go: https://nofile.io/f/VqRg644AT01/vmstat.tar.gz
> >> trace_pipe: https://nofile.io/f/wFShvZScpvn/trace_pipe.gz
> >>
> > 
> > There we go again.
> > 
> > First of all, I have set up this monitoring on 1 host, as a matter of
> > fact it did not occur on that single
> > one for days and weeks now, so I set this up again on all the hosts
> > and it just happened again on another one.
> > 
> > This issue is far from over, even when upgrading to the latest 4.18.12
> > 
> > https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> > https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz
> 
> I have plot the vmstat using the attached script, and got the attached
> plots. X axis are the vmstat snapshots, almost 14k of them, each for 5
> seconds, so almost 19 hours. I can see the following phases:

Thanks a lot. I like the script much!

[...]

> 12000 - end:
> - free pages growing sharply
> - page cache declining sharply
> - slab still slowly declining

$ cat filter 
pgfree
pgsteal_
pgscan_
compact
nr_free_pages

$ grep -f filter -h vmstat.1539866837 vmstat.1539874353 | awk '{if (c[$1]) {printf "%s %d\n", $1, $2-c[$1]}; c[$1]=$2}'
nr_free_pages 4216371
pgfree 267884025
pgsteal_kswapd 0
pgsteal_direct 11890416
pgscan_kswapd 0
pgscan_direct 11937805
compact_migrate_scanned 2197060121
compact_free_scanned 4747491606
compact_isolated 54281848
compact_stall 1797
compact_fail 1721
compact_success 76

So we have ended up with 16G freed pages in that last time period.
Kswapd was sleeping throughout the time but direct reclaim was quite
active. ~46GB pages recycled. Note that much more pages were freed which
suggests there was quite a large memory allocation/free activity.

One notable thing here is that there shouldn't be any reason to do the
direct reclaim when kswapd itself doesn't do anything. It could be
either blocked on something but I find it quite surprising to see it in
that state for the whole 1500s time period or we are simply not low on
free memory at all. That would point towards compaction triggered memory
reclaim which account as the direct reclaim as well. The direct
compaction triggered more than once a second in average. We shouldn't
really reclaim unless we are low on memory but repeatedly failing
compaction could just add up and reclaim a lot in the end. There seem to
be quite a lot of low order request as per your trace buffer

$ grep order trace-last-phase | sed 's@.*\(order=[0-9]*\).*gfp_flags=\(.*\)@\1 \2@' | sort | uniq -c
   1238 order=1 __GFP_HIGH|__GFP_ATOMIC|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
   5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
    121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
     22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
 395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
 783055 order=1 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
   1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
   3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
 797255 order=2 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
  93524 order=3 GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
 498148 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
 243563 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
     10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
    114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
  67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE

We can safely rule out NOWAIT and ATOMIC because those do not reclaim.
That leaves us with 
   5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
    121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
     22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
 395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
   1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
   3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
     10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
    114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
  67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE

by large the kernel stack allocations are in lead. You can put some
relief by enabling CONFIG_VMAP_STACK. There is alos a notable number of
THP pages allocations. Just curious are you running on a NUMA machine?
If yes [1] might be relevant. Other than that nothing really jumped at
me.

[1] http://lkml.kernel.org/r/20180925120326.24392-2-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
