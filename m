Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1117B6B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:36:06 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so94880561iec.0
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:36:05 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id e4si6966625igc.10.2015.04.19.20.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Apr 2015 20:36:05 -0700 (PDT)
Message-ID: <553473CD.9020600@huawei.com>
Date: Mon, 20 Apr 2015 11:34:37 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com> <5531679d.4642ec0a.1beb.3569@mx.google.com> <55345756.40902@huawei.com> <5534603a.36208c0a.4784.6286@mx.google.com> <55345FC4.4070404@cn.fujitsu.com> <55346B99.2060602@huawei.com> <55346f49.8bc6ec0a.5fe5.ffffcdac@mx.google.com>
In-Reply-To: <55346f49.8bc6ec0a.5fe5.ffffcdac@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/4/20 11:15, Yasuaki Ishimatsu wrote:

> 
> On Mon, 20 Apr 2015 10:59:37 +0800
> Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> On 2015/4/20 10:09, Gu Zheng wrote:
>>
>>> Hi Ishimatsu, Xishi,
>>>
>>> On 04/20/2015 10:11 AM, Yasuaki Ishimatsu wrote:
>>>
>>>>
>>>>> When hot adding memory and creating new node, the node is offline.
>>>>> And after calling node_set_online(), the node becomes online.
>>>>>
>>>>> Oh, sorry. I misread your ptaches.
>>>>>
>>>>
>>>> Please ignore it...
>>>
>>> Seems also a misread to me.
>>> I clear it (my worry) here:
>>> If we set the node size to 0 here, it may hidden more things than we experted.
>>> All the init chunks around with the size (spanned/present/managed...) will
>>> be non-sense, and the user/caller will not get a summary of the hot added node
>>> because of the changes here.
>>> I am not sure the worry is necessary, please correct me if I missing something.
>>>
>>> Regards,
>>> Gu
>>>
>>
>> Hi Gu,
>>
>> My patch is just set size to 0 when hotadd a node(old or new). I know your worry,
>> but I think it is not necessary.
>>
> 
>> When we calculate the size, it uses "arch_zone_lowest_possible_pfn[]" and "memblock",
>> and they are both from boot time. If we hotadd a new node, the calculated size is
>> 0 too. When add momery, __add_zone() will grow the size and start.
> 
> If hot adding new node, you are right. But if hot removing a memory which
> is presented at boot time, memblock of the memory range is not deleted.
> So when hot adding the memory, the calculated size does not become 0.
> 

Yes, so I just set it to 0, init_currently_empty_zone() and memmap_init() will be called
in __add_zone(), and start/size also will be grow there.

Thanks,
Xishi Qiu

> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> Thanks,
>> Xishi Qiu
>>
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
