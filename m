Date: Fri, 21 Jan 2000 14:24:02 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.10.10001210329300.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001211402470.486-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>> >Once we've reached free_pages.high, kswapd will sleep
>> >and not wake up again until we've reached an emergency
>> >situation. And when we are in an even worse emergency
>> >kswapd will bloody SLEEP for 10 seconds!
>> 
>> That's fine instead.
>
>Why is this a good thing? I really don't see why it
>helps us any bit...

The worse emergency is oom. During oom kswapd can only harm. Only real
application can do something getting killed or releasing memory thus
having kswapd out of the game will allow to handle oom gracefully.

>Not on a quiet machine. Or on a somewhat larger machine.
>Think a webserver, or a desktop machine that's streaming
>mp3s from disk or reading email.

Reading emails my mailer executable grow with a 35mbyte/sec rate
regularly.

>In those loads there is enough idle time that kswapd can
>free up memory in the background and memory consumption
>is so slow that normal processes never stall or even leave
>the fast path. That is definately a good thing.

This is true only for shrink_mmap (for swap there's not enough time). The
pre-wakeup patch I posted this night will take care of this memory-freeing
in background (potentially in a parallel cpu).

>Indeed. And the probability is that the most unused
>process will be continuously swapping while the hog
>is using up most of system memory. We've all seen
>it happen.

If you'll apply my trashing_mem patch that bias the current trashing_mem
heuristic making it a per-task thing you would see what happens instead to
a trashing hog.

>> Run the trashing_mem patch I pointed out to Alan. I debugged it
>> with printk and it punish the right process here. Give it a try.
>> It will only bias a bit more the current heuristic.
>
>Sounds like a good idea, but for 2.3. I'll check it out.

My per-task trashing_mem is used for production just now in 2.2.x since
quite some time ago. it's not a news. it's also how I designed the code
originally (that make more sense to me).

>> And I am not changing the semantics of anything. Please read the
>> diff before complaining.
>
>What diff? [..]

	ftp://ftp.*.kernel.org/pub/linux/kernel/v2.2/patch-2.2.14.gz

(or precisely the interesting part with the sparc updates excluded is:

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.13aa6/oom-2.2.12-I.gz
)

>And if it's too big to post, it's definately
>too big to go into the stable kernel...

So backout patch-2.2.14 if you want to return to get oom deadlocks :). I
took the small patch approch and then Linus didn't liked it and he liked
the way that 2.3.x took and to do so I had to break all archs but then I
am been able to do things like sending SIGTERM to process in iopl so that
they can recover the oom gracefully without screwing up the console.

>> I'll try to send a patch against 2.2.14 for the atomic allocation
>> thing that I think to see ASAP.
>
>OK, great. Let's try to use each other's ideas and
>make the code as good as possible.

I have not used your ideas, but someway discussing with you
I seen what could be the allocation problem, so the discussion IMHO had a
positive result :). You didn't either changed GFP in your patches (while I
only reworked GFP) and you didn't killed the 1 second polling (while I
killed the 1 second polling).

IMHO, the right fix is to wakeup kswapd from GFP unconditionally when the
low watermark triggers as I did in my patch. In the patch I posted I am
waking up on the _high_ watermark, but I just did a new version of the
patch that wakeups at the _low_ watermark. Using the _high_ is safer (it's
better for atomic allocations) but it will produce worse performance
because kswapd will be wakenup too often for a little work. While waking
up at the low (and it's not low but "low" here means middle) watermark
will wakeup kswapd only when there is some good work to do. Hopefully
waking up at the low watermark won't be too late... But I'd like to try it
out because for the normal allocations the low limit seems way better than
the high one.

The new patch against 2.2.14 is here:

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/atomic-allocations-2.gz

The only difference between my last patch and the new patch is this:

--- 2.2.14-kswapd/mm/page_alloc.c.~2~	Fri Jan 21 03:29:40 2000
+++ 2.2.14-kswapd/mm/page_alloc.c	Fri Jan 21 13:50:58 2000
@@ -222,7 +222,8 @@
 		}
 		else
 		{
-			wake_up_interruptible(&kswapd_wait);
+			if (nr_free_pages < freepages.low)
+				wake_up_interruptible(&kswapd_wait);
 			if (nr_free_pages > freepages.min && !low_on_memory)
 				goto ok_to_allocate;
 		}

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
