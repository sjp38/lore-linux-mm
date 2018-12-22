Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69CBE8E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 07:08:35 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so8935409eda.12
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 04:08:35 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id b4-v6si9433537ejd.235.2018.12.22.04.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Dec 2018 04:08:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id E12C01C34C9
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 12:08:32 +0000 (GMT)
Date: Sat, 22 Dec 2018 12:08:31 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [LKP] [mm] ac5b2c1891: vm-scalability.throughput -61.3%
 regression
Message-ID: <20181222120831.GC31517@techsingularity.net>
References: <CAHk-=wjm9V843eg0uesMrxKnCCq7UfWn8VJ+z-cNztb_0fVW6A@mail.gmail.com>
 <alpine.DEB.2.21.1812061505010.162675@chino.kir.corp.google.com>
 <CAHk-=wjVuLjZ1Wr52W=hNqh=_8gbzuKA+YpsVb4NBHCJsE6cyA@mail.gmail.com>
 <alpine.DEB.2.21.1812091538310.215735@chino.kir.corp.google.com>
 <20181210044916.GC24097@redhat.com>
 <alpine.DEB.2.21.1812111609060.255489@chino.kir.corp.google.com>
 <0bbf4202-6187-28fb-37b7-da6885b89cce@suse.cz>
 <alpine.DEB.2.21.1812141244450.186427@chino.kir.corp.google.com>
 <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
 <alpine.DEB.2.21.1812211416020.219499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1812211416020.219499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, s.priebe@profihost.ag, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, alex.williamson@redhat.com, lkp@01.org, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, zi.yan@cs.rutgers.edu, Linux-MM layout <linux-mm@kvack.org>

On Fri, Dec 21, 2018 at 02:18:45PM -0800, David Rientjes wrote:
> On Fri, 14 Dec 2018, Vlastimil Babka wrote:
> 
> > > It would be interesting to know if anybody has tried using the per-zone 
> > > free_area's to determine migration targets and set a bit if it should be 
> > > considered a migration source or a migration target.  If all pages for a 
> > > pageblock are not on free_areas, they are fully used.
> > 
> > Repurposing/adding a new pageblock bit was in my mind to help multiple
> > compactors not undo each other's work in the scheme where there's no
> > free page scanner, but I didn't implement it yet.
> > 
> 
> It looks like Mel has a series posted that still is implemented with 
> linear scans through memory, so I'm happy to move the discussion there; I 
> think the goal for compaction with regard to this thread is determining 
> whether reclaim in the page allocator would actually be useful and 
> targeted reclaim to make memory available for isolate_freepages() could be 
> expensive.  I'd hope that we could move in a direction where compaction 
> doesn't care where the pageblock is and does the minimal amount of work 
> possible to make a high-order page available, not sure if that's possible 
> with a linear scan.  I'll take a look at Mel's series though.

That series has evolved significantly because there was a lot of missing
pieces. While it's somewhat ready other than badly written changelogs, I
didn't post it because I'm going offline and wouldn't respond to feedback
and I imagine others are offline too and unavailable for review. Besides,
the merge window is about to open and I know there are patches in Andrews
tree for mainline that should be taken into account.

The series is now 25 patches long and covers a lot of pre-requisites that
would be necessary before removing the linear scanner. What is critical
for a purely free-list scanner is that the exit conditions are identified
and the series provides a lot of the pieces. For example, a non-linear
scanner must properly control skip bits and isolate pageblocks from
multiple compaction instances which this series does.

The main takeawy from the series is that it reduces system CPU usage by
17%, reduces free scan rates by 99.5% and increases THP allocation success
rates by 33% giving almost 99% allocation success rates. It also;

o Isolates pageblocks for a single compaction instance
o Synchronises async/sync scanners when appropriate to reduce rescanning
o Identifies when a pageblock is being rescanned and is "sticky" and
  makes forward progress instead of looping excessively
o Smarter logic when clearing pageblock skip bits so reduce scanning
o Various different methods for reducing unnecessary scanning
o Better handling of contention
o Avoids compaction of remote nodes in direct compaction context

If you do not want to wait until the new year, it's at
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-fast-compact-v2r15

Preliminary results based on thpscale using MADV_HUGEPAGE to allocate
huge pages on a fragmented system.

thpscale Fault Latencies
                                    4.20.0-rc6             4.20.0-rc6
                                mmotm-20181210         noremote-v2r14
Amean     fault-both-1       864.83 (   0.00%)     1006.88 * -16.43%*
Amean     fault-both-3      3566.05 (   0.00%)     2460.97 *  30.99%*
Amean     fault-both-5      5685.02 (   0.00%)     4052.92 *  28.71%*
Amean     fault-both-7      7289.40 (   0.00%)     5929.65 (  18.65%)
Amean     fault-both-12    10937.46 (   0.00%)     8870.53 (  18.90%)
Amean     fault-both-18    15440.48 (   0.00%)    11464.86 *  25.75%*
Amean     fault-both-24    15345.83 (   0.00%)    13040.01 *  15.03%*
Amean     fault-both-30    20159.73 (   0.00%)    16618.73 *  17.56%*
Amean     fault-both-32    20843.51 (   0.00%)    14401.25 *  30.91%*

Fault latency (either huge or base) is mostly improved even when 32
tasks are trying to allocate huge pages on an 8-CPU single socket
machine where contention is a factor

thpscale Percentage Faults Huge
                               4.20.0-rc6             4.20.0-rc6
                           mmotm-20181210         noremote-v2r14
Percentage huge-1        96.03 (   0.00%)       96.94 (   0.95%)
Percentage huge-3        71.43 (   0.00%)       95.43 (  33.60%)
Percentage huge-5        70.44 (   0.00%)       96.85 (  37.48%)
Percentage huge-7        70.39 (   0.00%)       94.77 (  34.63%)
Percentage huge-12       71.53 (   0.00%)       98.07 (  37.11%)
Percentage huge-18       70.61 (   0.00%)       98.42 (  39.38%)
Percentage huge-24       71.84 (   0.00%)       97.85 (  36.20%)
Percentage huge-30       69.94 (   0.00%)       98.13 (  40.31%)
Percentage huge-32       66.92 (   0.00%)       97.79 (  46.13%)

96-98% of THP requests get huge pages on request

         4.20.0-rc6  4.20.0-rc6
       mmotm-20181210noremote-v2r14
User          27.30       27.86
System       192.70      159.42
Elapsed      580.13      571.98

System CPU usage is reduced so we get more huge pages for less work and
the workload completes slightly faster.

                               4.20.0-rc6     4.20.0-rc6
                           mmotm-20181210 noremote-v2r14
Allocation stalls                19156.00        3627.00

Fewer stalls which is always a plus.

THP fault alloc                  77804.00       84618.00
THP fault fallback                7628.00         816.00
THP collapse alloc                  12.00           0.00
THP collapse fail                    0.00           0.00
THP split                        56921.00       56920.00
THP split failed                  1982.00         116.00
Compaction stalls                36350.00       25541.00
Compaction success               17491.00       22651.00
Compaction failures              18859.00        2890.00
Compaction efficiency               48.12          88.68

Compaction efficiency is increased a lot (efficiency is a basic measure
of success vs failure). Previously almost half of the THP requests failed.

Page migrate success          10200844.00     7802473.00
Page migrate failure              3703.00         409.00
Compaction pages isolated     23093029.00    16532642.00
Compaction migrate scanned    28454655.00     8976143.00
Compaction free scanned      717517120.00     3632762.00
Compact scan efficiency              3.97         247.09

Migration scanning is down 32%, free scanning is down 99.5%. Scan efficiency
is interesting because it's a measure of how many pages the free scanner
examines for one migration source. Before the series, we had to scan *way*
more pages to find a free page where as now we scan *fewer* pages to find
a migration target due to the use of free lists.

Kcompactd wake                       1.00           9.00
Kcompactd migrate scanned        14023.00       13318.00
Kcompactd free scanned            6932.00        6643.00

Minor improvements for kcompactd but for this workload, it was barely
active.

I'll rebase and repost in the new year and I think it should be considered
a prerequisite before considering the removal of the linear scanning.
It'll be impossible to remove completely due to memory isoluation. If
built on this series I would imagine that it would take the following
approach.

o The migration scanner remains linear or mostly linear (series uses
  free page lists to get hints on where suitable migration sources are)
o The free scanner would be purely based on the free lists i.e.
  fast_isolate_freepages would be the only scanner
o The migration scanner would need to be strict about obeying the skip
  bit to avoid picking a migration source that was previously a
  migration target
o The exit condition for compaction is not when scanners meet but when
  fast_isolate_freepages cannot find any pageblock that is
  MIGRATE_MOVABLE && !pageblock_skip

-- 
Mel Gorman
SUSE Labs
