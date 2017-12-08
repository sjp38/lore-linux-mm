Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40E8B6B025E
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 17:37:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so8958203pgf.13
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 14:37:01 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id q8si6142044pgs.224.2017.12.08.14.36.57
        for <linux-mm@kvack.org>;
        Fri, 08 Dec 2017 14:36:58 -0800 (PST)
Date: Sat, 9 Dec 2017 09:36:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171208223654.GP5858@dastard>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Fri, Dec 08, 2017 at 12:35:07PM -0500, Alan Stern wrote:
> On Fri, 8 Dec 2017, Byungchul Park wrote:
> 
> > I'm sorry to hear that.. If I were you, I would also get
> > annoyed. And.. thanks for explanation.
> > 
> > But, I think assigning lock classes properly and checking
> > relationship of the classes to detect deadlocks is reasonable.
> > 
> > In my opinion about the common lockdep stuff, there are 2
> > problems on it.
> > 
> > 1) Firstly, it's hard to assign lock classes *properly*. By
> > default, it relies on the caller site of lockdep_init_map(),
> > but we need to assign another class manually, where ordering
> > rules are complicated so cannot rely on the caller site. That
> > *only* can be done by experts of the subsystem.

Sure, but that's not the issue here. The issue here is the lack of
communication with subsystem experts and that the annotation
complexity warnings given immediately by the subsystem experts were
completely ignored...

> > I think if they want to get benifit from lockdep, they have no
> > choice but to assign classes manually with the domain knowledge,
> > or use *lockdep_set_novalidate_class()* to invalidate locks
> > making the developers annoyed and not want to use the checking
> > for them.
> 
> Lockdep's no_validate class is used when the locking patterns are too
> complicated for lockdep to understand.  Basically, it tells lockdep to
> ignore those locks.

Let me just point out two things here:

	1. Using lockdep_set_novalidate_class() for anything other
	than device->mutex will throw checkpatch warnings. Nice. (*)

	2. lockdep_set_novalidate_class() is completely undocumented
	- it's the first I've ever heard of this functionality. i.e.
	nobody has ever told us there is a mechanism to turn off
	validation of an object; we've *always* been told to "change
	your code and/or fix your annotations" when discussing
	lockdep deficiencies. (**)

> The device core uses that class.  The tree of struct devices, each with
> its own lock, gets used in many different and complicated ways.  
> Lockdep can't understand this -- it doesn't have the ability to
> represent an arbitrarily deep hierarchical tree of locks -- so we tell
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

That largely describes the in-memory structure of XFS, except we
have a forest of lock trees, not just one....

> it to ignore the device locks.
> 
> It sounds like XFS may need to do the same thing with its semaphores.

Who-ever adds semaphore checking to lockdep can add those
annotations. The externalisation of the development cost of new
lockdep functionality is one of the problems here.

-Dave.

(*) checkpatch.pl is considered mostly harmful round here, too,
but that's another rant....

(**) the frequent occurrence of "core code/devs aren't held to the
same rules/standard as everyone else" is another rant I have stored
up for a rainy day.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
