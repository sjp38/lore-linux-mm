Date: Sat, 12 Nov 2005 21:09:13 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051112210913.0b365815.pj@sgi.com>
In-Reply-To: <43716476.1030306@yahoo.com.au>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	<20051107175358.62c484a3.akpm@osdl.org>
	<1131416195.20471.31.camel@akash.sc.intel.com>
	<43701FC6.5050104@yahoo.com.au>
	<20051107214420.6d0f6ec4.pj@sgi.com>
	<43703EFB.1010103@yahoo.com.au>
	<1131473876.2400.9.camel@akash.sc.intel.com>
	<43716476.1030306@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohit.seth@intel.com, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The __GFP_HIGH, GFP_ATOMIC, __GFP_WAIT flags are still driving me bonkers.

It seems to me that:
 1) __GFP_WAIT is supposed to mean can wait, and __alloc_pages()
    keys off that bit to set its "wait" variable.  Good so far.
 2) __GFP_HIGH is supposed to mean can access emergency pools
    (use lower watermarks), and __alloc_pages() does that.  Also
    good so far.
 3) But gfp.h defines GFP_ATOMIC to be an alias for __GFP_HIGH,
    and many callers through out the kernel use GFP_ATOMIC to mean
    "can't sleep" or "can't wait" or some such.  These folks are
    not getting the service they expect - they are asking for the
    most aggressive form of allocation (short perhaps of the
    special case for allocations that will net free more memory
    than they require, such as exiting), and they get the half way
    improvement instead, with the possibility of sleeping (!).

The confusion even extends to the comments in __alloc_pages(),
such as in the lines:

	/* Atomic allocations - we can't balance anything */
	if (!wait)
		goto nopage;

The "!wait" condition is --not-- GFP_ATOMIC, which is what
one might think was meant by "Atomic allocations", and likely
what the many users of GFP_ATOMIC were expecting - a nopage
response in such cases.

Perhaps GFP_ATOMIC should be its own __GFP_ATOMIC bit, with a BUG_ON
if both __GFP_ATOMIC and __GFP_WAIT are set at the same time,
leaving __GFP_HIGH for the few uses where people were just asking
to go a bit lower in the reserves.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
