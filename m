Subject: Re: [PATCH] fix for VM test9-pre,
Message-ID: <OFDCCD4FB3.D8224F16-ON8825696C.0062CC27@LocalDomain>
From: "Ying Chen/Almaden/IBM" <ying@almaden.ibm.com>
Date: Mon, 2 Oct 2000 12:01:03 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



>> Eample 2: I ran SPEC SFS tests to stress the Linux box. During
>> the tests, the lower memory will be filled up with inode cache
>> and dcache entries, while HIGHMEM is not quite used at all. Once
>> this happens, again, any interactive commands would take forever
>> to finish... Eventually, SPEC SFS would timeout and fail.
>> Sometimes, if I managed to kill some processes, I can
>> temporarilly get some other applications run. But most of the
>> applications would get stuch somewhere very quickly later on.



> However, I have no idea why your buffers and pagecache pages
> aren't bounced into the HIGHMEM zone ... They /should/ just
> be moved to the HIGHMEM zone where they don't bother the rest
> of the system, but for some reason it looks like that doesn't
> work right on your system ...


In the second example (running SPEC SFS), not much buffer space is used
though.
All of the stuff there in NORMAL is from inode cache and dcache entries.
So,
it doesn't seem that bouncing buffers to highmem would help much in the
second case.

Also, it's not the case that the buffers and pagecaches are not bounced to
the highmem I think.
For example, I tried to stick shrink_icache_memory() and
shrink_dcache_memory() below
refill_inactive_scan(xx) in kswapd(), to let it clean up some inode and
dcache entires
even if there is no memory pressure (every 1 sec I think). This seems to
make the system go back to normal.
When this happens, the system was able to use all the available space for
pagecache and buffers, both HIGH and LOW.
But as you can see, this fix doesn't seem to make sense, at least not quite
to me, and I don't know if
it would break anything else.

Ying



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
