Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA19594
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 06:17:34 -0500
Date: Tue, 24 Nov 1998 11:17:22 GMT
Message-Id: <199811241117.LAA06562@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981123215933.2401.qmail@sidney.remcomp.fr>
References: <19981119002037.1785.qmail@sidney.remcomp.fr>
	<199811231808.SAA21383@dax.scot.redhat.com>
	<19981123215933.2401.qmail@sidney.remcomp.fr>
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Nov 1998 21:59:33 -0000, jfm2@club-internet.fr said:

> The problem is: will you be able to manage the following situation?

> Two processes running in an 8 Meg box.  Both will page fault every ms
> if you give them 4 Megs (they are scanning large arrays so no
> locality), a page fault will take 20 ms to handle.  That means only 5%
> of the CPU time is used, remainder is spent waiting for page being
> brought from disk or pushing a page of the other process out of
> memory.  And both of these processes would run like hell (no page
> fault) given 6 Megs of memory.

These days, most people agree that in this situation your box is simply
misconfigured for the load. :)  Seriously, requirements have changed
enormously since swapping was first implemented.

> Only solution I see is stop one of them (short of adding memory :) and
> let the other one make some progress.  That is swapping.  

No it is not.  That is scheduling.  Swapping is a very precise term used
to define a mechanism by which we suspend a process and stream all of
its internal state to disk, including page tables and so on.  There's no
reason why we can't do a temporary schedule trick to deal with this in
Linux: it's still not true swapping.

> In 96 I asked for that same feature, gave the same example (same
> numbers :-) and Alan Cox agreed but told Linux was not used under
> heavy loads. That means we are in a catch 22 situation: Linux not used
> for heavy loads because it does not handle them well and the necessary
> feaatures not implemented because it is not used in such situations.

Linux is used under very heavy load, actually.

> And now we are at it: in 2.0 I found a deamon can be killed by the
> system if it runs out of VM.  

Same on any BSD.  Once virtual memory is full, any new memory
allocations must fail.  It doesn't matter whether that allocation comes
from a user process or a daemon: if there is no more virtual memory then
the process will get a NULL back from malloc.  If a daemon dies as a
result of that, the death will happen on any Unix system.  

> Problem is: it was a normal user process who had allocatedc most of it
> and in addition that daemon could be important enough it is better to
> kill anything else, so it would be useful to give some privilege to
> root processes here.

No.  It's not an issue of the operating system killing processes.  It is
an issue of the O/S failing a request for new memory, and a process
exit()ing as a result of that failed malloc.  The process is voluntarily
exiting, as far as the kernel is concerned.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
