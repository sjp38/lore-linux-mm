Received: from mail.ccr.net (ccr@alogconduit1al.ccr.net [208.130.159.12])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA27276
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 13:44:32 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <369E0501.987D2B3B@xinit.se>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 14 Jan 1999 10:49:05 -0600
In-Reply-To: Hans Eric Sandstrom's message of "Thu, 14 Jan 1999 15:53:54 +0100"
Message-ID: <m1hftt94vy.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Hans Eric Sandstrom <hes@xinit.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "HS" == Hans Eric Sandstrom <hes@xinit.se> writes:

HS> Eric W. Biederman wrote:
>> This patch is agains 2.2.0-pre5.
>> 
>> I have been working and have implemented a daemon that does
>> all swaping out except from shm areas (todo).
>> 
>> It is intended as an early protype for 2.3.
>> But it's acting like a bug magnet.
>> 
>> What it does is add an extra kernel daemon that does nothing but
>> walking through the page tables start I/O on dirty pages and mark them
>> clean and write protected.  Sleep 30 seconds and do it again.
>> 
>> Since aging isn't taken into account, and because it writes all
>> dirty pages this code is much more aggressive than any variation of
>> our current code in writing swap pages out.
>> 

HS> Can you explain this a little, why mark the pages write protected?

I am making a distinct difference between what our daemons do.
pgflush only writes out data, it never frees memory.
kswapd only frees memory it never writes anything out.

This should be useful for tuning.

The specific selection of write protection is that the
current vm assumes that if a page is in the swap cache,
it is not dirty, and that it is write protected.

To get write access it needs to either copy the page, or tear
down the swap cache.

Currently something is failing to obey this rule but I don't know where.

There is a small race (wrt data intgrity) that the setting of write protection
should be before we can start any I/O on the page.  (So if we write to the page
while it is undergoing I/O, and don't output those bytes we might miss it).

But that has nothing to do with the swapping problem :(

HS> And, this daemon shuld probably try to avoid IO if the system is IO bound already.

Agreed.  But that is a tunining issue.  I don't plan to tackle that until
the code stops blowing up in my face.   However avoiding I/O when the
system is IO bound is very difficult, because at this point we can't detect it.


Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
