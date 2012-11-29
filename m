Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1EFF76B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 10:26:47 -0500 (EST)
Message-ID: <50B77F84.1030907@leemhuis.info>
Date: Thu, 29 Nov 2012 16:30:12 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com> <50B52DC4.5000109@redhat.com> <20121127214928.GA20253@cmpxchg.org> <50B5387C.1030005@redhat.com> <20121127222637.GG2301@cmpxchg.org> <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com> <20121128101359.GT8218@suse.de> <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de>
In-Reply-To: <20121128235412.GW8218@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Mel Gorman wrote on 29.11.2012 00:54:
> On Wed, Nov 28, 2012 at 02:52:15PM -0800, Andrew Morton wrote:
>> On Wed, 28 Nov 2012 10:13:59 +0000
>> Mel Gorman <mgorman@suse.de> wrote:
>> 
>> > Based on the reports I've seen I expect the following to work for 3.7
>> > Keep
>> >   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
>> >   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
>> > Revert
>> >   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
>> > Merge
>> >   mm: vmscan: fix kswapd endless loop on higher order allocation
>> >   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended
>> "mm: Avoid waking kswapd for THP ..." is marked "I have not tested it
>> myself" and when Zdenek tested it he hit an unexplained oom.
> I thought Zdenek was testing with __GFP_NO_KSWAPD when he hit that OOM.
> Further, when he hit that OOM, it looked like a genuine OOM. He had no
> swap configured and inactive/active file pages were very low. Finally,
> the free pages for Normal looked off and could also have been affected by
> the accounting bug. I'm looking at https://lkml.org/lkml/2012/11/18/132
> here. Are you thinking of something else?
> 
> I have not tested with the patch admittedly but Thorsten has and seemed
> to be ok with it https://lkml.org/lkml/2012/11/23/276.

Yeah, on my two main work horses a few different kernels based on rc6 or
rc7 worked fine with this patch. But sorry, it seems the patch doesn't
fix the problems Fedora user John Ellson sees, who tried kernels I built
in the Fedora buildsystem. Details:

In https://bugzilla.redhat.com/show_bug.cgi?id=866988#c35 he mentioned
his machine worked fine with a rc6 based kernel I built that contained
82b212f4 (Revert "mm: remove __GFP_NO_KSWAPD"). Before that he had tried
a kernel with the same baseline that contained "Avoid waking kswapd for
THP allocations when [a?|]" instead and reported it didn't help on his
i686 machine (seems it helped the x86-64 one):
https://bugzilla.redhat.com/show_bug.cgi?id=866988#c33

He now tried a recent mainline kernel I built 20 hours ago that is based
on a git checkout from round about two days ago, reverts 82b212f4, and had
 * fix-kswapd-endless-loop-on-higher-order-allocation.patch
 * Avoid-waking-kswapd-for-THP-allocations-when.patch
 * mm-compaction-Fix-return-value-of-capture_free_page.patch
applied. In https://bugzilla.redhat.com/show_bug.cgi?id=866988#c39 and
comment 41 he reported that this kernel on his i686 host showed 100%cpu
usage by kswapd0 :-/

Build log for said kernel rpms (I quite sure I applied the patches
properly, but you know: mistakes happen, so be careful, maybe I did
something stupid somewhere...):
http://kojipkgs.fedoraproject.org//work/tasks/8253/4738253/build.log

I know, this makes things more complicated again; but I wanted to let
you guys know that some problem might still be lurking somewhere. Side
note: right now it seems John with kernels that contain
"Avoid-waking-kswapd-for-THP-allocations-when" can trigger the problem
quicker (or only?) on i686 than on x86-64.

CU
Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
