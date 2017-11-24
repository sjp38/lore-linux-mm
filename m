Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 404A56B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 20:16:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r12so20306440pgu.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:16:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e62si6331207pfa.154.2017.11.23.17.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 17:16:08 -0800 (PST)
Date: Thu, 23 Nov 2017 17:16:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: XArray documentation
Message-ID: <20171124011607.GB3722@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

Here's the current state of the documentation for the XArray.  Suggestions
for improvement gratefully received.

======
XArray
======

Overview
========

The XArray is an array of ULONG_MAX entries.  Each entry can be either
a pointer, or an encoded value between 0 and LONG_MAX.  It is efficient
when the indices used are densely clustered; hashing the object and
using the hash as the index will not perform well.  A freshly-initialised
XArray contains a NULL pointer at every index.  There is no difference
between an entry which has never been stored to and an entry which has most
recently had NULL stored to it.

Pointers to be stored in the XArray must have the bottom two bits clear
(ie must point to something which is 4-byte aligned).  This includes all
objects allocated by calling :c:func:`kmalloc` and :c:func:`alloc_page`,
but you cannot store pointers to arbitrary offsets within an object.
The XArray does not support storing :c:func:`IS_ERR` pointers; some
conflict with data values and others conflict with entries the XArray
uses for its own purposes.  If you need to store special values which
cannot be confused with real kernel pointers, the values 4, 8, ... 4092
are available.

Each non-NULL entry in the array has three bits associated with it called
tags.  Each tag may be flipped on or off independently of the others.
You can search for entries with a given tag set.

An unusual feature of the XArray is the ability to tie multiple entries
together.  Once stored to, looking up any entry in the range will give
the same result as looking up any other entry in the range.  Setting a
tag on one entry will set it on all of them.  Multiple entries can be
explicitly split into smaller entries, or storing NULL into any entry
will cause the XArray to forget about the tie.

Normal API
==========

Start by initialising an XArray, either with :c:func:`DEFINE_XARRAY`
for statically allocated XArrays or :c:func:`xa_init` for dynamically
allocated ones.

You can then set entries using :c:func:`xa_store` and get entries using
:c:func:`xa_load`.  xa_store will overwrite a non-NULL entry with the
new entry.  It returns the previous entry stored at that index.  You can
conditionally replace an entry at an index by using :c:func:`xa_cmpxchg`.
Like :c:func:`cmpxchg`, it will only succeed if the entry at that
index has the 'old' value.  It also returns the entry which was at
that index; if it returns the same entry which was passed as 'old',
then :c:func:`xa_cmpxchg` succeeded.

If you want to store a pointer, you can do that directly.  If you want
to store an integer between 0 and LONG_MAX, you must first encode it
using :c:func:`xa_mk_value`.  When you retrieve an entry from the XArray,
you can check whether it is a data value by calling :c:func:`xa_is_value`,
and convert it back to an integer by calling :c:func:`xa_to_value`.

You can enquire whether a tag is set on an entry by using
:c:func:`xa_get_tag`.  If the entry is not NULL, you can set a tag on
it by using :c:func:`xa_set_tag` and remove the tag from an entry by
calling :c:func:`xa_clear_tag`.  You can ask whether any entry in the
XArray has a particular tag set by calling :c:func:`xa_tagged`.

You can copy entries out of the XArray into a plain array by
calling :c:func:`xa_get_entries` and copy tagged entries by calling
:c:func:`xa_get_tagged`.  Or you can iterate over the non-NULL entries
in place in the XArray by calling :c:func:`xa_for_each`.  You may prefer
to use :c:func:`xa_find` or :c:func:`xa_next` to move to the next present
entry in the XArray.

Finally, you can remove all entries from an XArray by calling
:c:func:`xa_destroy`.  If the XArray entries are pointers, you may wish
to free the entries first.  You can do this by iterating over all non-NULL
entries in

When using the Normal API, you do not have to worry about locking.
The XArray uses RCU and an irq-safe spinlock to synchronise access to
the XArray:

No lock needed:
 * :c:func:`xa_empty`
 * :c:func:`xa_tagged`

Takes RCU read lock:
 * :c:func:`xa_load`
 * :c:func:`xa_for_each`
 * :c:func:`xa_find`
 * :c:func:`xa_next`
 * :c:func:`xa_get_entries`
 * :c:func:`xa_get_tagged`
 * :c:func:`xa_get_tag`

Takes xa_lock internally:
 * :c:func:`xa_store`
 * :c:func:`xa_cmpxchg`
 * :c:func:`xa_destroy`
 * :c:func:`xa_set_tag`
 * :c:func:`xa_clear_tag`

The :c:func:`xa_store` and :c:func:`xa_cmpxchg` functions take a gfp_t
parameter in case the XArray needs to allocate memory to store this entry.
If the entry being stored is NULL, no memory allocation needs to be
performed, and the GFP flags specified here will be ignored.

Advanced API
============

The advanced API offers more flexibility and better performance at the
cost of an interface which can be harder to use and has fewer safeguards.
No locking is done for you by the advanced API, and you are required to
use the xa_lock while modifying the array.  You can choose whether to use
the xa_lock or the RCU lock while doing read-only operations on the array.

The advanced API is based around the xa_state.  This is an opaque data
structure which you declare on the stack using the :c:func:`XA_STATE`
macro.  This macro initialises the xa_state ready to start walking
around the XArray.  It is used as a cursor to maintain the position
in the XArray and let you compose various operations together without
having to restart from the top every time.

The xa_state is also used to store errors.  If an operation fails, it
calls :c:func:`xas_set_err` to note the error.  All operations check
whether the xa_state is in an error state before proceeding, so there's
no need for you to check for an error after each call; you can make
multiple calls in succession and only check at a convenient point.

The only error currently generated by the xarray code itself is
ENOMEM, but it supports arbitrary errors in case you want to call
:c:func:`xas_set_err` yourself.  If the xa_state is holding an ENOMEM
error, :c:func:`xas_nomem` will attempt to allocate a single xa_node using
the specified gfp flags and store it in the xa_state for the next attempt.
The idea is that you take the xa_lock, attempt the operation and drop
the lock.  Then you allocate memory if there was a memory allocation
failure and retry the operation.  You must call :c:func:`xas_destroy`
if you call :c:func:`xas_nomem` in case it's not necessary to use the
memory that was allocated.

When using the advanced API, it's possible to see internal entries
in the XArray.  You should never see an :c:func:`xa_is_node` entry,
but you may see other internal entries, including sibling entries,
skip entries and retry entries.  The :c:func:`xas_retry` function is a
useful helper function for handling internal entries, particularly in
the middle of iterations.

Functions
=========

.. kernel-doc:: include/linux/xarray.h
.. kernel-doc:: lib/xarray.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
