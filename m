Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9D47B6B0209
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 17:48:14 -0400 (EDT)
Date: Wed, 24 Mar 2010 22:47:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100324214742.GL10659@random.random>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
 <1269347146-7461-8-git-send-email-mel@csn.ul.ie>
 <20100324133347.9b4b2789.akpm@linux-foundation.org>
 <20100324145946.372f3f31@bike.lwn.net>
 <20100324211924.GH10659@random.random>
 <20100324152854.48f72171@bike.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100324152854.48f72171@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 03:28:54PM -0600, Jonathan Corbet wrote:
> On Wed, 24 Mar 2010 22:19:24 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > > > It's a bit strange to test this when we're about to oops anyway.  The
> > > > oops will tell us the same thing.  
> > > 
> > > ...except that we've seen a fair number of null pointer dereference
> > > exploits that have told us something altogether different.  Are we
> > > *sure* we don't want to test for null pointers...?  
> > 
> > Examples? Maybe WARN_ON != oops, but VM_BUG_ON still an oops that is
> > and without serial console it would go lost too. I personally don't
> > see how it's needed.
> 
> I don't quite understand the question; are you asking for examples of
> exploits?
> 
> 	http://lwn.net/Articles/347006/
> 	http://lwn.net/Articles/360328/
> 	http://lwn.net/Articles/342330/
> 	...

As far as I can tell, VM_BUG_ON would make _zero_ differences there.

I think you mistaken a VM_BUG_ON for a:

  if (could_be_null->something) {
     WARN_ON(1);
     return -ESOMETHING;
  }

adding a VM_BUG_ON(inode->something) would _still_ be as exploitable
as the null pointer deference, because it's a DoS. It's not really a
big deal of an exploit but it _sure_ need fixing.

The whole point is that VM_BUG_ON(!something) before something->else
won't move the needle as far as your null pointer deference exploits
are concerned.

> As to whether this particular test makes sense, I don't know.  But the
> idea that we never need to test about-to-be-dereferenced pointers for
> NULL does worry me a bit.

Being worried is good idea, as we don't want DoS bugs ;). It's just
that VM_BUG_ON isn't a solution to the problem (and the really
important thing, it's not improving its detectability either), fixing
the actual bug is the solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
