Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50F9D8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:34:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so8225577edr.7
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 02:34:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i12si2286459edq.418.2018.12.17.02.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 02:34:28 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBHASjUD120941
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:34:27 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pea1v0a44-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:34:26 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 17 Dec 2018 10:34:26 -0000
Subject: Re: [PATCH 3/3] hugetlbfs: remove unnecessary code after i_mmap_rwsem
 synchronization
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
 <20181203200850.6460-4-mike.kravetz@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 17 Dec 2018 16:04:15 +0530
MIME-Version: 1.0
In-Reply-To: <20181203200850.6460-4-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <b6d50644-7d0c-2c1e-2781-2c6cc81ddc80@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/4/18 1:38 AM, Mike Kravetz wrote:
> After expanding i_mmap_rwsem use for better shared pmd and page fault/
> truncation synchronization, remove code that is no longer necessary.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   fs/hugetlbfs/inode.c | 46 +++++++++++++++-----------------------------
>   mm/hugetlb.c         | 21 ++++++++++----------
>   2 files changed, 25 insertions(+), 42 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 3244147fc42b..a9c00c6ef80d 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -383,17 +383,16 @@ hugetlb_vmdelete_list(struct rb_root_cached *root, pgoff_t start, pgoff_t end)
>    * truncation is indicated by end of range being LLONG_MAX
>    *	In this case, we first scan the range and release found pages.
>    *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
> - *	maps and global counts.  Page faults can not race with truncation
> - *	in this routine.  hugetlb_no_page() prevents page faults in the
> - *	truncated range.  It checks i_size before allocation, and again after
> - *	with the page table lock for the page held.  The same lock must be
> - *	acquired to unmap a page.
> + *	maps and global counts.
>    * hole punch is indicated if end is not LLONG_MAX
>    *	In the hole punch case we scan the range and release found pages.
>    *	Only when releasing a page is the associated region/reserv map
>    *	deleted.  The region/reserv map for ranges without associated
> - *	pages are not modified.  Page faults can race with hole punch.
> - *	This is indicated if we find a mapped page.
> + *	pages are not modified.
> + *
> + * Callers of this routine must hold the i_mmap_rwsem in write mode to prevent
> + * races with page faults.

Should this patch be merged to the previous one? Because the changes to 
callers are done in the previous patch.


> + *
>    * Note: If the passed end of range value is beyond the end of file, but
>    * not LLONG_MAX this routine still performs a hole punch operation.
>    */
> @@ -423,32 +422,14 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
> 
>   		for (i = 0; i < pagevec_count(&pvec); ++i) {
> 
-aneesh
