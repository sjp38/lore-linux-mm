Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAJCidot021481
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 19 Nov 2008 21:44:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F04B545DD77
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 21:44:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE19A45DD71
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 21:44:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF34B1DB803F
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 21:44:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F6431DB8040
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 21:44:38 +0900 (JST)
Message-ID: <59529.10.75.179.61.1227098677.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0811181653290.3506@blonde.site>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp><20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com><20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp><20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp><Pine.LNX.4.64.0811181234430.9680@blonde.site><20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp><6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com><Pine.LNX.4.64.0811181629070.417@blonde.site>
    <Pine.LNX.4.64.0811181653290.3506@blonde.site>
Date: Wed, 19 Nov 2008 21:44:37 +0900 (JST)
Subject: Re: [PATCH mmotm] memcg: avoid using buggy kmap at swap_cgroup
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LiZefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins said:
> On Tue, 18 Nov 2008, Hugh Dickins wrote:
>> On Wed, 19 Nov 2008, KAMEZAWA Hiroyuki wrote:
>>
>> >  2. later, add kmap_atomic + HighMem buffer support in explicit style.
>> >     maybe KM_BOUNCE_READ...can be used.....
>>
>> It's hardly appropriate (there's no bouncing here), and you could only
>> use it if you disable interrupts.  Oh, you do disable interrupts:
>> why's that?
>
> In fact, why do you even need the spinlock?  I can see that you would
> need it if in future you reduce the size of the elements of the array
> from pointers; but at present, aren't you already in trouble if there's
> a race on the pointer?
>
Hmm, I originally added it just for doing exchange-entry.
Now, lookup and exchange operation is implemented for swap_cgroup.

This field is touched when
  - try to map swap cache (try_charge_swapin) -> lookup
  - after swapcache is mapped -> exchange
  - swap cache is read by shmem -> lookup/exchange
  - swap cache is dropped -> exchange
  - swap entry is freed. -> exchange
  ...
Hmm.....
  When accessed via SwapCache -> SwapCache is locked -> no race..
  When accessed vid swap_free -> no user of swap -> no race....

Then, maybe lock is not needed...I'll review and prepare rework patch
for patch-in-mmotn+fix1234.

Thank you for pointing out.
-Kame





> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
