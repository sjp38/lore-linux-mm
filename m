Date: Fri, 23 May 2008 07:24:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 07/18] hugetlbfs: per mount hstates
Message-ID: <20080523052425.GG13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.378900000@nick.local0.net> <20080425180933.GF9680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425180933.GF9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 11:09:33AM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:09 +1000], npiggin@suse.de wrote:
> > Add support to have individual hstates for each hugetlbfs mount
> > 
> > - Add a new pagesize= option to the hugetlbfs mount that allows setting
> > the page size
> > - Set up pointers to a suitable hstate for the set page size option
> > to the super block and the inode and the vma.
> > - Change the hstate accessors to use this information
> > - Add code to the hstate init function to set parsed_hstate for command
> > line processing
> > - Handle duplicated hstate registrations to the make command line user proof
> > 
> > [np: take hstate out of hugetlbfs inode and vma->vm_private_data]
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  fs/hugetlbfs/inode.c    |   48 ++++++++++++++++++++++++++++++++++++++----------
> >  include/linux/hugetlb.h |   14 +++++++++-----
> >  mm/hugetlb.c            |   16 +++-------------
> >  mm/memory.c             |   18 ++++++++++++++++--
> >  4 files changed, 66 insertions(+), 30 deletions(-)
> > 
> > Index: linux-2.6/include/linux/hugetlb.h
> > ===================================================================
> 
> <snip>
> 
> > @@ -226,19 +228,21 @@ extern struct hstate hstates[HUGE_MAX_HS
> > 
> >  #define global_hstate (hstates[0])
> > 
> > -static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> > +static inline struct hstate *hstate_inode(struct inode *i)
> >  {
> > -	return &global_hstate;
> > +	struct hugetlbfs_sb_info *hsb;
> > +	hsb = HUGETLBFS_SB(i->i_sb);
> > +	return hsb->hstate;
> >  }
> > 
> >  static inline struct hstate *hstate_file(struct file *f)
> >  {
> > -	return &global_hstate;
> > +	return hstate_inode(f->f_dentry->d_inode);
> >  }
> > 
> > -static inline struct hstate *hstate_inode(struct inode *i)
> > +static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> >  {
> > -	return &global_hstate;
> > +	return hstate_file(vma->vm_file);
> 
> Odd, diff seems to think you've moved these two functions around
> (hstate_{vma,inode})...

Yep, one depends on the other...

 
> >  static inline unsigned long huge_page_size(struct hstate *h)
> > Index: linux-2.6/fs/hugetlbfs/inode.c
> > ===================================================================
> 
> <snip>
> 
> > @@ -780,17 +784,13 @@ hugetlbfs_parse_options(char *options, s
> >  			break;
> > 
> >  		case Opt_size: {
> > - 			unsigned long long size;
> >  			/* memparse() will accept a K/M/G without a digit */
> >  			if (!isdigit(*args[0].from))
> >  				goto bad_val;
> >  			size = memparse(args[0].from, &rest);
> > -			if (*rest == '%') {
> > -				size <<= HPAGE_SHIFT;
> > -				size *= max_huge_pages;
> > -				do_div(size, 100);
> > -			}
> > -			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
> > +			setsize = SIZE_STD;
> > +			if (*rest == '%')
> > +				setsize = SIZE_PERCENT;
> 
> This seems like a change that could be pulled into its own clean-up
> patch and merged up quicker?
> 
> > @@ -801,6 +801,19 @@ hugetlbfs_parse_options(char *options, s
> >  			pconfig->nr_inodes = memparse(args[0].from, &rest);
> >  			break;
> > 
> > +		case Opt_pagesize: {
> > +			unsigned long ps;
> > +			ps = memparse(args[0].from, &rest);
> > +			pconfig->hstate = size_to_hstate(ps);
> > +			if (!pconfig->hstate) {
> > +				printk(KERN_ERR
> > +				"hugetlbfs: Unsupported page size %lu MB\n",
> > +					ps >> 20);
> 
> This again will give odd output for pagesizes < 1MB (64k on power).
> 
> > @@ -808,6 +821,18 @@ hugetlbfs_parse_options(char *options, s
> >  			break;
> >  		}
> >  	}
> > +
> > +	/* Do size after hstate is set up */
> > +	if (setsize > NO_SIZE) {
> > +		struct hstate *h = pconfig->hstate;
> > +		if (setsize == SIZE_PERCENT) {
> > +			size <<= huge_page_shift(h);
> > +			size *= h->max_huge_pages;
> > +			do_div(size, 100);
> > +		}
> > +		pconfig->nr_blocks = (size >> huge_page_shift(h));
> > +	}
> 
> Oh, I see. We just moved the percent caclulation down here. Sorry about
> that, seems sensible to leave it in this patch then.
> 
> >  bad_val:
> > @@ -832,6 +857,7 @@ hugetlbfs_fill_super(struct super_block 
> >  	config.uid = current->fsuid;
> >  	config.gid = current->fsgid;
> >  	config.mode = 0755;
> > +	config.hstate = size_to_hstate(HPAGE_SIZE);
> 
> So, we still only have one hugepage size, which is why this is written
> this way. Seems odd that an early patch adds multiple hugepage size
> support, but we don't actually need it in the series until much later...

True, but it is quite a long process and it is nice to have it working
each step of the way in small steps... I think the overall way Andi's done
the patchset is quite nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
