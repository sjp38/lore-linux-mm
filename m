Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E84936B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:46:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n59BKUdY012272
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 20:20:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF32145DD7D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:20:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B9FC45DD78
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:20:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8282A1DB803C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:20:30 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30BD71DB8037
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:20:30 +0900 (JST)
Message-ID: <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
Date: Tue, 9 Jun 2009 20:20:29 +0900 (JST)
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>


Minchan Kim wrote:
> On Tue, Jun 9, 2009 at 6:15 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't
>> know
>> from which LRU "cursor" page came from. Then, putback it to "src" list
>> is BUG.
>> Just leave it as it is.
>> (And I think rotate here is overkilling even if "src" is correct.)
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> mm/vmscan.c | 5 ++---
>> 1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> Index: mmotm-2.6.30-Jun4/mm/vmscan.c
>> ===================================================================
>> --- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
>> +++ mmotm-2.6.30-Jun4/mm/vmscan.c
>> @@ -940,10 +940,9 @@ static unsigned long isolate_lru_pages(u
>> nr_taken++;
>> scan++;
>> break;
>> -
>>case -EBUSY:
>
> We can remove case -EBUSY itself, too.
> It is meaningless.
>
Sure, will post v2 and remove EBUSY case.
(I'm sorry my webmail system converts a space to a multibyte char...
 then I cut some.)

>> - /* else it is being freed
>> elsewhere */
>> -
>> list_move(&cursor_page->lru, src);
>> +  /* Do nothing because we
>> don't know where
>> + cusrsor_page comes
>> from */
>>default:
>> break; /* ! on LRU or
>> wrong list */
>
> Hmm.. what meaning of this break ?
> We are in switch case.
> This "break" can't go out of loop.
yes.

> But comment said "abort this block scan".
>
Where ? the comment says the cursor_page is not on lru (PG_lru is unset)
> If I understand it properly , don't we add goto phrase ?
>
No.

Just try next page on list.

Thank you for review, I'll post updated one tomorrow.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
