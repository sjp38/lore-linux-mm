Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1CE9D6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 10:39:48 -0500 (EST)
Received: by eekc41 with SMTP id c41so534073eek.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 07:39:46 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP
 prior to isolating
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
Date: Thu, 05 Jan 2012 16:39:43 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7ma4hm33l0zgt@mpn-glaptop>
In-Reply-To: <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang
 Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, 29 Dec 2011 13:39:02 +0100, Marek Szyprowski <m.szyprowski@samsu=
ng.com> wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
>
> When set_migratetype_isolate() sets pageblock's migrate type, it does
> not change each page_private data.  This makes sense, as the function
> has no way of knowing what kind of information page_private stores.
>
> Unfortunately, if a page is on PCP list, it's page_private indicates
> its migrate type.  This means, that if a page on PCP list gets
> isolated, a call to free_pcppages_bulk() will assume it has the old
> migrate type rather than MIGRATE_ISOLATE.  This means, that a page
> which should be isolated, will end up on a free list of it's old
> migrate type.
>
> Coincidentally, at the very end, set_migratetype_isolate() calls
> drain_all_pages() which leads to calling free_pcppages_bulk(), which
> does the wrong thing.
>
> To avoid this situation, this commit moves the draining prior to
> setting pageblock's migratetype and moving pages from old free list to=

> MIGRATETYPE_ISOLATE's free list.
>
> Because of spin locks this is a non-trivial change however as both
> set_migratetype_isolate() and free_pcppages_bulk() grab zone->lock.
> To solve this problem, this commit renames free_pcppages_bulk() to
> __free_pcppages_bulk() and changes it so that it no longer grabs
> zone->lock instead requiring caller to hold it.  This commit later
> adds a __zone_drain_all_pages() function which works just like
> drain_all_pages() expects that it drains only pages from a single zone=

> and assumes that caller holds zone->lock.

As it turns out, with some more testing on SMP systems, this whole patch=

turned out to be incorrect.

We have been thinking about other approach and, if we were to use someth=
ing
else then the first patch from CMAv17[1], the best thing we could came u=
p
with was to unconditionally call drain_all_pages() at the beginning of
set_migratetype_isolate() before the call to spin_lock_irqsave().  It ha=
s
a possible race condition but a nightly stress test did have not shown a=
ny
problems.

Nonetheless, the cleanest, in my opinion, solution is to use the first p=
atch
 from CMAv17 which can be found at [1].

So, to sum up: if you intend to test CMAv18, instead of applying this fi=
rst
patch either use first patch from CMAv17[1] or put an unconditional call=
 to
drain_all_pages() at the beginning of set_migrate_isolate() function.

Sorry for the troubles.

[1] http://www.spinics.net/lists/arm-kernel/msg148494.html

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
