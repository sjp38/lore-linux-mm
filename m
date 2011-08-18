Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9706B0169
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 18:29:27 -0400 (EDT)
Date: Thu, 18 Aug 2011 15:28:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-Id: <20110818152846.e76ff944.akpm@linux-foundation.org>
In-Reply-To: <4E4C3A2B.3000405@cray.com>
References: <4E4C3A2B.3000405@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Barry <abarry@cray.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>

On Wed, 17 Aug 2011 17:01:15 -0500
Andrew Barry <abarry@cray.com> wrote:

> This patch fixes a race between the umount of a hugetlbfs filesystem, and quota
> updates in that filesystem, which can result in the update of the filesystem
> quota record, after the record structure has been freed.
> 
> Rather than an address-space struct pointer, it puts a hugetlbfs_sb_info struct
> pointer into page_private of the page struct. A reference count and an active
> bit are added to the hugetlbfs_sb_info struct; the reference count is increased
> by hugetlb_get_quota and decreased by hugetlb_put_quota. When hugetlbfs is
> unmounted, it frees the hugetlbfs_sb_info struct, but only if the reference
> count is zero, otherwise it clears the active bit. The last hugetlb_put_quota
> then frees the hugetlbfs_sb_info struct.
> 
> Discussion was titled:  Fix refcounting in hugetlbfs quota handling.
> See:  https://lkml.org/lkml/2011/8/11/28

The changelog doesn't actually describe the race - it just asserts that
there is one.  This makes it unnecessarily difficult to review the
fix!  So I didn't really look at the code - I just scanned the trivial
stuff.

The patch was somewhat wordwrapped - please fix the email client then
resend.

> +		if (hugetlb_get_quota(HUGETLBFS_SB(inode->i_mapping->host->i_sb), chg))
> +			hugetlb_put_quota(HUGETLBFS_SB(inode->i_mapping->host->i_sb), chg);
> +	set_page_private(page, (unsigned long)HUGETLBFS_SB(inode->i_mapping->host->i_sb));
> +			hugetlb_put_quota(HUGETLBFS_SB(vma->vm_file->f_mapping->host->i_sb), reserve);
> +	if (hugetlb_get_quota(HUGETLBFS_SB(inode->i_mapping->host->i_sb), chg))
> +		hugetlb_put_quota(HUGETLBFS_SB(inode->i_mapping->host->i_sb), chg);
> +	hugetlb_put_quota(HUGETLBFS_SB(inode->i_mapping->host->i_sb), (chg - freed));

Are all the inode->i_mapping->host pointer hops actually necessary?  I
didn't see anything about them in the changelog and I'd expect that
inode->i_mapping->host is always equal to `inode' for hugetlbfs?

If they _are_ necessary then I'd suggest that the code could be cleaned
up by adding

static struct hugetlbfs_sb_info *inode_to_sb(struct inode *inode)
{
	return HUGETLBFS_SB(inode->i_mapping->host->i_sb);
}

to hugetlbfs.c.  This will reduce the relatively large number of
checkpatch warnings which were added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
