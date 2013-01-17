Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 22B226B0069
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 00:09:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 303273EE0C1
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 14:09:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A0A45DEC8
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 14:09:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB95945DEC3
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 14:09:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB8B81DB8038
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 14:09:37 +0900 (JST)
Received: from G01JPEXCHKW22.g01.fujitsu.local (G01JPEXCHKW22.g01.fujitsu.local [10.0.193.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AA6C1DB803B
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 14:09:37 +0900 (JST)
Message-ID: <50F78750.8070403@jp.fujitsu.com>
Date: Thu, 17 Jan 2013 14:08:32 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com>
In-Reply-To: <50F72F17.9030805@zytor.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2013/01/17 7:52, H. Peter Anvin wrote:
> On 01/16/2013 01:29 PM, Andrew Morton wrote:
>>>
>>> Yes. If SRAT support is available, all memory which enabled hotpluggable
>>> bit are managed by ZONEMOVABLE. But performance degradation may
>>> occur by NUMA because we can only allocate anonymous page and page-cache
>>> from these memory.
>>>
>>> In this case, if user cannot change SRAT information, user needs a way to
>>> select/set removable memory manually.
>>
>> If I understand this correctly you mean that once SRAT parsing is
>> implemented, the user can use movablecore_map to override that SRAT
>> parsing, yes?  That movablecore_map will take precedence over SRAT?
>>
>
> Yes, but we still need a higher-level user interface which specifies
> which nodes, not which memory ranges, should be movable.

I thought about the method of specifying the node. But I think
this method is inconvenience. Node number is decided by OS.
So the number is changed easily.

for example:

o exmaple 1
   System has 3 nodes:
   node0, node1, node2

   When user remove node1, the system has:
   node0, node2

   But after rebooting the system, the system has:
   node0, node1

   So node2 becomes node1.

o example 2:
   System has 2 nodes:
   0x40000000 - 0x7fffffff : node0
   0xc0000000 - 0xffffffff : node1

   When user add a node wchih memory range is [0x80000000 - 0xbfffffff],
   system has:
   0x40000000 - 0x7fffffff : node0
   0xc0000000 - 0xffffffff : node1
   0x80000000 - 0xbfffffff : node2

   But after rebooting the system, the system's node may become:
   0x40000000 - 0x7fffffff : node0
   0x80000000 - 0xbfffffff : node1
   0xc0000000 - 0xffffffff : node2

   So node nunber is changed.

Specifying node number may be easy method than specifying memory
range. But if user uses node number for specifying removable memory,
user always need to care whether node number is changed or not at
every hotplug operation.

Thanks,
Yasuaki Ishimatsu


> That is the
> policy granularity that is actually appropriate for the administrator
> (trading off performance vs reliability.)
>
> 	-hpa
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
