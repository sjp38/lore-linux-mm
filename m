Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3SIkeXM029260
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 14:46:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3SIkdpc256644
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 14:46:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3SIkd4e021068
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 14:46:39 -0400
Date: Mon, 28 Apr 2008 11:46:38 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 07/18] hugetlbfs: per mount hstates
Message-ID: <20080428184638.GA4284@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.378900000@nick.local0.net> <20080425180933.GF9680@us.ibm.com> <20080425203639.GE14623@us.ibm.com> <20080425223909.GF14623@us.ibm.com> <1209406849.2183.4.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1209406849.2183.4.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 28.04.2008 [13:20:49 -0500], Adam Litke wrote:
> On Fri, 2008-04-25 at 15:39 -0700, Nishanth Aravamudan wrote: 
> > On 25.04.2008 [13:36:39 -0700], Nishanth Aravamudan wrote:
> > > On 25.04.2008 [11:09:33 -0700], Nishanth Aravamudan wrote:
> > > > On 23.04.2008 [11:53:09 +1000], npiggin@suse.de wrote:
> > > > > Add support to have individual hstates for each hugetlbfs mount
> > > > > 
> > > > > - Add a new pagesize= option to the hugetlbfs mount that allows setting
> > > > > the page size
> > > > > - Set up pointers to a suitable hstate for the set page size option
> > > > > to the super block and the inode and the vma.
> > > > > - Change the hstate accessors to use this information
> > > > > - Add code to the hstate init function to set parsed_hstate for command
> > > > > line processing
> > > > > - Handle duplicated hstate registrations to the make command line user proof
> > > > > 
> > > > > [np: take hstate out of hugetlbfs inode and vma->vm_private_data]
> > > > > 
> > > > > Signed-off-by: Andi Kleen <ak@suse.de>
> > > > > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > > > > ---
> > > > >  fs/hugetlbfs/inode.c    |   48 ++++++++++++++++++++++++++++++++++++++----------
> > > > >  include/linux/hugetlb.h |   14 +++++++++-----
> > > > >  mm/hugetlb.c            |   16 +++-------------
> > > > >  mm/memory.c             |   18 ++++++++++++++++--
> > > > >  4 files changed, 66 insertions(+), 30 deletions(-)
> > > > > 
> > > > > Index: linux-2.6/include/linux/hugetlb.h
> > > > > ===================================================================
> > > > 
> > > > <snip>
> > > > 
> > > > > @@ -226,19 +228,21 @@ extern struct hstate hstates[HUGE_MAX_HS
> > > > > 
> > > > >  #define global_hstate (hstates[0])
> > > > > 
> > > > > -static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> > > > > +static inline struct hstate *hstate_inode(struct inode *i)
> > > > >  {
> > > > > -	return &global_hstate;
> > > > > +	struct hugetlbfs_sb_info *hsb;
> > > > > +	hsb = HUGETLBFS_SB(i->i_sb);
> > > > > +	return hsb->hstate;
> > > > >  }
> > > > > 
> > > > >  static inline struct hstate *hstate_file(struct file *f)
> > > > >  {
> > > > > -	return &global_hstate;
> > > > > +	return hstate_inode(f->f_dentry->d_inode);
> > > > >  }
> > > > > 
> > > > > -static inline struct hstate *hstate_inode(struct inode *i)
> > > > > +static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> > > > >  {
> > > > > -	return &global_hstate;
> > > > > +	return hstate_file(vma->vm_file);
> > > > 
> > > > Odd, diff seems to think you've moved these two functions around
> > > > (hstate_{vma,inode})...
> > > 
> > > Err, duh, which of course you have to because of the definitions :)
> > > 
> > > However, doesn't this now make a core hugetlb functionality (which
> > > really should only depend on CONFIG_HUGETLB_PAGE) depend on HUGETLBFS
> > > being set to have access to HUGETLBFS_SB()? That seems to go in the
> > > opposite direction from where we want to... Perhaps some of these
> > > functions should be in the CONFIG_HUGETLBFS section of hugetlb.h?
> > 
> > Even if you don't move anything as I had originally suggested, I think
> > you need to express the CONFIG_ dependencies more clearly (that now
> > HUGETLB_PAGE depends on HUGETLBFS, afaict).
> > 
> > Urgh, there's actually other similar issue(s) in this file already...
> > 
> > if CONFIG_HUGETLBFS, is_file_hugepages() is defined and calls
> > is_file_shm_hugepages(), but that is defined in shm.h, which is only
> > included if CONFIG_HUGETLB_PAGE... Adam, that seems buggy? Is this just
> > further evidence that our current separation of the two options is
> > bull-honky?
> 
> Yeah.  I'd say there is little reason to separate them anymore.  I am
> not an expert on the history here, but I suspect the original reason for
> separating CONFIG_HUGETLBFS and CONFIG_HUGETLB_PAGE was a lack of
> psychic abilities.  Hugetlbfs is ubiquitous now and there is no other
> valid way to use huge pages.  Even SHM_HUGETLB shared memory segments
> use hugetlbfs.

Yeah, I was thinking it might make sense to merge them now and then
separate them back out later, if we do add any other interfaces to
hugepages.

> One thing you should check is which config options are required for
> the hugetlb kernel mappings.  Otherwise, I think we are in the clear
> to merge them.

Yep, thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
