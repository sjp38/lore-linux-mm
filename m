Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id F32706B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:11:12 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so120523719lbc.1
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:11:11 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id pz9si14019637lbb.92.2015.04.19.20.11.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Apr 2015 20:11:10 -0700 (PDT)
Message-ID: <55346859.30605@huawei.com>
Date: Mon, 20 Apr 2015 10:45:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com> <5531679d.4642ec0a.1beb.3569@mx.google.com> <55345979.2020502@cn.fujitsu.com>
In-Reply-To: <55345979.2020502@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, yasu.ishimatsu@gmail.com

On 2015/4/20 9:42, Gu Zheng wrote:

> Hi Xishi,
> On 04/18/2015 04:05 AM, Yasuaki Ishimatsu wrote:
> 
>>
>> Your patches will fix your issue.
>> But, if BIOS reports memory first at node hot add, pgdat can
>> not be initialized.
>>
>> Memory hot add flows are as follows:
>>
>> add_memory
>>   ...
>>   -> hotadd_new_pgdat()
>>   ...
>>   -> node_set_online(nid)
>>
>> When calling hotadd_new_pgdat() for a hot added node, the node is
>> offline because node_set_online() is not called yet. So if applying
>> your patches, the pgdat is not initialized in this case.
> 
> Ishimtasu's worry is reasonable. And I am afraid the fix here is a bit
> over-kill. 
> 
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>> On Fri, 17 Apr 2015 18:50:32 +0800
>> Xishi Qiu <qiuxishi@huawei.com> wrote:
>>
>>> Hot remove nodeXX, then hot add nodeXX. If BIOS report cpu first, it will call
>>> hotadd_new_pgdat(nid, 0), this will set pgdat->node_start_pfn to 0. As nodeXX
>>> exists at boot time, so pgdat->node_spanned_pages is the same as original. Then
>>> free_area_init_core()->memmap_init() will pass a wrong start and a nonzero size.
> 
> As your analysis said the root cause here is passing a *0* as the node_start_pfn,
> then the chaos occurred when init the zones. And this only happens to the re-hotadd
> node, so how about using the saved *node_start_pfn* (via get_pfn_range_for_nid(nid, &start_pfn, &end_pfn))
> instead if we find "pgdat->node_start_pfn == 0 && !node_online(XXX)"?
> 
> Thanks,
> Gu
> 

Hi Gu,

I first considered this method, but if the hot added node's start and size are different
from before, it makes the chaos.

e.g.
nodeXX (8-16G)
remove nodeXX 
BIOS report cpu first and online it
hotadd nodeXX
use the original value, so pgdat->node_start_pfn is set to 8G, and size is 8G
BIOS report mem(10-12G)
call add_memory()->__add_zone()->grow_zone_span()/grow_pgdat_span()
the start is still 8G, not 10G, this is chaos!

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
