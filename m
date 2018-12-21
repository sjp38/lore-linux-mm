Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4858E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:28:43 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id j3so5870009itf.5
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:28:43 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z200si1490146jab.77.2018.12.21.10.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 10:28:42 -0800 (PST)
Subject: Re: [PATCH v2 2/2] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-3-mike.kravetz@oracle.com>
 <20181221102824.5v36l6l5t2zthpgr@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <849f5202-2200-265f-7769-8363053e8373@oracle.com>
Date: Fri, 21 Dec 2018 10:28:25 -0800
MIME-Version: 1.0
In-Reply-To: <20181221102824.5v36l6l5t2zthpgr@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/21/18 2:28 AM, Kirill A. Shutemov wrote:
> On Tue, Dec 18, 2018 at 02:35:57PM -0800, Mike Kravetz wrote:
>> Instead of writing the required complicated code for this rare
>> occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
>> mode for the duration of page fault processing.  Hold i_mmap_rwsem
>> longer in truncation and hold punch code to cover the call to
>> remove_inode_hugepages.
> 
> One of remove_inode_hugepages() callers is noticeably missing --
> hugetlbfs_evict_inode(). Why?
> 
> It at least deserves a comment on why the lock rule doesn't apply to it.

In the case of hugetlbfs_evict_inode, the vfs layer guarantees there are
no more users of the inode/file.  Therefore, it is safe to call without
holding the mutex.  But, I did add this comment to remove_inode_hugepages.

* Callers of this routine must hold the i_mmap_rwsem in write mode to prevent
* races with page faults.

So, I violated the rule that I documented.  Thanks for catching.

I will update the comments to note this excpetion to the rule.  Another
option is to simply take the semaphore and still note why it is technically
not needed.  Since there are no users there will be no contention of the
semaphore and the overhead should be negligible.
-- 
Mike Kravetz
