Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 864DF8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 05:10:20 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so107971eda.12
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 02:10:20 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m14-v6si2954435ejr.112.2019.01.07.02.10.18
        for <linux-mm@kvack.org>;
        Mon, 07 Jan 2019 02:10:19 -0800 (PST)
Date: Mon, 7 Jan 2019 10:10:13 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU
 primitives
Message-ID: <20190107101013.334spvonrenl3mne@mbp>
References: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
 <20190104183715.GC187360@arrakis.emea.arm.com>
 <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Zhe <zhe.he@windriver.com>
Cc: paulmck@linux.ibm.com, josh@joshtriplett.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2019 at 03:31:18PM +0800, He Zhe wrote:
> On 1/5/19 2:37 AM, Catalin Marinas wrote:
> > On Fri, Jan 04, 2019 at 10:29:13PM +0800, zhe.he@windriver.com wrote:
> >> It's not necessary to keep consistency between readers and writers of
> >> kmemleak_lock. RCU is more proper for this case. And in order to gain better
> >> performance, we turn the reader locks to RCU read locks and writer locks to
> >> normal spin locks.
> > This won't work.
> >
> >> @@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
> >>  	struct kmemleak_object *object;
> >>  
> >>  	rcu_read_lock();
> >> -	read_lock_irqsave(&kmemleak_lock, flags);
> >>  	object = lookup_object(ptr, alias);
> >> -	read_unlock_irqrestore(&kmemleak_lock, flags);
> > The comment on lookup_object() states that the kmemleak_lock must be
> > held. That's because we don't have an RCU-like mechanism for removing
> > removing objects from the object_tree_root:
> >
> >>  
> >>  	/* check whether the object is still available */
> >>  	if (object && !get_object(object))
> >> @@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
> >>  	unsigned long flags;
> >>  	struct kmemleak_object *object;
> >>  
> >> -	write_lock_irqsave(&kmemleak_lock, flags);
> >> +	spin_lock_irqsave(&kmemleak_lock, flags);
> >>  	object = lookup_object(ptr, alias);
> >>  	if (object) {
> >>  		rb_erase(&object->rb_node, &object_tree_root);
> >>  		list_del_rcu(&object->object_list);
> >>  	}
> >> -	write_unlock_irqrestore(&kmemleak_lock, flags);
> >> +	spin_unlock_irqrestore(&kmemleak_lock, flags);
> > So here, while list removal is RCU-safe, rb_erase() is not.
> >
> > If you have time to implement an rb_erase_rcu(), than we could reduce
> > the locking in kmemleak.
> 
> Thanks, I really neglected that rb_erase is not RCU-safe here.
> 
> I'm not sure if it is practically possible to implement rb_erase_rcu. Here
> is my concern:
> In the code paths starting from rb_erase, the tree is tweaked at many
> places, in both __rb_erase_augmented and ____rb_erase_color. To my
> understanding, there are many intermediate versions of the tree
> during the erasion. In some of the versions, the tree is incomplete, i.e.
> some nodes(not the one to be deleted) are invisible to readers. I'm not
> sure if this is acceptable as an RCU implementation. Does it mean we
> need to form a rb_erase_rcu from scratch?

If it's possible, I think it would help. I had a quick look as well but
as it seemed non-trivial, I moved on to something else.

> And are there any other concerns about this attempt?

No concerns if it's possible at all. In the meantime, you could try to
replace the rw_lock with a classic spinlock. There was a thread recently
and I concluded that the rw_lock is no longer necessary as we don't have
multiple readers contention.

Yet another improvement could be to drop the kmemleak_object.lock
entirely and just rely on the main kmemleak_lock. I don't think the
fine-grained locking saves us much as in most cases where it acquires
the object->lock it already holds (or may have acquired/released) the
kmemleak_lock.

Note that even if we have an rb_erase_rcu(), we'd still need to acquire
the object->lock to prevent the scanned block being de-allocated
(unmapped in the case of vmalloc()). So if we manage with a single
kmemleak_lock (spin_lock_t), it may give a similar performance boost to
what you've got without kmemleak_lock.

FTR, the original aim of RCU grace period in kmemleak was to avoid a
recursive call into the slab freeing code; it later came in handy for
some list traversal.

-- 
Catalin
