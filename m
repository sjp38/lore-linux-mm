Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k2A84mvq028942 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:04:48 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k2A84mHC002964 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:04:48 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 12E6F34A590
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:04:48 +0900 (JST)
Received: from ml9.s.css.fujitsu.com (ml9.s.css.fujitsu.com [10.23.4.199])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A41634A5A3
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:04:47 +0900 (JST)
Date: Fri, 10 Mar 2006 17:04:45 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH: 004/017](RFC) Memory hotplug for new nodes v.3. (generic alloc pgdat)
In-Reply-To: <20060309040045.17dbf286.akpm@osdl.org>
References: <20060308212719.002A.Y-GOTO@jp.fujitsu.com> <20060309040045.17dbf286.akpm@osdl.org>
Message-Id: <20060310161339.CA7B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +#ifdef CONFIG_HAVE_ARCH_NODEDATA_EXTENSION
> > +/*
> > + * For supporint node-hotadd, we have to allocate new pgdat.
> > + *
> > + * If an arch have generic style NODE_DATA(),
> > + * node_data[nid] = kzalloc() works well . But it depends on each arch.
> > + *
> > + * In general, generic_alloc_nodedata() is used.
> > + * generic...is a local function in mm/memory_hotplug.c
> > + *
> > + * Now, arch_free_nodedata() is just defined for error path of node_hot_add.
> > + *
> > + */
> > +extern struct pglist_data * arch_alloc_nodedata(int nid);
> > +extern void arch_free_nodedata(pg_data_t *pgdat);
> > +
> > +#else /* !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
> > +#define arch_alloc_nodedata(nid)	generic_alloc_nodedata(nid)
> > +#define arch_free_nodedata(pgdat)	generic_free_nodedata(pgdat)
> > +
> > +#ifdef CONFIG_NUMA
> > +/*
> > + * If ARCH_HAS_NODEDATA_EXTENSION=n, this func is used to allocate pgdat.
> > + */
> > +static inline struct pglist_data *generic_alloc_nodedata(int nid)
> > +{
> > +	return kzalloc(sizeof(struct pglist_data), GFP_ATOMIC);
> > +}
> 
> >From an interface design point of view it's usually best to pass the
> gfp_flags ito a function which performs memory allocation, rather than
> assuming the worst-case like this.
> 
> If it's known that callers of generic_alloc_nodedata() can just never ever
> be permitted to sleep then OK.  But GFP_KERNEL allocations are always
> preferable.

Ok. I'll change GFP_KERNEL for it.

> > +/*
> > + * This definition is just for error path in node hotadd.
> > + * For node hotremove, we have to replace this.
> > + */
> > +static inline void generic_free_nodedata(struct pglist_data *pgdat)
> > +{
> > +	kfree(pgdat);
> > +}
> > +
> > +#else /* !CONFIG_NUMA */
> > +/* never called */
> > +static inline struct pglist_data *generic_alloc_nodedata(int nid)
> > +{
> > +	BUG();
> > +	return NULL;
> > +}
> > +static inline void generic_free_nodedata(struct pglist_data *pgdat)
> > +{
> > +}
> > +#endif /* CONFIG_NUMA */
> > +#endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
> > +
> 
> Should the patch provide stubs for generic_alloc_nodedata() and
> generic_alloc_nodedata() if !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION?
> 
> (If all callers are also inside #ifdef CONFIG_HAVE_ARCH_NODEDATA_EXTENSION
> then the answer would be "no").

No. 
They are stubs for !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION.
They are inside of !CONFIG case. Not for special archtectures.
I intend that if an architecture needs some kind of extension, 
it should define CONFIG_HAVE_ARCH..... and arch_alloc_nodedata(nid).

Did I make mistake comment for #ifdef?

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
