Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 6F9E46B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 04:24:37 -0400 (EDT)
Date: Mon, 29 Jul 2013 17:24:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: hugepage related lockdep trace.
Message-ID: <20130729082453.GB29129@bbox>
References: <20130717153223.GD27731@redhat.com>
 <20130718000901.GA31972@blaptop>
 <87hafrdatb.fsf@linux.vnet.ibm.com>
 <20130719001303.GB23354@blaptop>
 <20130723140120.GG8677@dhcp22.suse.cz>
 <20130724024428.GA14795@bbox>
 <20130725133040.GI12818@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130725133040.GI12818@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Michal,

On Thu, Jul 25, 2013 at 03:30:40PM +0200, Michal Hocko wrote:
> On Wed 24-07-13 11:44:28, Minchan Kim wrote:
> > On Tue, Jul 23, 2013 at 04:01:20PM +0200, Michal Hocko wrote:
> > > On Fri 19-07-13 09:13:03, Minchan Kim wrote:
> > > > On Thu, Jul 18, 2013 at 11:12:24PM +0530, Aneesh Kumar K.V wrote:
> > > [...]
> > > > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > > > index 83aff0a..2cb1be3 100644
> > > > > --- a/mm/hugetlb.c
> > > > > +++ b/mm/hugetlb.c
> > > > > @@ -3266,8 +3266,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> > > > >  		put_page(virt_to_page(spte));
> > > > >  	spin_unlock(&mm->page_table_lock);
> > > > >  out:
> > > > > -	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> > > > >  	mutex_unlock(&mapping->i_mmap_mutex);
> > > > > +	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> > > > >  	return pte;
> > > > 
> > > > I am blind on hugetlb but not sure it doesn't break eb48c071.
> > > > Michal?
> > > 
> > > Well, it is some time since I debugged the race and all the details
> > > vanished in the meantime. But this part of the changelog suggests that
> > > this indeed breaks the fix:
> > > "
> > >     This patch addresses the issue by moving pmd_alloc into huge_pmd_share
> > >     which guarantees that the shared pud is populated in the same critical
> > >     section as pmd.  This also means that huge_pte_offset test in
> > >     huge_pmd_share is serialized correctly now which in turn means that the
> > >     success of the sharing will be higher as the racing tasks see the pud
> > >     and pmd populated together.
> > > "
> > > 
> > > Besides that I fail to see how moving pmd_alloc down changes anything.
> > > Even if pmd_alloc triggered reclaim then we cannot trip over the same
> > > i_mmap_mutex as hugetlb pages are not reclaimable because they are not
> > > on the LRU.
> > 
> > I thought we could map some part of binary with normal page and other part
> > of the one with MAP_HUGETLB so that a address space could have both normal
> > page and HugeTLB page. Okay, it's impossible so HugeTLB pages are not on LRU.
> > Then, above lockdep warning is totally false positive.
> > Best solution is avoiding pmd_alloc with holding i_mmap_mutex but we need it
> > to fix eb48c071 so how about this if we couldn't have a better idea?
> 
> Shouldn't we rather use a hugetlb specific lock_class_key. I am not
> familiar with lockdep much but something like bellow should do the
> trick?

Looks good to me.
Could you resend it with formal patch with Ccing Peter for Dave to confirm it?
Below just a nitpick.

> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index a3f868a..40a61f6 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -463,6 +463,8 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
>  	return inode;
>  }
>  
> +struct lock_class_key hugetlbfs_i_mmap_mutex_key;

Let's add comment why we need this special something.
How about this?

/*
 * Now, reclaim path never hold hugetlbfs_inode->i_mmap_mutex while it could
 * hold normal inode->i_mmap_mutex so this annoation avoids a lockdep splat.
 */
static struct lock_class_key hugetlbctx_mutex;


> +
>  static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  					struct inode *dir,
>  					umode_t mode, dev_t dev)
> @@ -474,6 +476,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  		struct hugetlbfs_inode_info *info;
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
> +		lockdep_set_class(&inode->i_mapping->i_mmap_mutex, &hugetlbfs_i_mmap_mutex_key);
>  		inode->i_mapping->a_ops = &hugetlbfs_aops;
>  		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
