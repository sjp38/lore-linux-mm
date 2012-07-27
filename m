Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 339476B00AA
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:46:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Close race leading to pagetable corruption using hugetlbfs
Date: Fri, 27 Jul 2012 11:46:03 +0100
Message-Id: <1343385965-7738-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is a two-patch series to fix a bug where messages like this appear in the
kernel log

    [  ..........] Lots of bad pmd messages followed by this
    [  127.164256] mm/memory.c:391: bad pmd ffff880412e04fe8(80000003de4000e7).
    [  127.164257] mm/memory.c:391: bad pmd ffff880412e04ff0(80000003de6000e7).
    [  127.164258] mm/memory.c:391: bad pmd ffff880412e04ff8(80000003de0000e7).
    [  127.186778] ------------[ cut here ]------------
    [  127.186781] kernel BUG at mm/filemap.c:134!
    [  127.186782] invalid opcode: 0000 [#1] SMP
    [  127.186783] CPU 7

The messy details of the bug are in patch 2. Patch 1 of the series is
required to revert a patch that is in mmotm. That patch avoids taking
i_mmap_mutex but the mutex is required to stabilise the page count during
unsharing. This looks like a mistake and it should be dealt with sooner rather
than later.

There is a potential large snag with patch 2 but I'm sending it now anyway
as patch 1 of the series has to be dealt with. The snag with the second
patch is that while it works for me for the test case included in the patch,
Larry Woodman reports that it does *not* fix the bug for him. We have yet
to establish if this is because of something RHEL specific or because my
test machine is simply unable to reproduce the race with the patch applied.

 include/linux/hugetlb.h |    3 +++
 mm/hugetlb.c            |   28 ++++++++++++++++++++++++++--
 mm/memory.c             |    7 +++++--
 3 files changed, 34 insertions(+), 4 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
