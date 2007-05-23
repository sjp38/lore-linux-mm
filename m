Date: Wed, 23 May 2007 10:45:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [2/4] migration by kernel
Message-Id: <20070523104558.a877d869.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705221143450.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221143450.29456@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007 11:49:04 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:
> 
> > +config MIGRATION_BY_KERNEL
> > +	bool "Page migration by kernel's page scan"
> > +	def_bool y
> > +	depends on MIGRATION
> > +	help
> > +	  Allows page migration from kernel context. This means page migration
> > +	  can be done by codes other than sys_migrate() system call. Will add
> > +	  some additional check code in page migration.
> 
> I think the scope of this is much bigger than you imagine. This is also 
> going to be useful when Mel is going to implement defragmentation. So I 
> think this should not be a separate option but be on by default.

ok. (Then I can remove this config.)


> >  static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> > -			struct page *page, int force)
> > +			struct page *page, int force, int context)
> 
> context is set if there is no context? Call this nocontext instead?
> 
ok, this should be.
> >  
> > -	if (rc)
> > +	if (rc) {
> >  		remove_migration_ptes(page, page);
> > +	}
> 
> Why are you adding { } here?
> 
maybe my garbage from older version.

> > +#ifdef CONFIG_MIGRATION_BY_KERNEL
> > +struct anon_vma *anon_vma_hold(struct page *page) {
> > +	struct anon_vma *anon_vma;
> > +	anon_vma = page_lock_anon_vma(page);
> > +	if (!anon_vma)
> > +		return NULL;
> > +	atomic_set(&anon_vma->ref, 1);
> 
> Why use an atomic value if it is set and cleared within a spinlock?

anon_vma_free(), which see this value, doesn't take any lock and use atomic ops.
I used atomic ops to handle atomic_t.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
