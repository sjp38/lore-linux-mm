Date: Sat, 23 Oct 2004 17:28:57 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Migration cache
Message-ID: <20041023192857.GA12334@logos.cnet>
References: <20041021103005.GA18917@logos.cnet> <Pine.LNX.4.44.0410212005590.12985-100000@localhost.localdomain> <20041021182218.GE21530@logos.cnet> <20041022.154912.129768542.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041022.154912.129768542.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: hugh@veritas.com, haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2004 at 03:49:12PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > On Thu, Oct 21, 2004 at 08:09:35PM +0100, Hugh Dickins wrote:
> > > On Thu, 21 Oct 2004, Marcelo Tosatti wrote:
> > > > On Thu, Oct 21, 2004 at 02:10:44AM +0900, Hirokazu Takahashi wrote:
> > > > > 
> > > > > I guess it would be better to reserve one swap type for the migration
> > > > > cache instead of reserving the bit to reduce the impact of the maximum
> > > > > number of swap types.
> > > 
> > > I thought the same ...
> > > 
> > > > By reserving one swap type we would also use a bit. Using a swap type is 
> > > > the same thing as using a bit in the swap pagetableentry. (the swap type 
> > > > has 5 bits reserved for swap devices, 2^5 = 32 swap devices).
> > > 
> > > ... and don't understand your response.
> > > 
> > > Reserving a swap type leaves 31 swap devices for normal use, okay;
> > > but reserving a bit leaves only 16 swap devices for normal use.
> > 
> > Oh stupid idiot I am! Of course, we can then remove "pte_is_migration" 
> > (and all the related pte handling code). 
> > 
> > Added to TODO list. 
> > 
> > If anyone wants to contribute that it would be cool cause I'm 
> > quite busy with other stuff right now.
> 
> The following code is my simple idea, which might help you.
> 
> 
> #define MIGRATION_TYPE	(MAX_SWAPFILES - 1)
> 
> static inline int pte_is_migration(pte_t pte)
> {
> 	unsigned long swp_type;
> 	swp_entry_t arch_entry;
> 
> 	arch_entry = __pte_to_swp_entry(pte);
> 
> 	swp_type = __swp_type(arch_entry);
> 
> 	return swp_type == MIGRATION_TYPE;
> }

OK thanks this code works fine (just pasted into swapops.h and tested).
Thanks.

> static inline int PageMigration(page)
> { 
>       swp_entry_t entry = { .val = page->private,};
>       return (PageSwapCache(page) && swp_type(entry) == MIGRATION_TYPE);
> }

Oh and with that we no longer need PG_migration bit, but, page->private 
does not contain swp_type information (MIGRATION_TYPE bit) in it. Its simply 
an offset counting from 0 increasing sequentially. 

ANDing migration type bit into the offset should work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
