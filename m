Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5498A6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 21:13:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u144so543413pgb.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:13:50 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id h1si10036002pln.121.2017.10.10.18.13.48
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 18:13:49 -0700 (PDT)
Date: Wed, 11 Oct 2017 12:09:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v8 06/14] xfs: wire up MAP_DIRECT
Message-ID: <20171011010922.GY3666@dastard>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150764697001.16882.13486539828150761233.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150764697001.16882.13486539828150761233.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Oct 10, 2017 at 07:49:30AM -0700, Dan Williams wrote:
> @@ -1009,6 +1019,22 @@ xfs_file_llseek(
>  }
>  
>  /*
> + * MAP_DIRECT faults can only be serviced while the FL_LAYOUT lease is
> + * valid. See map_direct_invalidate.
> + */
> +static int
> +xfs_can_fault_direct(
> +	struct vm_area_struct	*vma)
> +{
> +	if (!xfs_vma_is_direct(vma))
> +		return 0;
> +
> +	if (!test_map_direct_valid(vma->vm_private_data))
> +		return VM_FAULT_SIGBUS;
> +	return 0;
> +}

Better, but I'm going to be an annoying pedant here: a "can
<something>" check should return a boolean true/false.

Also, it's a bit jarring to see that a non-direct VMA that /can't/
do direct faults returns the same thing as a direct-vma that /can/
do direct faults, so a couple of extra comments for people who will
quickly forget how this code works (i.e. me) will be helpful. Say
something like this:

/*
 * MAP_DIRECT faults can only be serviced while the FL_LAYOUT lease is
 * valid. See map_direct_invalidate.
 */
static bool
xfs_vma_has_direct_lease(
	struct vm_area_struct	*vma)
{
	/* Non MAP_DIRECT vmas do not require layout leases */
	if (!xfs_vma_is_direct(vma))
		return true;

	if (!test_map_direct_valid(vma->vm_private_data))
		return false;

	/* We have a valid lease */
	return true;
}

.....
	if (!xfs_vma_has_direct_lease(vma)) {
		ret = VM_FAULT_SIGBUS;
		goto out_unlock;
	}
....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
