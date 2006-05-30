Message-ID: <447BEFCF.5000406@yahoo.com.au>
Date: Tue, 30 May 2006 17:10:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au>	<20060529121556.349863b8.akpm@osdl.org>	<447B8CE6.5000208@yahoo.com.au>	<20060529183201.0e8173bc.akpm@osdl.org>	<447BB3FD.1070707@yahoo.com.au>	<Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>	<447BD31E.7000503@yahoo.com.au>	<447BD63D.2080900@yahoo.com.au> <17531.57913.151520.946557@cse.unsw.edu.au>
In-Reply-To: <17531.57913.151520.946557@cse.unsw.edu.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Neil Brown wrote:
> On Tuesday May 30, nickpiggin@yahoo.com.au wrote:
> 
>>Nick Piggin wrote:
>>

>>For workloads where plugging helps (ie. lots of smaller, contiguous
>>requests going into the IO layer), the request pattern should be
>>pretty good without plugging these days, due to multiple page
>>readahead and writeback.
> 
> 
> Can I please put in a vote for not thinking that every device is disk
> drive?
> 
> I find plugging fairly important for raid5, particularly for write.
> 
> The more whole-stripe writes I can get, the better throughput I get.
> So I tend to keep a raid5 array plugged while any requests are
> arriving, and interpret 'plugged' to mean that incomplete stripes
> don't get processed while full stripes (needing no pre-reading) do get
> processed.
> 
> The only way "large requests" are going to replace plugging is they
> are perfectly aligned, which I don't expect to ever see.

Fair enough, thanks for the input. I was more imagining that IO tends
to come down in decent chunks, but obviously that's still not sufficient
for some. OK.

> 
> As for your original problem.... I wonder if PG_locked is protecting
> too much?  It protects against IO and it also protects against ->mapping
> changes.  So if you want to ensure that ->mapping won't change, you
> need to wait for any pending read request to finish, which seems a bit
> dumb.

I don't think that is the problem. set_page_dirty_lock is really
unlikely to get held up on read IO: that'd mean there were two things
writing into that page at the same time.

 >
> Maybe we need a new bit: PG_maplocked.  You are only allowed to change
> ->mapping or ->index of you hold PG_locked and PG_maplocked, you are
> not allowed to wait for PG_locked while holding PG_maplocked, and
> you can read ->mapping or ->index while PG_locked or PG_maplocked are
> held.
> Think of PG_locked like a mutex and PG_maplocked like a spinlock (and
> probably use bit_spinlock to get it).

Well the original problem is fixed by not doing the sync_page thing in
set_page_dirty_lock. Is there any advantage to having another bit?
Considering a) it will be very unlikely that a page is locked at the
same time one would like to dirty it; and b) that would seem to imply
adding extra atomic ops and barriers to reclaim and truncate (maybe
others).

> 
> Then set_page_dirty_lock would use PG_maplocked to get access to
> ->mapping, and then hold a reference on the address_space while
> calling into balance_dirty_pages ... I wonder how you hold a reference
> on an address space...

inode. Presumably PG_maplocked would pin it? I don't understand
why you've brought balance_dirty_pages into it, though.

> 
> There are presumably few pieces of code that change ->mapping.  Once
> they all take PG_maplocked as well as PG_locked, you can start freeing
> up other code to take PG_maplocked instead of PG_locked....
> 
> Does that make sense at all?  Do we have any spare page bits?

I'm sure it could be made to work, but I don't really see the point.
If someone really wanted to do it, I guess the right way to go is have
a PG_readin counterpart to PG_writeback (or even extend PG_writeback
to PG_io)...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
