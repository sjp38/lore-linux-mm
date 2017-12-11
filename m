Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9F356B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 17:43:11 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g69so17227725ita.9
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 14:43:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 12si3478401itq.66.2017.12.11.14.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 14:43:10 -0800 (PST)
Date: Mon, 11 Dec 2017 14:43:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171211224301.GA3925@bombadil.infradead.org>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
 <20171208223654.GP5858@dastard>
 <1512838818.26342.7.camel@perches.com>
 <20171211214300.GT5858@dastard>
 <1513030348.3036.5.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513030348.3036.5.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Dave Chinner <david@fromorbit.com>, Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon, Dec 11, 2017 at 02:12:28PM -0800, Joe Perches wrote:
> Completely reasonable.  Thanks.

If we're doing "completely reasonable" complaints, then ...

 - I don't understand why plain 'unsigned' is deemed bad.

 - The rule about all function parameters in prototypes having a name
   doesn't make sense.  Example:

int ida_get_new_above(struct ida *ida, int starting_id, int *p_id);

   There is zero additional value in naming 'ida'.  I know it's an ida.
   The struct name tells me that.  If there're two struct ida pointers
   in the prototype, then sure, I want to name them so I know which is
   which (maybe 'src' and 'dst').  Having an unadorned 'int' parameter
   to a function should be a firable offence.  But there's no need to
   call 'gfp_t' anything.  We know it's a gfp_t.  Adding 'gfp_mask'
   after it doesn't tell us anything extra.

 - Forcing a blank line after variable declarations sometimes makes for
   some weird-looking code.  For example, there is no problem with this
   code (from a checkpatch PoV):

        if (xa_is_sibling(entry)) {
                offset = xa_to_sibling(entry);
                entry = xa_entry(xas->xa, node, offset);
                /* Move xa_index to the first index of this entry */
                xas->xa_index = (((xas->xa_index >> node->shift) &
                                  ~XA_CHUNK_MASK) | offset) << node->shift;
        }

   but if I decide I don't need 'offset' outside this block, and I want
   to move the declaration inside, it looks like this:

        if (xa_is_sibling(entry)) {
                unsigned int offset = xa_to_sibling(entry);

                entry = xa_entry(xas->xa, node, offset);
                /* Move xa_index to the first index of this entry */
                xas->xa_index = (((xas->xa_index >> node->shift) &
                                  ~XA_CHUNK_MASK) | offset) << node->shift;
        }

   Does that blank line really add anything to your comprehension of the
   block?  It upsets my train of thought.

   Constructively, I think this warning can be suppressed for blocks
   that are under, say, 8 lines.  Or maybe indented blocks is where I don't
   want this warning.  Not sure.

   Here's another example where I don't think the blank line adds anything:

static inline int xa_store_empty(struct xarray *xa, unsigned long index,
                void *entry, gfp_t gfp, int errno)
{
        void *curr = xa_cmpxchg(xa, index, NULL, entry, gfp);
        if (!curr)
                return 0;
        if (xa_is_err(curr))
                return xa_err(curr);
        return errno;
}

   So line count definitely has something to do with it.

 - There's no warning for the first paragraph of section 6:

6) Functions
------------

Functions should be short and sweet, and do just one thing.  They should
fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
as we all know), and do one thing and do that well.

   I'm not expecting you to be able to write a perl script that checks
   the first line, but we have way too many 200-plus line functions in
   the kernel.  I'd like a warning on anything over 200 lines (a factor
   of 4 over Linus's stated goal).

 - I don't understand the error for xa_head here:

struct xarray {
        spinlock_t      xa_lock;
        gfp_t           xa_flags;
        void __rcu *    xa_head;
};

   Do people really think that:

struct xarray {
        spinlock_t      xa_lock;
        gfp_t           xa_flags;
        void __rcu	*xa_head;
};

   is more aesthetically pleasing?  And not just that, but it's an *error*
   so the former is *RIGHT* and this is *WRONG*.  And not just a matter
   of taste?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
