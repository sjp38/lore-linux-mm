Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 279D66B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 16:18:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m4so10602724pgc.23
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 13:18:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k16si17474690pli.74.2017.11.24.13.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 13:18:10 -0800 (PST)
Date: Fri, 24 Nov 2017 13:18:09 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: XArray documentation
Message-ID: <20171124211809.GA17136@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
 <3543098.x2GeNdvaH7@merkaba>
 <20171124170307.GA681@bombadil.infradead.org>
 <2627399.jpLCoM7KBo@merkaba>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2627399.jpLCoM7KBo@merkaba>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <martin@lichtvoll.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Nov 24, 2017 at 07:01:31PM +0100, Martin Steigerwald wrote:
> > The XArray is an abstract data type which behaves like an infinitely
> > large array of pointers.  The index into the array is an unsigned long.
> > A freshly-initialised XArray contains a NULL pointer at every index.
> 
> Yes, I think this is clearer already.
> 
> Maybe with a few sentences on "Why does the kernel provide this?", "Where is 
> it used?" (if already known), "What use case is it suitable for a?? if I want to 
> implement something into the kernel (or in user space?) ?" and probably "How 
> does it differ from user data structures the kernel provides?"

OK, I think this is getting more useful.  Here's what I currently have:

Overview
========

The XArray is an abstract data type which behaves like a very large array
of pointers.  It meets many of the same needs as a hash or a conventional
resizable array.  Unlike a hash, it allows you to sensibly go to the
next or previous entry in a cache-efficient manner.  In contrast to
a resizable array, there is no need for copying data or changing MMU
mappings in order to grow the array.  It is more memory-efficient,
parallelisable and cache friendly than a doubly-linked list.  It takes
advantage of RCU to perform lookups without locking.

The XArray implementation is efficient when the indices used are
densely clustered; hashing the object and using the hash as the index
will not perform well.  The XArray is optimised for small indices,
but still has good performance with large indices.  If your index is
larger than ULONG_MAX then the XArray is not the data type for you.
The most important user of the XArray is the page cache.

A freshly-initialised XArray contains a ``NULL`` pointer at every index.
Each non-``NULL`` entry in the array has three bits associated with
it called tags.  Each tag may be flipped on or off independently of
the others.  You can search for entries with a given tag set.

Normal pointers may be stored in the XArray directly.  They must be 4-byte
aligned, which is true for any pointer returned from :c:func:`kmalloc` and
:c:func:`alloc_page`.  It isn't true for arbitrary user-space pointers,
nor for function pointers.  You can store pointers to statically allocated
objects, as long as those objects have an alignment of at least 4.

The XArray does not support storing :c:func:`IS_ERR` pointers; some
conflict with data values and others conflict with entries the XArray
uses for its own purposes.  If you need to store special values which
cannot be confused with real kernel pointers, the values 4, 8, ... 4092
are available.

You can also store integers between 0 and ``LONG_MAX`` in the XArray.
You must first convert it into an entry using :c:func:`xa_mk_value`.
When you retrieve an entry from the XArray, you can check whether it is
a data value by calling :c:func:`xa_is_value`, and convert it back to
an integer by calling :c:func:`xa_to_value`.

An unusual feature of the XArray is the ability to create entries which
occupy a range of indices.  Once stored to, looking up any index in
the range will give the same entry as looking up any other index in
the range.  Setting a tag on one index will set it on all of them.
Storing to any index will store to all of them.  Multi-index entries can
be explicitly split into smaller entries, or storing ``NULL`` into any
entry will cause the XArray to forget about the range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
