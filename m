Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9C136B028E
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 12:09:08 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y131-v6so11454036wmd.5
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 09:09:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k140-v6sor3627113wmd.25.2018.10.30.09.09.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 09:09:07 -0700 (PDT)
MIME-Version: 1.0
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
In-Reply-To: <20181030152632.GG32673@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Tue, 30 Oct 2018 17:08:53 +0100
Message-ID: <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Am Di., 30. Okt. 2018 um 16:30 Uhr schrieb Michal Hocko <mhocko@suse.com>:
>
> On Tue 30-10-18 14:44:27, Vlastimil Babka wrote:
> > On 10/22/18 3:19 AM, Marinko Catovic wrote:
> > > Am Mi., 29. Aug. 2018 um 18:44 Uhr schrieb Marinko Catovic
> [...]
> > >> here you go: https://nofile.io/f/VqRg644AT01/vmstat.tar.gz
> > >> trace_pipe: https://nofile.io/f/wFShvZScpvn/trace_pipe.gz
> > >>
> > >
> > > There we go again.
> > >
> > > First of all, I have set up this monitoring on 1 host, as a matter of
> > > fact it did not occur on that single
> > > one for days and weeks now, so I set this up again on all the hosts
> > > and it just happened again on another one.
> > >
> > > This issue is far from over, even when upgrading to the latest 4.18.12
> > >
> > > https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> > > https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz
> >
> > I have plot the vmstat using the attached script, and got the attached
> > plots. X axis are the vmstat snapshots, almost 14k of them, each for 5
> > seconds, so almost 19 hours. I can see the following phases:
>
> Thanks a lot. I like the script much!
>
> [...]
>
> > 12000 - end:
> > - free pages growing sharply
> > - page cache declining sharply
> > - slab still slowly declining
>
> $ cat filter
> pgfree
> pgsteal_
> pgscan_
> compact
> nr_free_pages
>
> $ grep -f filter -h vmstat.1539866837 vmstat.1539874353 | awk '{if (c[$1]) {printf "%s %d\n", $1, $2-c[$1]}; c[$1]=$2}'
> nr_free_pages 4216371
> pgfree 267884025
> pgsteal_kswapd 0
> pgsteal_direct 11890416
> pgscan_kswapd 0
> pgscan_direct 11937805
> compact_migrate_scanned 2197060121
> compact_free_scanned 4747491606
> compact_isolated 54281848
> compact_stall 1797
> compact_fail 1721
> compact_success 76
>
> So we have ended up with 16G freed pages in that last time period.
> Kswapd was sleeping throughout the time but direct reclaim was quite
> active. ~46GB pages recycled. Note that much more pages were freed which
> suggests there was quite a large memory allocation/free activity.
>
> One notable thing here is that there shouldn't be any reason to do the
> direct reclaim when kswapd itself doesn't do anything. It could be
> either blocked on something but I find it quite surprising to see it in
> that state for the whole 1500s time period or we are simply not low on
> free memory at all. That would point towards compaction triggered memory
> reclaim which account as the direct reclaim as well. The direct
> compaction triggered more than once a second in average. We shouldn't
> really reclaim unless we are low on memory but repeatedly failing
> compaction could just add up and reclaim a lot in the end. There seem to
> be quite a lot of low order request as per your trace buffer
>
> $ grep order trace-last-phase | sed 's@.*\(order=[0-9]*\).*gfp_flags=\(.*\)@\1 \2@' | sort | uniq -c
>    1238 order=1 __GFP_HIGH|__GFP_ATOMIC|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>    5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>     121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>      22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>  395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
>  783055 order=1 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>    1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>    3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>  797255 order=2 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>   93524 order=3 GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
>  498148 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>  243563 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
>      10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>     114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>   67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE
>
> We can safely rule out NOWAIT and ATOMIC because those do not reclaim.
> That leaves us with
>    5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>     121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>      22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>  395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
>    1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>    3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>      10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>     114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>   67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE
>
> by large the kernel stack allocations are in lead. You can put some
> relief by enabling CONFIG_VMAP_STACK. There is alos a notable number of
> THP pages allocations. Just curious are you running on a NUMA machine?
> If yes [1] might be relevant. Other than that nothing really jumped at
> me.
>
> [1] http://lkml.kernel.org/r/20180925120326.24392-2-mhocko@kernel.org
> --
> Michal Hocko
> SUSE Labs

thanks a lot Vlastimil!

I would not really know whether this is a NUMA, it is some usual
server running with a i7-8700
and ECC RAM. How would I find out?
So I should do CONFIG_VMAP_STACK=y and try that..?
