Subject: Re: Please test: workaround to help swapoff behaviour
Message-ID: <OF4314E00C.5B8A0E4C-ON85256A64.006F54E0@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Thu, 7 Jun 2001 16:33:38 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




>This is for the people who has been experiencing the lockups while running
>swapoff.
>
>Please test. (against 2.4.6-pre1)
>
>
>--- linux.orig/mm/swapfile.c Wed Jun  6 18:16:45 2001
>+++ linux/mm/swapfile.c Thu Jun  7 16:06:11 2001
>@@ -345,6 +345,8 @@
>         /*
>          * Find a swap page in use and read it in.
>          */
>+        if (current->need_resched)
>+             schedule();
>         swap_device_lock(si);
>         for (i = 1; i < si->max ; i++) {
>              if (si->swap_map[i] > 0 && si->swap_map[i] != SWAP_MAP_BAD)
{


I tested your patch against 2.4.5.  It works.  No more lockups.  Without
the
patch it took 14 minutes 51 seconds to complete swapoff (this is to recover
1.5GB of
swap space).  During this time the system was frozen.  No keyboard, no
screen, etc. Practically locked-up.

With the patch there are no more lockups. Swapoff kept running in the
background.
This is a winner.

But here is the caveat: swapoff keeps burning 100% of the cycles until it
completes.
This is not going to be a big deal during shutdowns.  Only when you enter
swapoff from
the command line it is going to be a problem.

I looked at try_to_unuse in swapfile.c.  I believe that the algorithm is
broken.
For each and every swap entry it is walking the entire process list
(for_each_task(p)).  It is also grabbing a whole bunch of locks
for each swap entry.  It might be worthwhile processing swap entries in
batches instead of one entry at a time.

In any case, I think having this patch is worthwhile as a quick and dirty
remedy.

Bulent Abali



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
