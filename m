Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7C16B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 21:14:53 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so59638337pdb.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:14:53 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id uw7si30312231pac.8.2015.08.24.18.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 18:14:52 -0700 (PDT)
Message-ID: <55DBC061.8040508@huawei.com>
Date: Tue, 25 Aug 2015 09:09:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] memhp: Add hot-added memory ranges to memblock before
 allocate node_data for a node.
References: <1440349573-24260-1-git-send-email-tangchen@cn.fujitsu.com> <55DAE26E.1050302@huawei.com>
In-Reply-To: <55DAE26E.1050302@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, vbabka@suse.cz, mgorman@techsingularity.net, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/8/24 17:22, Xishi Qiu wrote:

> On 2015/8/24 1:06, Tang Chen wrote:
> 
>> The commit below adds hot-added memory range to memblock, after
>> creating pgdat for new node.
>>
>> commit f9126ab9241f66562debf69c2c9d8fee32ddcc53
>> Author: Xishi Qiu <qiuxishi@huawei.com>
>> Date:   Fri Aug 14 15:35:16 2015 -0700
>>
>>     memory-hotplug: fix wrong edge when hot add a new node
>>
>> But there is a problem:
>>
>> add_memory()
>> |--> hotadd_new_pgdat()
>>      |--> free_area_init_node()
>>           |--> get_pfn_range_for_nid()
>>                |--> find start_pfn and end_pfn in memblock
>> |--> ......
>> |--> memblock_add_node(start, size, nid)    --------    Here, just too late.
>>
>> get_pfn_range_for_nid() will find that start_pfn and end_pfn are both 0.
>> As a result, when adding memory, dmesg will give the following wrong message.
>>

Hi Tang,

Another question, if we add cpu first, there will be print error too.

cpu_up()
	try_online_node()
		hotadd_new_pgdat()

So how about just skip the print if the size is empty or just print 
"node xx is empty now, will update when online memory"? 

Thanks,
Xishi Qiu

>> [ 2007.577000] Initmem setup node 5 [mem 0x0000000000000000-0xffffffffffffffff]
>> [ 2007.584000] On node 5 totalpages: 0
>> [ 2007.585000] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 32588823
>> [ 2007.594000] Policy zone: Normal
>> [ 2007.598000] init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
>>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
