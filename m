Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D8AD66B0027
	for <linux-mm@kvack.org>; Fri,  6 May 2011 07:42:49 -0400 (EDT)
Date: Fri, 6 May 2011 12:42:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110506114245.GE6591@suse.de>
References: <20110428171826.GZ4658@suse.de>
 <1304015436.2598.19.camel@mulgrave.site>
 <20110428192104.GA4658@suse.de>
 <1304020767.2598.21.camel@mulgrave.site>
 <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
 <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110506074224.GB6591@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 06, 2011 at 08:42:24AM +0100, Mel Gorman wrote:
> On Tue, May 03, 2011 at 09:22:33AM -0500, James Bottomley wrote:
> > On Tue, 2011-05-03 at 09:13 -0500, James Bottomley wrote:
> > > I've got a ftrace output of kswapd ... it's 500k compressed, so I'll
> > > send under separate cover.
> > 
> > Here it is ... it's under 2.6.38.4 vanilla, but the code is similar. 
> > 
> 
> I was quiet because I was off trying to reproduce this but not having
> much luck. It doesn't seem directly related to filesystems or
> cgroups. For example, here is what I see with ext4 without cgroups
> 
>                 2.6.34-vanilla    2.6.37-vanilla    2.6.38-vanilla       rc6-vanilla
> download tar           70 ( 0.00%)   68 ( 2.94%)   69 ( 1.45%)   70 ( 0.00%)
> unpack tar            601 ( 0.00%)  605 (-0.66%)  604 (-0.50%)  605 (-0.66%)
> copy source files     319 ( 0.00%)  321 (-0.62%)  320 (-0.31%)  332 (-3.92%)
> create tarfile       1368 ( 0.00%) 1372 (-0.29%) 1371 (-0.22%) 1363 ( 0.37%)
> delete source dirs     21 ( 0.00%)   21 ( 0.00%)   23 (-8.70%)   22 (-4.55%)
> expand tar            263 ( 0.00%)  261 ( 0.77%)  257 ( 2.33%)  259 ( 1.54%)
> 
> (all results are in seconds)
> 
> When running in cgroups, the results are similar - bit slower but
> not remarkably so. ext3 is slower but not enough to count as the bug.
> 
> The trace you posted is very short but kswapd is not going to sleep
> in it. It's less than a seconds worth on different cpus so it's hard
> to draw any conclusion from it other than sleeping_prematurely()
> is often deciding that kswapd should not sleep.
> 
> So lets consider what keeps it awake.
> 
> 1. High-order allocations? You machine is using i915 and RPC, something
>    neither of my test machine uses. i915 is potentially a source for
>    high-order allocations. I'm attaching a perl script. Please run it as
>    ./watch-highorder.pl --output /tmp/highorders.txt
>    while you are running tar. When kswapd is running for about 30
>    seconds, interrupt it with ctrl+c twice in quick succession and
>    post /tmp/highorders.txt
> 
> 2. All unreclaimable is not being set or we are not balancing at all.
>    Can you post the output of sysrq+m while the machine is struggling
>    please?
> 
> 3. Slab may not be shrinking for some reason. Can you run a shell
>    script like this during the whole test and record its output please?
> 
>    #!/bin/bash
>    while [ 1 ]; do
> 	   echo time: `date +%s`
> 	   cat /proc/vmstat
> 	   sleep 2
>    done
> 
>    Similarly if this is a slab issue, it'd be nice to know who it is so
> 
>    #!/bin/bash
>    while [ 1 ]; do
> 	   echo time: `date +%s`
> 	   cat /proc/slabinfo
> 	   sleep $MONITOR_UPDATE_FREQUENCY
>    done
> 
> 4. Lets get a better look at what is going on in kswapd
> 
>    echo 1 > /sys/kernel/debug/tracing/events/vmscan/enable
>    cat /sys/kernel/debug/tracing/trace_pipe > vmscan-ftrace.txt
> 

Also, could you test the patch at https://lkml.org/lkml/2011/3/5/121
please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
