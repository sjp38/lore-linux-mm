Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 430CD6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:03:58 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id c6so18127684qga.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:03:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j138si24678719qhc.103.2016.04.12.08.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 08:03:57 -0700 (PDT)
Date: Tue, 12 Apr 2016 17:03:47 +0200
From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Ideas for SLUB allocator
Message-ID: <20160412170347.4e21f5d3@redhat.com>
In-Reply-To: <20160412133728.GM2781@linux.intel.com>
References: <20160412120215.000283c7@redhat.com>
	<20160412133728.GM2781@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, js1304@gmail.com, lsf-pc@lists.linux-foundation.org

On Tue, 12 Apr 2016 09:37:28 -0400
Matthew Wilcox <willy@linux.intel.com> wrote:

> On Tue, Apr 12, 2016 at 12:02:15PM +0200, Jesper Dangaard Brouer wrote:
> > Hi Rik,
> > 
> > I have another topic, which is very MM-specific.
> > 
> > I have some ideas for improving SLUB allocator further, after my work
> > on implementing the slab bulk APIs.  Maybe you can give me a small
> > slot, I only have 7 guidance slides.  Or else I hope we/I can talk
> > about these ideas in a hallway track with Christoph and others involved
> > in slab development...
> > 
> > I've already published the preliminary slides here:
> >  http://people.netfilter.org/hawk/presentations/MM-summit2016/slab_mm_summit2016.odp  
> 
> The current bulk API returns the pointers in an array.  What the
> radix tree would like is the ability to bulk allocate from a slab and
> chain the allocations through an offset.  See __radix_tree_preload()
> in lib/radix-tree.c.  I don't know if this is a common thing to do
> elsewhere in the kernel.  Obviously, radix-tree could allocate the array
> on the stack and set up the chain itself, but I would think it would be
> just as easy for slab to do it itself and save the stack space.

It does look like a good candidate for bulk alloc in __radix_tree_preload().
Especially because you have an annoying preempt_disable() and
preempt_enable() interaction loop, and reloading of this_cpu_ptr.

And RADIX_TREE_PRELOAD_SIZE==21 is not excessive alloc bulking.
Considering local_irq's are disabled during the bulk alloc.

The allocator is delivering "raw" memory, thus it does not know
anything about the callers data structure, and shouldn't. (I have
considered delivering bulk objects single linked via offset 0, as this
already happens internally in SLUB, but I decided against it)

Looking closer at your specific data structures, they are also a bit
complicated to deliver "linked" easily...

struct radix_tree_preload {
	int nr;
	/* nodes->private_data points to next preallocated node */
	struct radix_tree_node *nodes;
};

struct radix_tree_node {
	unsigned int	path;	/* Offset in parent & height from the bottom */
	unsigned int	count;
	union {
		struct {
			/* Used when ascending tree */
			struct radix_tree_node *parent;
			/* For tree user */
			void *private_data;
		};
		/* Used when freeing node */
		struct rcu_head	rcu_head;
	};
	/* For tree user */
	struct list_head private_list;
	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
};

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
