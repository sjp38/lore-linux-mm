Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9LAwf8N005640
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 21:58:41 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LAwNbF4374626
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 21:58:23 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9LAwMXS022840
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 21:58:22 +1100
Message-ID: <48FDB5BE.4000308@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 16:28:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp> <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp> <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com> <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com> <48FD6901.6050301@linux.vnet.ibm.com> <20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com> <48FD74AB.9010307@cn.fujitsu.com> <20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com> <48FD7EEF.3070803@cn.fujitsu.com> <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com> <48FD82E3.9050502@cn.fujitsu.com> <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com> <48FD943D.5090709@cn.fujitsu.com> <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com> <48FD9D30.2030500@cn.fujitsu.com> <20081021182551.0158a47b.kamezawa.hiroyu@jp.fujitsu.com> <48FDA6D4.3090809@cn.fujitsu.com> <20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 17:54:28 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 21 Oct 2008 17:13:20 +0800
>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>
>>>> KAMEZAWA Hiroyuki wrote:
>>>>> On Tue, 21 Oct 2008 16:35:09 +0800
>>>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>>>
>>>>>> KAMEZAWA Hiroyuki wrote:
>>>>>>> On Tue, 21 Oct 2008 15:21:07 +0800
>>>>>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>>>>>> dmesg is attached.
>>>>>>>>
>>>>>>> Thanks....I think I caught some. (added Mel Gorman to CC:)
>>>>>>>
>>>>>>> NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
>>>>>>>
>>>>>>> So, If there is a hole between zone, node->spanned_pages doesn't mean
>>>>>>> length of node's memmap....(then, some hole can be skipped.)
>>>>>>>
>>>>>>> OMG....Could you try this ? 
>>>>>>>
>>>>>> No luck, the same bug still exists. :(
>>>>>>
>>>>> This is a little fixed one..
>>>>>
>>>> I tried the patch, but it doesn't solve the problem..
>>>>
>>> Hmm.. Can you catch "pfn" of troublesome page_cgroup ?
>>> By patch like this ?
>>>
>> I got what you want:
>>
>> pc c1d589dc pc->page 00000000 page c105f67c pfn 1d5b
>> ...
>> pc c1d589f0 pc->page 00000000 page c105f6b0 pfn 1d5c
>>
> Oh! thanks...but it seems pc->page is NULL in the middle of ZONE_NORMAL..
> ==
>  Normal   0x00001000 -> 0x000373fe
> ==
> This is appearently in the range of page_cgroup initialization.
> (if pgdat->node_page_cgroup is initalized correctly.. == .)
> 
> I think write to page_cgroup->page happens only at initialization.
> Hmm ? not initilization failure but curruption ?
> 


0x3bff0 = 245744
Looking at dmesg, we used 4914560 for page_cgroup, page_cgroup is 20 bytes, so
the number of page_cgroups we have = 245728. The difference is 16

That would make sense, if we look at

early_node_map[2] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x0003bff0

Node 0 starts from pfn 0x10 == 16.

OK, so we were able to allocate the page_cgroup, so either

1) Like Kamezawa suggested, there was corruption (very unlikely)
2) pfn_to_page() returned NULL
3) We did not initialize a certain set of page_cgroups

> What happens if replacing __alloc_bootmem() with vmalloc() in page_cgroup.c init ?


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
