Date: Fri, 10 Mar 2006 13:38:54 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [patch] hugetlb strict commit accounting
Message-ID: <20060310023854.GD9776@localhost.localdomain>
References: <200603100045.k2A0jAg26642@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603100045.k2A0jAg26642@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 09, 2006 at 04:45:11PM -0800, Chen, Kenneth W wrote:
> hugetlb strict commit accounting for shared mapping - v2
> 
> Changes since v1:
> 
> * change resv_huge_pages to normal unsigned long
> * add proper lock around update/access resv_huge_pages
> * resv_huge_pages record future needs of hugetlb pages
> * strict commit accounting for shared mapping
> * don't allow free_huge_pages to dip below reserved page in sysctl path
> 
> 
> David - what do you think? I don't think kernel needs to traverse page
> cache twice. It already has all the information it needed to calculate
> what are the future reservation requirement: at truncate time, it knows:
> (1) total length, (2) how much to truncate, (3) how much hugetlb page
> was free'ed because of truncate.  Then you can just do the math.  This
> version doesn't do extra traverse.  I suspect you can do the same thing
> with yours too.

Ah.. yes, I believe I can.  Erm... except I'm not sure about the
locking, I suspect in both approaches we may need to hold tree_lock
across a larger chunk of the truncate path.

> I still want to convince you that this patch is better because it allows
> arbitrary mmap offset.

I'm almost convinced.  Only fundamental thing I still dislike is the
100 or so extra lines of code for the region manipulation.


One minor nitpick remaining:
[snip]
> +#define VMACCTPG(x) ((x) >> (HPAGE_SHIFT - PAGE_SHIFT))

This macro confuses me every time I see it - the name utterly fails to
conjure its very simple meaning.  Let's kill it, it's not really any
more verbose to expand its two callers.

> +static int hugetlb_acct_memory(long delta)
> +{
> +	int ret = -ENOMEM;
> +
> +	spin_lock(&hugetlb_lock);
> +	if ((delta + resv_huge_pages) <= free_huge_pages) {
> +		resv_huge_pages += delta;
> +		ret = 0;
> +	}
> +	spin_unlock(&hugetlb_lock);
> +	return ret;
> +}
> +
> +int hugetlb_reserve_pages(struct inode *inode, struct vm_area_struct *vma)
> +{
> +	int ret, chg;
> +	int from = VMACCTPG(vma->vm_pgoff);
> +	int to = VMACCTPG(vma->vm_pgoff +
> +			 ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT));
> +
> +	chg = region_chg(&inode->i_mapping->private_list, from, to);
> +	if (chg < 0)
> +		return chg;
> +	ret = hugetlb_acct_memory(chg);
> +	if (ret < 0)
> +		return ret;
> +	region_add(&inode->i_mapping->private_list, from, to);
> +	return 0;
> +}
> +
> +void hugetlb_unreserve_pages(struct inode *inode, pgoff_t offset, int freed)
> +{
> +	int chg;
> +	chg  = region_truncate(&inode->i_mapping->private_list, offset);
> +	hugetlb_acct_memory(freed - chg);
> +}
> 
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
