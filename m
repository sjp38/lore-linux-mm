Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 085DF6B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 05:51:20 -0500 (EST)
Message-ID: <50B5ECA3.9040407@leemhuis.info>
Date: Wed, 28 Nov 2012 11:51:15 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com> <50B52DC4.5000109@redhat.com> <20121127214928.GA20253@cmpxchg.org> <50B5387C.1030005@redhat.com> <20121127222637.GG2301@cmpxchg.org> <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com> <20121128101359.GT8218@suse.de>
In-Reply-To: <20121128101359.GT8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Mel Gorman wrote on 28.11.2012 11:13:
> On Tue, Nov 27, 2012 at 03:19:38PM -0800, Linus Torvalds wrote:
>> On Tue, Nov 27, 2012 at 2:26 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > On Tue, Nov 27, 2012 at 05:02:36PM -0500, Rik van Riel wrote:
>
>> And the one who comes out gets to explain to me which patch(es) I
>> should apply, and which I should revert, if any.
> 
> Based on the reports I've seen I expect the following to work for 3.7
> 
> Keep
>   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
>   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
> 
> Revert
>   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
> 
> Merge
>   mm: vmscan: fix kswapd endless loop on higher order allocation
>   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended

I'll build a kernel with this combination and will give it a try. Maybe
one of those people that reported problems in
https://bugzilla.redhat.com/show_bug.cgi?id=866988 can try them, too.
There two people recently reported their problems were gone with kernels
that contained 82b212f4.

> Johannes' patch should remove the necessity for __GFP_NO_KSWAPD revert but I
> think we should also avoid waking kswapd for THP allocations if compaction
> is deferred. Johannes' patch might mean that kswapd goes quickly go back
> to sleep but it's still busy work.

Is there a way to trigger (some benchmark?) and detect (something in
/proc/vmstat ?) the problem Hannes patch tries to fix?

Background: The two main problems that got me into this discussion
vanished thx to 9671009 (mm: revert "mm: vmscan: scale number of pages
reclaimed by reclaim/compaction based on failures") and ef6c5be (fix
incorrect NR_FREE_PAGES accounting (appears like memory leak)). I
thought all my problems had gone, but after a few days of uptime
(suspended and resumed the particular machine a few times in between, as
I was using it just in the evenings) kswap now and then started
consuming nearly 100% of one cpu core for 10 to 15 seconds intervals (it
seems watching a YouTube video triggered it; and the machine was using a
little bit swap space). I just had started debugging this, but due to
some stupid mistake
(https://plus.google.com/107616711159256259828/posts/GXuhf1LTien ) then
rebooted the machine :-/ So maybe I hit the problem Hannes patch tries
to solve, but I'm not sure; and I have no easy way to verify quickly if
the proposed patch combination helps.

Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
