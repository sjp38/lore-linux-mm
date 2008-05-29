Date: Wed, 28 May 2008 18:51:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3]
 hugetlb-allow-huge-page-mappings-to-be-created-without-reservations
Message-Id: <20080528185121.86805747.akpm@linux-foundation.org>
In-Reply-To: <1211929806.0@pinky>
References: <exportbomb.1211929624@pinky>
	<1211929806.0@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com, Michael Kerrisk <mtk.manpages@googlemail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 May 2008 00:10:06 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> +		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
> +				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
> +		return region_chg(&inode->i_mapping->private_list,
> +							idx, idx + 1);
> +
> +	} else {
> +		if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> +			return 1;
> +	}
> +
> +	return 0;
> +}
> +static void vma_commit_reservation(struct vm_area_struct *vma,
> +							unsigned long addr)
> +{
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	struct inode *inode = mapping->host;
> +
> +	if (vma->vm_flags & VM_SHARED) {
> +		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
> +				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
> +		region_add(&inode->i_mapping->private_list, idx, idx + 1);

There are a couple more users of the little helper function which I
suggested that Mel add.

They both use ulong too - I do think that pgoff_t has a little
documentary value.

I guess these changes impact the manpages, but the mmap manpage doesn't
seem to know about huge pages at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
