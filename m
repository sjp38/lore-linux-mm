Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A9CF86B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 08:31:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5MCWUwg004976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Jun 2009 21:32:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E3B845DE4F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 21:32:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7461C45DD72
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 21:32:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D445E08009
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 21:32:30 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ED2ADE08001
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 21:32:26 +0900 (JST)
Message-ID: <f9931fe09c239cd30222bf8532e62b65.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090622122615.GA28503@elte.hu>
References: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com>
    <20090622105231.GA17242@elte.hu>
    <18e69edd004ec13730246bd40600448c.squirrel@webmail-b.css.fujitsu.com>
    <ec48fff1916d3e82c3c4fc610245f0b6.squirrel@webmail-b.css.fujitsu.com>
    <20090622122615.GA28503@elte.hu>
Date: Mon, 22 Jun 2009 21:32:26 +0900 (JST)
Subject: Re: [RFC][PATCH] cgroup: fix permanent wait in rmdir
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
>> Ah, while I test 2.6.30-git18 (includes above patch), I don't see
>> above stack dump (with LIST_DEBUG=y) under quick memory pressure
>> test...
>
> Note, it still occurs even with latest -git (f234012).
>
Could you try this ? (Sorry, I can't send a patch right now)
== vmscan.c
865 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
866                 struct list_head *src, struct list_head *dst,
867                 unsigned long *scanned, int order, int mode, int file)
868 {
869         unsigned long nr_taken = 0;
870         unsigned long scan;
871
<snip>
 930                         /* Check that we have not crossed a zone
boundary. */
931                         if (unlikely(page_zone_id(cursor_page) !=
zone_id))
932                                 continue;
933                         if (__isolate_lru_page(cursor_page, mode,
file) == 0) {
934                                 list_move(&cursor_page->lru, dst);
935                                 mem_cgroup_del_lru(page);
936                                 nr_taken++;
937                                 scan++;
938                         }


change line 935
from
  mem_cgroup_del_lru(page);
to
  mem_cgroup_del_lru(cursor_page);


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
