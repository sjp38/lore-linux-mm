From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910152113.OAA54020@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Fri, 15 Oct 1999 14:13:36 -0700 (PDT)
In-Reply-To: <380792E9.7D1E5E1@colorfullife.com> from "Manfred Spraul" at Oct 15, 99 10:47:37 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Kanoj Sarcar wrote:
> > Explain ... who are the readers, and who are the writers? I think if you
> > are talking about a semaphore lock being held thru out swapout() in the
> > try_to_swap_out path, you are reduced to the same deadlock I just pointed
> > out. I was talking more about a monitor like approach here.
> 
> The lock is held thru out swapout(), but it is a shared lock: multiple
> swapper threads can own it. There should be no lock-up.
> 
> reader: swapper. Reentrancy is not a problem because it is a read-lock,
> ie shared. The implementation must starve exclusive waiters (ie a reader
> is allowed to continue even if a writer is waiting).
> 
> write: everyone who changes the vma list. These functions must not sleep
> while owning the ERESOURCE (IIRC the NT kernel name) exclusive.
> 
> I hope I have not overlocked a detail,
> 	Manfred
> 

With an eye partly towards this implementation, I had the page stealer
code grab vmlist_access_lock, while others get vmlist_modify_lock, 
although in mm.h, both of these reduce to a down() operation.

The reason I am not very keen on this solution either is if you 
consider process A holding vmlist_access_lock of B, going into swapout(),
where it tries to get a (sleeping) driver lock. Meanwhile, process B
has the driver lock, and is trying to grab the vmlist_update_lock on
itself, ie B, maybe to add/delete the vma. I do not think there is
such a driver currently though.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
