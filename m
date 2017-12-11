Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF7B56B0253
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 18:10:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id w7so15928501pfd.4
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 15:10:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f1si4066494plb.58.2017.12.11.15.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 15:10:34 -0800 (PST)
Subject: Re: [PATCH v4 08/73] xarray: Add documentation
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-9-willy@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <66ad068b-1973-ca41-7bbf-8a0634cc488d@infradead.org>
Date: Mon, 11 Dec 2017 15:10:22 -0800
MIME-Version: 1.0
In-Reply-To: <20171206004159.3755-9-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On 12/05/2017 04:40 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This is documentation on how to use the XArray, not details about its
> internal implementation.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  Documentation/core-api/index.rst  |   1 +
>  Documentation/core-api/xarray.rst | 281 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 282 insertions(+)
>  create mode 100644 Documentation/core-api/xarray.rst
> 
> diff --git a/Documentation/core-api/xarray.rst b/Documentation/core-api/xarray.rst
> new file mode 100644
> index 000000000000..871161539242
> --- /dev/null
> +++ b/Documentation/core-api/xarray.rst
> @@ -0,0 +1,281 @@
> +======
> +XArray
> +======
> +
> +Overview
> +========
> +
> +The XArray is an abstract data type which behaves like a very large array
> +of pointers.  It meets many of the same needs as a hash or a conventional
> +resizable array.  Unlike a hash, it allows you to sensibly go to the
> +next or previous entry in a cache-efficient manner.  In contrast to
> +a resizable array, there is no need for copying data or changing MMU
> +mappings in order to grow the array.  It is more memory-efficient,
> +parallelisable and cache friendly than a doubly-linked list.  It takes
> +advantage of RCU to perform lookups without locking.
> +
> +The XArray implementation is efficient when the indices used are
> +densely clustered; hashing the object and using the hash as the index
> +will not perform well.  The XArray is optimised for small indices,
> +but still has good performance with large indices.  If your index is
> +larger than ULONG_MAX then the XArray is not the data type for you.
> +The most important user of the XArray is the page cache.
> +
> +A freshly-initialised XArray contains a ``NULL`` pointer at every index.
> +Each non-``NULL`` entry in the array has three bits associated with
> +it called tags.  Each tag may be flipped on or off independently of
> +the others.  You can search for entries with a given tag set.

Only tags that are set, or search for entries with some tag(s) cleared?
Or is that like a mathematical set?


> +Normal pointers may be stored in the XArray directly.  They must be 4-byte
> +aligned, which is true for any pointer returned from :c:func:`kmalloc` and
> +:c:func:`alloc_page`.  It isn't true for arbitrary user-space pointers,
> +nor for function pointers.  You can store pointers to statically allocated
> +objects, as long as those objects have an alignment of at least 4.

This (above) is due to the internal usage of low bits for flags?

> +The XArray does not support storing :c:func:`IS_ERR` pointers; some
> +conflict with data values and others conflict with entries the XArray
> +uses for its own purposes.  If you need to store special values which
> +cannot be confused with real kernel pointers, the values 4, 8, ... 4092
> +are available.

or if I know that they values are errno-range values, I can just shift them
left by 2 to store them and then shift them right by 2 to use them?

oh, or use the following function?

> +You can also store integers between 0 and ``LONG_MAX`` in the XArray.
> +You must first convert it into an entry using :c:func:`xa_mk_value`.
> +When you retrieve an entry from the XArray, you can check whether it is
> +a data value by calling :c:func:`xa_is_value`, and convert it back to
> +an integer by calling :c:func:`xa_to_value`.
> +
> +An unusual feature of the XArray is the ability to create entries which
> +occupy a range of indices.  Once stored to, looking up any index in
> +the range will return the same entry as looking up any other index in
> +the range.  Setting a tag on one index will set it on all of them.
> +Storing to any index will store to all of them.  Multi-index entries can
> +be explicitly split into smaller entries, or storing ``NULL`` into any
> +entry will cause the XArray to forget about the range.
> +
> +Normal API
> +==========
> +
> +Start by initialising an XArray, either with :c:func:`DEFINE_XARRAY`
> +for statically allocated XArrays or :c:func:`xa_init` for dynamically
> +allocated ones.
> +
> +You can then set entries using :c:func:`xa_store` and get entries
> +using :c:func:`xa_load`.  xa_store will overwrite any entry with the
> +new entry and return the previous entry stored at that index.  If you
> +store %NULL, the XArray does not need to allocate memory.  You can call
> +:c:func:`xa_erase` to avoid inventing a GFP flags value.  There is no
> +difference between an entry that has never been stored to and one that
> +has most recently had %NULL stored to it.
> +
> +You can conditionally replace an entry at an index by using
> +:c:func:`xa_cmpxchg`.  Like :c:func:`cmpxchg`, it will only succeed if
> +the entry at that index has the 'old' value.  It also returns the entry
> +which was at that index; if it returns the same entry which was passed as
> +'old', then :c:func:`xa_cmpxchg` succeeded.
> +
> +You can enquire whether a tag is set on an entry by using
> +:c:func:`xa_get_tag`.  If the entry is not ``NULL``, you can set a tag
> +on it by using :c:func:`xa_set_tag` and remove the tag from an entry by
> +calling :c:func:`xa_clear_tag`.  You can ask whether any entry in the

                                                        an entry

> +XArray has a particular tag set by calling :c:func:`xa_tagged`.

or maybe I don't understand.  Does xa_tagged() test one entry and return its
"tagged" result/status?  or does it test (potentially) the entire array to search
for a particular tag value?


> +You can copy entries out of the XArray into a plain array by
> +calling :c:func:`xa_get_entries` and copy tagged entries by calling
> +:c:func:`xa_get_tagged`.  Or you can iterate over the non-``NULL``
> +entries in place in the XArray by calling :c:func:`xa_for_each`.
> +You may prefer to use :c:func:`xa_find` or :c:func:`xa_find_after`
> +to move to the next present entry in the XArray.
> +
> +Finally, you can remove all entries from an XArray by calling
> +:c:func:`xa_destroy`.  If the XArray entries are pointers, you may
> +wish to free the entries first.  You can do this by iterating over
> +all non-``NULL`` entries in the XArray using the :c:func:`xa_for_each`
> +iterator.
> +
> +When using the Normal API, you do not have to worry about locking.
> +The XArray uses RCU and an irq-safe spinlock to synchronise access to
> +the XArray:

[snip]

> +Advanced API
> +============
> +
> +The advanced API offers more flexibility and better performance at the
> +cost of an interface which can be harder to use and has fewer safeguards.
> +No locking is done for you by the advanced API, and you are required
> +to use the xa_lock while modifying the array.  You can choose whether
> +to use the xa_lock or the RCU lock while doing read-only operations on
> +the array.  You can mix advanced and normal operations on the same array;
> +indeed the normal API is implemented in terms of the advanced API.  The
> +advanced API is only available to modules with a GPL-compatible license.
> +
> +The advanced API is based around the xa_state.  This is an opaque data
> +structure which you declare on the stack using the :c:func:`XA_STATE`
> +macro.  This macro initialises the xa_state ready to start walking
> +around the XArray.  It is used as a cursor to maintain the position
> +in the XArray and let you compose various operations together without
> +having to restart from the top every time.
> +
> +The xa_state is also used to store errors.  You can call
> +:c:func:`xas_error` to retrieve the error.  All operations check whether
> +the xa_state is in an error state before proceeding, so there's no need
> +for you to check for an error after each call; you can make multiple
> +calls in succession and only check at a convenient point.  The only error
> +currently generated by the xarray code itself is %ENOMEM, but it supports
> +arbitrary errors in case you want to call :c:func:`xas_set_err` yourself.
> +
> +If the xa_state is holding an %ENOMEM error, calling :c:func:`xas_nomem`
> +will attempt to allocate more memory using the specified gfp flags and
> +cache it in the xa_state for the next attempt.  The idea is that you take
> +the xa_lock, attempt the operation and drop the lock.  The operation
> +attempts to allocate memory while holding the lock, but it is more
> +likely to fail.  Once you have dropped the lock, :c:func:`xas_nomem`
> +can try harder to allocate more memory.  It will return ``true`` if it
> +is worth retrying the operation (ie that there was a memory error *and*

                         usually    i.e.

> +more memory was allocated.  If it has previously allocated memory, and

                   allocated).

> +that memory wasn't used, and there is no error (or some error that isn't
> +%ENOMEM), then it will free the memory previously allocated.
> +
> +Some users wish to hold the xa_lock for their own purpose while performing
> +one simple XArray operation, and then some other operation of their
> +own, protected by the same lock.  While they could declare an xa_state
> +and use it to call one of the usual advanced API functions, it is a
> +little cumbersome.  These interfaces are added on demand; at the moment,
> +:c:func:`__xa_erase`, :c:func:`__xa_set_tag` and :c:func:`__xa_clear_tag`
> +are available.
> +
> +Internal Entries
> +----------------

[snip]

> +Additional functionality
> +------------------------
> +
> +The :c:func:`xas_create` function ensures that there is somewhere in the
> +XArray to store an entry.  It will store ENOMEM in the xa_state if it
> +cannot allocate memory.  You do not normally need to call this function
> +yourself as it is called by :c:func:`xas_store`.
> +
> +You can use :c:func:`xas_init_tags` to reset the tags on an entry
> +to their default state.  This is usually all tags clear, unless the
> +XArray is marked with ``XA_FLAGS_TRACK_FREE``, in which case tag 0 is set
> +and all other tags are clear.  Replacing one entry with another using
> +:c:func:`xas_store` will not reset the tags on that entry; if you want
> +the tags reset, you should do that explicitly.
> +
> +The :c:func:`xas_load` will walk the xa_state as close to the entry
> +as it can.  If you know the xa_state has already been walked to the
> +entry and need to check that the entry hasn't changed, you can use
> +:c:func:`xas_reload` to save a function call.
> +
> +If you need to move to a different index in the XArray, call
> +:c:func:`xas_set`.  This reinitialises the cursor which will generally

I would put a comma .... here.......................^
but consult your $editor.  :)

> +have the effect of making the next operation walk the cursor to the
> +desired spot in the tree.  If you want to move to the next or previous
> +index, call :c:func:`xas_next` or :c:func:`xas_prev`.  Setting the index
> +does not walk the cursor around the array so does not require a lock to
> +be held, while moving to the next or previous index does.

[snip]


Nicely done.  Thanks.
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
