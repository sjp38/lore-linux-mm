Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 890566B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 12:35:10 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j58so13638721qtj.18
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 09:35:10 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id e14si1389598qka.142.2017.12.08.09.35.08
        for <linux-mm@kvack.org>;
        Fri, 08 Dec 2017 09:35:08 -0800 (PST)
Date: Fri, 8 Dec 2017 12:35:07 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
In-Reply-To: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
Message-ID: <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Fri, 8 Dec 2017, Byungchul Park wrote:

> I'm sorry to hear that.. If I were you, I would also get
> annoyed. And.. thanks for explanation.
> 
> But, I think assigning lock classes properly and checking
> relationship of the classes to detect deadlocks is reasonable.
> 
> In my opinion about the common lockdep stuff, there are 2
> problems on it.
> 
> 1) Firstly, it's hard to assign lock classes *properly*. By
> default, it relies on the caller site of lockdep_init_map(),
> but we need to assign another class manually, where ordering
> rules are complicated so cannot rely on the caller site. That
> *only* can be done by experts of the subsystem.
> 
> I think if they want to get benifit from lockdep, they have no
> choice but to assign classes manually with the domain knowledge,
> or use *lockdep_set_novalidate_class()* to invalidate locks
> making the developers annoyed and not want to use the checking
> for them.

Lockdep's no_validate class is used when the locking patterns are too
complicated for lockdep to understand.  Basically, it tells lockdep to
ignore those locks.

The device core uses that class.  The tree of struct devices, each with
its own lock, gets used in many different and complicated ways.  
Lockdep can't understand this -- it doesn't have the ability to
represent an arbitrarily deep hierarchical tree of locks -- so we tell
it to ignore the device locks.

It sounds like XFS may need to do the same thing with its semaphores.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
