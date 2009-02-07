Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 680686B003D
	for <linux-mm@kvack.org>; Sat,  7 Feb 2009 11:51:10 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so670441waf.22
        for <linux-mm@kvack.org>; Sat, 07 Feb 2009 08:51:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090206130009.99400d43.akpm@linux-foundation.org>
References: <20090206031125.693559239@cmpxchg.org>
	 <20090206031324.004715023@cmpxchg.org>
	 <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206044907.GA18467@cmpxchg.org>
	 <20090206130009.99400d43.akpm@linux-foundation.org>
Date: Sun, 8 Feb 2009 01:51:06 +0900
Message-ID: <2f11576a0902070851q7d478679i8a47ad9b3810dc0e@mail.gmail.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, rjw@sisk.pl, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/2/7 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 6 Feb 2009 05:49:07 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>> > and, I think you should mesure performence result.
>>
>> Yes, I'm still thinking about ideas how to quantify it properly.  I
>> have not yet found a reliable way to check for whether the working set
>> is intact besides seeing whether the resumed applications are
>> responsive right away or if they first have to swap in their pages
>> again.
>
> Describing your subjective non-quantitative impressions would be better
> than nothing...
>
> The patch bugs me.
>
> The whole darn point behind the whole darn page reclaim is "reclaim the
> pages which we aren't likely to need soon".  There's nothing special
> about the swsusp code at all!  We want it to do exactly what page
> reclaim normally does, only faster.
>
> So why do we need to write special hand-rolled code to implement
> something which we've already spent ten years writing?
>
> hm?  And if this approach leads to less-than-optimum performance after
> resume then the fault lies with core page reclaim - it reclaimed the
> wrong pages!
>
> That actually was my thinking when I first worked on
> shrink_all_memory() and it did turn out to be surprisingly hard to
> simply reuse the existing reclaim code for this application.  Things
> kept on going wrong.  IIRC this was because we were freeing pages as we
> were reclaiming, so the page reclaim logic kept on seeing all these
> free pages and kept on wanting to bale out.
>
> Now, the simple and obvious fix to this is not to free the pages - just
> keep on allocating pages and storing them locally until we have
> "enough" memory.  Then when we're all done, dump them all straight onto
> to the freelists.
>
> But for some reason which I do not recall, we couldn't do that.

current strategy is introduced commit d6277db4ab271862ed599da08d78961c70f00002
quotation here.

    Author: Rafael J. Wysocki <rjw@sisk.pl>
    Date:   Fri Jun 23 02:03:18 2006 -0700
    Subject: [PATCH] swsusp: rework memory shrinker

    Rework the swsusp's memory shrinker in the following way:

    - Simplify balance_pgdat() by removing all of the swsusp-related code
      from it.

    - Make shrink_all_memory() use shrink_slab() and a new function
      shrink_all_zones() which calls shrink_active_list() and
      shrink_inactive_list() directly for each zone in a way that's optimized
      for suspend.

    In shrink_all_memory() we try to free exactly as many pages as the caller
    asks for, preferably in one shot, starting from easier targets.  ?If slab
    caches are huge, they are most likely to have enough pages to reclaim.
    ?The inactive lists are next (the zones with more inactive pages go first)
    etc.

    Each time shrink_all_memory() attempts to shrink the active and inactive
    lists for each zone in 5 passes.  ?In the first pass, only the inactive
    lists are taken into consideration.  ?In the next two passes the active
    lists are also shrunk, but mapped pages are not reclaimed.  ?In the last
    two passes the active and inactive lists are shrunk and mapped pages are
    reclaimed as well.  The aim of this is to alter the reclaim logic to choose
    the best pages to keep on resume and improve the responsiveness of the

and related discussion mail here.

akpm wrote:
--------------
 And what was the observed effect of all this?

Rafael wrote:
--------------
Measurable effects:
1) It tends to free only as much memory as required, eg. if the image_size
is set to 450 MB, the actual image sizes are almost always well above
400 MB and they tended to be below that number without the patch
(~5-10% of a difference, but still :-)).
2) If image_size = 0, it frees everything that can be freed without any
workarounds (we had to add the additional loop checking for
ret >= nr_pages with the additional blk_congestion_wait() to the
"original" shrinker to achieve this).



my conclusion is, nobody says "we can't". it's performance improvement
purpose commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
