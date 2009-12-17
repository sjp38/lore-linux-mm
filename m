Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 617F56B0098
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:16:52 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 28] Transparent Hugepage support #2
Message-Id: <patchbomb.1261076403@v2.random>
Date: Thu, 17 Dec 2009 19:00:03 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

This is an update of my status on the transparent hugepage patchset. Quite
some changes happened in the last two weeks as I handled all feedback
provided so far (notably from Avi, Andi, Nick and others), and continuted on
the original todo list.

On the "brainer" side perhaps the most notable change worth review is one idea
suggested by Avi that during the hugepage-split userland can still access the
memory. Even when it's not shared, it can write to it. Because the split
happens in place and it only mangles over kernel page-metadata structures,
the page-data not. So I replaced the notpresent bit with a _SPLITTING bit
using a reserved pmd bit (that is never used in the pmd, it was only used by
two other features in the pte). I renamed it to splitting and not frozen under
Andi's suggestion. collapse_huge_page then will not be able to use the same
splitting bit, as collapse_huge_page is not working in place so it has to at
least wrprotect the page during the copy.

With madvise(MADV_HUGEPAGE) already functional (try running the below program
w/ and w/o madvise after "echo madvise >
/sys/kernel/mm/transparent_hugepage/enabled" to notice the speed difference)
the only notable bit missing that I'm still working on (on top of this
patchset) is the khugepaged daemon (and later possibly the removal of
split_huge_page_mm from some places with lower priority). In the meantime
further review of the patchset is very welcome.

-----------
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/mman.h>

#define SIZE (3UL*1024*1024*1024)

int main()
{
	char *p;
	if (posix_memalign((void **)&p, 4096, SIZE))
		perror("memalign"), exit(1);
	madvise(p, SIZE, 14);
	memset(p, 0, SIZE);

	return 0;
}
-----------

I've also been reported the last patchset doesn't boot on some huge system
with EFI, so I recommend trying again with this latest patchset and if it
still doesn't boot it's good idea to try with transparent_hugepage=2 as boot
parameter (which only enables transparent hugepages under madvise).

The updated quilt tree is here:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.32-843b53823beb/transparent_hugepage-2/

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
