Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D969B8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 04:13:04 -0500 (EST)
Date: Mon, 28 Feb 2011 10:12:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v4
Message-ID: <20110228091256.GA4648@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
 <1298485162.7236.4.camel@nimitz>
 <20110224134045.GA22122@tiehlicka.suse.cz>
 <20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
 <20110225095357.GA23241@tiehlicka.suse.cz>
 <20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 28-02-11 09:53:47, KAMEZAWA Hiroyuki wrote:
> On Fri, 25 Feb 2011 10:53:57 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 25-02-11 12:25:22, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 24 Feb 2011 14:40:45 +0100
[...]
> > > The patch itself is fine but please update the description.
> > 
> > I have updated the description but kept those parts which describe how
> > the memory is wasted for different configurations. Do you have any tips
> > how it can be improved?
> > 
> 
> This part was in your description.
> ==
> We can reduce the internal fragmentation either by imeplementing 2
> dimensional array and allocate kmalloc aligned sizes for each entry (as
> suggested in https://lkml.org/lkml/2011/2/23/232) or we can get rid of
> kmalloc altogether and allocate directly from the buddy allocator (use
> alloc_pages_exact) as suggested by Dave Hansen.
> ==
> 
> please remove 2 dimentional..... etc. That's just a history.

I just wanted to mention both approaches. OK, I can remove that, of
course.

> > > 
> > > But have some comments, below.
> > [...]
> > > > -/* __alloc_bootmem...() is protected by !slab_available() */
> > > > +static void *__init_refok alloc_mcg_table(size_t size, int nid)
> > > > +{
> > > > +	void *addr = NULL;
> > > > +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> > > > +		return addr;
> > > > +
> > > > +	if (node_state(nid, N_HIGH_MEMORY)) {
> > > > +		addr = kmalloc_node(size, GFP_KERNEL | __GFP_NOWARN, nid);
> > > > +		if (!addr)
> > > > +			addr = vmalloc_node(size, nid);
> > > > +	} else {
> > > > +		addr = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > > > +		if (!addr)
> > > > +			addr = vmalloc(size);
> > > > +	}
> > > > +
> > > > +	return addr;
> > > > +}
> > > 
> > > What is the case we need to call kmalloc_node() even when alloc_pages_exact() fails ?
> > > vmalloc() may need to be called when the size of chunk is larger than
> > > MAX_ORDER or there is fragmentation.....
> > 
> > I kept the original kmalloc with fallback to vmalloc because vmalloc is
> > more scarce resource (especially on i386 where we can have memory
> > hotplug configured as well).
> > 
> 
> My point is, if alloc_pages_exact() failes because of order of the page,
> kmalloc() will always fail. 

You are right. I thought that kmalloc can make a difference due to reclaim
but the reclaim is already triggered by alloc_pages_exact and if it doesn't
succeed there are not big chances to have those pages ready for kmalloc.

> Please remove kmalloc().

OK.

Thanks for the review again and the updated patch is bellow:

Change since v3
- updated changelog - to not mentioned 2dim. solution
- get rid of kmalloc fallback based on Kame's suggestion.
- free_page_cgroup accidentally returned void* (we do not need any return value
  there)

Changes since v2
- rename alloc_mcg_table to alloc_page_cgroup
- free__mcg_table renamed to free_page_cgroup
- get VM_BUG_ON(!slab_is_available()) back into the allocation path

---
