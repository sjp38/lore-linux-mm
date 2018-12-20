Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 244618E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 16:06:47 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so2569041pgm.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:06:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si19558256plb.103.2018.12.20.13.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 13:06:45 -0800 (PST)
Date: Thu, 20 Dec 2018 13:06:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/2] hugetlbfs: use i_mmap_rwsem for better
 synchronization
Message-Id: <20181220130642.e43bee30cf572c5a9a3a8557@linux-foundation.org>
In-Reply-To: <20181218223557.5202-1-mike.kravetz@oracle.com>
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>

On Tue, 18 Dec 2018 14:35:55 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> There are two primary issues addressed here:
> 1) For shared pmds, huge PTE pointers returned by huge_pte_alloc can become
>    invalid via a call to huge_pmd_unshare by another thread.
> 2) hugetlbfs page faults can race with truncation causing invalid global
>    reserve counts and state.
> Both issues are addressed by expanding the use of i_mmap_rwsem.
> 
> These issues have existed for a long time.  They can be recreated with a
> test program that causes page fault/truncation races.  For simple mappings,
> this results in a negative HugePages_Rsvd count.  If racing with mappings
> that contain shared pmds, we can hit "BUG at fs/hugetlbfs/inode.c:444!" or
> Oops! as the result of an invalid memory reference.

Still no reviewers or ackers :(

I'll queue these for 4.21-rc1.  The Fixes: commits are over a decade
old so I assume things aren't super-urgent and the cc:stable will do
its work.
