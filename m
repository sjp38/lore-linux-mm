Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 685046B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:12:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n59BlkbY007113
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 20:47:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8558D45DD75
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:47:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 667A445DD74
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:47:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56F64E0800A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:47:46 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09B2DE08002
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:47:46 +0900 (JST)
Message-ID: <7ca0521d9b798ef8b56212e5b17ea713.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
    <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
    <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com>
Date: Tue, 9 Jun 2009 20:47:45 +0900 (JST)
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

> I mean follow as
>  908         /*
>  909          * Attempt to take all pages in the order aligned region
>  910          * surrounding the tag page.  Only take those pages of
>  911          * the same active state as that tag page.  We may safely
>  912          * round the target page pfn down to the requested order
>  913          * as the mem_map is guarenteed valid out to MAX_ORDER,
>  914          * where that page is in a different zone we will detect
>  915          * it from its zone id and abort this block scan.
>  916          */
>  917         zone_id = page_zone_id(page);
>
But what this code really do is.
==
931                         /* Check that we have not crossed a zone
boundary. */
 932                         if (unlikely(page_zone_id(cursor_page) !=
zone_id))
 933                                 continue;
==
continue. I think this should be "break"
I wonder what "This block scan" means is "scanning this aligned block".

But I think the whoe code is not written as commented.

>
>>> If I understand it properly , don't we add goto phrase ?
>>>
>> No.
>
> If it is so, the break also is meaningless.
>
yes. I'll remove it. But need to add "exit from for loop" logic again.

I'm sorry that the wrong logic of this loop was out of my sight.
I'll review and rewrite this part all, tomorrow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
