Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA30393
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 09:51:18 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <199901191515.PAA05462@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 20 Jan 1999 08:52:33 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 19 Jan 1999 15:15:33 GMT"
Message-ID: <m1ognuvvwu.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On 14 Jan 1999 04:08:02 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
ST> said:

>> This patch is agains 2.2.0-pre5.
>> I have been working and have implemented a daemon that does
>> all swaping out except from shm areas (todo).

>> What it does is add an extra kernel daemon that does nothing but
>> walking through the page tables start I/O on dirty pages and mark them
>> clean and write protected.  Sleep 30 seconds and do it again.

ST> This feels like the wrong way of doing it.  We _already_ have a page
ST> walking algorithm.  Why do we need another one?

This was just supposed to be just a small a refinement of the current one.

The thought was:  
(a)  A single walk of all of the page tables is relatively cheap.
(b)  There is a real advantage to clearing all of dirty pte entries
     before writing out pages.  For mulitple mapped pages if we can
     clear all of the dirty pte entries before we go actually write a page
     to disk is an advantage.
(c)  This was a small first step, in the direction of putting everything 
     in a laundry list.  I just wanted to go write the code that cleared
     the dirty bit, and filled the laundry list first.
(d)  For playing with the code this was as far as I felt I could
     possibly go if I was to consider it for 2.2.
     Consider both my problems making this change, and more
     importantly the problems balancing the code, I have removed
     it for consideration for 2.2.

ST> My own feeling is that a laundry list (a list of pages needing written
ST> out, either to swap or via filemap) is a better way of running the
ST> background swapout thread.  That way we can cluster the IO appropriately
ST> (using the ordering of the laundry list) while still making the IO
ST> completely asynchronous.

After working with this code for a while, as it currently exists.
I have learned a couple of things.

1) With a totally seperate writeout daemon it is hard to modify,
   try_to_free_pages so that it waits long enough for pages to be swapped.

2) You can walk the page tables very fast.  
   Not fast enough to want to walk all of the pages for a single call of try to free pages.
   But fast enough to refill the dirty list.

ST> I'd suspect any new code first, and old code second: 

Actually I always do but there are times my mind boggles, and can't possibly
imagine what I'm doing wrong.

ST> if my own experience
ST> with the VM is anything to go by, seemingly trivial changes can have
ST> unexpected and subtle side effects...

After working with this agreed.  And thank you for looking.
Did you see my later posts?
I have already said it was my fault.

I have fixed the pte write race.  Added the missing flush_tlb_page calls,
and a few other things.
And eventually found there was one external source of problems,
but it was my misunderstanding of the code.

Having 2 dirty pte's for a write protected page resulting from 
fork was not something I was expecting to come walking by.

As I said later as we get close to 2.2 I get nervous, and would rather
report a possible bug early, and fall flat on my face.  Then have it get into
2.2.

Eric

p.s.
Since I'm getting some interest, here is my patch with all known
bugs fixed.  It doesn't work well but it isn't broken.

And following that is it against 2.2.0-pre7 where I am experimenting,
with trying to see if I can make the balancing work at all.
Watch out for this later one as I have observed it getting into
lockups, waking up my daemon and calling shrink_mmap, but never
freeing any memory?

begin 644 linux-2.2.0-pre5.eb1.2.diff.gz
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
B^5A_G-4OBX(2)/<+)I0MZ\[M%_&"FE+?_P'393UWYU<``+(\
`
end


begin 644 linux-2.2.0-pre7.eb1.4.diff.gz
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
2R+D]HISX`F;S/T@BT2XQ5@``
`
end
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
