Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 356E96B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 21:33:56 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id hw13so8743906qab.4
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 18:33:55 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id l5si4637024qai.146.2014.03.31.18.33.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 18:33:55 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 31 Mar 2014 21:33:54 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2809738C8045
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 21:33:52 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s311XqFi131480
	for <linux-mm@kvack.org>; Tue, 1 Apr 2014 01:33:52 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s311XpIv008774
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 21:33:51 -0400
Date: Mon, 31 Mar 2014 18:33:46 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
Message-ID: <20140401013346.GD5144@linux.vnet.ibm.com>
References: <20140311210614.GB946@linux.vnet.ibm.com>
 <20140313170127.GE22247@linux.vnet.ibm.com>
 <20140324230550.GB18778@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251116490.16557@nuc>
 <20140325162303.GA29977@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251152250.16870@nuc>
 <20140325181010.GB29977@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251323030.26744@nuc>
 <20140327203354.GA16651@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403290038200.24286@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1403290038200.24286@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On 29.03.2014 [00:40:41 -0500], Christoph Lameter wrote:
> On Thu, 27 Mar 2014, Nishanth Aravamudan wrote:
> 
> > > That looks to be the correct way to handle things. Maybe mark the node as
> > > offline or somehow not present so that the kernel ignores it.
> >
> > This is a SLUB condition:
> >
> > mm/slub.c::early_kmem_cache_node_alloc():
> > ...
> >         page = new_slab(kmem_cache_node, GFP_NOWAIT, node);
> > ...
> 
> So the page allocation from the node failed. We have a strange boot
> condition where the OS is aware of anode but allocations on that node
> fail.

Yep. The node exists, it's just fully exhausted at boot (due to the
presence of 16GB pages reserved at boot-time).

>  >         if (page_to_nid(page) != node) {
> >                 printk(KERN_ERR "SLUB: Unable to allocate memory from "
> >                                 "node %d\n", node);
> >                 printk(KERN_ERR "SLUB: Allocating a useless per node structure "
> >                                 "in order to be able to continue\n");
> >         }
> > ...
> >
> > Since this is quite early, and we have not set up the nodemasks yet,
> > does it make sense to perhaps have a temporary init-time nodemask that
> > we set bits in here, and "fix-up" those nodes when we setup the
> > nodemasks?
> 
> Please take care of this earlier than this. The page allocator in
> general should allow allocations from all nodes with memory during
> boot,

I'd appreciate a bit more guidance? I'm suggesting that in this case the
node functionally has no memory. So the page allocator should not allow
allocations from it -- except (I need to investigate this still)
userspace accessing the 16GB pages on that node, but that, I believe,
doesn't go through the page allocator at all, it's all from hugetlb
interfaces. It seems to me there is a bug in SLUB that we are noting
that we have a useless per-node structure for a given nid, but not
actually preventing requests to that node or reclaim because of those
allocations.

The page allocator is actually fine here, afaict. We've pulled out
memory from this node, even though it's present, so none is free. All of
that is working as expected, based upon the issue we've seen. The
problems start when we "force" (by way of a round-robin page allocation
request from /proc/sys/vm/nr_hugepages) a THISNODE allocation to come
from the exhausted node, which has no memory free, causing reclaim,
which progresses on other nodes, and thus never alleviates the
allocation failure (and can't).

I think there is a logical bug (even if it only occurs in this
particular corner case) where if reclaim progresses for a THISNODE
allocation, we don't check *where* the reclaim is progressing, and thus
may falsely be indicating that we have done some progress when in fact
the allocation that is causing reclaim will not possibly make any more
progress.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
