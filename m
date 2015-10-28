Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2D0782F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 12:10:47 -0400 (EDT)
Received: by oiao187 with SMTP id o187so7281890oia.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 09:10:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c4si28071976oif.115.2015.10.28.09.10.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 09:10:46 -0700 (PDT)
Subject: Re: [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page
 faults
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1510271919200.2872@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5630F274.5010908@oracle.com>
Date: Wed, 28 Oct 2015 09:06:12 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510271919200.2872@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 10/27/2015 08:34 PM, Hugh Dickins wrote:
> On Tue, 20 Oct 2015, Mike Kravetz wrote:
> 
>> The hugetlbfs fallocate hole punch code can race with page faults.  The
>> result is that after a hole punch operation, pages may remain within the
>> hole.  No other side effects of this race were observed.
>>
>> In preparation for adding userfaultfd support to hugetlbfs, it is desirable
>> to close the window of this race.  This patch set starts by using the same
>> mechanism employed in shmem (see commit f00cdc6df7).  This greatly reduces
>> the race window.  However, it is still possible for the race to occur.
>>
>> The current hugetlbfs code to remove pages did not deal with pages that
>> were mapped (because of such a race).  This patch set also adds code to
>> unmap pages in this rare case.  This unmapping of a single page happens
>> under the hugetlb_fault_mutex, so it can not be faulted again until the
>> end of the operation.
>>
>> v2:
>>   Incorporated Andrew Morton's cleanups and added suggested comments
>>   Added patch 4/4 to unmap single pages in remove_inode_hugepages
>>
>> Mike Kravetz (4):
>>   mm/hugetlb: Define hugetlb_falloc structure for hole punch race
>>   mm/hugetlb: Setup hugetlb_falloc during fallocate hole punch
>>   mm/hugetlb: page faults check for fallocate hole punch in progress and
>>     wait
>>   mm/hugetlb: Unmap pages to remove if page fault raced with hole punch
>>
>>  fs/hugetlbfs/inode.c    | 155 ++++++++++++++++++++++++++++--------------------
>>  include/linux/hugetlb.h |  10 ++++
>>  mm/hugetlb.c            |  39 ++++++++++++
>>  3 files changed, 141 insertions(+), 63 deletions(-)
> 
> With the addition of i_mmap_lock_write() around hugetlb_vmdelete_list()
> in 4/4 (that you already sent a patch for), and two very minor and
> inessential mods to the test in 3/4 that I'll suggest in reply to that,
> this all looks correct to me.

Thanks for the detailed response Hugh.  I will try to address your questions
and provide more reasoning behind the use case and need for this code.

> 
> And yet, and yet...
> 
> ... I have to say that it looks like a bunch of unnecessary complexity:
> for which the only justification you give is above, not in any of the
> patches: "In preparation for adding userfaultfd support to hugetlbfs,
> it is desirable to close the window of this race" (pages faulted into
> the hole during holepunch may be left there afterwards).
> 
> Of course, the code you've sampled from shmem.c is superb ;)

That goes without saying. :)

>                                                              and it
> all should work as you have it (and I wouldn't want to tinker with it,
> to try and make it simpler here, it's just to easy to get it wrong);
> but it went into shmem.c for very different reasons.
> 
> I don't know whether you studied the sequence of 1aac1400319d before,
> then f00cdc6df7d7 which you cite, then 8e205f779d14 which corrected it,
> then b1a366500bd5 which plugged the remaining holes: I had to refresh
> my memory of how it came to be like this.

To be honest, no I did not study the evolution of this code.  I only
looked at the final result.

> 
> The driving reasons for it in shmem.c were my aversion to making the
> shmem inode any bigger for such an offbeat case (but hugetlbfs wouldn't
> expect a large number of tiny files, to justify such space saving); my

I did not seriously consider the option of expanding the size of
hugetlbfs inodes, simply based on your comments in shmem.  It would
certainly be easier to use something like a rw_semaphore to handle this
situation.  There is already a table of mutexes that are used (and taken)
during hugetlb faults.  Another mutex might not be too much additional
overhead in the fault path.

I would not claim to have enough experience to say whether or not the
additional space in hugetlbfs inodes would be worth the simplicity of
of code.  If you and others think this is the case, I would certainly
be open to take this path.

> aversion to adding further locking into the fast path of shmem_fault();
> the fact that we already had this fallocate range checking mechanism
> from the earliest of those commits; and the CVE number that meant that
> the starvation issue had to be taken more seriously than it deserved.
> 
> One of the causes of that starvation issue was the fallback unmapping
> of single pages within the holepunch loop: your 4/4 actually introduces
> that into hugetlbfs for the first time.  Another cause of the starvation
> issue was the "for ( ; ; )" pincer loop that I reverted in the last of
> those commits above: whereas hugetlbfs just has a straightforward start
> to end loop there.
> 
> It's inherent in the nature of holepunching, that immediately after
> the holepunch someone may fault into the hole: I wouldn't have bothered
> to make those changes in shmem.c, if there hadn't been the CVE starvation
> issue - which I doubt hugetlbfs has before your changes.
> 

Yes.  In the current hugetlbfs hole punch code, it knows that such
situations
exist.  It even 'cheats' and takes advantage of this for simpler code.  If
it notices a page fault during a hole punch, it simply leaves the page as
is and continues on with other pages in the hole.

> But I've found some linux-mm mail from you to Andrea on Sep 30, in a
> 00/12 userfaultfd thread, where you say "I would like a mechanism to
> catch all new huge page allocations as a result of page faults" and
> "They would like to 'catch' any tasks that (incorrectly) fault in a
> page after hole punch".
> 
> I confess I've not done my userfaultfd homework: perhaps it does give
> you very good reason for this hugetlbfs holepunch-fault race series, but
> I'd really like you to explain that in more detail, before I can Ack it.

Ok, here is a bit more explanation of the proposed use case.  It all
revolves around a DB's use of hugetlbfs and the desire for more control
over the underlying memory.  This additional control is achieved by
adding existing fallocate and userfaultfd semantics to hugetlbfs.

In this use case there is a single process that manages hugetlbfs files
and the underlying memory resources.  It pre-allocates/initializes these
files.

In addition, there are many other processes which access (rw mode) these
files.  They will simply mmap the files.  It is expected that they will
not fault in any new pages.  Rather, all pages would have been pre-allocated
by the management process.

At some time, the management process determines that specific ranges of
pages within the hugetlbfs files are no longer needed.  It will then punch
holes in the files.  These 'free' pages within the holes may then be used
for other purposes.  For applications like this (sophisticated DBs), huge
pages are reserved at system init time and closely managed by the
application.
Hence, the desire for this additional control.

So, when a hole containing N huge pages is punched, the management process
wants to know that it really has N huge pages for other purposes.  Ideally,
none of the other processes mapping this file/area would access the hole.
This is an application error, and it can be 'caught' with  userfaultfd.

Since these other (non-management) processes will never fault in pages,
they would simply set up userfaultfd to catch any page faults immediately
after mmaping the hugetlbfs file.

> 
> But it sounds to me more as if the holes you want punched are not
> quite like on other filesystems, and you want to be able to police
> them afterwards with userfaultfd, to prevent them from being refilled.

I am not sure if they are any different.

One could argue that a hole punch operation must always result in all
pages within the hole being deallocated.  As you point out, this could
race with a fault.  Previously, there would be no way to determine if
all pages had been deallocated because user space could not detect this
race.  Now, userfaultfd allows user space to catch page faults.  So,
it is now possible to catch/depend on hole punch deallocating all pages
within the hole.

> 
> Can't userfaultfd be used just slightly earlier, to prevent them from
> being filled while doing the holepunch?  Then no need for this patchset?

I do not think so, at least with current userfaultfd semantics.  The hole
needs to be punched before being caught with UFFDIO_REGISTER_MODE_MISSING.

> 
> Hugh
> 

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
