Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PKal55014751
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 16:36:47 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PKafSJ220172
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:36:46 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PKaf4d003883
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:36:41 -0600
Date: Fri, 25 Apr 2008 13:36:39 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 07/18] hugetlbfs: per mount hstates
Message-ID: <20080425203639.GE14623@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.378900000@nick.local0.net> <20080425180933.GF9680@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425180933.GF9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [11:09:33 -0700], Nishanth Aravamudan wrote:
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

Err, duh, which of course you have to because of the definitions :)

However, doesn't this now make a core hugetlb functionality (which
really should only depend on CONFIG_HUGETLB_PAGE) depend on HUGETLBFS
being set to have access to HUGETLBFS_SB()? That seems to go in the
opposite direction from where we want to... Perhaps some of these
functions should be in the CONFIG_HUGETLBFS section of hugetlb.h?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
