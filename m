Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DEADF6B021A
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 10:43:22 -0400 (EDT)
Date: Thu, 29 Apr 2010 16:41:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #22
Message-ID: <20100429144136.GA22108@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master; git diff a41f0dcfdbebeac21b42e152d3ed9f4bf20070a3

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc5/transparent_hugepage-22
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc5/transparent_hugepage-22.gz

This fixes the swapops.h crash in migrate.c:migration_entry_wait
(Kame/Mel if you could test if you can still reproduce your memory
compaction crash on aa.git let me know, this fix is here
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=6efa1dfa5152ef8d7f26beb188d6877525a9dd03). It
also fixes potential memory corruption when swapping out hugepage
backed kvm (host_level wasn't read inside the mmu notifier protected
critical section of the page fault). It cleanups some bits in
khugepaged and notably it's removing
transparent_hugepage/khugepaged/enabled. Now khugepaged is started
automatically if transparent_hugepage/enabled is set to
"always|madvise" and it exits if it's set to "never" (I found it too
confusing to have it separated and an unnecessary annoyance having to
change two files instead of just one). I removed the dependency on
embedded to set transparent hugepage support to N at compile time, and
I leave the default to N to reduce as much as possible the risk while
merging the feature.

All reports I have says it's very stable (the only two open issues in
migrate vs execve and in the kvm patch should be fixed in #22).

There is no easy way this can work with the new anon-vma code until I
adapt it significantly (as an example see how wait_split_huge_page is
implemented right now
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=blob_plain;f=include/linux/huge_mm.h;hb=HEAD),
and I'll have to consider if it's possible to move completely away
from the anon-vma lock and use compound_lock or something else. For
now this has to run on the old stable anon-vma code to be stable.

I added more details to the generic document.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=blob_plain;f=Documentation/vm/transhuge.txt;hb=HEAD

If anybody wants a patchbomb let me know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
