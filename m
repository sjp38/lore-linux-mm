Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id DFCAC6B0035
	for <linux-mm@kvack.org>; Sat, 29 Mar 2014 01:40:44 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so1599401igc.4
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 22:40:44 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id ac8si9193824icc.108.2014.03.28.22.40.43
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 22:40:44 -0700 (PDT)
Date: Sat, 29 Mar 2014 00:40:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
In-Reply-To: <20140327203354.GA16651@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1403290038200.24286@nuc>
References: <20140311210614.GB946@linux.vnet.ibm.com> <20140313170127.GE22247@linux.vnet.ibm.com> <20140324230550.GB18778@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251116490.16557@nuc> <20140325162303.GA29977@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251152250.16870@nuc>
 <20140325181010.GB29977@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251323030.26744@nuc> <20140327203354.GA16651@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On Thu, 27 Mar 2014, Nishanth Aravamudan wrote:

> > That looks to be the correct way to handle things. Maybe mark the node as
> > offline or somehow not present so that the kernel ignores it.
>
> This is a SLUB condition:
>
> mm/slub.c::early_kmem_cache_node_alloc():
> ...
>         page = new_slab(kmem_cache_node, GFP_NOWAIT, node);
> ...

So the page allocation from the node failed. We have a strange boot
condition where the OS is aware of anode but allocations on that node
fail.

 >         if (page_to_nid(page) != node) {
>                 printk(KERN_ERR "SLUB: Unable to allocate memory from "
>                                 "node %d\n", node);
>                 printk(KERN_ERR "SLUB: Allocating a useless per node structure "
>                                 "in order to be able to continue\n");
>         }
> ...
>
> Since this is quite early, and we have not set up the nodemasks yet,
> does it make sense to perhaps have a temporary init-time nodemask that
> we set bits in here, and "fix-up" those nodes when we setup the
> nodemasks?

Please take care of this earlier than this. The page allocator in general
should allow allocations from all nodes with memory during boot,




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
