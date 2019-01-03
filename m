Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED5B8E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 16:44:38 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id m200so18432440ywd.14
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 13:44:38 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p189si35103599ywh.366.2019.01.03.13.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 13:44:36 -0800 (PST)
Subject: Re: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
References: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com>
 <6e608107-e071-90c0-bd73-4215325433c1@oracle.com>
 <dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com>
 <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
 <495081357.93179893.1546535169172.JavaMail.zimbra@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6e341052-fe38-b71c-ebb2-47e2e34f5963@oracle.com>
Date: Thu, 3 Jan 2019 13:44:20 -0800
MIME-Version: 1.0
In-Reply-To: <495081357.93179893.1546535169172.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kirill shutemov <kirill.shutemov@linux.intel.com>, ltp@lists.linux.it, mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, dave@stgolabs.net, prakash sangappa <prakash.sangappa@oracle.com>, colin king <colin.king@canonical.com>

On 1/3/19 9:06 AM, Jan Stancek wrote:
<snip>
>> 1) with LTP move_pages12 (MAP_PRIVATE version of reproducer)
>> Patch below fixes the panic for me.
>> It didn't apply cleanly to latest master, but conflicts were easy to resolve.
>>
>> 2) with MAP_SHARED version of reproducer
>> It still hangs in user-space.
>> v4.19 kernel appears to work fine so I've started a bisect.
> 
> My bisect with MAP_SHARED version arrived at same 2 commits:
>   c86aa7bbfd55 hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
>   b43a99900559 hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
> 
> Maybe a deadlock between page lock and mapping->i_mmap_rwsem?
> 
> thread1:
>   hugetlbfs_evict_inode
>     i_mmap_lock_write(mapping);
>     remove_inode_hugepages
>       lock_page(page);
> 
> thread2:
>   __unmap_and_move
>     trylock_page(page) / lock_page(page)
>       remove_migration_ptes
>         rmap_walk_file
>           i_mmap_lock_read(mapping);

Thanks Jan!  That is an ABBA deadlock. :(

Commit c86aa7bbfd55 ("Use i_mmap_rwsem to fix page fault/truncate race") is
the patch which causes remove_inode_hugepages to be called with i_mmap_rwsem
held in write mode.  Clearly, i_mmap_rwsem should not be held when calling
remove_inode_hugepages.  If you back out that patch, then the deadlock will
go away.

But, the whole point of that patch is to expand the locking so that
remove_inode_hugepages can not race with a page fault.  If they do race, then
hugetlbfs specific metadata becomes inconsistent.  With some tweaks to
c86aa7bbfd55, I think we could make truncate/page fault races safe.  However,
the issue would still exist for hole punch/page fault races.  We need some
way to prevent page faults while in remove_inode_hugepages.

Andrew, it might be best to revert these patches.  I am not sure if all the
issues with this approach to synchronization can be fixed.  To do so would
likely require more 'special case' conditions to code paths.  The code is
already difficult to understand.  I'd like to step back and take another look
at the best way to fix these problems.  As mentioned before, the issues these
patches address have existed for at least 10 years.  AFAIK, they have not been
seen in real world use cases.  They were discovered via code inspection and
can only be reproduced with highly targeted test programs.  So, waiting for
another release cycle to get a better solution might be the best approach.
I will continue to work this, but if you agree that backing out is the best
approach for now please let me know the process.  Do I simply send a 'revert'
patch to you and the list?

-- 
Mike Kravetz
