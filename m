Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id DE41D6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:36:27 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so85494225qkb.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:36:27 -0700 (PDT)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id b141si20066630qka.14.2015.10.23.11.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 11:36:27 -0700 (PDT)
Received: by qkfm62 with SMTP id m62so85359445qkf.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:36:27 -0700 (PDT)
Message-ID: <562a7e2a.4dc3370a.a30e5.ffff8e63@mx.google.com>
Date: Fri, 23 Oct 2015 11:36:26 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V7] mm: memory hot-add: memory can not be added to
 movable zone defaultly
In-Reply-To: <5627586C.6000502@cn.fujitsu.com>
References: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com>
	<561E8056.7050609@suse.cz>
	<5626F667.9000003@inspur.com>
	<56275423.6050506@suse.cz>
	<5627586C.6000502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>


On Wed, 21 Oct 2015 17:18:36 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> 
> On 10/21/2015 05:00 PM, Vlastimil Babka wrote:
> > On 10/21/2015 04:20 AM, Changsheng Liu wrote:
> >>
> >>
> >> a?? 2015/10/15 0:18, Vlastimil Babka a??e??:
> >>> On 10/12/2015 08:58 AM, Changsheng Liu wrote:
> >>>> From: Changsheng Liu <liuchangcheng@inspur.com>
> >>>>
> >>>> After the user config CONFIG_MOVABLE_NODE,
> >>>> When the memory is hot added, should_add_memory_movable() return 0
> >>>> because all zones including ZONE_MOVABLE are empty,
> >>>> so the memory that was hot added will be assigned to ZONE_NORMAL
> >>>> and ZONE_NORMAL will be created firstly.
> >>>> But we want the whole node to be added to ZONE_MOVABLE by default.
> >>>>
> >>>> So we change should_add_memory_movable(): if the user config
> >>>> CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable is 1
> >>>> and the ZONE_NORMAL is empty or the pfn of the hot-added memory
> >>>> is after the end of the ZONE_NORMAL it will always return 1
> >>>> and then the whole node will be added to ZONE_MOVABLE by default.
> >>>> If we want the node to be assigned to ZONE_NORMAL,
> >>>> we can do it as follows:
> >>>> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
> >>>>
> >>>> By the patch, the behavious of kernel is changed by sysctl,
> >>>> user can automatically create movable memory
> >>>> by only the following udev rule:
> >>>> SUBSYSTEM=="memory", ACTION=="add",
> >>>> ATTR{state}=="offline", ATTR{state}="online"
> >>       I'm sorry for replying you so late due to the busy business trip.
> >>> So just to be clear, we are adding a new sysctl, because the existing
> >>> movable_node kernel option, which is checked by 
> >>> movable_node_is_enabled(), and
> >>> does the same thing for non-hot-added-memory (?) cannot be reused 
> >>> for hot-added
> >>> memory, as that would be a potentially surprising behavior change? 
> >>> Correct? Then
> >>> this should be mentioned in the changelog too, and wherever 
> >>> "movable_node" is
> >>> documented should also mention the new sysctl. Personally, I would 
> >>> expect
> >>> movable_node to affect hot-added memory as well, and would be 
> >>> surprised that it
> >>> doesn't...
> >>       I think it can let the user decides when to use this feature.
> >>       The user can enable the feature when making the hot_added memory
> >> of a node movable and
> >>       make the feature disable to assign the hot_added memory of the 
> >> next
> >> node to ZONE_NORMAL .
> >
> > So you mean sysctl is more flexible than boot option. OK, but wasn't 
> > such flexibility already provided by "echo online_kernel" vs "echo 
> > online_movable"? It doesn't sound like a strong reason for a new 
> > sysctl? Not doing surprising behavior change maybe does...
> > .
> >
> Hi Vlastimil,
> 
> The current kernel will add hot-added memory to ZONE_NORMAL by default. 
> If users use a udev rule as below:
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
> 
> it will online the memory as normal memory, which will not be hotpluggable.
> 
> Please refer to: https://lkml.org/lkml/2015/10/9/58
> 
> I think this is the root motivation of the patch.
> 

> But BTW, I'm quite familiar with udev rules, but can something like this 
> work ?
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online_movable"
> 
> I'm not sure. I added Ishimatu in.

I think the udev rules fails to online memory as movable.

When hot adding memory, the memory is managed as ZONE_NORMAL.
And add events of memory section are notified to udev in ascending
order, like 0->1->2->3. Thus udev starts to online memory from section 0.
But to change zone from ZONE_NORMAL to ZONE_MOVALBE, udev onlines memory
in descending order, like 3->2->1->0. So the udev rules cannot online
memory as movable.

Thanks,
Yasuaki Ishimatsu

> 
> For now, I think, if the above rule works, we don't need this patch. If 
> not, maybe we should just change the kernel behavior to make the 
> hot-added memory be added to ZONE_MOVABLE by default.
> 
> I don't have objection. But a sysctl doesn't sound necessary.



> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
