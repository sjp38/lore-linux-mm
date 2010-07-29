Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E37486B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:37:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T0bGsX008339
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Jul 2010 09:37:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7037145DE54
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 09:37:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4391845DE4F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 09:37:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 21CEBE38002
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 09:37:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBB241DB8052
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 09:37:15 +0900 (JST)
Date: Thu, 29 Jul 2010 09:32:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100729093226.7b899930.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100728124513.85bfa047.akpm@linux-foundation.org>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728124513.85bfa047.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010 12:45:13 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 27 Jul 2010 16:53:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > This virt-array allocates a virtally contiguous array via get_vm_area()
> > and allows object allocation per an element of array.
> > Physical pages are used only for used items in the array.
> > 
> >  - At first, the user has to create an array by create_virt_array().
> >  - At using an element, virt_array_alloc_index(index) should be called.
> >  - At freeing an element, virt_array_free_index(index) should be called.
> >  - At destroying, destroy_virt_array() should be called.
> > 
> > Item used/unused status is controlled by bitmap and back-end physical
> > pages are automatically allocated/freed. This is useful when you
> > want to access objects by index in light weight. For example,
> > 
> > 	create_virt_array(va);
> > 	struct your_struct *objmap = va->address;
> > 	Then, you can access your objects by objmap[i].
> > 
> > In usual case, holding reference by index rather than pointer can save memory.
> > But index -> object lookup cost cannot be negligible. In such case,
> > this virt-array may be helpful. Ah yes, if lookup performance is not important,
> > using radix-tree will be better (from TLB point of view). This virty-array
> > may consume VMALLOC area too much. and alloc/free routine is very slow.
> > 
> > Changelog:
> >  - fixed bugs in bitmap ops.
> >  - add offset for find_free_index.
> > 
> 
> My gut reaction to this sort of thing is "run away in terror".  It
> encourages kernel developers to operate like lackadaisical userspace
> developers and to assume that underlying code can perform heroic and
> immortal feats.  But it can't.  This is the kernel and the kernel is a
> tough and hostile place and callers should be careful and defensive and
> take great efforts to minimise the strain they put upon other systems.
> 
> IOW, can we avoid doing this?
> 

Hmm. To pack more information into page_cgroup, I'd like reduce the size of it.
One candidate is pc->mem_cgroup, a pointer. mem_cgroup has its own ID already.

If we replace pc->mem_cgroup from a pointer to ID,
-	struct mem_cgroup *mem = pc->mem_cgroup;
+	struct mem_cgroup *mem = id_to_mem_cgroup(pc->mem_cgroup);

call will be added.

The problem is that we have to call id_to_mem_cgroup routine even in
add_to_lru() and delete_from_lru(). Any kind of "lookup" routines aren't
enough fast. So, I'd like to use an array[].
(mem_cgroup_add_to_lru(), delete_from_lru() has been slow codes already...
 andI hear there is a brave guy who uses 2000+ memory cgroup on a host.

With this, we just pay pointer calculation cost but have no more memory access.

The basic idea of this virt-array[] implemenation is vmemmap(virtual memmap).
But it's highly hard-coded per architecture and use very-very big space.
So, I wrote a generic library routine.

One another idea I thought of a technique making this kind of lookup
is to prepare per-cpu lookup cache. But it adds much more complicated
controls and can't garantee "works well always".

IOW, I love this virt-array[]. But it's okay to move this routine to
memcontrol.c and don't show any interface to others if you have concerns.

If you recommened more 16bytes cost per page rather than implementing a
thing like this, okay, it's much easier.



> >
> > ...
> >
> > +void free_varray_item(struct virt_array *v, int idx)
> > +{
> > +	mutex_lock(&v->mutex);
> > +	__free_unmap_entry(v, idx);
> > +	mutex_unlock(&v->mutex);
> > +}
> 
> It's generally a bad idea for library code to perform its own locking. 
> In this case we've just made this whole facility inaccessible to code
> which runs from interrupt or atomic contexts.
> 
hmm, IIUC, because this use codes like vmalloc, this can't be used in atomic
context.  But ok, I'll move this lock and adds comment.


> > +		pg[0] = alloc_page(GFP_KERNEL);
> 
> And hard-wiring GFP_KERNEL makes this facility inaccessible to GFP_NOIO
> and GFP_NOFS contexts as well.
> 
ok, I'll pass gfp mask.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
