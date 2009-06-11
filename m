Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 587C36B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 07:19:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BBJmBM001808
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 20:19:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 922C345DD7B
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:19:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3550445DD76
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:19:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2745A1DB8013
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:19:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48E3A1DB8018
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:19:46 +0900 (JST)
Message-ID: <9d4a7c0691aa5e13247f694f2dfe55ad.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360906110237u1f3d1877hae54a51575955549@mail.gmail.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
    <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
    <20090611172249.6D3C.A69D9226@jp.fujitsu.com>
    <20090611173819.0f76e431.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360906110237u1f3d1877hae54a51575955549@mail.gmail.com>
Date: Thu, 11 Jun 2009 20:19:45 +0900 (JST)
Subject: Re: [PATCH 2/3] check unevictable flag in lumy reclaim v2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Minchan Kim さん wrote:
> On Thu, Jun 11, 2009 at 5:38 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> How about this ?
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Lumpy reclaim check pages from their pfn. Then, it can find unevictable
>> pages
>> in its loop.
>> Abort lumpy reclaim when we find Unevictable page, we never get a lump
>> of pages for requested order.
>>
>> Changelog: v1->v2
>> ?- rewrote commet.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> ?mm/vmscan.c | ? ?9 +++++++++
>> ?1 file changed, 9 insertions(+)
>>
>> Index: lumpy-reclaim-trial/mm/vmscan.c
>> ===================================================================
>> --- lumpy-reclaim-trial.orig/mm/vmscan.c
>> +++ lumpy-reclaim-trial/mm/vmscan.c
>> @@ -936,6 +936,15 @@ static unsigned long isolate_lru_pages(u
>> ? ? ? ? ? ? ? ? ? ? ? ?/* Check that we have not crossed a zone
>> boundary. */
>> ? ? ? ? ? ? ? ? ? ? ? ?if (unlikely(page_zone_id(cursor_page) !=
>> zone_id))
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?continue;
>> + ? ? ? ? ? ? ? ? ? ? ? /*
>> + ? ? ? ? ? ? ? ? ? ? ? ?* We tries to free all pages in this range to
>> create
>> + ? ? ? ? ? ? ? ? ? ? ? ?* a free large page. Then, if the range
>> includes a page
>> + ? ? ? ? ? ? ? ? ? ? ? ?* never be reclaimed, we have no reason to do
>> more.
>> + ? ? ? ? ? ? ? ? ? ? ? ?* PageUnevictable page is not a page which can
>> be
>> + ? ? ? ? ? ? ? ? ? ? ? ?* easily freed. Abort this scan now.
>> + ? ? ? ? ? ? ? ? ? ? ? ?*/
>> + ? ? ? ? ? ? ? ? ? ? ? if (unlikely(PageUnevictable(cursor_page)))
>> + ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? break;
>
> __isolate_lru_pages already checked PageUnevictable to return error.
> I want to remove repeated check although it is trivial.
>
> By your patch, It seems to remove PageUnevictable check in
> __isolate_lru_pages.
>
yes.

> But I know that. If we remove PageUnevictable check in
> __isolate_lru_pages, it can't go into BUG in non-lumpy case. ( I
> mentioned following as code)
>
In non-lumpy case, we'll never see Unevictable, maybe.

>                 case -EBUSY:
>                         /* else it is being freed elsewhere */
>                         list_move(&page->lru, src);
>                         continue;
>
>                 default:
>                         BUG();
>                 }
>
>
> It means we can remove BUG in non-lumpy case and then add BUG into
> __isolate_lru_pages directly.
>
> If we can do it, we can remove unnecessary PageUnevictable check in
> __isolate_lru_page.
>
Hmm, but Unevicable check had tons of troubles at its implementation
and I don't want to do it at once.

> I am not sure this is right in case of memcg.
>
I think we don't see Unevictable in memcg's path if my memcg-lru code
works as designed.

I'll postpone this patch for a while until my brain works well.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
