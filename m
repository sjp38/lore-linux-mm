From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62272.298499.628883@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:12:16 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
In-Reply-To: <199906282111.OAA54637@google.engr.sgi.com>
References: <14199.56793.520615.700914@dukat.scot.redhat.com>
	<199906282111.OAA54637@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 14:11:18 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> If I understand right, here is an example. Lets say I believe I 
> have scanned uptil pid 10. You are suggesting, after having scanned
> pid 10, hold on to task_lock, and look for the min pid > 10. Say
> that is pid 12. Problem is, while I was scanning pid 10, maybe
> pid 5 got reallocated, and pid 5 is a new process (probably a 
> child of pid 20). 

Fine --- repeat the whole thing until we have no swap entries left.  We
can still guarantee to make progress without extra locking for normal
swapping. 

>> It will work.  It's a little extra overhead, but it confines all of
>> the cost to the swapoff path.  The pid scan isn't going to be nearly
>> as expensive as the rest of the vm scanning we are already forced to
>> do in swapoff.

> I would love to confine the complexity in the swapoff path, except
> I can't come up with a solution. In any case, I think I was not 
> clear about what the cost is in my fix. It is adding 2 chain fields
> in the mm structure, adding and deleting to this chain at mm alloc/free
> time, and the up/down cost on the mutex. 

But it's not necessary.  Other OSes may add a lock here, a lock there
every time it happens to make a non-performance-critical path easier,
but in the long term that sort of thinking just bloats the fast paths.

> Note that the up/down cost is minimal (one atomic inc/dec) when no
> swapoff is going on

On SMP, the cache traffic produced by such locks is not minimal.  You
can measure the performance hit of every single cache miss that results.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
