Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 725896B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 21:46:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q7so3362896pgr.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 18:46:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h12si14624371pgq.681.2017.11.22.18.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 18:46:23 -0800 (PST)
Date: Wed, 22 Nov 2017 18:46:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 00/62] XArray November 2017 Edition
Message-ID: <20171123024621.GA9059@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
 <20171123012501.GK4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123012501.GK4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Nov 23, 2017 at 12:25:01PM +1100, Dave Chinner wrote:
> On Wed, Nov 22, 2017 at 01:06:37PM -0800, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > I've lost count of the number of times I've posted the XArray before,
> > so time for a new numbering scheme.  Here're two earlier versions,
> > https://lkml.org/lkml/2017/3/17/724
> > https://lwn.net/Articles/715948/ (this one's more loquacious in its
> > description of things that are better about the radix tree API than the
> > XArray).
> > 
> > This time around, I've gone for an approach of many small changes.
> > Unfortunately, that means you get 62 moderate patches instead of dozens
> > of big ones.
> 
> Where's the API documentation that tells things like constraints
> about locking and lock-less lookups via RCU?

Pretty spartan so far:

 * An eXtensible Array is an array of entries indexed by an unsigned
 * long.  The XArray takes care of its own locking, using an irqsafe
 * spinlock for operations that modify the XArray and RCU for operations
 * which only read from the XArray.

That needs to be amended to specify it's only talking about the normal API.
For the advanced API, the user needs to handle their own locking.

> e.g. I notice in the XFS patches you seem to randomly strip out
> rcu_read_lock/unlock() pairs that are currently around radix tree
> lookup operations without explanation. Without documentation
> describing how this stuff is supposed to work, review is somewhat
> difficult...

It's not entirely random, although I appreciate it may seem that way.

Takes no lock, doesn't need it:
 * xa_empty
 * xa_tagged
Takes RCU read lock:
 * xa_load
 * xa_for_each
 * xa_find
 * xa_next
 * xa_get_entries
 * xa_get_tagged
 * xa_get_tag
Takes xa_lock internally:
 * xa_store
 * xa_cmpxchg
 * xa_destroy
 * xa_set_tag
 * xa_clear_tag

The __xa_ and xas_ functions take no locks, RCU or spin.  One advantage
the xarray has over the radix tree is that you'll get nice little RCU splats
if you forget to take a lock when you need it.

Some places in the xfs patches I had to leave the RCU locks in place
because they're preventing the thing we're looking up from evaporating
under us.  So we're taking the RCU lock twice, which isn't ideal, but
also not *that* expensive.  If it turns out to be a problem, we can
introduce __xa versions or use the existing xas_ family of functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
