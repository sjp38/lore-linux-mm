Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB7CYs5N026234
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 7 Dec 2008 21:34:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5462745DE52
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 21:34:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F02B45DE51
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 21:34:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 002921DB8042
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 21:34:54 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 919F61DB803C
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 21:34:53 +0900 (JST)
Message-ID: <17283.10.75.179.62.1228653292.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081207003138.2651f14b.akpm@linux-foundation.org>
References: <49389B69.9010902@cn.fujitsu.com><20081205122024.3fcc1d0e.kamezawa.hiroyu@jp.fujitsu.com><20081205122458.a37ae8e0.kamezawa.hiroyu@jp.fujitsu.com>
    <20081207003138.2651f14b.akpm@linux-foundation.org>
Date: Sun, 7 Dec 2008 21:34:52 +0900 (JST)
Subject: Re: [memcg BUG ?] failed to boot on IA64 with CONFIG_DISCONTIGMEM=y
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton said:
> On Fri, 5 Dec 2008 12:24:58 +0900 KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Fri, 5 Dec 2008 12:20:24 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > On Fri, 05 Dec 2008 11:09:29 +0800
>> > Li Zefan <lizf@cn.fujitsu.com> wrote:
>> >
>> > > Kernel version: 2.6.28-rc7
>> > > Arch: IA64
>> > > Memory model: DISCONTIGMEM
>> > >
>> > > ELILO boot: Uncompressing Linux... done
>> > > Loading file initrd-2.6.28-rc7-lizf.img...done
>> > > (frozen)
>> > >
>> > >
>> > > Booted successfully with cgroup_disable=memory, here is the dmesg:
>> > >
>> >
>> > thx, will dig into...Maybe you're the first person using DISCONTIGMEM
>> with
>> > empty_node after page_cgroup-alloc-at-boot.
>> >
>> > How about this ?
>>
>> Ahhh..sorry.
>>
>> this one please.
>> ==
>>
>> From: kamezawa.hiroyu@jp.fujitsu.com
>>
>> page_cgroup should ignore empty-nodes.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> ---
>>  mm/page_cgroup.c |    3 +++
>>  1 file changed, 3 insertions(+)
>>
>> Index: mmotm-2.6.28-Dec03/mm/page_cgroup.c
>> ===================================================================
>> --- mmotm-2.6.28-Dec03.orig/mm/page_cgroup.c
>> +++ mmotm-2.6.28-Dec03/mm/page_cgroup.c
>> @@ -51,6 +51,9 @@ static int __init alloc_node_page_cgroup
>>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
>>  	nr_pages = NODE_DATA(nid)->node_spanned_pages;
>>
>> +	if (!nr_pages)
>> +		return 0;
>> +
>>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>>
>>  	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
>
> Why did the kernel fail?
>
> Either __alloc_bootmem_node_nopanic() succeeds, in which case the code
> looks like it handles that OK.
>
> Or __alloc_bootmem_node_nopanic() fails this zero-sized allocation, and
> the code attempts to handle that, but fails to do so, which might be a
> bug, and the above patch just papers over it.
>
After this, print a message like "memcg cannot allocate memory, please try
cgroup_disable=memory as boot option", and panic.
This is a boot time failure which can be avoided by boot option.

> Of course, a full description of the problem will clear all this up.
> Better changelogs, please.
>

will do.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
