Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4F26B6B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:32:35 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/50] Basic scheduler support for automatic NUMA balancing V7
Date: Tue, 10 Sep 2013 10:31:40 +0100
Message-Id: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It has been a long time since V6 of this series and time for an update. Much
of this is now stabilised with the most important addition being the inclusion
of Peter and Rik's work on grouping tasks that share pages together.

This series has a number of goals. It reduces overhead of automatic balancing
through scan rate reduction and the avoidance of TLB flushes. It selects a
preferred node and moves tasks towards their memory as well as moving memory
toward their task. It handles shared pages and groups related tasks together.

Changelog since V6
o Group tasks that share pages together
o More scan avoidance of VMAs mapping pages that are not likely to migrate
o cpunid conversion, system-wide searching of tasks to balance with

Changelog since V6
o Various TLB flush optimisations
o Comment updates
o Sanitise task_numa_fault callsites for consistent semantics
o Revert some of the scanning adaption stuff
o Revert patch that defers scanning until task schedules on another node
o Start delayed scanning properly
o Avoid the same task always performing the PTE scan
o Continue PTE scanning even if migration is rate limited

Changelog since V5
o Add __GFP_NOWARN for numa hinting fault count
o Use is_huge_zero_page
o Favour moving tasks towards nodes with higher faults
o Optionally resist moving tasks towards nodes with lower faults
o Scan shared THP pages

Changelog since V4
o Added code that avoids overloading preferred nodes
o Swap tasks if nodes are overloaded and the swap does not impair locality

Changelog since V3
o Correct detection of unset last nid/pid information
o Dropped nr_preferred_running and replaced it with Peter's load balancing
o Pass in correct node information for THP hinting faults
o Pressure tasks sharing a THP page to move towards same node
o Do not set pmd_numa if false sharing is detected

Changelog since V2
o Reshuffle to match Peter's implied preference for layout
o Reshuffle to move private/shared split towards end of series to make it
  easier to evaluate the impact
o Use PID information to identify private accesses
o Set the floor for PTE scanning based on virtual address space scan rates
  instead of time
o Some locking improvements
o Do not preempt pinned tasks unless they are kernel threads

Changelog since V1
o Scan pages with elevated map count (shared pages)
o Scale scan rates based on the vsz of the process so the sampling of the
  task is independant of its size
o Favour moving towards nodes with more faults even if it's not the
  preferred node
o Laughably basic accounting of a compute overloaded node when selecting
  the preferred node.
o Applied review comments

This series integrates basic scheduler support for automatic NUMA balancing.
It borrows very heavily from Peter Ziljstra's work in "sched, numa, mm:
Add adaptive NUMA affinity support" but deviates too much to preserve
Signed-off-bys. As before, if the relevant authors are ok with it I'll
add Signed-off-bys (or add them yourselves if you pick the patches up).

There are still gaps between this series and manual binding but it's still
an important series of steps in the right direction and the size of the
series is getting unwieldly. As before, the intention is not to complete
the work but to incrementally improve mainline and preserve bisectability
for any bug reports that crop up.

Patch 1 is a monolothic dump of patches thare are destined for upstream that
	this series indirectly depends upon.

Patches 2-3 adds sysctl documentation and comment fixlets

Patch 4 avoids accounting for a hinting fault if another thread handled the
	fault in parallel

Patches 5-6 avoid races with parallel THP migration and THP splits.

Patch 7 corrects a THP NUMA hint fault accounting bug

Patch 8 sanitizes task_numa_fault callsites to have consist semantics and
	always record the fault based on the correct location of the page.

Patch 9 avoids trying to migrate the THP zero page

Patch 10 avoids the same task being selected to perform the PTE scan within
	a shared address space.

Patch 11 continues PTE scanning even if migration rate limited

Patch 12 notes that delaying the PTE scan until a task is scheduled on an
	alternatie node misses the case where the task is only accessing
	shared memory on a partially loaded machine and reverts a patch.

Patches 13,15 initialses numa_next_scan properly so that PTE scanning is delayed
	when a process starts.

Patch 14 sets the scan rate proportional to the size of the task being
	scanned.

Patches 16-17 avoids TLB flushes during the PTE scan if no updates are made

Patch 18 slows the scan rate if no hinting faults were trapped by an idle task.

Patch 19 tracks NUMA hinting faults per-task and per-node

Patches 20-24 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node. When initially selected the task is rescheduled on
	the preferred node if it is not running on that node already. This
	avoids waiting for the scheduler to move the task slowly.

Patch 25 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 26 avoids some unnecessary allocation

Patch 27-28 kicks away some training wheels and scans shared pages and
	small VMAs.

Patch 29 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently.

Patch 30 avoids migrating memory immediately after the load balancer moves
	a task to another node in case it's a transient migration.

Patch 31 pick the least loaded CPU based on a preferred node based on
	a scheduling domain common to both the source and destination
	NUMA node.

Patch 32 retries task migration if an earlier attempt failed

Patch 33 will begin task migration immediately if running on its preferred
	node

Patch 34 will avoid trapping hinting faults for shared read-only library
	pages as these never migrate anyway

Patch 35 avoids handling pmd hinting faults if none of the ptes below it were
	marked pte numa

Patches 36-37 introduce a mechanism for swapping tasks

Patch 38 uses a system-wide search to find tasks that can be swapped
	to improve the overall locality of the system.

Patch 39 notes that the system-wide search may ignore the preferred node and
	will use the preferred node placement if it has spare compute
	capacity.

Patches 40-42 use cpupid to track pages so potential sharing tasks can
	be quickly found

Patches 43-44 avoids grouping based on read-only pages

Patches 45-46 schedules tasks based on their numa group

Patch 47 adds some debugging aids

Patches 48-49 separately considers task and group weights when selecting the node to
	schedule a task on

Patch 50 avoids migrating tasks away from their preferred node.

Kernel 3.11-rc7 is the testing baseline.

o account-v7		Patches 1-7
o lesspmd-v7		Patches 1-35
o selectweight-v7	Patches 1-49
o avoidmove-v7		Patches 1-50

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system.

specjbb

                   3.11.0-rc7            3.11.0-rc7            3.11.0-rc7            3.11.0-rc7
                account-v7            lesspmd-v7       selectweight-v7          avoidmove-v7   
TPut 1      26483.00 (  0.00%)     26691.00 (  0.79%)     26618.00 (  0.51%)     25450.00 ( -3.90%)
TPut 2      55009.00 (  0.00%)     54744.00 ( -0.48%)     53200.00 ( -3.29%)     53998.00 ( -1.84%)
TPut 3      86711.00 (  0.00%)     85564.00 ( -1.32%)     86547.00 ( -0.19%)     85424.00 ( -1.48%)
TPut 4     108073.00 (  0.00%)    112757.00 (  4.33%)    111408.00 (  3.09%)    113522.00 (  5.04%)
TPut 5     138128.00 (  0.00%)    137733.00 ( -0.29%)    140797.00 (  1.93%)    140930.00 (  2.03%)
TPut 6     161949.00 (  0.00%)    164499.00 (  1.57%)    164759.00 (  1.74%)    161916.00 ( -0.02%)
TPut 7     185205.00 (  0.00%)    190214.00 (  2.70%)    189409.00 (  2.27%)    191425.00 (  3.36%)
TPut 8     214152.00 (  0.00%)    216550.00 (  1.12%)    219510.00 (  2.50%)    217374.00 (  1.50%)
TPut 9     245408.00 (  0.00%)    242975.00 ( -0.99%)    241001.00 ( -1.80%)    243116.00 ( -0.93%)
TPut 10    262786.00 (  0.00%)    267812.00 (  1.91%)    260897.00 ( -0.72%)    267728.00 (  1.88%)
TPut 11    293162.00 (  0.00%)    299621.00 (  2.20%)    291130.00 ( -0.69%)    300006.00 (  2.33%)
TPut 12    310423.00 (  0.00%)    317867.00 (  2.40%)    307821.00 ( -0.84%)    317531.00 (  2.29%)
TPut 13    328542.00 (  0.00%)    347286.00 (  5.71%)    327800.00 ( -0.23%)    344849.00 (  4.96%)
TPut 14    362081.00 (  0.00%)    374173.00 (  3.34%)    342014.00 ( -5.54%)    366256.00 (  1.15%)
TPut 15    374475.00 (  0.00%)    393658.00 (  5.12%)    348941.00 ( -6.82%)    376056.00 (  0.42%)
TPut 16    407367.00 (  0.00%)    409212.00 (  0.45%)    361272.00 (-11.32%)    409353.00 (  0.49%)
TPut 17    423282.00 (  0.00%)    424424.00 (  0.27%)    377808.00 (-10.74%)    410761.00 ( -2.96%)
TPut 18    447960.00 (  0.00%)    456736.00 (  1.96%)    392421.00 (-12.40%)    437756.00 ( -2.28%)
TPut 19    449296.00 (  0.00%)    475797.00 (  5.90%)    404142.00 (-10.05%)    446286.00 ( -0.67%)
TPut 20    480073.00 (  0.00%)    487883.00 (  1.63%)    414085.00 (-13.75%)    453840.00 ( -5.46%)
TPut 21    476891.00 (  0.00%)    505589.00 (  6.02%)    422953.00 (-11.31%)    458974.00 ( -3.76%)
TPut 22    492092.00 (  0.00%)    503878.00 (  2.40%)    433232.00 (-11.96%)    461927.00 ( -6.13%)
TPut 23    500602.00 (  0.00%)    523202.00 (  4.51%)    433320.00 (-13.44%)    454256.00 ( -9.26%)
TPut 24    500408.00 (  0.00%)    509350.00 (  1.79%)    441878.00 (-11.70%)    460559.00 ( -7.96%)
TPut 25    503390.00 (  0.00%)    521126.00 (  3.52%)    454313.00 ( -9.75%)    468970.00 ( -6.84%)
TPut 26    514905.00 (  0.00%)    523315.00 (  1.63%)    453013.00 (-12.02%)    455508.00 (-11.54%)
TPut 27    513125.00 (  0.00%)    529317.00 (  3.16%)    461561.00 (-10.05%)    463229.00 ( -9.72%)
TPut 28    508313.00 (  0.00%)    540357.00 (  6.30%)    460727.00 ( -9.36%)    452718.00 (-10.94%)
TPut 29    514726.00 (  0.00%)    534836.00 (  3.91%)    451867.00 (-12.21%)    449201.00 (-12.73%)
TPut 30    509362.00 (  0.00%)    526295.00 (  3.32%)    453946.00 (-10.88%)    444615.00 (-12.71%)
TPut 31    506812.00 (  0.00%)    532603.00 (  5.09%)    448303.00 (-11.54%)    450953.00 (-11.02%)
TPut 32    500600.00 (  0.00%)    524926.00 (  4.86%)    452692.00 ( -9.57%)    432748.00 (-13.55%)
TPut 33    491116.00 (  0.00%)    525059.00 (  6.91%)    436046.00 (-11.21%)    433109.00 (-11.81%)
TPut 34    483206.00 (  0.00%)    508843.00 (  5.31%)    440762.00 ( -8.78%)    408980.00 (-15.36%)
TPut 35    489281.00 (  0.00%)    504354.00 (  3.08%)    423368.00 (-13.47%)    408371.00 (-16.54%)
TPut 36    480259.00 (  0.00%)    489147.00 (  1.85%)    415108.00 (-13.57%)    397698.00 (-17.19%)
TPut 37    474611.00 (  0.00%)    497076.00 (  4.73%)    411894.00 (-13.21%)    396970.00 (-16.36%)
TPut 38    470478.00 (  0.00%)    487195.00 (  3.55%)    407295.00 (-13.43%)    389028.00 (-17.31%)
TPut 39    437255.00 (  0.00%)    477739.00 (  9.26%)    413837.00 ( -5.36%)    391655.00 (-10.43%)
TPut 40    463513.00 (  0.00%)    473658.00 (  2.19%)    407789.00 (-12.02%)    383771.00 (-17.20%)
TPut 41    426922.00 (  0.00%)    446614.00 (  4.61%)    384862.00 ( -9.85%)    376937.00 (-11.71%)
TPut 42    423707.00 (  0.00%)    442783.00 (  4.50%)    393131.00 ( -7.22%)    389373.00 ( -8.10%)
TPut 43    443489.00 (  0.00%)    444903.00 (  0.32%)    375795.00 (-15.26%)    377239.00 (-14.94%)
TPut 44    415987.00 (  0.00%)    432628.00 (  4.00%)    367343.00 (-11.69%)    383026.00 ( -7.92%)
TPut 45    409382.00 (  0.00%)    424978.00 (  3.81%)    364387.00 (-10.99%)    385429.00 ( -5.85%)
TPut 46    402538.00 (  0.00%)    393039.00 ( -2.36%)    359730.00 (-10.63%)    370411.00 ( -7.98%)
TPut 47    373125.00 (  0.00%)    406744.00 (  9.01%)    342382.00 ( -8.24%)    375368.00 (  0.60%)
TPut 48    405485.00 (  0.00%)    421600.00 (  3.97%)    347063.00 (-14.41%)    400586.00 ( -1.21%)

So this is somewhat of a bad start. The initial bulk of the patches help
but the grouping code did not work out as well. This tends to be a bit
variable as a re-run sometimes behaves very differently. Modelling the task
groupings show that threads in the same task group are still scheduled to
run on CPUs from different nodes so more work is needed there.

specjbb Peaks
                                  3.11.0-rc7                 3.11.0-rc7                 3.11.0-rc7                 3.11.0-rc7
                               account-v7                 lesspmd-v7            selectweight-v7               avoidmove-v7   
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        373125.00 (  0.00%)        406744.00 (  9.01%)        342382.00 ( -8.24%)        375368.00 (  0.60%)
 Actual Warehouse            27.00 (  0.00%)            29.00 (  7.41%)            28.00 (  3.70%)            26.00 ( -3.70%)
 Actual Peak Bops        514905.00 (  0.00%)        540357.00 (  4.94%)        461561.00 (-10.36%)        468970.00 ( -8.92%)
 SpecJBB Bops              8275.00 (  0.00%)          8604.00 (  3.98%)          7083.00 (-14.40%)          8175.00 ( -1.21%)
 SpecJBB Bops/JVM          8275.00 (  0.00%)          8604.00 (  3.98%)          7083.00 (-14.40%)          8175.00 ( -1.21%)

The actual specjbb score for the overall series does not look as bad
as the raw figures illustrate.

          3.11.0-rc7  3.11.0-rc7  3.11.0-rc7  3.11.0-rc7
        account-v7   lesspmd-v7   selectweight-v7   avoidmove-v7   
User        43513.28    44403.17    44513.42    44406.55
System        871.01      122.46      107.05      116.15
Elapsed      1665.24     1664.94     1665.03     1665.06

A big positive at least is that system CPU overhead is slashed.

                            3.11.0-rc7  3.11.0-rc7  3.11.0-rc7  3.11.0-rc7
                          account-v7   lesspmd-v7   selectweight-v7   avoidmove-v7   
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success         133385393    14958732     9859116    12092458
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                 138454       15527       10233       12551
NUMA PTE updates              19952605      712634      674115      730464
NUMA hint faults               4113211      710022      668011      729294
NUMA hint local faults         1197939      274740      251230      273679
NUMA hint local percent             29          38          37          37
NUMA pages migrated          133385393    14958732     9859116    12092458
AutoNUMA cost                    23240        3839        3532        3881

And the source of the reduction is obvious here from the much smaller
number of PTE updates and hinting faults.


This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running per node on the system.

specjbb
                     3.11.0-rc7            3.11.0-rc7            3.11.0-rc7            3.11.0-rc7
                  account-v7            lesspmd-v7       selectweight-v7          avoidmove-v7   
Mean   1      29995.75 (  0.00%)     30321.50 (  1.09%)     29457.25 ( -1.80%)     30791.75 (  2.65%)
Mean   2      62699.25 (  0.00%)     60564.75 ( -3.40%)     59721.00 ( -4.75%)     61050.00 ( -2.63%)
Mean   3      88312.75 (  0.00%)     89286.50 (  1.10%)     88451.50 (  0.16%)     90461.75 (  2.43%)
Mean   4     117827.00 (  0.00%)    115583.00 ( -1.90%)    116043.00 ( -1.51%)    114945.75 ( -2.45%)
Mean   5     139419.00 (  0.00%)    137869.25 ( -1.11%)    137761.00 ( -1.19%)    136841.25 ( -1.85%)
Mean   6     156185.25 (  0.00%)    155811.50 ( -0.24%)    151628.50 ( -2.92%)    149850.25 ( -4.06%)
Mean   7     162258.25 (  0.00%)    160665.25 ( -0.98%)    154775.25 ( -4.61%)    154356.25 ( -4.87%)
Mean   8     160665.00 (  0.00%)    160376.75 ( -0.18%)    150849.00 ( -6.11%)    154266.50 ( -3.98%)
Mean   9     156048.00 (  0.00%)    159689.75 (  2.33%)    150347.00 ( -3.65%)    150804.75 ( -3.36%)
Mean   10    144640.75 (  0.00%)    153683.50 (  6.25%)    146165.50 (  1.05%)    143256.00 ( -0.96%)
Mean   11    136418.75 (  0.00%)    146141.75 (  7.13%)    139216.75 (  2.05%)    137435.00 (  0.74%)
Mean   12    132808.00 (  0.00%)    141567.75 (  6.60%)    131523.25 ( -0.97%)    139129.50 (  4.76%)
Mean   13    126834.75 (  0.00%)    140738.50 ( 10.96%)    124446.25 ( -1.88%)    138181.50 (  8.95%)
Mean   14    127837.25 (  0.00%)    140882.00 ( 10.20%)    121495.50 ( -4.96%)    128275.75 (  0.34%)
Mean   15    122268.50 (  0.00%)    139983.50 ( 14.49%)    115737.25 ( -5.34%)    119838.75 ( -1.99%)
Mean   16    118739.25 (  0.00%)    142654.25 ( 20.14%)    110902.25 ( -6.60%)    123369.50 (  3.90%)
Mean   17    117972.75 (  0.00%)    136969.50 ( 16.10%)    108398.00 ( -8.12%)    115575.00 ( -2.03%)
Mean   18    116308.50 (  0.00%)    134009.50 ( 15.22%)    109094.25 ( -6.20%)    118385.75 (  1.79%)
Mean   19    114594.75 (  0.00%)    125941.75 (  9.90%)    108366.75 ( -5.43%)    117998.00 (  2.97%)
Mean   20    116338.50 (  0.00%)    121586.50 (  4.51%)    110267.25 ( -5.22%)    121703.00 (  4.61%)
Mean   21    114274.00 (  0.00%)    118586.00 (  3.77%)    105316.25 ( -7.84%)    112591.75 ( -1.47%)
Mean   22    113135.00 (  0.00%)    121886.75 (  7.74%)    108124.25 ( -4.43%)    107672.00 ( -4.83%)
Mean   23    109514.25 (  0.00%)    117894.25 (  7.65%)    111499.50 (  1.81%)    108045.75 ( -1.34%)
Mean   24    112897.00 (  0.00%)    119902.75 (  6.21%)    110615.50 ( -2.02%)    117146.00 (  3.76%)
Mean   25    107127.75 (  0.00%)    125763.50 ( 17.40%)    107750.75 (  0.58%)    116425.75 (  8.68%)
Mean   26    109338.75 (  0.00%)    119034.00 (  8.87%)    105875.25 ( -3.17%)    116591.00 (  6.63%)
Mean   27    110967.75 (  0.00%)    122720.50 ( 10.59%)     99660.75 (-10.19%)    118399.25 (  6.70%)
Mean   28    116559.50 (  0.00%)    121524.50 (  4.26%)     98095.50 (-15.84%)    116433.50 ( -0.11%)
Mean   29    113278.00 (  0.00%)    115992.75 (  2.40%)    101014.00 (-10.83%)    122954.25 (  8.54%)
Mean   30    110273.75 (  0.00%)    112436.50 (  1.96%)    103679.75 ( -5.98%)    127165.50 ( 15.32%)
Mean   31    107409.50 (  0.00%)    120160.00 ( 11.87%)    101122.75 ( -5.85%)    128566.25 ( 19.70%)
Mean   32    105624.00 (  0.00%)    122808.50 ( 16.27%)    100410.75 ( -4.94%)    126009.50 ( 19.30%)
Mean   33    107521.75 (  0.00%)    118049.50 (  9.79%)     97788.25 ( -9.05%)    124172.00 ( 15.49%)
Mean   34    108135.75 (  0.00%)    118198.75 (  9.31%)     99215.25 ( -8.25%)    129010.75 ( 19.30%)
Mean   35    104407.75 (  0.00%)    115090.50 ( 10.23%)     97804.00 ( -6.32%)    126019.75 ( 20.70%)
Mean   36    101119.00 (  0.00%)    118554.75 ( 17.24%)    101608.00 (  0.48%)    126106.00 ( 24.71%)
Mean   37    104228.25 (  0.00%)    123893.25 ( 18.87%)     99277.75 ( -4.75%)    122410.25 ( 17.44%)
Mean   38    104402.50 (  0.00%)    118543.50 ( 13.54%)     97255.00 ( -6.85%)    118682.75 ( 13.68%)
Mean   39    100158.50 (  0.00%)    116866.00 ( 16.68%)     99918.00 ( -0.24%)    122019.75 ( 21.83%)
Mean   40    101911.75 (  0.00%)    117276.25 ( 15.08%)     98766.25 ( -3.09%)    121322.00 ( 19.05%)
Mean   41    104757.50 (  0.00%)    116656.75 ( 11.36%)     97970.25 ( -6.48%)    121403.00 ( 15.89%)
Mean   42    104782.50 (  0.00%)    116385.25 ( 11.07%)     96897.25 ( -7.53%)    118765.25 ( 13.34%)
Mean   43     97073.00 (  0.00%)    113745.50 ( 17.18%)     93433.00 ( -3.75%)    118571.25 ( 22.15%)
Mean   44     99739.00 (  0.00%)    116286.00 ( 16.59%)     96193.50 ( -3.55%)    116149.75 ( 16.45%)
Mean   45    104422.25 (  0.00%)    109978.25 (  5.32%)     95737.50 ( -8.32%)    113604.75 (  8.79%)
Mean   46    103389.25 (  0.00%)    110703.00 (  7.07%)     93711.50 ( -9.36%)    110550.75 (  6.93%)
Mean   47     96092.25 (  0.00%)    108942.50 ( 13.37%)     94220.50 ( -1.95%)    104079.00 (  8.31%)
Mean   48     97596.25 (  0.00%)    109194.00 ( 11.88%)    101071.25 (  3.56%)    101543.00 (  4.04%)
Stddev 1       1326.20 (  0.00%)      1351.58 ( -1.91%)      1525.30 (-15.01%)      1048.89 ( 20.91%)
Stddev 2       1837.05 (  0.00%)      1538.27 ( 16.26%)       919.58 ( 49.94%)      1974.67 ( -7.49%)
Stddev 3       1267.24 (  0.00%)      2599.37 (-105.12%)      2323.12 (-83.32%)      2091.33 (-65.03%)
Stddev 4       6125.28 (  0.00%)      2980.50 ( 51.34%)      1706.84 ( 72.13%)      2497.81 ( 59.22%)
Stddev 5       6161.12 (  0.00%)      2495.59 ( 59.49%)      2466.47 ( 59.97%)      3077.78 ( 50.05%)
Stddev 6       5784.16 (  0.00%)      4799.20 ( 17.03%)      4580.83 ( 20.80%)      2889.81 ( 50.04%)
Stddev 7       6607.07 (  0.00%)      1167.21 ( 82.33%)      6196.26 (  6.22%)      4385.20 ( 33.63%)
Stddev 8       1671.12 (  0.00%)      6631.06 (-296.80%)      6812.80 (-307.68%)      8598.19 (-414.52%)
Stddev 9       6052.25 (  0.00%)      6954.93 (-14.91%)      6382.84 ( -5.46%)      8987.78 (-48.50%)
Stddev 10     11473.39 (  0.00%)      4442.38 ( 61.28%)      6772.50 ( 40.97%)     16758.82 (-46.07%)
Stddev 11      7093.02 (  0.00%)      4526.31 ( 36.19%)      9026.86 (-27.26%)     13353.17 (-88.26%)
Stddev 12      3865.06 (  0.00%)      2743.41 ( 29.02%)     15584.41 (-303.21%)     14112.46 (-265.13%)
Stddev 13      2777.36 (  0.00%)      1050.96 ( 62.16%)     16286.28 (-486.39%)      8243.38 (-196.81%)
Stddev 14      1795.89 (  0.00%)       536.93 ( 70.10%)     13502.75 (-651.87%)      6328.98 (-252.42%)
Stddev 15      2250.85 (  0.00%)      1135.62 ( 49.55%)      9908.63 (-340.22%)     11274.74 (-400.91%)
Stddev 16      1963.42 (  0.00%)       379.50 ( 80.67%)      9645.69 (-391.27%)      2679.87 (-36.49%)
Stddev 17      1592.42 (  0.00%)      1388.57 ( 12.80%)      6322.29 (-297.02%)      3768.27 (-136.64%)
Stddev 18      3317.92 (  0.00%)       721.81 ( 78.25%)      3065.44 (  7.61%)      6375.92 (-92.17%)
Stddev 19      4525.33 (  0.00%)      3273.36 ( 27.67%)      5565.31 (-22.98%)      3248.71 ( 28.21%)
Stddev 20      4140.94 (  0.00%)      2332.35 ( 43.68%)      8000.27 (-93.20%)      6237.91 (-50.64%)
Stddev 21      1515.71 (  0.00%)      3309.22 (-118.33%)      6587.02 (-334.58%)     10217.84 (-574.13%)
Stddev 22      5498.36 (  0.00%)      2437.41 ( 55.67%)      7920.50 (-44.05%)      8414.84 (-53.04%)
Stddev 23      5637.68 (  0.00%)      1832.68 ( 67.49%)      6543.07 (-16.06%)      5976.59 ( -6.01%)
Stddev 24      4862.89 (  0.00%)      6295.82 (-29.47%)      9229.15 (-89.79%)      9046.57 (-86.03%)
Stddev 25      1725.07 (  0.00%)      2986.87 (-73.15%)     13679.77 (-693.00%)      9521.44 (-451.95%)
Stddev 26      4590.06 (  0.00%)      1862.17 ( 59.43%)     10773.97 (-134.72%)      5417.65 (-18.03%)
Stddev 27      6060.43 (  0.00%)      1567.32 ( 74.14%)     10217.36 (-68.59%)      2934.56 ( 51.58%)
Stddev 28      2742.94 (  0.00%)      2533.06 (  7.65%)     11375.97 (-314.74%)      3713.72 (-35.39%)
Stddev 29      3878.01 (  0.00%)       783.58 ( 79.79%)      8718.86 (-124.83%)      2870.90 ( 25.97%)
Stddev 30      4446.49 (  0.00%)       852.75 ( 80.82%)      5318.24 (-19.61%)      2174.56 ( 51.09%)
Stddev 31      3825.27 (  0.00%)       876.75 ( 77.08%)      7412.96 (-93.79%)      1517.78 ( 60.32%)
Stddev 32      8118.60 (  0.00%)      1367.48 ( 83.16%)      5757.34 ( 29.08%)      1025.48 ( 87.37%)
Stddev 33      3237.05 (  0.00%)      3807.47 (-17.62%)      7493.40 (-131.49%)      4600.54 (-42.12%)
Stddev 34      7413.56 (  0.00%)      3599.54 ( 51.45%)      8514.89 (-14.86%)      2999.21 ( 59.54%)
Stddev 35      6061.77 (  0.00%)      3756.88 ( 38.02%)      5594.20 (  7.71%)      4241.61 ( 30.03%)
Stddev 36      5836.80 (  0.00%)      2944.03 ( 49.56%)     10641.97 (-82.33%)      1267.44 ( 78.29%)
Stddev 37      2719.65 (  0.00%)      3819.92 (-40.46%)      4075.76 (-49.86%)      2604.21 (  4.24%)
Stddev 38      3267.94 (  0.00%)      2148.38 ( 34.26%)      5219.19 (-59.71%)      4865.10 (-48.87%)
Stddev 39      3596.06 (  0.00%)      1042.13 ( 71.02%)      5891.17 (-63.82%)      3067.42 ( 14.70%)
Stddev 40      4303.03 (  0.00%)      2518.02 ( 41.48%)      5279.70 (-22.70%)      1750.86 ( 59.31%)
Stddev 41     10269.08 (  0.00%)      3602.25 ( 64.92%)      5907.68 ( 42.47%)      3163.17 ( 69.20%)
Stddev 42      3221.41 (  0.00%)      3707.32 (-15.08%)      6926.80 (-115.02%)      2555.18 ( 20.68%)
Stddev 43      7203.43 (  0.00%)      3082.74 ( 57.20%)      6537.72 (  9.24%)      3912.25 ( 45.69%)
Stddev 44      6164.48 (  0.00%)      2946.14 ( 52.21%)      4702.32 ( 23.72%)      3228.17 ( 47.63%)
Stddev 45      7696.65 (  0.00%)      2461.14 ( 68.02%)      4697.11 ( 38.97%)      4675.68 ( 39.25%)
Stddev 46      6989.59 (  0.00%)      3713.96 ( 46.86%)      5105.63 ( 26.95%)      5008.38 ( 28.35%)
Stddev 47      5580.13 (  0.00%)      4025.00 ( 27.87%)      4034.38 ( 27.70%)      5538.34 (  0.75%)
Stddev 48      5647.24 (  0.00%)      1694.00 ( 70.00%)      2980.82 ( 47.22%)      8123.60 (-43.85%)
TPut   1     119983.00 (  0.00%)    121286.00 (  1.09%)    117829.00 ( -1.80%)    123167.00 (  2.65%)
TPut   2     250797.00 (  0.00%)    242259.00 ( -3.40%)    238884.00 ( -4.75%)    244200.00 ( -2.63%)
TPut   3     353251.00 (  0.00%)    357146.00 (  1.10%)    353806.00 (  0.16%)    361847.00 (  2.43%)
TPut   4     471308.00 (  0.00%)    462332.00 ( -1.90%)    464172.00 ( -1.51%)    459783.00 ( -2.45%)
TPut   5     557676.00 (  0.00%)    551477.00 ( -1.11%)    551044.00 ( -1.19%)    547365.00 ( -1.85%)
TPut   6     624741.00 (  0.00%)    623246.00 ( -0.24%)    606514.00 ( -2.92%)    599401.00 ( -4.06%)
TPut   7     649033.00 (  0.00%)    642661.00 ( -0.98%)    619101.00 ( -4.61%)    617425.00 ( -4.87%)
TPut   8     642660.00 (  0.00%)    641507.00 ( -0.18%)    603396.00 ( -6.11%)    617066.00 ( -3.98%)
TPut   9     624192.00 (  0.00%)    638759.00 (  2.33%)    601388.00 ( -3.65%)    603219.00 ( -3.36%)
TPut   10    578563.00 (  0.00%)    614734.00 (  6.25%)    584662.00 (  1.05%)    573024.00 ( -0.96%)
TPut   11    545675.00 (  0.00%)    584567.00 (  7.13%)    556867.00 (  2.05%)    549740.00 (  0.74%)
TPut   12    531232.00 (  0.00%)    566271.00 (  6.60%)    526093.00 ( -0.97%)    556518.00 (  4.76%)
TPut   13    507339.00 (  0.00%)    562954.00 ( 10.96%)    497785.00 ( -1.88%)    552726.00 (  8.95%)
TPut   14    511349.00 (  0.00%)    563528.00 ( 10.20%)    485982.00 ( -4.96%)    513103.00 (  0.34%)
TPut   15    489074.00 (  0.00%)    559934.00 ( 14.49%)    462949.00 ( -5.34%)    479355.00 ( -1.99%)
TPut   16    474957.00 (  0.00%)    570617.00 ( 20.14%)    443609.00 ( -6.60%)    493478.00 (  3.90%)
TPut   17    471891.00 (  0.00%)    547878.00 ( 16.10%)    433592.00 ( -8.12%)    462300.00 ( -2.03%)
TPut   18    465234.00 (  0.00%)    536038.00 ( 15.22%)    436377.00 ( -6.20%)    473543.00 (  1.79%)
TPut   19    458379.00 (  0.00%)    503767.00 (  9.90%)    433467.00 ( -5.43%)    471992.00 (  2.97%)
TPut   20    465354.00 (  0.00%)    486346.00 (  4.51%)    441069.00 ( -5.22%)    486812.00 (  4.61%)
TPut   21    457096.00 (  0.00%)    474344.00 (  3.77%)    421265.00 ( -7.84%)    450367.00 ( -1.47%)
TPut   22    452540.00 (  0.00%)    487547.00 (  7.74%)    432497.00 ( -4.43%)    430688.00 ( -4.83%)
TPut   23    438057.00 (  0.00%)    471577.00 (  7.65%)    445998.00 (  1.81%)    432183.00 ( -1.34%)
TPut   24    451588.00 (  0.00%)    479611.00 (  6.21%)    442462.00 ( -2.02%)    468584.00 (  3.76%)
TPut   25    428511.00 (  0.00%)    503054.00 ( 17.40%)    431003.00 (  0.58%)    465703.00 (  8.68%)
TPut   26    437355.00 (  0.00%)    476136.00 (  8.87%)    423501.00 ( -3.17%)    466364.00 (  6.63%)
TPut   27    443871.00 (  0.00%)    490882.00 ( 10.59%)    398643.00 (-10.19%)    473597.00 (  6.70%)
TPut   28    466238.00 (  0.00%)    486098.00 (  4.26%)    392382.00 (-15.84%)    465734.00 ( -0.11%)
TPut   29    453112.00 (  0.00%)    463971.00 (  2.40%)    404056.00 (-10.83%)    491817.00 (  8.54%)
TPut   30    441095.00 (  0.00%)    449746.00 (  1.96%)    414719.00 ( -5.98%)    508662.00 ( 15.32%)
TPut   31    429638.00 (  0.00%)    480640.00 ( 11.87%)    404491.00 ( -5.85%)    514265.00 ( 19.70%)
TPut   32    422496.00 (  0.00%)    491234.00 ( 16.27%)    401643.00 ( -4.94%)    504038.00 ( 19.30%)
TPut   33    430087.00 (  0.00%)    472198.00 (  9.79%)    391153.00 ( -9.05%)    496688.00 ( 15.49%)
TPut   34    432543.00 (  0.00%)    472795.00 (  9.31%)    396861.00 ( -8.25%)    516043.00 ( 19.30%)
TPut   35    417631.00 (  0.00%)    460362.00 ( 10.23%)    391216.00 ( -6.32%)    504079.00 ( 20.70%)
TPut   36    404476.00 (  0.00%)    474219.00 ( 17.24%)    406432.00 (  0.48%)    504424.00 ( 24.71%)
TPut   37    416913.00 (  0.00%)    495573.00 ( 18.87%)    397111.00 ( -4.75%)    489641.00 ( 17.44%)
TPut   38    417610.00 (  0.00%)    474174.00 ( 13.54%)    389020.00 ( -6.85%)    474731.00 ( 13.68%)
TPut   39    400634.00 (  0.00%)    467464.00 ( 16.68%)    399672.00 ( -0.24%)    488079.00 ( 21.83%)
TPut   40    407647.00 (  0.00%)    469105.00 ( 15.08%)    395065.00 ( -3.09%)    485288.00 ( 19.05%)
TPut   41    419030.00 (  0.00%)    466627.00 ( 11.36%)    391881.00 ( -6.48%)    485612.00 ( 15.89%)
TPut   42    419130.00 (  0.00%)    465541.00 ( 11.07%)    387589.00 ( -7.53%)    475061.00 ( 13.34%)
TPut   43    388292.00 (  0.00%)    454982.00 ( 17.18%)    373732.00 ( -3.75%)    474285.00 ( 22.15%)
TPut   44    398956.00 (  0.00%)    465144.00 ( 16.59%)    384774.00 ( -3.55%)    464599.00 ( 16.45%)
TPut   45    417689.00 (  0.00%)    439913.00 (  5.32%)    382950.00 ( -8.32%)    454419.00 (  8.79%)
TPut   46    413557.00 (  0.00%)    442812.00 (  7.07%)    374846.00 ( -9.36%)    442203.00 (  6.93%)
TPut   47    384369.00 (  0.00%)    435770.00 ( 13.37%)    376882.00 ( -1.95%)    416316.00 (  8.31%)
TPut   48    390385.00 (  0.00%)    436776.00 ( 11.88%)    404285.00 (  3.56%)    406172.00 (  4.04%)

This is looking a bit better overall. One would generally expect this
JVM configuration to be handled better because there are far few problems
dealing with shared pages.

specjbb Peaks
                                  3.11.0-rc7                 3.11.0-rc7                 3.11.0-rc7                 3.11.0-rc7
                               account-v7                 lesspmd-v7            selectweight-v7               avoidmove-v7   
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        545675.00 (  0.00%)        584567.00 (  7.13%)        556867.00 (  2.05%)        549740.00 (  0.74%)
 Actual Warehouse             8.00 (  0.00%)             8.00 (  0.00%)             8.00 (  0.00%)             8.00 (  0.00%)
 Actual Peak Bops        649033.00 (  0.00%)        642661.00 ( -0.98%)        619101.00 ( -4.61%)        617425.00 ( -4.87%)
 SpecJBB Bops            474931.00 (  0.00%)        523877.00 ( 10.31%)        454089.00 ( -4.39%)        482435.00 (  1.58%)
 SpecJBB Bops/JVM        118733.00 (  0.00%)        130969.00 ( 10.31%)        113522.00 ( -4.39%)        120609.00 (  1.58%)

Because the specjvm score is based on lower number of clients this does
not look as impressive but at least the overall series does not have a
worse specjbb score.


          3.11.0-rc7  3.11.0-rc7  3.11.0-rc7  3.11.0-rc7
        account-v7   lesspmd-v7   selectweight-v7   avoidmove-v7   
User       464762.73   474999.54   474756.33   475883.65
System      10593.13      725.15      752.36      689.00
Elapsed     10409.45    10414.85    10416.46    10441.17

On the other hand, look at the system CPU overhead. We are getting comparable
or better performance at a small fraction of the cost.


                            3.11.0-rc7  3.11.0-rc7  3.11.0-rc7  3.11.0-rc7
                          account-v7   lesspmd-v7   selectweight-v7   avoidmove-v7   
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success        1339274585    55904453    50672239    48174428
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                1390167       58028       52597       50005
NUMA PTE updates             501107230     9187590     8925627     9120756
NUMA hint faults              69895484     9184458     8917340     9096029
NUMA hint local faults        21848214     3778721     3832832     4025324
NUMA hint local percent             31          41          42          44
NUMA pages migrated         1339274585    55904453    50672239    48174428
AutoNUMA cost                   378431       47048       45611       46459

And again the reduced cost is from massively reduced numbers of PTE updates
and faults. This may mean some workloads may converge slower but the system
will not get hammered constantly trying to converge either.

                                     3.11.0-rc7            3.11.0-rc7            3.11.0-rc7            3.11.0-rc7
                                  account-v7            lesspmd-v7       selectweight-v7          avoidmove-v7   
User    NUMA01               53586.49 (  0.00%)    57956.00 ( -8.15%)    38838.20 ( 27.52%)    45977.10 ( 14.20%)
User    NUMA01_THEADLOCAL    16956.29 (  0.00%)    17070.87 ( -0.68%)    16972.80 ( -0.10%)    17262.89 ( -1.81%)
User    NUMA02                2024.02 (  0.00%)     2022.45 (  0.08%)     2035.17 ( -0.55%)     2013.42 (  0.52%)
User    NUMA02_SMT             968.96 (  0.00%)      992.63 ( -2.44%)      979.86 ( -1.12%)     1379.96 (-42.42%)
System  NUMA01                1442.97 (  0.00%)      542.69 ( 62.39%)      309.92 ( 78.52%)      405.48 ( 71.90%)
System  NUMA01_THEADLOCAL      117.16 (  0.00%)       72.08 ( 38.48%)       75.60 ( 35.47%)       91.56 ( 21.85%)
System  NUMA02                   7.12 (  0.00%)        7.86 (-10.39%)        7.84 (-10.11%)        6.38 ( 10.39%)
System  NUMA02_SMT               8.49 (  0.00%)        3.74 ( 55.95%)        3.53 ( 58.42%)        6.26 ( 26.27%)
Elapsed NUMA01                1216.88 (  0.00%)     1372.29 (-12.77%)      918.05 ( 24.56%)     1065.63 ( 12.43%)
Elapsed NUMA01_THEADLOCAL      375.15 (  0.00%)      388.68 ( -3.61%)      386.02 ( -2.90%)      382.63 ( -1.99%)
Elapsed NUMA02                  48.61 (  0.00%)       52.19 ( -7.36%)       49.65 ( -2.14%)       51.85 ( -6.67%)
Elapsed NUMA02_SMT              49.68 (  0.00%)       51.23 ( -3.12%)       50.36 ( -1.37%)       80.91 (-62.86%)
CPU     NUMA01                4522.00 (  0.00%)     4262.00 (  5.75%)     4264.00 (  5.71%)     4352.00 (  3.76%)
CPU     NUMA01_THEADLOCAL     4551.00 (  0.00%)     4410.00 (  3.10%)     4416.00 (  2.97%)     4535.00 (  0.35%)
CPU     NUMA02                4178.00 (  0.00%)     3890.00 (  6.89%)     4114.00 (  1.53%)     3895.00 (  6.77%)
CPU     NUMA02_SMT            1967.00 (  0.00%)     1944.00 (  1.17%)     1952.00 (  0.76%)     1713.00 ( 12.91%)

Elapsed figures here are poor. The numa01 test case saw an improvement but
it's an adverse workload and not that interesting per-se. Its main benefit
is from the reduction of system overhead. numa02_smt suffered badly due
to the last patch in the series that needs addressing.

nas-omp
                     3.11.0-rc7            3.11.0-rc7            3.11.0-rc7            3.11.0-rc7
                  account-v7            lesspmd-v7       selectweight-v7          avoidmove-v7   
Time bt.C      187.22 (  0.00%)      188.02 ( -0.43%)      188.19 ( -0.52%)      197.49 ( -5.49%)
Time cg.C       61.58 (  0.00%)       49.64 ( 19.39%)       61.44 (  0.23%)       56.84 (  7.70%)
Time ep.C       13.28 (  0.00%)       13.28 (  0.00%)       14.05 ( -5.80%)       13.34 ( -0.45%)
Time ft.C       38.35 (  0.00%)       37.39 (  2.50%)       35.08 (  8.53%)       37.05 (  3.39%)
Time is.C        2.12 (  0.00%)        1.75 ( 17.45%)        2.20 ( -3.77%)        2.14 ( -0.94%)
Time lu.C      180.71 (  0.00%)      183.01 ( -1.27%)      186.64 ( -3.28%)      169.77 (  6.05%)
Time mg.C       32.02 (  0.00%)       31.57 (  1.41%)       29.45 (  8.03%)       31.98 (  0.12%)
Time sp.C      413.92 (  0.00%)      396.36 (  4.24%)      400.92 (  3.14%)      388.54 (  6.13%)
Time ua.C      200.27 (  0.00%)      204.68 ( -2.20%)      211.46 ( -5.59%)      194.92 (  2.67%)

This is Nasa Parallel Benchmark (npb) running with openmp. Some small improvements.

          3.11.0-rc7  3.11.0-rc7  3.11.0-rc7  3.11.0-rc7
        account-v7   lesspmd-v7   selectweight-v7   avoidmove-v7   
User        47694.80    47262.68    47998.27    46282.27
System        421.02      136.12      129.91      131.36
Elapsed      1265.34     1242.74     1267.06     1229.70

With large reductions of system CPU usage.

So overall it is still a bit of a mixed bag. There is not a universal
performance win but there are massive reductions in system CPU overhead
which may of big benefit on larger machines meaning the series is still
worth considering.  The ratio of local/remote NUMA hinting faults is still
very slow and the fact that there are tasks sharing a numa group running
on different nodes should be examined closer.

 Documentation/sysctl/kernel.txt   |   73 ++
 arch/x86/mm/numa.c                |    6 +-
 fs/proc/array.c                   |    2 +
 include/linux/migrate.h           |    7 +-
 include/linux/mm.h                |  107 ++-
 include/linux/mm_types.h          |   14 +-
 include/linux/page-flags-layout.h |   28 +-
 include/linux/sched.h             |   45 +-
 include/linux/stop_machine.h      |    1 +
 kernel/bounds.c                   |    4 +
 kernel/fork.c                     |    5 +-
 kernel/sched/core.c               |  196 ++++-
 kernel/sched/debug.c              |   60 +-
 kernel/sched/fair.c               | 1523 ++++++++++++++++++++++++++++++-------
 kernel/sched/features.h           |   19 +-
 kernel/sched/idle_task.c          |    2 +-
 kernel/sched/rt.c                 |    5 +-
 kernel/sched/sched.h              |   19 +-
 kernel/sched/stop_task.c          |    2 +-
 kernel/stop_machine.c             |  272 ++++---
 kernel/sysctl.c                   |    7 +
 lib/vsprintf.c                    |    5 +
 mm/huge_memory.c                  |  103 ++-
 mm/memory.c                       |   95 ++-
 mm/mempolicy.c                    |   24 +-
 mm/migrate.c                      |   21 +-
 mm/mm_init.c                      |   18 +-
 mm/mmzone.c                       |   14 +-
 mm/mprotect.c                     |   70 +-
 mm/page_alloc.c                   |    4 +-
 30 files changed, 2147 insertions(+), 604 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
