Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6D58A6B0256
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:21:30 -0400 (EDT)
Received: by iofz202 with SMTP id z202so50667940iof.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:21:30 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id y101si6523618ioi.210.2015.10.21.02.21.27
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 02:21:29 -0700 (PDT)
Message-ID: <5627586C.6000502@cn.fujitsu.com>
Date: Wed, 21 Oct 2015 17:18:36 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com> <561E8056.7050609@suse.cz> <5626F667.9000003@inspur.com> <56275423.6050506@suse.cz>
In-Reply-To: <56275423.6050506@suse.cz>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>


On 10/21/2015 05:00 PM, Vlastimil Babka wrote:
> On 10/21/2015 04:20 AM, Changsheng Liu wrote:
>>
>>
>> =E5=9C=A8 2015/10/15 0:18, Vlastimil Babka =E5=86=99=E9=81=93:
>>> On 10/12/2015 08:58 AM, Changsheng Liu wrote:
>>>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>>>
>>>> After the user config CONFIG_MOVABLE_NODE,
>>>> When the memory is hot added, should_add_memory_movable() return 0
>>>> because all zones including ZONE_MOVABLE are empty,
>>>> so the memory that was hot added will be assigned to ZONE_NORMAL
>>>> and ZONE_NORMAL will be created firstly.
>>>> But we want the whole node to be added to ZONE_MOVABLE by default.
>>>>
>>>> So we change should_add_memory_movable(): if the user config
>>>> CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable is 1
>>>> and the ZONE_NORMAL is empty or the pfn of the hot-added memory
>>>> is after the end of the ZONE_NORMAL it will always return 1
>>>> and then the whole node will be added to ZONE_MOVABLE by default.
>>>> If we want the node to be assigned to ZONE_NORMAL,
>>>> we can do it as follows:
>>>> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>>>>
>>>> By the patch, the behavious of kernel is changed by sysctl,
>>>> user can automatically create movable memory
>>>> by only the following udev rule:
>>>> SUBSYSTEM=3D=3D"memory", ACTION=3D=3D"add",
>>>> ATTR{state}=3D=3D"offline", ATTR{state}=3D"online"
>>       I'm sorry for replying you so late due to the busy business trip.
>>> So just to be clear, we are adding a new sysctl, because the existing
>>> movable_node kernel option, which is checked by=20
>>> movable_node_is_enabled(), and
>>> does the same thing for non-hot-added-memory (?) cannot be reused=20
>>> for hot-added
>>> memory, as that would be a potentially surprising behavior change?=20
>>> Correct? Then
>>> this should be mentioned in the changelog too, and wherever=20
>>> "movable_node" is
>>> documented should also mention the new sysctl. Personally, I would=20
>>> expect
>>> movable_node to affect hot-added memory as well, and would be=20
>>> surprised that it
>>> doesn't...
>>       I think it can let the user decides when to use this feature.
>>       The user can enable the feature when making the hot_added memory
>> of a node movable and
>>       make the feature disable to assign the hot_added memory of the=20
>> next
>> node to ZONE_NORMAL .
>
> So you mean sysctl is more flexible than boot option. OK, but wasn't=20
> such flexibility already provided by "echo online_kernel" vs "echo=20
> online_movable"? It doesn't sound like a strong reason for a new=20
> sysctl? Not doing surprising behavior change maybe does...
> .
>
Hi Vlastimil,

The current kernel will add hot-added memory to ZONE_NORMAL by default.=20
If users use a udev rule as below:

SUBSYSTEM=3D=3D"memory", ACTION=3D=3D"add", ATTR{state}=3D=3D"offline", ATT=
R{state}=3D"online"

it will online the memory as normal memory, which will not be hotpluggable.

Please refer to: https://lkml.org/lkml/2015/10/9/58

I think this is the root motivation of the patch.

But BTW, I'm quite familiar with udev rules, but can something like this=20
work ?

SUBSYSTEM=3D=3D"memory", ACTION=3D=3D"add", ATTR{state}=3D=3D"offline", ATT=
R{state}=3D"online_movable"

I'm not sure. I added Ishimatu in.

For now, I think, if the above rule works, we don't need this patch. If=20
not, maybe we should just change the kernel behavior to make the=20
hot-added memory be added to ZONE_MOVABLE by default.

I don't have objection. But a sysctl doesn't sound necessary.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
