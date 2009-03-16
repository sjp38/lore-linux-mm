Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E96846B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:58:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2GBwW1F003198
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 20:58:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AA8645DE52
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:58:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C1E5445DE50
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:58:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3BD1DB8042
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:58:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69F981DB8038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:58:31 +0900 (JST)
Message-ID: <969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090316113853.GA16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
    <20090314173111.16591.68465.sendpatchset@localhost.localdomain>
    <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316083512.GV16897@balbir.in.ibm.com>
    <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316091024.GX16897@balbir.in.ibm.com>
    <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
    <20090316113853.GA16897@balbir.in.ibm.com>
Date: Mon, 16 Mar 2009 20:58:30 +0900 (JST)
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16
> 20:10:41]:
>> >> At least, this check will be necessary in v7, I think.
>> >> shrink_slab() should be called.
>> >
>> > Why do you think so? So here is the design
>> >
>> > 1. If a cgroup was using over its soft limit, we believe that this
>> >    cgroup created overall memory contention and caused the page
>> >    reclaimer to get activated.
>> This assumption is wrong, see below.
>>
>> >    If we can solve the situation by
>> >    reclaiming from this cgroup, why do we need to invoke shrink_slab?
>> >
>> No,
>> IIUC, in big server, inode, dentry cache etc....can occupy Gigabytes
>> of memory even if 99% of them are not used.
>>
>> By shrink_slab(), we can reclaim unused but cached slabs and make
>> the kernel more healthy.
>>
>
> But that is not the job of the soft limit reclaimer.. Yes if no groups
> are over their soft limit, the regular action will take place.
>
Oh, yes, it's not job of memcg but it's job of memory management.


>>
>> > If the concern is that we are not following the traditional reclaim,
>> > soft limit reclaim can be followed by unconditional reclaim, but I
>> > believe this is not necessary. Remember, we wake up kswapd that will
>> > call shrink_slab if needed.
>> kswapd doesn't call shrink_slab() when zone->free is enough.
>> (when direct recail did good jobs.)
>>
>
> If zone->free is high why do we need shrink_slab()? The other way
> of asking it is, why does the soft limit reclaimer need to call
> shrink_slab(), when its job is to reclaim memory from cgroups above
> their soft limits.
>
Why do you consider that softlimit is called more than necessary
if shrink_slab() is never called ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
