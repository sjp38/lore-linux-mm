Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06046C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6558D2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:20:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZVTBxzdm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6558D2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE7C36B0003; Mon, 25 Mar 2019 13:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9AA76B0006; Mon, 25 Mar 2019 13:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C39BE6B0007; Mon, 25 Mar 2019 13:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 384F76B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:20:23 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 6so3040283lje.9
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:20:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rfHbYb+Gh1HahxQDhbrWtdqktQqCwcMgpLIeD6QFCIo=;
        b=pzQYmnu/hlBouu2SuOD3xIXFS3/Kw9RyeGlOQbUaxLkNgb8za3orksSnu0bP8bjAoB
         o+VCBY4PMKgrBOyhXM/Dz4GrOVa1SFOeiIzU+jZgllzpOBPXH8VA0zCJjbD36OBMLEfA
         vjgHnhglz6BUJb1pJhRdyaa4rhDGYjhraEEtY3o7W5F42U3YrUxGp7vek9GrJsG/fCfL
         x+06aFd3cPDBifMhE7ApxxEur0JlrcOlfFFrurq3L32tM4exheNYmXKnZGbnB3p7Z/MZ
         /O2X496Bj6lZCQKbfVwfQvq/Bq0RywWQC6oPb62Z8AavTslEh86iFR/q5F1vt1uUU5ae
         NzFA==
X-Gm-Message-State: APjAAAWXQoqe1IcRz9JYOkWp86OH6psxU8FMxx0/W+rUgBx1X9BNmkFu
	3sHO5zvmA0YmRDJq+HKiv2Zq7mCykNkFt+O3JukqsMyi+IVM5fOVzRVcPLthfeJilpdgkLPDIEr
	n+pzgr9qMCfjrFThRzOrdw39MrARPp31RfCe6FmHez3+F5TXjZyNTOv8OA3RimXwL0g==
X-Received: by 2002:a2e:9151:: with SMTP id q17mr13559139ljg.87.1553534422402;
        Mon, 25 Mar 2019 10:20:22 -0700 (PDT)
X-Received: by 2002:a2e:9151:: with SMTP id q17mr13559051ljg.87.1553534420374;
        Mon, 25 Mar 2019 10:20:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553534420; cv=none;
        d=google.com; s=arc-20160816;
        b=G+e3K7FHdap6OO73ljqgoeXYvJilm8bihSSJpwcOSUfkHI8VEj32hoATgPjsgqqHuC
         J72WKwOINvc/Xwd6U0IxWks2hXJsdh1kYskmMovfcOyuNNiQo6DfjJEMbeFfWzUuiIvq
         kZdq0uuWuaOKqo5qcXpc7L25pwmCfVbfqOVB2DEKGQ34W2WIUyeWib1DFyrgCIB9D36D
         Bl+D5PxOZtPcz/Q0Z2ot1icXxSGMzZ3zuPtckSYUV64u267PMfkxQ3H0xmk91KxfUfA7
         jOVExu4ET7UJBtbq41hPgbWQj0NGA5j7XWX9Y1ocj9z09o4T97PufPyguF0XL7HTiWfh
         dySg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=rfHbYb+Gh1HahxQDhbrWtdqktQqCwcMgpLIeD6QFCIo=;
        b=EXKvPsz97CPrD/VGPZ4LZ7pm3eOY9QOxcfRZ+5H8ZAF5yvKZs7FVCRp2ikzyamzND9
         wplOQrJfgxBuB40GVNa35YnRuANnqXFn+ZzHV/crywwNN1p7AfePNg3cb5pldJMCnoNa
         vMf3G6y2ArTOwj3q+F0xDHQOrpmwiUNcq3EZtOTFcjPtRQnjI/epvQit7IXOfpnYks45
         y6BiBhbqVfRrxjqGyQ0clMIE76pU7jdQ08Dy+QaD3s6jStlfp2kp/+ENMCa9Z4Y/2QkR
         JQMZ9JoPJT1KF2OUOIsZ6N67QAjr8kAHnIQCokl7zuvydMcHU+lgi6b0/lMFoQAfaAA6
         3R2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZVTBxzdm;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor4631418ljh.7.2019.03.25.10.20.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 10:20:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZVTBxzdm;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rfHbYb+Gh1HahxQDhbrWtdqktQqCwcMgpLIeD6QFCIo=;
        b=ZVTBxzdmq37CsuRrnGOVrRgnEHc5qdeMD0QBYDHuqorhje2PXxi7N0Ygtot5iKPbA4
         MLL9N5C1bVACArNFiT0/6ecwy1Pum9Qe+Q6brRVEIPDK7aWqROvNHm/scuLgUbcNNG25
         bjXXq/AkHsZhY8UxIG0Tsd6oezLvdvIXBFCCzvrwu0nprr63e35MiS5hFqsUC4drjdf2
         feQq7vnbOBYjCAid78AMfj4g1+CTIKpc66YSQhrrN/IaewyAblOlKDZGG5N5S2FcBpaf
         I9WtqCPFJXUbJIGkMW3fJW/nO+Nj1ihtcuVktVjVF9+0R1n1MQHFXCqSHHwZvoXno15c
         OZTw==
X-Google-Smtp-Source: APXvYqwsCcYhqobkisZVJFAOCLqYFcLWsXdFpmIBmueeR8MQ8toXtsGZckAik1BMwB6n4/o7iMr4NA==
X-Received: by 2002:a05:651c:d7:: with SMTP id 23mr13857640ljr.5.1553534419826;
        Mon, 25 Mar 2019 10:20:19 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id m19sm411084lji.70.2019.03.25.10.20.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Mar 2019 10:20:18 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 25 Mar 2019 18:20:10 +0100
To: Roman Gushchin <guro@fb.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Message-ID: <20190325172010.q343626klaozjtg4@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321190327.11813-2-urezki@gmail.com>
 <20190322215413.GA15943@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322215413.GA15943@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman!

> Hi, Uladzislau!
> 
> Definitely a clever idea and very promising numbers!
> 
> The overall approach makes total sense to me.
> 
> I tried to go through the code, but it was a bit challenging.
> I wonder, if you can split it into smaller parts to simplify the review?
> 
I appreciate that you spent your time on it. Thank you :)

> Idk how easy is to split the core (maybe the area merging code can be
> separated?), but at least the optionally compiled debug code can
> be moved into separate patches.
> 
At least debug code should be split, i totally agree with you. As for
"merging" part. We can split it, but then it will be kind of broken.
I mean it will not work because one part/patch depends on other.

Another approach is to make "prepare patches" and one final replacing
patch that will remove old code. But i am not sure if it is worth it
or not.

> Some small nits/questions below.
> 
> > 
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > ---
> >  include/linux/vmalloc.h |    6 +-
> >  mm/vmalloc.c            | 1109 ++++++++++++++++++++++++++++++++++++-----------
> >  2 files changed, 871 insertions(+), 244 deletions(-)
> > 
> > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > index 398e9c95cd61..ad483378fdd1 100644
> > --- a/include/linux/vmalloc.h
> > +++ b/include/linux/vmalloc.h
> > @@ -45,12 +45,16 @@ struct vm_struct {
> >  struct vmap_area {
> >  	unsigned long va_start;
> >  	unsigned long va_end;
> > +
> > +	/*
> > +	 * Largest available free size in subtree.
> > +	 */
> > +	unsigned long subtree_max_size;
> >  	unsigned long flags;
> >  	struct rb_node rb_node;         /* address sorted rbtree */
> >  	struct list_head list;          /* address sorted list */
> >  	struct llist_node purge_list;    /* "lazy purge" list */
> >  	struct vm_struct *vm;
> > -	struct rcu_head rcu_head;
> >  };
> >  
> >  /*
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 755b02983d8d..29e9786299cf 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -31,6 +31,7 @@
> >  #include <linux/compiler.h>
> >  #include <linux/llist.h>
> >  #include <linux/bitops.h>
> > +#include <linux/rbtree_augmented.h>
> >  
> >  #include <linux/uaccess.h>
> >  #include <asm/tlbflush.h>
> > @@ -320,8 +321,9 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
> >  }
> >  EXPORT_SYMBOL(vmalloc_to_pfn);
> >  
> > -
> >  /*** Global kva allocator ***/
> > +#define DEBUG_AUGMENT_PROPAGATE_CHECK 0
> > +#define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
> >  
> >  #define VM_LAZY_FREE	0x02
> >  #define VM_VM_AREA	0x04
> > @@ -331,14 +333,76 @@ static DEFINE_SPINLOCK(vmap_area_lock);
> >  LIST_HEAD(vmap_area_list);
> >  static LLIST_HEAD(vmap_purge_list);
> >  static struct rb_root vmap_area_root = RB_ROOT;
> > +static bool vmap_initialized __read_mostly;
> > +
> > +/*
> > + * This kmem_cache is used for vmap_area objects. Instead of
> > + * allocating from slab we reuse an object from this cache to
> > + * make things faster. Especially in "no edge" splitting of
> > + * free block.
> > + */
> > +static struct kmem_cache *vmap_area_cachep;
> > +
> > +/*
> > + * This linked list is used in pair with free_vmap_area_root.
> > + * It gives O(1) access to prev/next to perform fast coalescing.
> > + */
> > +static LIST_HEAD(free_vmap_area_list);
> > +
> > +/*
> > + * This augment red-black tree represents the free vmap space.
> > + * All vmap_area objects in this tree are sorted by va->va_start
> > + * address. It is used for allocation and merging when a vmap
> > + * object is released.
> > + *
> > + * Each vmap_area node contains a maximum available free block
> > + * of its sub-tree, right or left. Therefore it is possible to
> > + * find a lowest match of free area.
> > + */
> > +static struct rb_root free_vmap_area_root = RB_ROOT;
> > +
> > +static inline unsigned long
> > +__va_size(struct vmap_area *va)
> > +{
> > +	return (va->va_end - va->va_start);
> > +}
> > +
> > +static unsigned long
> > +get_subtree_max_size(struct rb_node *node)
> > +{
> > +	struct vmap_area *va;
> > +
> > +	va = rb_entry_safe(node, struct vmap_area, rb_node);
> > +	return va ? va->subtree_max_size : 0;
> > +}
> > +
> > +/*
> > + * Gets called when remove the node and rotate.
> > + */
> > +static unsigned long
> > +compute_subtree_max_size(struct vmap_area *va)
> > +{
> > +	unsigned long max_size = __va_size(va);
> > +	unsigned long child_max_size;
> > +
> > +	child_max_size = get_subtree_max_size(va->rb_node.rb_right);
> > +	if (child_max_size > max_size)
> > +		max_size = child_max_size;
> >  
> > -/* The vmap cache globals are protected by vmap_area_lock */
> > -static struct rb_node *free_vmap_cache;
> > -static unsigned long cached_hole_size;
> > -static unsigned long cached_vstart;
> > -static unsigned long cached_align;
> > +	child_max_size = get_subtree_max_size(va->rb_node.rb_left);
> > +	if (child_max_size > max_size)
> > +		max_size = child_max_size;
> >  
> > -static unsigned long vmap_area_pcpu_hole;
> > +	return max_size;
> > +}
> > +
> > +RB_DECLARE_CALLBACKS(static, free_vmap_area_rb_augment_cb,
> > +	struct vmap_area, rb_node, unsigned long, subtree_max_size,
> > +	compute_subtree_max_size)
> > +
> > +static void purge_vmap_area_lazy(void);
> > +static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> > +static unsigned long lazy_max_pages(void);
> >  
> >  static struct vmap_area *__find_vmap_area(unsigned long addr)
> >  {
> > @@ -359,41 +423,623 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
> >  	return NULL;
> >  }
> >  
> > -static void __insert_vmap_area(struct vmap_area *va)
> > +/*
> > + * This function returns back addresses of parent node
> > + * and its left or right link for further processing.
> > + */
> > +static inline void
> > +__find_va_links(struct vmap_area *va,
> > +	struct rb_root *root, struct rb_node *from,
> > +	struct rb_node **parent, struct rb_node ***link)
> 
> This function returns a pointer to parent, and it doesn't use
> the initial value of (*parent). Can't it just return it?
> I mean something like:
> 
> static struct rb_node *__find_va_links(struct vmap_area *va,
> 	struct rb_root *root, struct rb_node *from,
> 	struct rb_node ***link) { ... }
> 
> It would simplify things a bit.
Yes, we can do that. Do not see any issues returning "parent" instead.

> 
> Also this triple pointer looks scary.
> If it returns a parent and one of two children, can't it return
> a desired child instead? Or it can be NULL with a non-NULL parent?
> 
We use triple pointer because we just want to return back to caller address
either of rb_left or rb_right pointer of the "parent" node to bind a new
rb_node to the tree. parent->rb_left/parent->rb_right are NULL, whereas their
addresses("&") are not.

**p = &parent->rb_left;
*link = p;

<snip rbtree.h>
static inline void rb_link_node(struct rb_node *node,
struct rb_node *parent, struct rb_node **rb_link)
...
*rb_link = node;
<snip rbtree.h>

I think we should simplify it by just returning pointer to pointer
and leave how "parent" is returned:

static inline struct rb_node **
__find_va_links(struct vmap_area *va,
	struct rb_root *root, struct rb_node *from,
	struct rb_node **parent)
{
	struct vmap_area *tmp_va;
	struct rb_node **link;

	if (root) {
		link = &root->rb_node;
		if (unlikely(!*link)) {
			*parent = NULL;
			return link;
		}
	} else {
		link = &from;
	}

	/*
	 * Go to the bottom of the tree.
	 */
	do {
		tmp_va = rb_entry(*link, struct vmap_area, rb_node);

		/*
		 * During the traversal we also do some sanity check.
		 * Trigger the BUG() if there are sides(left/right)
		 * or full overlaps.
		 */
		if (va->va_start < tmp_va->va_end &&
				va->va_end <= tmp_va->va_start)
			link = &(*link)->rb_left;
		else if (va->va_end > tmp_va->va_start &&
				va->va_start >= tmp_va->va_end)
			link = &(*link)->rb_right;
		else
			BUG();
	} while (*link);

	*parent = &tmp_va->rb_node;
	return link;
}

What do you think?

> >  {
> > -	struct rb_node **p = &vmap_area_root.rb_node;
> > -	struct rb_node *parent = NULL;
> > -	struct rb_node *tmp;
> > +	struct vmap_area *tmp_va;
> >  
> > -	while (*p) {
> > -		struct vmap_area *tmp_va;
> > +	if (root) {
> > +		*link = &root->rb_node;
> > +		if (unlikely(!**link)) {
> > +			*parent = NULL;
> > +			return;
> > +		}
> > +	} else {
> > +		*link = &from;
> > +	}
> >  
> > -		parent = *p;
> > -		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
> > -		if (va->va_start < tmp_va->va_end)
> > -			p = &(*p)->rb_left;
> > -		else if (va->va_end > tmp_va->va_start)
> > -			p = &(*p)->rb_right;
> > +	/*
> > +	 * Go to the bottom of the tree.
> > +	 */
> > +	do {
> > +		tmp_va = rb_entry(**link, struct vmap_area, rb_node);
> > +
> > +		/*
> > +		 * During the traversal we also do some sanity check.
> > +		 * Trigger the BUG() if there are sides(left/right)
> > +		 * or full overlaps.
> > +		 */
> > +		if (va->va_start < tmp_va->va_end &&
> > +				va->va_end <= tmp_va->va_start)
> > +			*link = &(**link)->rb_left;
> > +		else if (va->va_end > tmp_va->va_start &&
> > +				va->va_start >= tmp_va->va_end)
> > +			*link = &(**link)->rb_right;
> >  		else
> >  			BUG();
> > +	} while (**link);
> > +
> > +	*parent = &tmp_va->rb_node;
> > +}
> > +
> > +static inline void
> > +__find_va_free_siblings(struct rb_node *parent, struct rb_node **link,
> > +	struct list_head **prev, struct list_head **next)
> > +{
> > +	struct list_head *list;
> > +
> > +	if (likely(parent)) {
> > +		list = &rb_entry(parent, struct vmap_area, rb_node)->list;
> > +		if (&parent->rb_right == link) {
> > +			*next = list->next;
> > +			*prev = list;
> > +		} else {
> > +			*prev = list->prev;
> > +			*next = list
> 
> So, does it mean that this function always returns two following elements?
> Can't it return a single element using the return statement instead?
> The second one can be calculated as ->next?
> 
Yes, they follow each other and if you return "prev" for example you can easily
refer to next. But you will need to access "next" anyway. I would rather keep
implementation, because it strictly clear what it return when you look at this
function.

But if there are some objections and we can simplify, let's discuss :)

> > +		}
> > +	} else {
> > +		/*
> > +		 * The red-black tree where we try to find VA neighbors
> > +		 * before merging or inserting is empty, i.e. it means
> > +		 * there is no free vmap space. Normally it does not
> > +		 * happen but we handle this case anyway.
> > +		 */
> > +		*prev = *next = &free_vmap_area_list;
> 
> And for example, return NULL in this case.
> 
Then we will need to check in the __merge_or_add_vmap_area() that
next/prev are not NULL and not head. But i do not like current implementation
as well, since it is hardcoded to specific list head.

> > +}
> >  
> > -	rb_link_node(&va->rb_node, parent, p);
> > -	rb_insert_color(&va->rb_node, &vmap_area_root);
> > +static inline void
> > +__link_va(struct vmap_area *va, struct rb_root *root,
> > +	struct rb_node *parent, struct rb_node **link, struct list_head *head)
> > +{
> > +	/*
> > +	 * VA is still not in the list, but we can
> > +	 * identify its future previous list_head node.
> > +	 */
> > +	if (likely(parent)) {
> > +		head = &rb_entry(parent, struct vmap_area, rb_node)->list;
> > +		if (&parent->rb_right != link)
> > +			head = head->prev;
> > +	}
> >  
> > -	/* address-sort this list */
> > -	tmp = rb_prev(&va->rb_node);
> > -	if (tmp) {
> > -		struct vmap_area *prev;
> > -		prev = rb_entry(tmp, struct vmap_area, rb_node);
> > -		list_add_rcu(&va->list, &prev->list);
> > -	} else
> > -		list_add_rcu(&va->list, &vmap_area_list);
> > +	/* Insert to the rb-tree */
> > +	rb_link_node(&va->rb_node, parent, link);
> > +	if (root == &free_vmap_area_root) {
> > +		/*
> > +		 * Some explanation here. Just perform simple insertion
> > +		 * to the tree. We do not set va->subtree_max_size to
> > +		 * its current size before calling rb_insert_augmented().
> > +		 * It is because of we populate the tree from the bottom
> > +		 * to parent levels when the node _is_ in the tree.
> > +		 *
> > +		 * Therefore we set subtree_max_size to zero after insertion,
> > +		 * to let __augment_tree_propagate_from() puts everything to
> > +		 * the correct order later on.
> > +		 */
> > +		rb_insert_augmented(&va->rb_node,
> > +			root, &free_vmap_area_rb_augment_cb);
> > +		va->subtree_max_size = 0;
> > +	} else {
> > +		rb_insert_color(&va->rb_node, root);
> > +	}
> > +
> > +	/* Address-sort this list */
> > +	list_add(&va->list, head);
> >  }
> >  
> > -static void purge_vmap_area_lazy(void);
> > +static inline void
> > +__unlink_va(struct vmap_area *va, struct rb_root *root)
> > +{
> > +	/*
> > +	 * During merging a VA node can be empty, therefore
> > +	 * not linked with the tree nor list. Just check it.
> > +	 */
> > +	if (!RB_EMPTY_NODE(&va->rb_node)) {
> > +		if (root == &free_vmap_area_root)
> > +			rb_erase_augmented(&va->rb_node,
> > +				root, &free_vmap_area_rb_augment_cb);
> > +		else
> > +			rb_erase(&va->rb_node, root);
> >  
> > -static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> > +		list_del(&va->list);
> > +	}
> > +}
> > +
> > +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> > +static void
> > +augment_tree_propagate_do_check(struct rb_node *n)
> > +{
> > +	struct vmap_area *va;
> > +	struct rb_node *node;
> > +	unsigned long size;
> > +	bool found = false;
> > +
> > +	if (n == NULL)
> > +		return;
> > +
> > +	va = rb_entry(n, struct vmap_area, rb_node);
> > +	size = va->subtree_max_size;
> > +	node = n;
> > +
> > +	while (node) {
> > +		va = rb_entry(node, struct vmap_area, rb_node);
> > +
> > +		if (get_subtree_max_size(node->rb_left) == size) {
> > +			node = node->rb_left;
> > +		} else {
> > +			if (__va_size(va) == size) {
> > +				found = true;
> > +				break;
> > +			}
> > +
> > +			node = node->rb_right;
> > +		}
> > +	}
> > +
> > +	if (!found) {
> > +		va = rb_entry(n, struct vmap_area, rb_node);
> > +		pr_emerg("tree is corrupted: %lu, %lu\n",
> > +			__va_size(va), va->subtree_max_size);
> > +	}
> > +
> > +	augment_tree_propagate_do_check(n->rb_left);
> > +	augment_tree_propagate_do_check(n->rb_right);
> > +}
> > +
> > +static void augment_tree_propagate_from_check(void)
> > +{
> > +	augment_tree_propagate_do_check(free_vmap_area_root.rb_node);
> > +}
> > +#endif
> > +
> > +/*
> > + * This function populates subtree_max_size from bottom to upper
> > + * levels starting from VA point. The propagation must be done
> > + * when VA size is modified by changing its va_start/va_end. Or
> > + * in case of newly inserting of VA to the tree.
> > + *
> > + * It means that __augment_tree_propagate_from() must be called:
> > + * - After VA has been inserted to the tree(free path);
> > + * - After VA has been shrunk(allocation path);
> > + * - After VA has been increased(merging path).
> > + *
> > + * Please note that, it does not mean that upper parent nodes
> > + * and their subtree_max_size are recalculated all the time up
> > + * to the root node.
> > + *
> > + *       4--8
> > + *        /\
> > + *       /  \
> > + *      /    \
> > + *    2--2  8--8
> > + *
> > + * For example if we modify the node 4, shrinking it to 2, then
> > + * no any modification is required. If we shrink the node 2 to 1
> > + * its subtree_max_size is updated only, and set to 1. If we shrink
> > + * the node 8 to 6, then its subtree_max_size is set to 6 and parent
> > + * node becomes 4--6.
> > + */
> > +static inline void
> > +__augment_tree_propagate_from(struct vmap_area *va)
> > +{
> > +	struct rb_node *node = &va->rb_node;
> > +	unsigned long new_va_sub_max_size;
> > +
> > +	while (node) {
> > +		va = rb_entry(node, struct vmap_area, rb_node);
> > +		new_va_sub_max_size = compute_subtree_max_size(va);
> > +
> > +		/*
> > +		 * If the newly calculated maximum available size of the
> > +		 * subtree is equal to the current one, then it means that
> > +		 * the tree is propagated correctly. So we have to stop at
> > +		 * this point to save cycles.
> > +		 */
> > +		if (va->subtree_max_size == new_va_sub_max_size)
> > +			break;
> > +
> > +		va->subtree_max_size = new_va_sub_max_size;
> > +		node = rb_parent(&va->rb_node);
> > +	}
> > +
> > +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> > +	augment_tree_propagate_from_check();
> > +#endif
> > +}
> > +
> > +static void
> > +__insert_vmap_area(struct vmap_area *va,
> > +	struct rb_root *root, struct list_head *head)
> > +{
> > +	struct rb_node **link;
> > +	struct rb_node *parent;
> > +
> > +	__find_va_links(va, root, NULL, &parent, &link);
> > +	__link_va(va, root, parent, link, head);
> > +}
> > +
> > +static void
> > +__insert_vmap_area_augment(struct vmap_area *va,
> > +	struct rb_node *from, struct rb_root *root,
> > +	struct list_head *head)
> > +{
> > +	struct rb_node **link;
> > +	struct rb_node *parent;
> > +
> > +	if (from)
> > +		__find_va_links(va, NULL, from, &parent, &link);
> > +	else
> > +		__find_va_links(va, root, NULL, &parent, &link);
> > +
> > +	__link_va(va, root, parent, link, head);
> > +	__augment_tree_propagate_from(va);
> > +}
> > +
> > +static inline void
> > +__remove_vmap_area_common(struct vmap_area *va,
> > +	struct rb_root *root)
> > +{
> > +	__unlink_va(va, root);
> > +}
> > +
> > +/*
> > + * Merge de-allocated chunk of VA memory with previous
> > + * and next free blocks. If coalesce is not done a new
> > + * free area is inserted. If VA has been merged, it is
> > + * freed.
> > + */
> > +static inline void
> > +__merge_or_add_vmap_area(struct vmap_area *va,
> > +	struct rb_root *root, struct list_head *head)
> > +{
> > +	struct vmap_area *sibling;
> > +	struct list_head *next, *prev;
> > +	struct rb_node **link;
> > +	struct rb_node *parent;
> > +	bool merged = false;
> > +
> > +	/*
> > +	 * Find a place in the tree where VA potentially will be
> > +	 * inserted, unless it is merged with its sibling/siblings.
> > +	 */
> > +	__find_va_links(va, root, NULL, &parent, &link);
> > +
> > +	/*
> > +	 * Get next/prev nodes of VA to check if merging can be done.
> > +	 */
> > +	__find_va_free_siblings(parent, link, &prev, &next);
> > +
> > +	/*
> > +	 * start            end
> > +	 * |                |
> > +	 * |<------VA------>|<-----Next----->|
> > +	 *                  |                |
> > +	 *                  start            end
> > +	 */
> > +	if (next != head) {
> > +		sibling = list_entry(next, struct vmap_area, list);
> > +		if (sibling->va_start == va->va_end) {
> > +			sibling->va_start = va->va_start;
> > +
> > +			/* Check and update the tree if needed. */
> > +			__augment_tree_propagate_from(sibling);
> > +
> > +			/* Remove this VA, it has been merged. */
> > +			__remove_vmap_area_common(va, root);
> > +
> > +			/* Free vmap_area object. */
> > +			kmem_cache_free(vmap_area_cachep, va);
> > +
> > +			/* Point to the new merged area. */
> > +			va = sibling;
> > +			merged = true;
> > +		}
> > +	}
> > +
> > +	/*
> > +	 * start            end
> > +	 * |                |
> > +	 * |<-----Prev----->|<------VA------>|
> > +	 *                  |                |
> > +	 *                  start            end
> > +	 */
> > +	if (prev != head) {
> > +		sibling = list_entry(prev, struct vmap_area, list);
> > +		if (sibling->va_end == va->va_start) {
> > +			sibling->va_end = va->va_end;
> > +
> > +			/* Check and update the tree if needed. */
> > +			__augment_tree_propagate_from(sibling);
> > +
> > +			/* Remove this VA, it has been merged. */
> > +			__remove_vmap_area_common(va, root);
> > +
> > +			/* Free vmap_area object. */
> > +			kmem_cache_free(vmap_area_cachep, va);
> > +
> > +			return;
> > +		}
> > +	}
> > +
> > +	if (!merged) {
> > +		__link_va(va, root, parent, link, head);
> > +		__augment_tree_propagate_from(va);
> > +	}
> > +}
> > +
> > +static inline bool
> > +is_within_this_va(struct vmap_area *va, unsigned long size,
> > +	unsigned long align, unsigned long vstart)
> > +{
> > +	unsigned long nva_start_addr;
> > +
> > +	if (va->va_start > vstart)
> > +		nva_start_addr = ALIGN(va->va_start, align);
> > +	else
> > +		nva_start_addr = ALIGN(vstart, align);
> > +
> > +	/* Can be overflowed due to big size or alignment. */
> > +	if (nva_start_addr + size < nva_start_addr ||
> > +			nva_start_addr < vstart)
> > +		return false;
> > +
> > +	return (nva_start_addr + size <= va->va_end);
> > +}
> > +
> > +/*
> > + * Find the first free block(lowest start address) in the tree,
> > + * that will accomplish the request corresponding to passing
> > + * parameters.
> > + */
> > +static inline struct vmap_area *
> > +__find_vmap_lowest_match(unsigned long size,
> > +	unsigned long align, unsigned long vstart)
> > +{
> > +	struct vmap_area *va;
> > +	struct rb_node *node;
> > +	unsigned long length;
> > +
> > +	/* Start from the root. */
> > +	node = free_vmap_area_root.rb_node;
> > +
> > +	/* Adjust the search size for alignment overhead. */
> > +	length = size + align - 1;
> > +
> > +	while (node) {
> > +		va = rb_entry(node, struct vmap_area, rb_node);
> > +
> > +		if (get_subtree_max_size(node->rb_left) >= length &&
> > +				vstart < va->va_start) {
> > +			node = node->rb_left;
> > +		} else {
> > +			if (is_within_this_va(va, size, align, vstart))
> > +				return va;
> > +
> > +			/*
> > +			 * Does not make sense to go deeper towards the right
> > +			 * sub-tree if it does not have a free block that is
> > +			 * equal or bigger to the requested search length.
> > +			 */
> > +			if (get_subtree_max_size(node->rb_right) >= length) {
> > +				node = node->rb_right;
> > +				continue;
> > +			}
> > +
> > +			/*
> > +			 * OK. We roll back and find the fist right sub-tree,
> > +			 * that will satisfy the search criteria. It can happen
> > +			 * only once due to "vstart" restriction.
> > +			 */
> > +			while ((node = rb_parent(node))) {
> > +				va = rb_entry(node, struct vmap_area, rb_node);
> > +				if (is_within_this_va(va, size, align, vstart))
> > +					return va;
> > +
> > +				if (get_subtree_max_size(node->rb_right) >= length &&
> > +						vstart <= va->va_start) {
> > +					node = node->rb_right;
> > +					break;
> > +				}
> > +			}
> > +		}
> > +	}
> > +
> > +	return NULL;
> > +}
> > +
> > +#if DEBUG_AUGMENT_LOWEST_MATCH_CHECK
> > +#include <linux/random.h>
> > +
> > +static struct vmap_area *
> > +__find_vmap_lowest_linear_match(unsigned long size,
> > +	unsigned long align, unsigned long vstart)
> > +{
> > +	struct vmap_area *va;
> > +
> > +	list_for_each_entry(va, &free_vmap_area_list, list) {
> > +		if (!is_within_this_va(va, size, align, vstart))
> > +			continue;
> > +
> > +		return va;
> > +	}
> > +
> > +	return NULL;
> > +}
> > +
> > +static void
> > +__find_vmap_lowest_match_check(unsigned long size)
> > +{
> > +	struct vmap_area *va_1, *va_2;
> > +	unsigned long vstart;
> > +	unsigned int rnd;
> > +
> > +	get_random_bytes(&rnd, sizeof(rnd));
> > +	vstart = VMALLOC_START + rnd;
> > +
> > +	va_1 = __find_vmap_lowest_match(size, 1, vstart);
> > +	va_2 = __find_vmap_lowest_linear_match(size, 1, vstart);
> > +
> > +	if (va_1 != va_2)
> > +		pr_emerg("not lowest: t: 0x%p, l: 0x%p, v: 0x%lx\n",
> > +			va_1, va_2, vstart);
> > +}
> > +#endif
> > +
> > +enum alloc_fit_type {
> > +	NOTHING_FIT = 0,
> > +	FL_FIT_TYPE = 1,	/* full fit */
> > +	LE_FIT_TYPE = 2,	/* left edge fit */
> > +	RE_FIT_TYPE = 3,	/* right edge fit */
> > +	NE_FIT_TYPE = 4		/* no edge fit */
> > +};
> > +
> > +static inline u8
> > +__classify_va_fit_type(struct vmap_area *va,
> > +	unsigned long nva_start_addr, unsigned long size)
> > +{
> > +	u8 fit_type;
> > +
> > +	/* Check if it is within VA. */
> > +	if (nva_start_addr < va->va_start ||
> > +			nva_start_addr + size > va->va_end)
> > +		return NOTHING_FIT;
> > +
> > +	/* Now classify. */
> > +	if (va->va_start == nva_start_addr) {
> > +		if (va->va_end == nva_start_addr + size)
> > +			fit_type = FL_FIT_TYPE;
> > +		else
> > +			fit_type = LE_FIT_TYPE;
> > +	} else if (va->va_end == nva_start_addr + size) {
> > +		fit_type = RE_FIT_TYPE;
> > +	} else {
> > +		fit_type = NE_FIT_TYPE;
> > +	}
> > +
> > +	return fit_type;
> > +}
> > +
> > +static inline int
> > +__adjust_va_to_fit_type(struct vmap_area *va,
> > +	unsigned long nva_start_addr, unsigned long size, u8 fit_type)
> > +{
> > +	struct vmap_area *lva;
> > +
> > +	if (fit_type == FL_FIT_TYPE) {
> > +		/*
> > +		 * No need to split VA, it fully fits.
> > +		 *
> > +		 * |               |
> > +		 * V      NVA      V
> > +		 * |---------------|
> > +		 */
> > +		__remove_vmap_area_common(va, &free_vmap_area_root);
> > +		kmem_cache_free(vmap_area_cachep, va);
> > +	} else if (fit_type == LE_FIT_TYPE) {
> > +		/*
> > +		 * Split left edge of fit VA.
> > +		 *
> > +		 * |       |
> > +		 * V  NVA  V   R
> > +		 * |-------|-------|
> > +		 */
> > +		va->va_start += size;
> > +	} else if (fit_type == RE_FIT_TYPE) {
> > +		/*
> > +		 * Split right edge of fit VA.
> > +		 *
> > +		 *         |       |
> > +		 *     L   V  NVA  V
> > +		 * |-------|-------|
> > +		 */
> > +		va->va_end = nva_start_addr;
> > +	} else if (fit_type == NE_FIT_TYPE) {
> > +		/*
> > +		 * Split no edge of fit VA.
> > +		 *
> > +		 *     |       |
> > +		 *   L V  NVA  V R
> > +		 * |---|-------|---|
> > +		 */
> > +		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> > +		if (unlikely(!lva))
> > +			return -1;
> > +
> > +		/*
> > +		 * Build the remainder.
> > +		 */
> > +		lva->va_start = va->va_start;
> > +		lva->va_end = nva_start_addr;
> > +
> > +		/*
> > +		 * Shrink this VA to remaining size.
> > +		 */
> > +		va->va_start = nva_start_addr + size;
> > +	} else {
> > +		return -1;
> > +	}
> > +
> > +	if (fit_type != FL_FIT_TYPE) {
> > +		__augment_tree_propagate_from(va);
> > +
> > +		if (fit_type == NE_FIT_TYPE)
> > +			__insert_vmap_area_augment(lva, &va->rb_node,
> > +				&free_vmap_area_root, &free_vmap_area_list);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Returns a start address of the newly allocated area, if success.
> > + * Otherwise a vend is returned that indicates failure.
> > + */
> > +static inline unsigned long
> > +__alloc_vmap_area(unsigned long size, unsigned long align,
> > +	unsigned long vstart, unsigned long vend, int node)
> > +{
> > +	unsigned long nva_start_addr;
> > +	struct vmap_area *va;
> > +	u8 fit_type;
> > +	int ret;
> > +
> > +	va = __find_vmap_lowest_match(size, align, vstart);
> > +	if (unlikely(!va))
> > +		return vend;
> > +
> > +	if (va->va_start > vstart)
> > +		nva_start_addr = ALIGN(va->va_start, align);
> > +	else
> > +		nva_start_addr = ALIGN(vstart, align);
> > +
> > +	/* Check the "vend" restriction. */
> > +	if (nva_start_addr + size > vend)
> > +		return vend;
> > +
> > +	/* Classify what we have found. */
> > +	fit_type = __classify_va_fit_type(va, nva_start_addr, size);
> > +	if (unlikely(fit_type == NOTHING_FIT)) {
> > +		WARN_ON_ONCE(true);
> 
> Nit: WARN_ON_ONCE() has unlikely() built-in and returns the value,
> so it can be something like:
> 
>   if (WARN_ON_ONCE(fit_type == NOTHING_FIT))
>   	return vend;
> 
> The same comment applies for a couple of other place, where is a check
> for NOTHING_FIT.
>
Agree. Will fix that!

> 
> I do not see any issues so far, just some places in the code are a bit
> hard to follow. I'll try to spend more time on the patch in the next
> couple of weeks.
> 
Thanks again for your time!

--
Vlad Rezki


