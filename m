From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] vm_operation to avoid pagefault/inval race
Date: Sat, 17 May 2003 20:21:56 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305172021.56773.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Please don't take lack of response for lack of interest.  The generic issue 
here is "what are the vfs changes needed to support cross-host mmap?".  You 
defined the problem nicely.

>
> [...]
>
> 5.	One way or another, life is now hard.

Indeed.  In brief, ->nopage just doesn't provide adequate coverage to support 
the cross-host lock.

> One solution would be for the distributed filesystem to hold
> onto a lock or semaphore upon return from the nopage function.
> The problem is that there is no way to determine (in a timely
> fashion) when it safe to release this lock or semaphore.
>
> The attached patch addresses this by adding a nopagedone
> function for when do_no_page() exits.  The filesystem may then
> drop the lock or semaphore in this nopagedone function.
>
> Thoughts?  Is there some other existing way to get this done?

There is.  One way is to make all of do_no_page a hook, and clearly this is 
more generic than what you proposed, since it covers your hook and the rest 
can be done with library calls.  Once you've gone there, the next question to 
ask is "what use is the existing ->nopage" hook, and the answer is: none, 
really.  The existing usage of ->nopage can be replaced by ->do_no_page plus 
library code, and the only problem is, we have to change pretty well every 
filesystem in and out of tree.  So that gets a little, em, interesting from 
the 2.6.0 point of view, which is why I cc'd Andrew on this.  Christoph has 
also expressed interest in this, which explains the other cc.

Any clustered filesystem that wants to support posix mmap is going to need 
this hook, so the sooner we hash this out, the better.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
