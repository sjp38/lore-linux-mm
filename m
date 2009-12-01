Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 43F32600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 05:04:47 -0500 (EST)
Date: Tue, 1 Dec 2009 11:04:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
Message-ID: <20091201100444.GN30235@random.random>
References: <20091125133752.2683c3e4@bree.surriel.com>
 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 30, 2009 at 05:00:29PM -0500, Larry Woodman wrote:
> Before the splitLRU patch shrink_active_list() would only call
> page_referenced() when reclaim_mapped got set.  reclaim_mapped only got
> set when the priority worked its way from 12 all the way to 7. This
> prevented page_referenced() from being called from shrink_active_list()
> until the system was really struggling to reclaim memory.

page_referenced should never be called and nobody should touch ptes
until priority went down to 7. This is a regression in splitLRU that
should be fixed. With light VM pressure we should never touch ptes ever.

> On way to prevent this is to change page_check_address() to execute a
> spin_trylock(ptl) when it was called by shrink_active_list() and simply
> fail if it could not get the pte_lockptr spinlock.  This will make
> shrink_active_list() consider the page not referenced and allow the
> anon_vma->lock to be dropped much quicker.
> 
> The attached patch does just that, thoughts???

Just stop calling page_referenced there...

Even if we ignore the above, one problem later in skipping over the PT
lock, is also to assume the page is not referenced when it actually
is, so it won't be activated again when page_referenced is called
again to move the page back in the active list... Not the end of the
world to lose a young bit sometime though.

There may be all reasons in the world why we have to mess with ptes
when there's light VM pressure, for whatever terabyte machine or
whatever workload that performs better that way, but I know in 100% of
my systems I don't ever want the VM to touch ptes when there's light
VM pressure, no matter what. So if you want the default to be messing
with ptes, just give me a sysctl knob to let me run faster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
