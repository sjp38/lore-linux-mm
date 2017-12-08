Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA3476B026B
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 17:49:02 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id t65so9862784pfe.22
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 14:49:02 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id x76si6896483pfi.70.2017.12.08.14.49.00
        for <linux-mm@kvack.org>;
        Fri, 08 Dec 2017 14:49:01 -0800 (PST)
Date: Sat, 9 Dec 2017 09:47:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Lockdep is less useful than it was
Message-ID: <20171208224717.GQ5858@dastard>
References: <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207160634.il3vt5d6a4v5qesi@thunk.org>
 <20171207223803.GC26792@bombadil.infradead.org>
 <20171208152717.fx5w66wvyrfx6vrz@thunk.org>
 <20171208181438.GA6406@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208181438.GA6406@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@kernel.org, byungchul.park@lge.com

On Fri, Dec 08, 2017 at 10:14:38AM -0800, Matthew Wilcox wrote:
> At the moment, the radix tree actively disables the RCU checking that
> enabling lockdep would give us.  It has to, because it has no idea what
> lock protects any individual access to the radix tree.  The XArray can
> use the RCU checking because it knows that every reference is protected
> by either the spinlock or the RCU lock.
> 
> Dave was saying that he has a tree which has to be protected by a mutex
> because of where it is in the locking hierarchy, and I was vigorously
> declining his proposal of allowing him to skip taking the spinlock.

Oh, I wasn't suggesting that you remove the internal tree locking
because we need external locking.

I was trying to point out that the internal locking doesn't remove
the need for external locking,  and that there are cases where
smearing the internal lock outside the XA tree doesn't work, either.
i.e. internal locking doesn't replace all the cases where external
locking is required, and so it's less efficient than the existing
radix tree code.

What I was questioning was the value of replacing the radix tree
code with a less efficient structure just to add lockdep validation
to a tree that doesn't actually need any extra locking validation...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
