Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 251A16B0036
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 08:55:10 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id u14so9254967lbd.37
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:55:09 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id kv5si8434897lbc.66.2014.02.14.05.55.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 05:55:07 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1WEJEO-0005Tl-B0
	for linux-mm@kvack.org; Fri, 14 Feb 2014 14:55:04 +0100
Received: from deibp9eh1--blueice1n3.emea.ibm.com ([195.212.29.165])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 14:55:04 +0100
Received: from ehrhardt by deibp9eh1--blueice1n3.emea.ibm.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 14:55:04 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
Date: Fri, 14 Feb 2014 13:10:06 +0000 (UTC)
Message-ID: <loom.20140214T135753-812@post.gmane.org>
References: <20140213104231.GX6732@suse.de> <CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Weijie Yang <weijie.yang.kh <at> gmail.com> writes:

> 
> On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman <at> suse.de> wrote:
[...]
> > -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> > +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
> 
[...]
> Does it lead to a "schlemiel the painter's algorithm"?
> (please forgive my rude words, but I can't find a precise word to describe it
> 
> How about modify it like this?
> 
[...]
> - next = swap_list.head;
> + next = type;
[...]

Hi,
unfortunately withou studying the code more thoroughly I'm not even sure if
you meant you code to extend or replace Mels patch.

To be sure about your intention.  You refered to algorithm scaling because
you were afraid the new code would scan the full list all the time right ?

But simply letting the machines give a try for both options I can now
qualify both.

Just your patch creates a behaviour of jumping over priorities (see the
following example), so I hope you meant combining both patches.
With that in mind the patch I eventually tested the combined patch looking
like this:

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 612a7c9..53a3873 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -650,7 +650,7 @@ swp_entry_t get_swap_page(void)
                goto noswap;
        atomic_long_dec(&nr_swap_pages);
 
-       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
+       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
                hp_index = atomic_xchg(&highest_priority_index, -1);
                /*
                 * highest_priority_index records current highest priority swap
@@ -675,7 +675,7 @@ swp_entry_t get_swap_page(void)
                next = si->next;
                if (next < 0 ||
                    (!wrapped && si->prio != swap_info[next]->prio)) {
-                       next = swap_list.head;
+                       next = type;
                        wrapped++;
                }


At least for the two different cases we identified to fix with it the new
code works as well:
I) incrementing swap now in proper priority order
Filename                                Type            Size    Used    Priority
/testswap1                              file            100004  100004  8
/testswap2                              file            100004  100004  7
/testswap3                              file            100004  100004  6
/testswap4                              file            100004  100004  5
/testswap5                              file            100004  100004  4
/testswap6                              file            100004  68764   3
/testswap7                              file            100004  0       2
/testswap8                              file            100004  0       1

II) comparing a memory based block device "as one" vs "split into 8 pieces"
as swap target(s).
Like with Mels patch alone I'm able to achieve 1.5G/s TP on the
overcommitted memory no matter how much swap targets I split it into.

So while I can't speak for the logical correctness of your addition to the
patch at least in terms of effectiveness it seems fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
