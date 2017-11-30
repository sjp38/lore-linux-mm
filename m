Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8086B025F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:34:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id j6so2907630pll.4
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:34:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r8si3110969pgq.4.2017.11.30.06.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 06:34:44 -0800 (PST)
Date: Thu, 30 Nov 2017 06:34:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171130143440.GA12684@bombadil.infradead.org>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511965054-6328-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 29, 2017 at 09:17:34AM -0500, Waiman Long wrote:
> The list_lru_del() function removes the given item from the LRU list.
> The operation looks simple, but it involves writing into the cachelines
> of the two neighboring list entries in order to get the deletion done.
> That can take a while if the cachelines aren't there yet, thus
> prolonging the lock hold time.
> 
> To reduce the lock hold time, the cachelines of the two neighboring
> list entries are now prefetched before acquiring the list_lru_node's
> lock.
> 
> Using a multi-threaded test program that created a large number
> of dentries and then killed them, the execution time was reduced
> from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
> 72-thread x86-64 system.

FWIW, I've been thinking about a new queue data structure based on
the xarray.  It'd avoid this cache miss problem altogether (deleting an
entry from the queue usually touches one cacheline).  I was specifically
thinking about list_lru when designing it because I'd love to reclaim the
two pointers in the radix_tree_node for use as a fourth tag bit.

There's no code behind this yet, but I wrote some documentation for it as
I was designing it in my head:


======
XQueue
======

Overview
========

The XQueue is an abstract data type which provides a low-overhead queue.
It supports up to two billion entries per queue and has a memory overhead
approximately 40% lower than the doubly-linked list approach.  It does
not require embedding any information in the object, allowing objects
to be on multiple queues simultaneously.  However, it may require memory
allocation in order to add an element to the queue.

Objects can be removed from arbitrary positions in the XQueue, but
insertion of new objects at arbitrary positions in the XQueue is not
possible.  Objects in the XQueue may be replaced with other objects.

How to use it
=============

Initialise your XQueue by defining it using :c:func:`DEFINE_XQUEUE` or
dynamically allocating it and calling :c:func:`xq_init`.

Most users can then call :c:func:`xq_push` to add a new object to the queue
and :c:func:`xq_pop` to remove the object at the front of the queue.

If you need to be able to remove an object from an arbitrary position
in the queue, embed the queue ID returned from :c:func:`xq_push` in your
object, and use :c:func:`xq_remove`.

Some users need to hold a lock of their own while pushing an object onto
the queue.  These users can either use GFP_ATOMIC in the gfp flags, or
(preferably) call :c:func:`xq_reserve` to reserve a queue ID for their
object before taking their lock, and placing the object into the queue
using :c:func:`xq_replace`.

Some users want to use the queue ID of the object for an external purpose
(eg use it as the ID of a network packet).  These users can constrain
the range of the ID allocated by calling :c:func:`xq_push_range` or
:c:func:`xq_reserve_range` instead.

If using the reserve/replace technique, the queue becomes not quite pure.
For example, the following situation can happen with two producers (B & C)
and one consumer (A):

B: Push queue ID 2
C: Reserve queue ID 3
B: Push queue ID 4
B: Push queue ID 5
A: Pop queue ID 2
A: Pop queue ID 4
C: Replace queue ID 3
A: Pop queue ID 3
A: Pop queue ID 5

C's object has left the queue between B's two objects.  This is not
normally a concern to most users, but if a producer puts a fence entry
on the queue, it is permeable to another entry which had an ID reserved
before the fence was enqueued, but not actually used until after the fence
was enqueued.

Non-queue usages
================

You may wish to use the XQueue as an ID allocator.  This is a perfectly
good use for the XQueue, and it is superior to the IDR in some ways.

For example, suppose you are allocating request IDs.  Using the IDR for a
cyclic allocation would lead to very deep trees being created and a lot
of memory being spent on internal structures.  The XQueue will compact
the trees that it uses and attempt to keep memory usage to a minimum.

In this scenario, you would almost never call xq_pop.  You'd call xq_push to
assign an ID

Functions and structures
========================

.. kernel-doc:: include/linux/xqueue.h
.. kernel-doc:: lib/xqueue.c


I also wrote xqueue.h:


/*
 * eXtensible Queues
 * Copyright (c) 2017 Microsoft Corporation <mawilcox@microsoft.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * eXtensible Queues provide queues which are more cache-efficient than
 * using list.h
 */

#ifndef _LINUX_XQUEUE_H
#define _LINUX_XQUEUE_H

#include <linux/xarray.h>

struct xqueue {
	struct xarray xq_xa;
	unsigned int xq_last;
	unsigned int xq_base;
}

#define XQ_INIT_FLAGS	(XA_FLAGS_TRACK_FREE | XA_FLAGS_TAG(0))

#define XQUEUE_INIT(name) {					\
	.xq_xa = __XARRAY_INIT(name, XQ_INIT_FLAGS),		\
	.xq_last = 0,						\
	.xq_base = 0,						\
}


#define DEFINE_XQUEUE(name) struct xqueue name = XQUEUE_INIT(name)

static inline void xq_init(struct xqueue *xq)
{
	xa_init(&xq->xq_xa);
	xq_last = 0;
	xq_base = 0;
}

int xq_push_range(struct xqueue *, void *entry, unsigned int min,
			unsigned int max, gfp_t);
void *xq_pop(struct xqueue *);
int xq_reserve_range(struct xqueue *, unsigned int min, unsigned int max,
			gfp_t);

static int xq_push(struct xqueue *xq, void *entry, gfp_t gfp)
{
	return xq_push_range(xq, entry, 0, INT_MAX, gfp);
}

static int xq_reserve(struct xqueue *xq, gfp_t gfp)
{
	return xq_reserve_range(xq, 0, INT_MAX, gfp);
}

/**
 * xq_replace() - Replace an entry in the queue.
 * @xq: The XQueue.
 * @id: Previously allocated queue ID.
 * @entry: The new object to insert into the queue.
 *
 * Normally used as part of the reserve/replace pattern, this function
 * can be used to replace any object still in the queue.
 */
static void xq_replace(struct xqueue *xq, unsigned int id, void *entry)
{
	xa_store(&xq->xq_xa, id, entry, 0);
}

static inline int xq_remove(struct xqueue *xq, unsigned int id)
{
	if (xa_store(&xq->xq_xa, id, NULL, 0))
		return 0;
	return -ENOENT;
}

static inline bool xq_empty(const struct xqueue *xq)
{
	return xa_empty(&xq->xq_xa);
}

#endif /* _LINUX_XQUEUE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
