Subject: Re: Please test: workaround to help swapoff behaviour
Message-ID: <OF2FF3269C.90D4688C-ON85256A66.006DEAFA@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sat, 9 Jun 2001 16:32:29 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



>Bulent,
>
>Could you please check if 2.4.6-pre2+the schedule patch has better
>swapoff behaviour for you?

Marcelo,

It works as expected.  Doesn't lockup the box however swapoff keeps burning
the CPU cycles.  It took 4 1/2 minutes to swapoff about 256MB of swap
content.  Shutdown took just as long.  I was hoping that shutdown would
kill the swapoff process but it doesn't.  It just hangs there.  Shutdown
is the common case.  Therefore, swapoff needs to be optimized for
shutdowns.
You could imagine users frustration waiting for a shutdown when there are
gigabytes in the swap.

So to summarize, schedule patch is better than nothing but falls far short.
I would put it in 2.4.6.  Read on.

----------

The problem is with the try_to_unuse() algorithm which is very inefficient.
I searched the linux-mm archives and Tweedie was on to this. This is what
he wrote:  "it is much cheaper to find a swap entry for a given page than
to find the swap cache page for a given swap entry." And he posted a
patch http://mail.nl.linux.org/linux-mm/2001-03/msg00224.html
His patch is in the Redhat 7.1 kernel 2.4.2-2 and not in 2.4.5.

But in any case I believe the patch will not work as expected.
It seems to me that he is calling the function check_orphaned_swap(page)
in the wrong place.  He is calling the function while scanning the
active_list in refill_inactive_scan().  The problem with that is if you
wait
60 seconds or longer the orphaned swap pages will move from active
to inactive lists. Therefore the function will miss the orphans in inactive
lists.  Any comments?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
