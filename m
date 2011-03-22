Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C6B5A8D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 17:41:28 -0400 (EDT)
Date: Tue, 22 Mar 2011 22:40:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110322214020.GD5698@random.random>
References: <4D84D3F2.4010200@fiec.espol.edu.ec>
 <20110319235144.GG10696@random.random>
 <20110321094149.GH707@csn.ul.ie>
 <20110321134832.GC5719@random.random>
 <20110321163742.GA24244@csn.ul.ie>
 <4D878564.6080608@fiec.espol.edu.ec>
 <20110321201641.GA5698@random.random>
 <20110322112032.GD24244@csn.ul.ie>
 <20110322150314.GC5698@random.random>
 <4D8907C2.7010304@fiec.espol.edu.ec>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4D8907C2.7010304@fiec.espol.edu.ec>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, Mar 22, 2011 at 03:34:10PM -0500, Alex Villaci-s Lasso wrote:
> I have just tested aa.git as of today, with the USB stick formatted
> as FAT32. I could no longer reproduce the stalls. There was no need
> to format as ext4. No /proc workarounds required.

Sounds good.

So Andrew the patches to apply to solve this most certainly are:

http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration-fix.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pages.patch
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=6daf7ff3adc1a243aa9f5a77c7bde2b713a3188a (not in -mm, posted to linux-mm Message-ID 20110321134832.GC5719)

Very likely it's the combination of all the above that is equally
important and needed for this specific compaction issue.

==== rest of aa.git not relevant for this bugreport below ====

http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-compaction-prevent-kswapd-compacting-memory-to-reduce-cpu-usage.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-vmscan-kswapd-should-not-free-an-excessive-number-of-pages-when-balancing-small-zones.patch

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=cb107ebbb7541e5442fd897436440e71835b6496 (not in -mm posted to linux-mm Message-ID: alpine.LSU.2.00.1103192318100.1877)

http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-add-__gfp_other_node-flag.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-add-__gfp_other_node-flag-checkpatch-fixes.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-use-__gfp_other_node-for-transparent-huge-pages.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-use-__gfp_other_node-for-transparent-huge-pages-checkpatch-fixes.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-add-vm-counters-for-transparent-hugepages.patch
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-add-vm-counters-for-transparent-hugepages-checkpatch-fixes.patch

smaps* (5 patches in -mm)


This is one experimental new feature that should improve mremap
significantly regardless of THP on or off (but bigger boost with THP
on). I'm using it for weeks without problem, I'd suggest it for
inclusion too. The version in the below link is the most uptodate. It
fixes a build trouble (s/__split_huge_page_pmd/split_huge_page_pmd/ in
move_page_tables) with CONFIG_TRANSPARENT_HUGEPAGE=n compared to the
last version I posted to linux-mm. But this is low priority.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=0e6f8bd8802c3309195d3e1a7af50093ed488f2d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
