Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3A79A600786
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 12:30:17 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 31] Transparent Hugepage support #6
Message-Id: <patchbomb.1264439931@v2.random>
Date: Mon, 25 Jan 2010 18:18:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello everyone,

so this is working on my laptop and for now on I'll keeping taking advantage
of hugepages here on my laptop (all sysctl set to "always") and there are no
bugs left that I am aware of, my laptop seems rock solid with sound, skype
videocall, youtube etc... On server I'm running this with lockdep, full
preempt and all all debug goodies enabled, and it's doing swap storms of 5G in
a loop with firefox and stuff running as well (which triggers the futex and
stuff on hugepages without splitting them).

The major bug that triggered with firefox was futex (firefox is using
hugepages all the time now), it was tricky to find because futex takes the pin
on a tail page and then run put_page on the head page only, so leaving at a
much later time (during pte teardown) one hugepage being freed but with
bad_page triggering because of the atomic count of the tail page being > 0.

Other cleanups and changes as usual.

I think next submit should be against mmotd, not agaist mainline anymore.
I still wait answer from Dave on the tail page handling for hugetlbfs to
decide if to optimize that bit with yet another new PG_trans_huge bitflag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
