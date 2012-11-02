Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6C84A6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 14:00:34 -0400 (EDT)
Date: Fri, 2 Nov 2012 19:00:32 +0100
From: Marc Duponcheel <marc@offline.be>
Subject: Re: [Bug 49361] New: configuring TRANSPARENT_HUGEPAGE_ALWAYS can
 make system unresponsive and reboot
Message-ID: <20121102180032.GA26700@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
References: <bug-49361-27@https.bugzilla.kernel.org/>
 <20121023123613.1bcdf3ab.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1210232242590.22652@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210291216330.15340@chino.kir.corp.google.com>
 <20121101171406.GC8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121101171406.GC8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Marc Duponcheel <marc@offline.be>

 Hi Mel

 Thanks for your interest.

  it is 3.6.2 that I tested

 I am not sure when TRANSPARENT_HUGEPAGE_ALWAYS was introduced but it
could be that the problem started first time I had it configured.

 In any case, I think I saw problem first on 3.6.0 or 3.5.x that came
just before 3.6.0

 Looking into logs: first time it happened was on Oct 7. But I am not
sure what exact kernel I was running then (it -could- have been
3.5.6).

 I sincerely hope this helps ...

 As mentioned, reproduction is not hard.

 Also: I can grant ssh access for you to troubleshoot.

 Have a nice day

On 2012 Nov 01, Mel Gorman wrote:
> On Mon, Oct 29, 2012 at 01:33:06PM -0700, David Rientjes wrote:
> > On Tue, 23 Oct 2012, David Rientjes wrote:
> > 
> > > We'll need to collect some information before we can figure out what the 
> > > problem is with 3.5.2.
> > > 
> 
> 3.6.2 or 3.5.2?
> 
> The bug mentioned "recently" but does not say what the last known
> working kernel was. What is the most recent working kernel so the
> problem candidate can be narrowed down?
> 
> > > First, let's take a look at khugepaged.  By default, it's supposed to wake 
> > > up rarely (10s at minimum) and only scan 4K pages before going back to 
> > > sleep.  Having a consistent and very high cpu usage suggests the settings 
> > > aren't the default.  Can you do
> > > 
> > > 	cat /sys/kernel/mm/transparent_hugepage/khugepaged/{alloc,scan}_sleep_millisecs
> > > 
> > > The defaults should be 60000 and 10000, respectively.  Then can you do
> > > 
> > > 	cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> > > 
> > > which should be 4096.  If those are your settings, then it seems like 
> > > khugepaged in 3.5.2 is going crazy and we'll need to look into that.  Try 
> > > collecting
> > > 
> > > 	grep -e "thp|compact" /proc/vmstat
> > > 
> > > and
> > > 
> > > 	cat /proc/$(pidof khugepaged)/stack
> > > 
> > > appended to a logfile at regular intervals after your start the build with 
> > > transparent hugepages enabled always.  After the machine becomes 
> > > unresponsive and reboots, post that log.
> > > 
> > 
> > This looks like an overly aggressive memory compaction issue; consider 
> > from your "49361.1" attachment:
> > 
> > Sat Oct 27 02:39:05 CEST 2012
> > 	compact_blocks_moved 488381
> > 	compact_pages_moved 581856
> > 	compact_pagemigrate_failed 52533
> > 	compact_stall 59
> > 	compact_fail 36
> > 	compact_success 23
> > Sat Oct 27 02:39:15 CEST 2012
> > 	compact_blocks_moved 7797480
> > 	compact_pages_moved 589996
> > 	compact_pagemigrate_failed 53507
> > 	compact_stall 90
> > 	compact_fail 56
> > 	compact_success 24
> > Sat Oct 27 02:43:07 CEST 2012
> > 	compact_blocks_moved 276422153
> > 	compact_pages_moved 597836
> > 	compact_pagemigrate_failed 53886
> > 	compact_stall 109
> > 	compact_fail 76
> > 	compact_success 26
> > 
> > In four minutes, transparent hugepage allocation has scanned 275933772 2MB 
> > pageblocks and only been successful three times in defragmenting enough 
> > memory for the allocation to succeed.  It's scanning on average 5518675 
> > pageblocks each time it is invoked.
> > 
> 
> We had the bug recently about excessive scanning and lock contention
> within compaction after lumpy reclaim was removed between 3.4 and 3.5.
> The impact was not obvious because compaction was used less frequently
> when lumpy reclaim was in place but once the crutch went away, it fell
> over. The "solution" as it stands right now is the following patches on
> top of 3.6. Can they be tested please?
> 
> e64c5237cf6ff474cb2f3f832f48f2b441dd9979 mm: compaction: abort compaction loop if lock is contended or run too long
> 3cc668f4e30fbd97b3c0574d8cac7a83903c9bc7 mm: compaction: move fatal signal check out of compact_checklock_irqsave
> 661c4cb9b829110cb68c18ea05a56be39f75a4d2 mm: compaction: Update try_to_compact_pages()kerneldoc comment
> 2a1402aa044b55c2d30ab0ed9405693ef06fb07c mm: compaction: acquire the zone->lru_lock as late as possible
> f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e mm: compaction: acquire the zone->lock as late as possible
> 753341a4b85ff337487b9959c71c529f522004f4 revert "mm: have order > 0 compaction start off where it left"
> bb13ffeb9f6bfeb301443994dfbf29f91117dfb3 mm: compaction: cache if a pageblock was scanned and no pages were isolated
> c89511ab2f8fe2b47585e60da8af7fd213ec877e mm: compaction: Restart compaction from near where it left off
> 62997027ca5b3d4618198ed8b1aba40b61b1137b mm: compaction: clear PG_migrate_skip based on compaction and reclaim activity
> 0db63d7e25f96e2c6da925c002badf6f144ddf30 mm: compaction: correct the nr_strict va isolated check for CMA
> 
> I can provide a monolithic patch of these commits if that is preferred.
> 
> > Adding Mel Gorman to the cc.
> 
> Thanks David.
> 
> -- 
> Mel Gorman
> SUSE Labs

--
 Marc Duponcheel
 Velodroomstraat 74 - 2600 Berchem - Belgium
 +32 (0)478 68.10.91 - marc@offline.be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
