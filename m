Date: Wed, 28 Sep 2005 23:20:27 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/3 htlb-acct] Demand faulting for huge pages
Message-Id: <20050928232027.28e1bb93.akpm@osdl.org>
In-Reply-To: <1127939593.26401.38.camel@localhost.localdomain>
References: <1127939141.26401.32.camel@localhost.localdomain>
	<1127939593.26401.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke <agl@us.ibm.com> wrote:
>
> Initial Post (Thu, 18 Aug 2005)
> 
> Basic overcommit checking for hugetlb_file_map() based on an implementation
> used with demand faulting in SLES9.
> 
> Since demand faulting can't guarantee the availability of pages at mmap time,
> this patch implements a basic sanity check to ensure that the number of huge
> pages required to satisfy the mmap are currently available.  Despite the
> obvious race, I think it is a good start on doing proper accounting.  I'd like
> to work towards an accounting system that mimics the semantics of normal pages
> (especially for the MAP_PRIVATE/COW case).  That work is underway and builds on
> what this patch starts.
> 
> Huge page shared memory segments are simpler and still maintain their commit on
> shmget semantics.
> 
> Diffed against 2.6.14-rc2-git6
> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
>  inode.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 47 insertions(+)
> diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
> --- reference/fs/hugetlbfs/inode.c
> +++ current/fs/hugetlbfs/inode.c
> @@ -45,9 +45,51 @@ static struct backing_dev_info hugetlbfs
>  
>  int sysctl_hugetlb_shm_group;
>  
> +static void huge_pagevec_release(struct pagevec *pvec);

nit: personally I prefer to move the helper function to the top of the file
rather than having to forward-declare it.

> +unsigned long
> +huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma)
> +{

What does this function do?  Seems to count all the present pages within a
vma which are backed by a particular hugetlbfs file?  Or something?

If so, the chosen name seems strange.  And it definitely needs a decent
comment.


> +	int i;
> +	struct pagevec pvec;
> +	unsigned long start = vma->vm_start;
> +	unsigned long end = vma->vm_end;
> +	unsigned long hugepages = (end - start) >> HPAGE_SHIFT;

`hugepages' is the size of the vma

> +	pgoff_t next = vma->vm_pgoff;
> +	pgoff_t endpg = next + ((end - start) >> PAGE_SHIFT);
> +	struct inode *inode = vma->vm_file->f_dentry->d_inode;
> +
> +	/*
> +	 * Shared memory segments are accounted for at shget time,
> +	 * not at shmat (when the mapping is actually created) so 
> +	 * check here if the memory has already been accounted for.
> +	 */
> +	if (inode->i_blocks != 0)
> +		return 0;
> +
> +	pagevec_init(&pvec, 0);
> +	while (next < endpg) {
> +		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
> +			break;
> +		for (i = 0; i < pagevec_count(&pvec); i++) {
> +			struct page *page = pvec.pages[i];
> +			if (page->index > next)
> +				next = page->index;
> +			if (page->index >= endpg)
> +				break;
> +			next++;
> +			hugepages--;

And we subtract one from it for each present page.

> +		}
> +		huge_pagevec_release(&pvec);
> +	}
> +	return hugepages << HPAGE_SHIFT;
> +}

So it seems to be returning the number of bytes which are still unpopulated
within this vma?

Think you can rework this code to reduce my perplexity?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
