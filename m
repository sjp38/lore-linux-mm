Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0441482F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 23:34:28 -0400 (EDT)
Received: by igdg1 with SMTP id g1so98115807igd.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:34:27 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id w11si31851985iod.120.2015.10.27.20.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 20:34:27 -0700 (PDT)
Received: by pabla5 with SMTP id la5so49358729pab.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:34:27 -0700 (PDT)
Date: Tue, 27 Oct 2015 20:34:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page
 faults
In-Reply-To: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
Message-ID: <alpine.LSU.2.11.1510271919200.2872@eggly.anvils>
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 20 Oct 2015, Mike Kravetz wrote:

> The hugetlbfs fallocate hole punch code can race with page faults.  The
> result is that after a hole punch operation, pages may remain within the
> hole.  No other side effects of this race were observed.
> 
> In preparation for adding userfaultfd support to hugetlbfs, it is desirable
> to close the window of this race.  This patch set starts by using the same
> mechanism employed in shmem (see commit f00cdc6df7).  This greatly reduces
> the race window.  However, it is still possible for the race to occur.
> 
> The current hugetlbfs code to remove pages did not deal with pages that
> were mapped (because of such a race).  This patch set also adds code to
> unmap pages in this rare case.  This unmapping of a single page happens
> under the hugetlb_fault_mutex, so it can not be faulted again until the
> end of the operation.
> 
> v2:
>   Incorporated Andrew Morton's cleanups and added suggested comments
>   Added patch 4/4 to unmap single pages in remove_inode_hugepages
> 
> Mike Kravetz (4):
>   mm/hugetlb: Define hugetlb_falloc structure for hole punch race
>   mm/hugetlb: Setup hugetlb_falloc during fallocate hole punch
>   mm/hugetlb: page faults check for fallocate hole punch in progress and
>     wait
>   mm/hugetlb: Unmap pages to remove if page fault raced with hole punch
> 
>  fs/hugetlbfs/inode.c    | 155 ++++++++++++++++++++++++++++--------------------
>  include/linux/hugetlb.h |  10 ++++
>  mm/hugetlb.c            |  39 ++++++++++++
>  3 files changed, 141 insertions(+), 63 deletions(-)

With the addition of i_mmap_lock_write() around hugetlb_vmdelete_list()
in 4/4 (that you already sent a patch for), and two very minor and
inessential mods to the test in 3/4 that I'll suggest in reply to that,
this all looks correct to me.

And yet, and yet...

... I have to say that it looks like a bunch of unnecessary complexity:
for which the only justification you give is above, not in any of the
patches: "In preparation for adding userfaultfd support to hugetlbfs,
it is desirable to close the window of this race" (pages faulted into
the hole during holepunch may be left there afterwards).

Of course, the code you've sampled from shmem.c is superb ;) and it
all should work as you have it (and I wouldn't want to tinker with it,
to try and make it simpler here, it's just to easy to get it wrong);
but it went into shmem.c for very different reasons.

I don't know whether you studied the sequence of 1aac1400319d before,
then f00cdc6df7d7 which you cite, then 8e205f779d14 which corrected it,
then b1a366500bd5 which plugged the remaining holes: I had to refresh
my memory of how it came to be like this.

The driving reasons for it in shmem.c were my aversion to making the
shmem inode any bigger for such an offbeat case (but hugetlbfs wouldn't
expect a large number of tiny files, to justify such space saving); my
aversion to adding further locking into the fast path of shmem_fault();
the fact that we already had this fallocate range checking mechanism
from the earliest of those commits; and the CVE number that meant that
the starvation issue had to be taken more seriously than it deserved.

One of the causes of that starvation issue was the fallback unmapping
of single pages within the holepunch loop: your 4/4 actually introduces
that into hugetlbfs for the first time.  Another cause of the starvation
issue was the "for ( ; ; )" pincer loop that I reverted in the last of
those commits above: whereas hugetlbfs just has a straightforward start
to end loop there.

It's inherent in the nature of holepunching, that immediately after
the holepunch someone may fault into the hole: I wouldn't have bothered
to make those changes in shmem.c, if there hadn't been the CVE starvation
issue - which I doubt hugetlbfs has before your changes.

But I've found some linux-mm mail from you to Andrea on Sep 30, in a
00/12 userfaultfd thread, where you say "I would like a mechanism to
catch all new huge page allocations as a result of page faults" and
"They would like to 'catch' any tasks that (incorrectly) fault in a
page after hole punch".

I confess I've not done my userfaultfd homework: perhaps it does give
you very good reason for this hugetlbfs holepunch-fault race series, but
I'd really like you to explain that in more detail, before I can Ack it.

But it sounds to me more as if the holes you want punched are not
quite like on other filesystems, and you want to be able to police
them afterwards with userfaultfd, to prevent them from being refilled.

Can't userfaultfd be used just slightly earlier, to prevent them from
being filled while doing the holepunch?  Then no need for this patchset?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
