Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1F58E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:17:51 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id h3so4300974ywc.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:17:51 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m129si15275197ywb.139.2018.12.21.14.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 14:17:50 -0800 (PST)
Subject: Re: [PATCH v2 2/2] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-3-mike.kravetz@oracle.com>
 <20181221102824.5v36l6l5t2zthpgr@kshutemo-mobl1>
 <849f5202-2200-265f-7769-8363053e8373@oracle.com>
 <20181221202136.crrwojz3k7muvyrh@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <732c0b7d-5a4e-97a8-9677-30f3520893cb@oracle.com>
Date: Fri, 21 Dec 2018 14:17:32 -0800
MIME-Version: 1.0
In-Reply-To: <20181221202136.crrwojz3k7muvyrh@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/21/18 12:21 PM, Kirill A. Shutemov wrote:
> On Fri, Dec 21, 2018 at 10:28:25AM -0800, Mike Kravetz wrote:
>> On 12/21/18 2:28 AM, Kirill A. Shutemov wrote:
>>> On Tue, Dec 18, 2018 at 02:35:57PM -0800, Mike Kravetz wrote:
>>>> Instead of writing the required complicated code for this rare
>>>> occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
>>>> mode for the duration of page fault processing.  Hold i_mmap_rwsem
>>>> longer in truncation and hold punch code to cover the call to
>>>> remove_inode_hugepages.
>>>
>>> One of remove_inode_hugepages() callers is noticeably missing --
>>> hugetlbfs_evict_inode(). Why?
>>>
>>> It at least deserves a comment on why the lock rule doesn't apply to it.
>>
>> In the case of hugetlbfs_evict_inode, the vfs layer guarantees there are
>> no more users of the inode/file.
> 
> I'm not convinced that it is true. See documentation for ->evict_inode()
> in Documentation/filesystems/porting:
> 
> 	Caller does *not* evict the pagecache or inode-associated
> 	metadata buffers; the method has to use truncate_inode_pages_final() to get rid
> 	of those.
> 

We may be talking about different things.

When I say there are no more users, I am talking about users via user space.
We get to the hugetlbfs evict inode code via iput->iput_final->evict.  In
this path the count on the inode is zero, and is marked (I_FREEING) so that
nobody will start using it.  As a result, there can be no additional page
faults against the file.  This is what we are using i_mmap_rwsem to prevent.

The Documentation above says that the ->evict_inode() method must evict from
pagecache and get rid of metadatta buffers.  hugetlbfs_evict_inode does this
remove_inode_hugepages evicts pages from page cache (and frees them) as well
as cleaning up the hugetlbfs specific reserve map metadata.

Am I misunderstanding your question/concern?

I have decided to add the locking (although unnecessary) with something like
this in hugetlbfs_evict_inode.

	/*
	 * The vfs layer guarantees that there are no other users of this
	 * inode.  Therefore, it would be safe to call remove_inode_hugepages
	 * without holding i_mmap_rwsem.  We acquire and hold here to be
	 * consistent with other callers.  Since there will be no contention
	 * on the semaphore, overhead is negligible.
	 */
	i_mmap_lock_write(mapping);
	remove_inode_hugepages(inode, 0, LLONG_MAX);
	i_mmap_unlock_write(mapping);

-- 
Mike Kravetz
