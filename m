Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6906C6B005C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 07:13:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BBDmVb031679
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 20:13:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B75045DD7E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:13:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 359A845DD80
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:13:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DEF9E08005
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:13:48 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 795681DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:13:47 +0900 (JST)
Message-ID: <4c72e5b8de091845036fe2b5227168f5.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360906110218t6a3ed908g9a4fba7fa7dd7b22@mail.gmail.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
    <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360906110218t6a3ed908g9a4fba7fa7dd7b22@mail.gmail.com>
Date: Thu, 11 Jun 2009 20:13:46 +0900 (JST)
Subject: Re: [PATCH 1/3] remove wrong rotation at lumpy reclaim
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> On Thu, Jun 11, 2009 at 5:00 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> At lumpy reclaim, a page failed to be taken by __isolate_lru_page() can
>> be pushed back to "src" list by list_move(). But the page may not be
>> from
>> "src" list. And list_move() itself is unnecessary because the page is
>> not on top of LRU. Then, leave it as it is if __isolate_lru_page()
>> fails.
>>
>> This patch doesn't change the logic as "we should exit loop or not" and
>> just fixes buggy list_move().
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> ?mm/vmscan.c | ? ?9 +--------
>> ?1 file changed, 1 insertion(+), 8 deletions(-)
>>
>> Index: lumpy-reclaim-trial/mm/vmscan.c
>> ===================================================================
>> --- lumpy-reclaim-trial.orig/mm/vmscan.c
>> +++ lumpy-reclaim-trial/mm/vmscan.c
>> @@ -936,18 +936,11 @@ static unsigned long isolate_lru_pages(u
>> ? ? ? ? ? ? ? ? ? ? ? ?/* Check that we have not crossed a zone
>> boundary. */
>> ? ? ? ? ? ? ? ? ? ? ? ?if (unlikely(page_zone_id(cursor_page) !=
>> zone_id))
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?continue;
>> - ? ? ? ? ? ? ? ? ? ? ? switch (__isolate_lru_page(cursor_page, mode,
>> file)) {
>> - ? ? ? ? ? ? ? ? ? ? ? case 0:
>> + ? ? ? ? ? ? ? ? ? ? ? if (__isolate_lru_page(cursor_page, mode, file)
>> == 0) {
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?list_move(&cursor_page->lru, dst);
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?nr_taken++;
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?scan++;
>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?break;
>
> break ??
>
good catch. I'll post updated one tomorrow.
I'm very sorry ;(

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
