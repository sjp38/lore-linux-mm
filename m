Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD15FC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C85F2070B
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:15:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C85F2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CB756B000A; Tue, 27 Aug 2019 03:15:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A1ED6B000C; Tue, 27 Aug 2019 03:15:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF8C96B000D; Tue, 27 Aug 2019 03:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id C4AE86B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 03:15:27 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 79C116124
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:15:27 +0000 (UTC)
X-FDA: 75867347094.02.soap64_12786652a333d
X-HE-Tag: soap64_12786652a333d
X-Filterd-Recvd-Size: 14535
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:15:26 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3231AAF37;
	Tue, 27 Aug 2019 07:15:25 +0000 (UTC)
Date: Tue, 27 Aug 2019 09:15:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, colona@arista.com
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190827071523.GR7538@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826193638.6638-1-echron@arista.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 12:36:28, Edward Chron wrote:
[...]
> Extensibility using OOM debug options
> -------------------------------------
> What is needed is an extensible system to optionally configure
> debug options as needed and to then dynamically enable and disable
> them. Also for options that produce multiple lines of entry based
> output, to configure which entries to print based on how much
> memory they use (or optionally all the entries).

With a patch this large and adding a lot of new stuff we need a more
detailed usecases described I believe.

[...]

> Use of debugfs to allow dynamic controls
> ----------------------------------------
> By providing a debugfs interface that allows options to be configured,
> enabled and where appropriate to set a minimum size for selecting
> entries to print, the output produced when an OOM event occurs can be
> dynamically adjusted to produce as little or as much detail as needed
> for a given system.

Who is going to consume this information and why would that consumer be
unreasonable to demand further maintenance of that information in future
releases? In other words debugfs is not considered a stableAPI which is
OK here but the side effect of any change to these files results in user
visible behavior and we consider that more or less a stable as long as
there are consumers.

> OOM debug options can be added to the base code as needed.
> 
> Currently we have the following OOM debug options defined:
> 
> * System State Summary
>   --------------------
>   One line of output that includes:
>   - Uptime (days, hour, minutes, seconds)

We do have timestamps in the log so why is this needed?

>   - Number CPUs
>   - Machine Type
>   - Node name
>   - Domain name

why are these needed? That is a static information that doesn't really
influence the OOM situation.

>   - Kernel Release
>   - Kernel Version

part of the oom report
> 
>   Example output when configured and enabled:
> 
> Jul 27 10:56:46 yoursystem kernel: System Uptime:0 days 00:17:27 CPUs:4 Machine:x86_64 Node:yoursystem Domain:localdomain Kernel Release:5.3.0-rc2+ Version: #49 SMP Mon Jul 27 10:35:32 PDT 2019
> 
> * Tasks Summary
>   -------------
>   One line of output that includes:
>   - Number of Threads
>   - Number of processes
>   - Forks since boot
>   - Processes that are runnable
>   - Processes that are in iowait

We do have sysrq+t for this kind of information. Why do we need to
duplicate it?

>   Example output when configured and enabled:
> 
> Jul 22 15:20:57 yoursystem kernel: Threads:530 Processes:279 forks_since_boot:2786 procs_runable:2 procs_iowait:0
> 
> * ARP Table and/or Neighbour Discovery Table Summary
>   --------------------------------------------------
>   One line of output each for ARP and ND that includes:
>   - Table name
>   - Table size (max # entries)
>   - Key Length
>   - Entry Size
>   - Number of Entries
>   - Last Flush (in seconds)
>   - hash grows
>   - entry allocations
>   - entry destroys
>   - Number lookups
>   - Number of lookup hits
>   - Resolution failures
>   - Garbage Collection Forced Runs
>   - Table Full
>   - Proxy Queue Length
> 
>   Example output when configured and enabled (for both):
> 
> ... kernel: neighbour: Table: arp_tbl size:   256 keyLen:  4 entrySize: 360 entries:     9 lastFlush:  1721s hGrows:     1 allocs:     9 destroys:     0 lookups:   204 hits:   199 resFailed:    38 gcRuns/Forced: 111 /  0 tblFull:  0 proxyQlen:  0
> 
> ... kernel: neighbour: Table:  nd_tbl size:   128 keyLen: 16 entrySize: 368 entries:     6 lastFlush:  1720s hGrows:     0 allocs:     7 destroys:     1 lookups:     0 hits:     0 resFailed:     0 gcRuns/Forced: 110 /  0 tblFull:  0 proxyQlen:  0

Again, why is this needed particularly for the OOM event? I do
understand this might be useful system health diagnostic information but
how does this contribute to the OOM?

> * Add Select Slabs Print
>   ----------------------
>   Allow select slab entries (based on a minimum size) to be printed.
>   Minimum size is specified as a percentage of the total RAM memory
>   in tenths of a percent, consistent with existing OOM process scoring.
>   Valid values are specified from 0 to 1000 where 0 prints all slab
>   entries (all slabs that have at least one slab object in use) up
>   to 1000 which would require a slab to use 100% of memory which can't
>   happen so in that case only summary information is printed.
> 
>   The first line of output is the standard Linux output header for
>   OOM printed Slab entries. This header looks like this:
> 
> Aug  6 09:37:21 egc103 yourserver: Unreclaimable slab info:
> 
>   The output is existing slab entry memory usage limited such that only
>   entries equal to or larger than the minimum size are printed.
>   Empty slabs (no slab entries in slabs in use) are never printed.
> 
>   Additional output consists of summary information that is printed
>   at the end of the output. This summary information includes:
>   - # entries examined
>   - # entries selected and printed
>   - minimum entry size for selection
>   - Slabs total size (kB)
>   - Slabs reclaimable size (kB)
>   - Slabs unreclaimable size (kB)
> 
>   Example Summary output when configured and enabled:
> 
> Jul 23 23:26:34 yoursystem kernel: Summary: Slab entries examined: 123 printed: 83 minsize: 0kB
> 
> Jul 23 23:26:34 yoursystem kernel: Slabs Total: 151212kB Reclaim: 50632kB Unreclaim: 100580kB

I am all for practical improvements for slab reporting. It is not really
trivial to find a good balance though. Printing all the caches simply
doesn't scale. So I would start by improving the current state rather
than adding more configurability.

> 
> * Add Select Vmalloc allocations Print
>   ------------------------------------
>   Allow select vmalloc entries (based on a minimum size) to be printed.
>   Minimum size is specified as a percentage of the total RAM memory
>   in tenths of a percent, consistent with existing OOM process scoring.
>   Valid values are specified from 0 to 1000 where 0 prints all vmalloc
>   entries (all vmalloc allocations that have at least one page in use) up
>   to 1000 which would require a vmalloc to use 100% of memory which can't
>   happen so in that case only summary information is printed.
> 
>   The first line of output is a new Vmalloc output header for
>   OOM printed Vmalloc entries. This header looks like this:
> 
> Aug 19 19:27:01 yourserver kernel: Vmalloc Info:
> 
>   The output is vmalloc entry information output limited such that only
>   entries equal to or larger than the minimum size are printed.
>   Unused vmallocs (no pages assigned to the vmalloc) are never printed.
>   The vmalloc entry information includes:
>   - Size (in bytes)
>   - pages (Number pages in use)
>   - Caller Information to identify the request
> 
>   A sample vmalloc entry output looks like this:
> 
> Jul 22 20:16:09 yoursystem kernel: Vmalloc size=2625536 pages=640 caller=__do_sys_swapon+0x78e/0x113
> 
>   Additional output consists of summary information that is printed
>   at the end of the output. This summary information includes:
>   - Number of Vmalloc entries examined
>   - Number of Vmalloc entries printed
>   - minimum entry size for selection
> 
>   A sample Vmalloc Summary output looks like this:
> 
> Aug 19 19:27:01 coronado kernel: Summary: Vmalloc entries examined: 1070 printed: 989 minsize: 0kB

This is a lot of information. I wouldn't be surprised if this alone
could easily overflow the ringbuffer. Besides that, it is rarely useful
for the OOM situation debugging. The overall size of the vmalloc area
is certainly interesting but I am not sure we have a handy counter to
cope with constrained OOM contexts.

> * Add Select Process Entries Print
>   --------------------------------
>   Allow select process entries (based on a minimum size) to be printed.
>   Minimum size is specified as a percentage totalpages (RAM + swap)
>   in tenths of a percent, consistent with existing OOM process scoring.
>   Note: user process memory can be swapped out when swap space present
>   so that is why swap space and ram memory comprise the totalpages
>   used to calculate the percentage of memory a process is using.
>   Valid values are specified from 0 to 1000 where 0 prints all user
>   processes (that have valid mm sections and aren't exiting) up to
>   1000 which would require a user process to use 100% of memory which
>   can't happen so in that case only summary information is printed.
> 
>   The first line of output is the standard Linux output headers for
>   OOM printed User Processes. This header looks like this:
> 
> Aug 19 19:27:01 yourserver kernel: Tasks state (memory values in pages):
> Aug 19 19:27:01 yourserver kernel: [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> 
>   The output is existing per user process data limited such that only
>   entries equal to or larger than the minimum size are printed.
> 
> Jul 21 20:07:48 yourserver kernel: [    579]     0   579     7942     1010          90112        0         -1000 systemd-udevd
> 
>   Additional output consists of summary information that is printed
>   at the end of the output. This summary information includes:
> 
> Aug 19 19:27:01 yourserver kernel: Summary: OOM Tasks considered:277 printed:143 minimum size:0kB totalpages:32791608kB

This sounds like a good idea to limit the eligible process list size but
I am concerned that it might get misleading easily when there are many
small processes contributing to the OOM in the end.

> * Add Enhanced Process Print Information
>   --------------------------------------
>   Add OOM Debug code that prints additional detailed information about
>   users processes that were considered for OOM killing for any print
>   selected processes. The information is displayed for each user process
>   that OOM prints in the output.
> 
>   This supplemental per user process information is very helpful for
>   determing how process memory is used to allow OOM event root cause
>   identifcation that might not otherwise be possible.
> 
>   Output information for enhanced user process entrys printed includes:
>   - pid
>   - parent pid
>   - ruid
>   - euid
>   - tgid
>   - Process State (S)
>   - utime in seconds
>   - stime in seconds
>   - oom_score_adjust
>   - task comm value (name of process)
>   - Vmem KiB
>   - MaxRss KiB
>   - CurRss KiB
>   - Pte KiB
>   - Swap KiB
>   - Sock KiB
>   - Lib KiB
>   - Text KiB
>   - Heap KiB
>   - Stack KiB
>   - File KiB
>   - Shmem KiB
>   - Read Pages
>   - Fault Pages
>   - Lock KiB
>   - Pinned KiB

I can see some of these being interesting but I would rather pick up
those and add to the regular oom output rather than go over configuring
them.

> Configuring Patches:
> -------------------
> OOM Debug and any options you want to use must first be configured so
> the code is included in your kernel. This requires selecting kernel
> config file options. You will find config options to select under:
> 
> Kernel hacking ---> Memory Debugging --->
> 
> [*] Debug OOM
>     [*] Debug OOM System State
>     [*] Debug OOM System Tasks Summary
>     [*] Debug OOM ARP Table
>     [*] Debug OOM ND Table
>     [*] Debug OOM Select Slabs Print
>        [*] Debug OOM Slabs Select Always Print Enable
>        [*] Debug OOM Enhanced Slab Print
>     [*] Debug OOM Select Vmallocs Print
>     [*] Debug OOM Select Process Print
>        [*] Debug OOM Enhanced Process Print

I really dislike these though. We already have zillions of debugging
options and the config space is enormous. Different combinations of them
make any compile testing a challenge and a lot of cpu cycles eaten.
Besides that, who is going to configure those in without using them
directly? Distributions are not going to enable without having all
options being disabled by default for example.

>  12 files changed, 1339 insertions(+), 11 deletions(-)

This must have a been a lot of work and I really appreciate that.

On the other hand it is a lot of code to maintain (note that you are
usually introspecting deep internals of subsystems so changes would
have to be carefully considered here as well) without a very strong
demand.

Sure it is a nice to have thing in some cases. I can imagine that some
of that information would have helped me when debugging some weird OOM
reports but I strongly suspect I would likely not have all necessary
pieces enabled because those were not reproducible. Having everything
on is just not usable due to amount of data. printk is not free and
we have seen cases where a lot of output just turned the machine into
unsuable state. If you have a reproducible OOMs then you can trigger
a panic and have the full state of the system to examine. So I am not
really convinced all this is going to be used to justify the maintenance
overhead.

All that being said, I do not think this is something we want to merge
without a really _strong_ usecase to back it.

Thanks!
-- 
Michal Hocko
SUSE Labs

