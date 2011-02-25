Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 201D98D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 04:54:05 -0500 (EST)
Date: Fri, 25 Feb 2011 10:53:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v3
Message-ID: <20110225095357.GA23241@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
 <1298485162.7236.4.camel@nimitz>
 <20110224134045.GA22122@tiehlicka.suse.cz>
 <20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 25-02-11 12:25:22, KAMEZAWA Hiroyuki wrote:
> On Thu, 24 Feb 2011 14:40:45 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Here is the second version of the patch. I have used alloc_pages_exact
> > instead of the complex double array approach.
> > 
> > I still fallback to kmalloc/vmalloc because hotplug can happen quite
> > some time after boot and we can end up not having enough continuous
> > pages at that time. 
> > 
> > I am also thinking whether it would make sense to introduce
> > alloc_pages_exact_node function which would allocate pages from the
> > given node.
> > 
> > Any thoughts?
> 
> The patch itself is fine but please update the description.

I have updated the description but kept those parts which describe how
the memory is wasted for different configurations. Do you have any tips
how it can be improved?

> 
> But have some comments, below.
[...]
> > -/* __alloc_bootmem...() is protected by !slab_available() */
> > +static void *__init_refok alloc_mcg_table(size_t size, int nid)
> > +{
> > +	void *addr = NULL;
> > +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> > +		return addr;
> > +
> > +	if (node_state(nid, N_HIGH_MEMORY)) {
> > +		addr = kmalloc_node(size, GFP_KERNEL | __GFP_NOWARN, nid);
> > +		if (!addr)
> > +			addr = vmalloc_node(size, nid);
> > +	} else {
> > +		addr = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > +		if (!addr)
> > +			addr = vmalloc(size);
> > +	}
> > +
> > +	return addr;
> > +}
> 
> What is the case we need to call kmalloc_node() even when alloc_pages_exact() fails ?
> vmalloc() may need to be called when the size of chunk is larger than
> MAX_ORDER or there is fragmentation.....

I kept the original kmalloc with fallback to vmalloc because vmalloc is
more scarce resource (especially on i386 where we can have memory
hotplug configured as well).

> 
> And the function name, alloc_mcg_table(), I don't like it because this is an
> allocation for page_cgroup.
> 
> How about alloc_page_cgroup() simply ?

OK, I have no preferences for the name. alloc_page_cgroup sounds good as
well.

I have also added VM_BUG_ON(!slab_is_available()) back to the allocation
path.

Thanks for the review. The updated patch is bellow:

Changes since v2
- rename alloc_mcg_table to alloc_page_cgroup
- free__mcg_table renamed to free_page_cgroup
- get VM_BUG_ON(!slab_is_available()) back into the allocation path
--- 
