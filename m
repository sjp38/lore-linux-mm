Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 967DE6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:07:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r16so184849866pfg.4
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 23:07:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id hc8si24376862pac.263.2016.10.16.23.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 23:07:09 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9H63va0012280
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:07:09 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 264eq8na3f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:07:08 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Oct 2016 00:07:07 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 15/17] dax: add struct iomap based DAX PMD support
In-Reply-To: <1476386619-2727-1-git-send-email-ross.zwisler@linux.intel.com>
References: <20161013154224.GB30680@quack2.suse.cz> <1476386619-2727-1-git-send-email-ross.zwisler@linux.intel.com>
Date: Mon, 17 Oct 2016 11:36:55 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87a8e3tsow.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Ross Zwisler <ross.zwisler@linux.intel.com> writes:

> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This patch allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled using the new struct
> iomap based fault handlers.
>
> There are currently three types of DAX 4k entries: 4k zero pages, 4k DAX
> mappings that have an associated block allocation, and 4k DAX empty
> entries.  The empty entries exist to provide locking for the duration of a
> given page fault.
>
> This patch adds three equivalent 2MiB DAX entries: Huge Zero Page (HZP)
> entries, PMD DAX entries that have associated block allocations, and 2 MiB
> DAX empty entries.
>
> Unlike the 4k case where we insert a struct page* into the radix tree for
> 4k zero pages, for HZP we insert a DAX exceptional entry with the new
> RADIX_DAX_HZP flag set.  This is because we use a single 2 MiB zero page in
> every 2MiB hole mapping, and it doesn't make sense to have that same struct
> page* with multiple entries in multiple trees.  This would cause contention
> on the single page lock for the one Huge Zero Page, and it would break the
> page->index and page->mapping associations that are assumed to be valid in
> many other places in the kernel.
>
> One difficult use case is when one thread is trying to use 4k entries in
> radix tree for a given offset, and another thread is using 2 MiB entries
> for that same offset.  The current code handles this by making the 2 MiB
> user fall back to 4k entries for most cases.  This was done because it is
> the simplest solution, and because the use of 2MiB pages is already
> opportunistic.
>
> If we were to try to upgrade from 4k pages to 2MiB pages for a given range,
> we run into the problem of how we lock out 4k page faults for the entire
> 2MiB range while we clean out the radix tree so we can insert the 2MiB
> entry.  We can solve this problem if we need to, but I think that the cases
> where both 2MiB entries and 4K entries are being used for the same range
> will be rare enough and the gain small enough that it probably won't be
> worth the complexity.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c            | 378 +++++++++++++++++++++++++++++++++++++++++++++++-----
>  include/linux/dax.h |  55 ++++++--
>  mm/filemap.c        |   3 +-
>  3 files changed, 386 insertions(+), 50 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 0582c7c..153cfd5 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -76,6 +76,26 @@ static void dax_unmap_atomic(struct block_device *bdev,
>  	blk_queue_exit(bdev->bd_queue);
>  }
>  
> +static int dax_is_pmd_entry(void *entry)
> +{
> +	return (unsigned long)entry & RADIX_DAX_PMD;
> +}
> +
> +static int dax_is_pte_entry(void *entry)
> +{
> +	return !((unsigned long)entry & RADIX_DAX_PMD);
> +}
> +
> +static int dax_is_zero_entry(void *entry)
> +{
> +	return (unsigned long)entry & RADIX_DAX_HZP;
> +}

How about dax_is_pmd_zero_entry() ?


> +
> +static int dax_is_empty_entry(void *entry)
> +{
> +	return (unsigned long)entry & RADIX_DAX_EMPTY;
> +}
> +

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
