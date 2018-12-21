Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5D1A8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 15:21:42 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id m10so727896lfk.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:21:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j81-v6sor16901847ljb.30.2018.12.21.12.21.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 12:21:40 -0800 (PST)
Date: Fri, 21 Dec 2018 23:21:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
Message-ID: <20181221202136.crrwojz3k7muvyrh@kshutemo-mobl1>
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-3-mike.kravetz@oracle.com>
 <20181221102824.5v36l6l5t2zthpgr@kshutemo-mobl1>
 <849f5202-2200-265f-7769-8363053e8373@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <849f5202-2200-265f-7769-8363053e8373@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Fri, Dec 21, 2018 at 10:28:25AM -0800, Mike Kravetz wrote:
> On 12/21/18 2:28 AM, Kirill A. Shutemov wrote:
> > On Tue, Dec 18, 2018 at 02:35:57PM -0800, Mike Kravetz wrote:
> >> Instead of writing the required complicated code for this rare
> >> occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
> >> mode for the duration of page fault processing.  Hold i_mmap_rwsem
> >> longer in truncation and hold punch code to cover the call to
> >> remove_inode_hugepages.
> > 
> > One of remove_inode_hugepages() callers is noticeably missing --
> > hugetlbfs_evict_inode(). Why?
> > 
> > It at least deserves a comment on why the lock rule doesn't apply to it.
> 
> In the case of hugetlbfs_evict_inode, the vfs layer guarantees there are
> no more users of the inode/file.

I'm not convinced that it is true. See documentation for ->evict_inode()
in Documentation/filesystems/porting:

	Caller does *not* evict the pagecache or inode-associated
	metadata buffers; the method has to use truncate_inode_pages_final() to get rid
	of those.

Is hugetlbfs special here?

-- 
 Kirill A. Shutemov
