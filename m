Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC518E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:22:50 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so5422356pfk.12
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:22:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h3si4824257pgi.391.2018.12.14.13.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 13:22:48 -0800 (PST)
Date: Fri, 14 Dec 2018 13:22:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] hugetlbfs: use i_mmap_rwsem for better
 synchronization
Message-Id: <20181214132239.9b74e2ca4bc4e38a409736dc@linux-foundation.org>
In-Reply-To: <20181203200850.6460-1-mike.kravetz@oracle.com>
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>

On Mon,  3 Dec 2018 12:08:47 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> These patches are a follow up to the RFC,
> http://lkml.kernel.org/r/20181024045053.1467-1-mike.kravetz@oracle.com
> Comments made by Naoya were addressed.
> 
> There are two primary issues addressed here:
> 1) For shared pmds, huge PE pointers returned by huge_pte_alloc can become
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
> 
> I broke up the larger RFC into separate patches addressing each issue.
> Hopefully, this is easier to understand/review.

Three patches tagged for -stable and no reviewers yet.  Could people
please take a close look?
