Message-ID: <380792E9.7D1E5E1@colorfullife.com>
Date: Fri, 15 Oct 1999 22:47:37 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
References: <199910151843.LAA14256@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> Explain ... who are the readers, and who are the writers? I think if you
> are talking about a semaphore lock being held thru out swapout() in the
> try_to_swap_out path, you are reduced to the same deadlock I just pointed
> out. I was talking more about a monitor like approach here.

The lock is held thru out swapout(), but it is a shared lock: multiple
swapper threads can own it. There should be no lock-up.

reader: swapper. Reentrancy is not a problem because it is a read-lock,
ie shared. The implementation must starve exclusive waiters (ie a reader
is allowed to continue even if a writer is waiting).

write: everyone who changes the vma list. These functions must not sleep
while owning the ERESOURCE (IIRC the NT kernel name) exclusive.

I hope I have not overlocked a detail,
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
