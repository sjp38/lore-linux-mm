Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC1B36B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:10:45 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2GBAgcl017194
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 20:10:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9224E45DE51
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:10:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68AC845DE4F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:10:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 501331DB803C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:10:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ED8D61DB803A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:10:41 +0900 (JST)
Message-ID: <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090316091024.GX16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
    <20090314173111.16591.68465.sendpatchset@localhost.localdomain>
    <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316083512.GV16897@balbir.in.ibm.com>
    <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
    <20090316091024.GX16897@balbir.in.ibm.com>
Date: Mon, 16 Mar 2009 20:10:41 +0900 (JST)
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
> 18:03:08]:
>
>> On Mon, 16 Mar 2009 17:49:43 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > On Mon, 16 Mar 2009 14:05:12 +0530
>> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> > For example, shrink_slab() is not called. and this must be called.
>> >
>> > For exmaple, we may have to add
>> >  sc->call_shrink_slab
>> > flag and set it "true" at soft limit reclaim.
>> >
>> At least, this check will be necessary in v7, I think.
>> shrink_slab() should be called.
>
> Why do you think so? So here is the design
>
> 1. If a cgroup was using over its soft limit, we believe that this
>    cgroup created overall memory contention and caused the page
>    reclaimer to get activated.
This assumption is wrong, see below.

>    If we can solve the situation by
>    reclaiming from this cgroup, why do we need to invoke shrink_slab?
>
No,
IIUC, in big server, inode, dentry cache etc....can occupy Gigabytes
of memory even if 99% of them are not used.

By shrink_slab(), we can reclaim unused but cached slabs and make
the kernel more healthy.


> If the concern is that we are not following the traditional reclaim,
> soft limit reclaim can be followed by unconditional reclaim, but I
> believe this is not necessary. Remember, we wake up kswapd that will
> call shrink_slab if needed.
kswapd doesn't call shrink_slab() when zone->free is enough.
(when direct recail did good jobs.)

Anyway, we'll have to add softlimit hook to kswapd.
I think you read Kosaki's e-mail to you.
==
in global reclaim view, foreground reclaim and background reclaim's
  reclaim rate is about 1:9 typically.
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
