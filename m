Received: from mail.ccr.net (ccr@alogconduit1ap.ccr.net [208.130.159.16])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA18254
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 23:58:47 -0500
Subject: Re: naive questions, docs, etc.
References: <199901051028.EAA10937@disco.cs.utexas.edu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 05 Jan 1999 22:41:28 -0600
In-Reply-To: "Paul R. Wilson"'s message of "Tue, 5 Jan 1999 04:28:21 -0600"
Message-ID: <m1btkdhv2f.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Paul R. Wilson" <wilson@cs.utexas.edu>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "PW" == Paul R Wilson <wilson@cs.utexas.edu> writes:
>> 

PW> Eric,

PW>    Thanks for all the comments.  (Colin, too.)

>> 
>> For the basic memory alloctor,  linux mostly implements a classic
>> two handed clock algorithm.    The first hand is swap_out which 
>> unmaps pages.  The second hand is shrink_mmap.  Which takes pages
>> which we are sure no one else is using and puts them in the free page pool.

PW> Is this a classic two-handed algorithm?  

Not in the exact implementation, and it is chance not design that brought
them together.  But I believe it is fundamentally the same.

I don't have a good reference on the two handed clock algorithm handy,
and a comparison with previous work would probably be useful.

The basic part of the algorithm that I recall is tow hands doing
seperate things, and going at different rates.  The virtual
vs physical thing is only a different ordering of the pages and it
should not make a significant difference.

PW> I thought that in a two-handed
PW> algorithm, both hands worked over page frames, and bore a particular
PW> relationship to each other.  (Rather than sweeping over different
PW> page orderings entirely, physical vs. virtual.)  I may have my terminology
PW> wrong, though.

>> The referenced bit on the on the on a page makes up for any mismatch 
>> between swap_out, and shrink_mmap.  Ensuring a page will stay if it
>> has been recently referenced, or in the case of newly allocated readahead,
>> not be expelled before the readahead is needed. 

PW> I take it you mean the reference bit on the page struct (the PG_referenced
PW> flag.
Yes.


PW> In the current scheme, it's not clear to me how much precision the 
PW> PG_referenced bit gives you.  Depending on the positions of both
PW> hands, it seems to me that a page could be touched and immediately
PW> one hand would sweep it, copying the bit to PG_referenced and clearing
PW> it, and then the other hand could come by and clear that.   At the
PW> other extreme, the page could be touched right after the first hand
PW> reaches it, and not be considered by that clock sweep until a
PW> whole cycle goes by;  then the same thing could happen to the bit
PW> in the second (shrink_mmap) clock after the bit is copied from the pte to
PW> PG_referenced.


>> The goofy part of implementing default actions inline is probably questionable
>> from a design perspective.  However there is no real loss, and further it
>> is a technique as branches, and icache misses get progressively more expensive
>> compiler writers are contemplating seriously considering.  In truth it is a
>> weak of VLIW optimizing.

PW> Is the performance benefit significant, or is it mostly just that the
PW> code hasn't been cleaned up, or a combination of both?

I haven't done the analysis to answer this one.  It appears to me
to be a matter of style, at this point.    Most of the code deals
with disk accesses in which case execution time of one style versus
another would be very significant.

>> SysV shm is a wart on the system that was orginally implemented as
>> a special case and no one has put in the time to clean it up since.
>> I have work underway that will probably do some of that for 2.3 however.

PW> Will that be just making shm segments anonymous regions and doing
PW> mmaps on them, so that their pages are handled by the normal clock
PW> and shrink-mmap?

Where I am currently at is:
I have experimented with generic dirty page handling in the page
cache and have uncovered all of the requirements, to make it work.
I have written a filesystem similiar to tmpfs to test this code.
Tuning has yet to happen.

I am currently experimenting with a light weight vm_store object
to replace inode in the page cache, to aid things like shm and the
swap cache in using it, and in general give the whole system more
flexibility.

How much happens is up in the air both because of inevitable time
constraints, and because I haven't decided how much I'm going to do.
But since I have essential written a work alike to shm with a
different interface there is a lot of potential for change,  with
ambition the lacking goal.

PW> I do have some questions about it that relate to my more basic questions
PW> about the swap cache.

PW> Is the swap cache typically large, because pages are evicted to it
PW> aggressively, so that it really acts as a significant aging stage?

PW> Is the swap cache used only for dirty pages, that is, pages that
PW> are dirty when swap_out gets to them? 

No.  When a swap page is read in it is kept in the swap cache.  
If that page isn't changed until it is removed from a process it waits
in the swap cache until it is either needed again or it's memory is 
reclaimed.

PW> This would seem to introduce
PW> a bias toward having dirtied pages cached (in swap cache) longer than
PW> clean ones.  So, for example, if you turned up the swap_out clock sweep
PW> speed and grew the swap cache, it would tend to favor user pages over
PW> shared library pages.  Is that right?

Hmm.

The issue of how to correctly handle dirty pages hasn't been 
resolved yet to my satisfaction.

shared library pages tend to be favored because generally they
have many mappings.  

The shrink_mmap from 2.1.132 currently clears the referenced bit
before looking to see if a page is locked, or has multiple users.
So a dirty page only has the extra bias of staying around until
it actually becomes clean.

Since the clocks tend to be demand driven how much of an advantage
being dirty confirs is hard to guess.

I seriously suspect a page cleaner with different goals would be
useful.  I'm going to try that anyway in 2.3. . .

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
