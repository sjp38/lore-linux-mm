Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE3F78D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:31:29 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1541592Ab1BJKag (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 10 Feb 2011 11:30:36 +0100
Date: Thu, 10 Feb 2011 11:30:36 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R3 1/7] mm: Add add_registered_memory() to memory hotplug API
Message-ID: <20110210103036.GA22430@router-fw-old.local.net-space.pl>
References: <20110203162514.GD1364@router-fw-old.local.net-space.pl> <20110208232538.GB9857@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110208232538.GB9857@dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 08, 2011 at 06:25:38PM -0500, Konrad Rzeszutek Wilk wrote:
> On Thu, Feb 03, 2011 at 05:25:14PM +0100, Daniel Kiper wrote:
> > add_registered_memory() adds memory ealier registered
> > as memory resource. It is required by memory hotplug
> > for Xen guests, however it could be used also by other
> > modules.
> > 
> > Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> > ---
> >  include/linux/memory_hotplug.h |    1 +
> >  mm/memory_hotplug.c            |   50 ++++++++++++++++++++++++++++++---------
> >  2 files changed, 39 insertions(+), 12 deletions(-)
> > 
> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 8122018..fe63912 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -223,6 +223,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >  
> >  extern int mem_online_node(int nid);
> > +extern int add_registered_memory(int nid, u64 start, u64 size);
> >  extern int add_memory(int nid, u64 start, u64 size);
> >  extern int arch_add_memory(int nid, u64 start, u64 size);
> >  extern int remove_memory(u64 start, u64 size);
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 321fc74..7947bdf 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -532,20 +532,12 @@ out:
> >  }
> >  
> >  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> > -int __ref add_memory(int nid, u64 start, u64 size)
> > +static int __ref __add_memory(int nid, u64 start, u64 size)
> >  {
> >  	pg_data_t *pgdat = NULL;
> >  	int new_pgdat = 0;
> > -	struct resource *res;
> >  	int ret;
> >  
> > -	lock_memory_hotplug();
> > -
> > -	res = register_memory_resource(start, size);
> > -	ret = -EEXIST;
> > -	if (!res)
> > -		goto out;
> > -
> >  	if (!node_online(nid)) {
> >  		pgdat = hotadd_new_pgdat(nid, start);
> >  		ret = -ENOMEM;
> > @@ -579,14 +571,48 @@ int __ref add_memory(int nid, u64 start, u64 size)
> >  	goto out;
> >  
> >  error:
> > -	/* rollback pgdat allocation and others */
> > +	/* rollback pgdat allocation */
> >  	if (new_pgdat)
> >  		rollback_node_hotadd(nid, pgdat);
> > -	if (res)
> > -		release_memory_resource(res);
> > +
> > +out:
> > +	return ret;
> > +}
> > +
> > +int add_registered_memory(int nid, u64 start, u64 size)
> > +{
> > +	int ret;
> > +
> > +	lock_memory_hotplug();
> > +	ret = __add_memory(nid, start, size);
> > +	unlock_memory_hotplug();
> 
> Isn't this a duplicate call to the mutex?
> The __add_memory does an unlock_memory_hotplug when it finishes
> and then you do another unlock_memory_hotplug here too.

No. Calls to lock_memory_hotplug()/unlock_memory_hotplug() were
moved from original add_memory() to add_registered_memory()
and new add_memory().

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
