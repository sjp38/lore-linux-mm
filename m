Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBB26B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:16:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q186so6365941pga.23
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 16:16:30 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id e76si4983611pfl.60.2017.12.07.16.16.26
        for <linux-mm@kvack.org>;
        Thu, 07 Dec 2017 16:16:27 -0800 (PST)
Date: Fri, 8 Dec 2017 11:14:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Lockdep is less useful than it was
Message-ID: <20171208001401.GM4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207160634.il3vt5d6a4v5qesi@thunk.org>
 <20171207223803.GC26792@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207223803.GC26792@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@kernel.org, byungchul.park@lge.com

On Thu, Dec 07, 2017 at 02:38:03PM -0800, Matthew Wilcox wrote:
> On Thu, Dec 07, 2017 at 11:06:34AM -0500, Theodore Ts'o wrote:
> > The problem is that if it has too many false positives --- and it's
> > gotten *way* worse with the completion callback "feature", people will
> > just stop using Lockdep as being too annyoing and a waste of developer
> > time when trying to figure what is a legitimate locking bug versus
> > lockdep getting confused.
> > 
> > <Rant>I can't even disable the new Lockdep feature which is throwing
> > lots of new false positives --- it's just all or nothing.</Rant>
> 
> You *can* ... but it's way more hacking Kconfig than you ought to have
> to do (which is a separate rant ...)
> 
> You need to get LOCKDEP_CROSSRELEASE off.  I'd revert patches
> e26f34a407aec9c65bce2bc0c838fabe4f051fc6 and
> b483cf3bc249d7af706390efa63d6671e80d1c09
> 
> I think it was a mistake to force these on for everybody; they have a
> much higher false-positive rate than the rest of lockdep, so as you say
> forcing them on leads to fewer people using *any* of lockdep.
> 
> The bug you're hitting isn't Byungchul's fault; it's an annotation
> problem.  The same kind of annotation problem that we used to have with
> dozens of other places in the kernel which are now fixed.

That's one of the fundamental problem with lockdep - it throws the
difficulty of solving all these new false positives onto the
developers who know nothing about lockdep and don't follow it's
development. And until they do solve them - especially in critical
subsystems that everyone uses like the storage stack - lockdep is
essentially worthless.

> If you didn't
> have to hack Kconfig to get rid of this problem, you'd be happier, right?

I'd be much happier if it wasn't turned on by default in the first
place.  We gave plenty of warnings that there were still unsolved
false positive problems with the new checks in the storage stack.

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
