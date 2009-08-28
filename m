Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 64DE26B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 11:21:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7SFLpCw006916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 29 Aug 2009 00:21:52 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7BC045DE6F
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:21:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EC4E45DE4D
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:21:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D23D1DB803E
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:21:51 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E82C51DB8037
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:21:50 +0900 (JST)
Message-ID: <b9c52b465bda540da8dbcd434bff55be.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090828151011.GS4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828151011.GS4889@balbir.in.ibm.com>
Date: Sat, 29 Aug 2009 00:21:50 +0900 (JST)
Subject: Re: [RFC][PATCH 2/5] memcg: uncharge in batched manner
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh さんは書きました：
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> 13:24:38]:
>
>>
>> In massive parallel enviroment, res_counter can be a performance
>> bottleneck.
>> This patch is a trial for reducing lock contention.
>> One strong techinque to reduce lock contention is reducing calls by
>> batching some amount of calls int one.
>>
>> Considering charge/uncharge chatacteristic,
>> 	- charge is done one by one via demand-paging.
>> 	- uncharge is done by
>> 		- in chunk at munmap, truncate, exit, execve...
>> 		- one by one via vmscan/paging.
>>
>> It seems we hace a chance to batched-uncharge.
>> This patch is a base patch for batched uncharge. For avoiding
>> scattering memcg's structure, this patch adds memcg batch uncharge
>> information to the task. please see start/end usage in next patch.
>>
>
> Overall it is a very good idea, can't we do the uncharge at the poin
> tof unmap_vmas, exit_mmap, etc so that we don't have to keep
> additional data structures around.
>
We can't. We uncharge when page->mapcount goes down to 0.
This is unknown until page_remove_rmap() decrement page->mapcount
by "atomic" ops.

My first version allocated memcg_batch_info on stack ...and..
I had to pass an extra argument to page_remove_rmap() etc....
That was very ugly ;(
Now, I adds per-task memcg_batch_info to task struct.
Because it will be always used at exit() and make exit() path
much faster, it's not very costly.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
