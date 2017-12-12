Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 252426B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:51:40 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id 18so26527447qtt.10
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 07:51:40 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id y67si10287699qkd.266.2017.12.12.07.51.37
        for <linux-mm@kvack.org>;
        Tue, 12 Dec 2017 07:51:38 -0800 (PST)
Date: Tue, 12 Dec 2017 10:51:37 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
In-Reply-To: <1513035963.3036.17.camel@perches.com>
Message-ID: <Pine.LNX.4.44L0.1712121041240.1358-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Chinner <david@fromorbit.com>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon, 11 Dec 2017, Joe Perches wrote:

> >  - I don't understand the error for xa_head here:
> > 
> > struct xarray {
> >         spinlock_t      xa_lock;
> >         gfp_t           xa_flags;
> >         void __rcu *    xa_head;
> > };
> > 
> >    Do people really think that:
> > 
> > struct xarray {
> >         spinlock_t      xa_lock;
> >         gfp_t           xa_flags;
> >         void __rcu	*xa_head;
> > };
> > 
> >    is more aesthetically pleasing?  And not just that, but it's an *error*
> >    so the former is *RIGHT* and this is *WRONG*.  And not just a matter

Not sure what was meant here.  Neither one is *WRONG* in the sense of 
being invalid C code.  In the sense of what checkpatch will accept, the 
former is *WRONG* and the latter is *RIGHT* -- the opposite of what 
was written.

> >    of taste?
> 
> No opinion really.
> That's from Andy Whitcroft's original implementation.

This one, at least, is easy to explain.  The original version tends to
lead to bugs, or easily misunderstood code.  Consider if another
variable was added to the declaration; it could easily turn into:

	void __rcu *	xa_head, xa_head2;

(The compiler will reject this, but it wouldn't if the underlying type
had been int instead of void.)

Doing it the other way makes the meaning a lot more clear:

	void __rcu	*xa_head, *xa_head2;

This is an idiom specifically intended to reduce the likelihood of 
errors.  Rather like avoiding assignments inside conditionals.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
