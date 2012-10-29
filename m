Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9274D6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 16:33:09 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4926964pbb.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 13:33:08 -0700 (PDT)
Date: Mon, 29 Oct 2012 13:33:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 49361] New: configuring TRANSPARENT_HUGEPAGE_ALWAYS can
 make system unresponsive and reboot
In-Reply-To: <alpine.DEB.2.00.1210232242590.22652@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1210291216330.15340@chino.kir.corp.google.com>
References: <bug-49361-27@https.bugzilla.kernel.org/> <20121023123613.1bcdf3ab.akpm@linux-foundation.org> <alpine.DEB.2.00.1210232242590.22652@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: marc@offline.be, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Tue, 23 Oct 2012, David Rientjes wrote:

> We'll need to collect some information before we can figure out what the 
> problem is with 3.5.2.
> 
> First, let's take a look at khugepaged.  By default, it's supposed to wake 
> up rarely (10s at minimum) and only scan 4K pages before going back to 
> sleep.  Having a consistent and very high cpu usage suggests the settings 
> aren't the default.  Can you do
> 
> 	cat /sys/kernel/mm/transparent_hugepage/khugepaged/{alloc,scan}_sleep_millisecs
> 
> The defaults should be 60000 and 10000, respectively.  Then can you do
> 
> 	cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> 
> which should be 4096.  If those are your settings, then it seems like 
> khugepaged in 3.5.2 is going crazy and we'll need to look into that.  Try 
> collecting
> 
> 	grep -e "thp|compact" /proc/vmstat
> 
> and
> 
> 	cat /proc/$(pidof khugepaged)/stack
> 
> appended to a logfile at regular intervals after your start the build with 
> transparent hugepages enabled always.  After the machine becomes 
> unresponsive and reboots, post that log.
> 

This looks like an overly aggressive memory compaction issue; consider 
from your "49361.1" attachment:

Sat Oct 27 02:39:05 CEST 2012
	compact_blocks_moved 488381
	compact_pages_moved 581856
	compact_pagemigrate_failed 52533
	compact_stall 59
	compact_fail 36
	compact_success 23
Sat Oct 27 02:39:15 CEST 2012
	compact_blocks_moved 7797480
	compact_pages_moved 589996
	compact_pagemigrate_failed 53507
	compact_stall 90
	compact_fail 56
	compact_success 24
Sat Oct 27 02:43:07 CEST 2012
	compact_blocks_moved 276422153
	compact_pages_moved 597836
	compact_pagemigrate_failed 53886
	compact_stall 109
	compact_fail 76
	compact_success 26

In four minutes, transparent hugepage allocation has scanned 275933772 2MB 
pageblocks and only been successful three times in defragmenting enough 
memory for the allocation to succeed.  It's scanning on average 5518675 
pageblocks each time it is invoked.

And then, from your "49361.2" attachment:

Sat Oct 27 02:48:30 CEST 2012
	compact_blocks_moved 504039382
	compact_pages_moved 776820
	compact_pagemigrate_failed 58437
	compact_stall 209
	compact_fail 163
	compact_success 36
...
Sat Oct 27 02:51:50 CEST 2012
	compact_blocks_moved 722746600
	compact_pages_moved 776820
	compact_pagemigrate_failed 58437
	compact_stall 209
	compact_fail 173
	compact_success 36

For more than three minutes, compact_stall does not increase but 
compact_fail does (and compact_blocks_moved increases 43%), which suggests 
deferred compaction is kicking in but for some reason we are still 
scanning like crazy.

Reading the code, the only way this can happen is if nr_remaining is 
always 0 (compact_pagemigrate_failed never increases), but also nr_migrate 
is always 0 (compact_pages_moved never increases).  So I think we're stuck 
in the while loop in compact_zone() and are constantly calling 
migrate_pages().  compact_finished() must be returning COMPACT_CONTINUE 
even though cc->nr_migratepages == 0?

Adding Mel Gorman to the cc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
