Message-ID: <000501c7e569$023fa240$6501a8c0@earthlink.net>
Reply-To: "Mitchell Erblich" <erblichs@earthlink.net>
From: "Mitchell Erblich" <erblichs@earthlink.net>
Subject: [RFC]  : mm : / Patch / Suggestion : Add 1 order or agressiveness to wakeup_kswapd() : 1 line / 1 arg change
Date: Thu, 23 Aug 2007 02:35:46 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "\"Ingo Molnar\"" <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Group,

    On the infrequent condition of failing to recieve a page from the
    freelists, one of the things you do is call wakeup_kswapd()(exception of
    NUMA or GFP_THISNODE).

    Asuming that wakeup_kswapd() does what we want, this call is
    such a high overhead call that you want to make sure that the
    call is infrequent.
    My initial guess is that it REALLY needs to re-populate the
    freelists just before they/it is used up. However, the simple change
    is being suggested NOW.

    Assuming that on avg that the order value will be used, you should
    increase the order to cover two allocs of that same level of order,
    thus the +1. If on the chance that later page_alloc() calls need
    fewer pages (smaller order) then the extra pages will be available
    for more page_allocs(). If later calls have larger orders, hopefully
    the latency between the calls is great enough that other parts of
    the system will respond to the low memory / on the freelist(s).

    Line 1265 within function __alloc_pages(), mm/page_alloc.c

wakeup_kswapd(*z, order);
      to
wakeup_kswapd(*z, order + 1);

In addition, isn't a call needed to determine that the
freelist(s) are almost empty, but are still returning a page?

Thus,  a lightweight call be done after a NORMAL
 page is recieved at line 1250 if (page) from the
 get_page_from_freelist()?  Or it could be embedded within the
 function call path that get_page_from_freelist() uses?

We could call  wakeup_kswapd()
 or equiv pro-actively?  The idea is that the call should check for
 2x of LOW_MEMORY equiv of the freelists and to re-populate them.
Then, HOPEFULLY the 2nd time calling get_page_from_freelist() would
then be obsolete.

When I come up with it, I will suggest it to the group.

Mitchell Erblich
FYI: My kernel is different enough that I can not validate this change
for the 2.6.2x git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
