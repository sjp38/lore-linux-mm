Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 968BE82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:00:28 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so64074338wic.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:00:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc8si10164533wjc.13.2015.10.21.02.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 02:00:27 -0700 (PDT)
Subject: Re: [PATCH V7] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com>
 <561E8056.7050609@suse.cz> <5626F667.9000003@inspur.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56275423.6050506@suse.cz>
Date: Wed, 21 Oct 2015 11:00:19 +0200
MIME-Version: 1.0
In-Reply-To: <5626F667.9000003@inspur.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, tangchen@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 10/21/2015 04:20 AM, Changsheng Liu wrote:
>
>
> a?? 2015/10/15 0:18, Vlastimil Babka a??e??:
>> On 10/12/2015 08:58 AM, Changsheng Liu wrote:
>>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>>
>>> After the user config CONFIG_MOVABLE_NODE,
>>> When the memory is hot added, should_add_memory_movable() return 0
>>> because all zones including ZONE_MOVABLE are empty,
>>> so the memory that was hot added will be assigned to ZONE_NORMAL
>>> and ZONE_NORMAL will be created firstly.
>>> But we want the whole node to be added to ZONE_MOVABLE by default.
>>>
>>> So we change should_add_memory_movable(): if the user config
>>> CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable is 1
>>> and the ZONE_NORMAL is empty or the pfn of the hot-added memory
>>> is after the end of the ZONE_NORMAL it will always return 1
>>> and then the whole node will be added to ZONE_MOVABLE by default.
>>> If we want the node to be assigned to ZONE_NORMAL,
>>> we can do it as follows:
>>> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>>>
>>> By the patch, the behavious of kernel is changed by sysctl,
>>> user can automatically create movable memory
>>> by only the following udev rule:
>>> SUBSYSTEM=="memory", ACTION=="add",
>>> ATTR{state}=="offline", ATTR{state}="online"
>       I'm sorry for replying you so late due to the busy business trip.
>> So just to be clear, we are adding a new sysctl, because the existing
>> movable_node kernel option, which is checked by movable_node_is_enabled(), and
>> does the same thing for non-hot-added-memory (?) cannot be reused for hot-added
>> memory, as that would be a potentially surprising behavior change? Correct? Then
>> this should be mentioned in the changelog too, and wherever "movable_node" is
>> documented should also mention the new sysctl. Personally, I would expect
>> movable_node to affect hot-added memory as well, and would be surprised that it
>> doesn't...
>       I think it can let the user decides when to use this feature.
>       The user can enable the feature when making the hot_added memory
> of a node movable and
>       make the feature disable to assign the hot_added memory of the next
> node to ZONE_NORMAL .

So you mean sysctl is more flexible than boot option. OK, but wasn't 
such flexibility already provided by "echo online_kernel" vs "echo 
online_movable"? It doesn't sound like a strong reason for a new sysctl? 
Not doing surprising behavior change maybe does...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
