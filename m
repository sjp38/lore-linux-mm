Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E472A6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 02:12:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 38BD33EE0BD
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:12:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1783245DE5D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:12:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED37945DE56
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:12:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D62D61DB804E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:12:04 +0900 (JST)
Received: from g01jpexchyt10.g01.fujitsu.local (g01jpexchyt10.g01.fujitsu.local [10.128.194.49])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76F701DB8049
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:12:04 +0900 (JST)
Message-ID: <50653F9A.10201@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 15:11:38 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] memory-hotplug: add memory_block_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-2-git-send-email-wency@cn.fujitsu.com> <CAEkdkmVW5wwG4_cy0yHFNVmk2bzAqzo2adRsMn1yHOW9Ex98_g@mail.gmail.com> <5064EE3F.3080606@jp.fujitsu.com> <CAHGf_=pDn852sRadnXQMWx3rOTxGLy7876pxk1Ww4oJtkBAZbQ@mail.gmail.com> <50651D65.5080400@jp.fujitsu.com> <50653DE7.70702@gmail.com>
In-Reply-To: <50653DE7.70702@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Chen,

2012/09/28 15:04, Ni zhan Chen wrote:
> On 09/28/2012 11:45 AM, Yasuaki Ishimatsu wrote:
>> Hi Kosaki-san,
>>
>> 2012/09/28 10:35, KOSAKI Motohiro wrote:
>>> On Thu, Sep 27, 2012 at 8:24 PM, Yasuaki Ishimatsu
>>> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>>>> Hi Chen,
>>>>
>>>>
>>>> 2012/09/27 19:20, Ni zhan Chen wrote:
>>>>>
>>>>> Hi Congyang,
>>>>>
>>>>> 2012/9/27 <wency@cn.fujitsu.com>
>>>>>
>>>>>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>>
>>>>>> When calling remove_memory_block(), the function shows following message
>>>>>> at
>>>>>> device_release().
>>>>>>
>>>>>> Device 'memory528' does not have a release() function, it is broken and
>>>>>> must
>>>>>> be fixed.
>>>>>>
>>>>>
>>>>> What's the difference between the patch and original implemetation?
>>>>
>>>>
>>>> The implementation is for removing a memory_block. So the purpose is
>>>> same as original one. But original code is bad manner. kobject_cleanup()
>>>> is called by remove_memory_block() at last. But release function for
>>>> releasing memory_block is not registered. As a result, the kernel message
>>>> is shown. IMHO, memory_block should be release by the releae function.
>>>
>>> but your patch introduced use after free bug, if i understand correctly.
>>> See unregister_memory() function. After your patch, kobject_put() call
>>> release_memory_block() and kfree(). and then device_unregister() will
>>> touch freed memory.
>>
>
> this patch is similiar to [RFC v9 PATCH 10/21] memory-hotplug: add memory_block_release, they handle the same issue, can these two patches be fold to one?

You're right. The patch is same as [RFC v9 PATCH 10/21].
The patch is a bug fix. So we separated it from memory-hotplug patch-set.

Thanks,
Yasuaki Ishimatsu

>> It is not correct. The kobject_put() is prepared against find_memory_block()
>> in remove_memory_block() since kobject->kref is incremented in it.
>> So release_memory_block() is called by device_unregister() correctly as follows:
>>
>> [ 1014.589008] Pid: 126, comm: kworker/0:2 Not tainted 3.6.0-rc3-enable-memory-hotremove-and-root-bridge #3
>> [ 1014.702437] Call Trace:
>> [ 1014.731684]  [<ffffffff8144d096>] release_memory_block+0x16/0x30
>> [ 1014.803581]  [<ffffffff81438587>] device_release+0x27/0xa0
>> [ 1014.869312]  [<ffffffff8133e962>] kobject_cleanup+0x82/0x1b0
>> [ 1014.937062]  [<ffffffff8133ea9d>] kobject_release+0xd/0x10
>> [ 1015.002718]  [<ffffffff8133e7ec>] kobject_put+0x2c/0x60
>> [ 1015.065271]  [<ffffffff81438107>] put_device+0x17/0x20
>> [ 1015.126794]  [<ffffffff8143918a>] device_unregister+0x2a/0x60
>> [ 1015.195578]  [<ffffffff8144d55b>] remove_memory_block+0xbb/0xf0
>> [ 1015.266434]  [<ffffffff8144d5af>] unregister_memory_section+0x1f/0x30
>> [ 1015.343532]  [<ffffffff811c0a58>] __remove_section+0x68/0x110
>> [ 1015.412318]  [<ffffffff811c0be7>] __remove_pages+0xe7/0x120
>> [ 1015.479021]  [<ffffffff81653d8c>] arch_remove_memory+0x2c/0x80
>> [ 1015.548845]  [<ffffffff8165497b>] remove_memory+0x6b/0xd0
>> [ 1015.613474]  [<ffffffff813d946c>] acpi_memory_device_remove_memory+0x48/0x73
>> [ 1015.697834]  [<ffffffff813d94c2>] acpi_memory_device_remove+0x2b/0x44
>> [ 1015.774922]  [<ffffffff813a61e4>] acpi_device_remove+0x90/0xb2
>> [ 1015.844796]  [<ffffffff8143c2fc>] __device_release_driver+0x7c/0xf0
>> [ 1015.919814]  [<ffffffff8143c47f>] device_release_driver+0x2f/0x50
>> [ 1015.992753]  [<ffffffff813a70dc>] acpi_bus_remove+0x32/0x6d
>> [ 1016.059462]  [<ffffffff813a71a8>] acpi_bus_trim+0x91/0x102
>> [ 1016.125128]  [<ffffffff813a72a1>] acpi_bus_hot_remove_device+0x88/0x16b
>> [ 1016.204295]  [<ffffffff813a2e57>] acpi_os_execute_deferred+0x27/0x34
>> [ 1016.280350]  [<ffffffff81090599>] process_one_work+0x219/0x680
>> [ 1016.350173]  [<ffffffff81090538>] ? process_one_work+0x1b8/0x680
>> [ 1016.422072]  [<ffffffff813a2e30>] ? acpi_os_wait_events_complete+0x23/0x23
>> [ 1016.504357]  [<ffffffff810923ce>] worker_thread+0x12e/0x320
>> [ 1016.571064]  [<ffffffff810922a0>] ? manage_workers+0x110/0x110
>> [ 1016.640886]  [<ffffffff810983a6>] kthread+0xc6/0xd0
>> [ 1016.699290]  [<ffffffff8167b144>] kernel_thread_helper+0x4/0x10
>> [ 1016.770149]  [<ffffffff81670bb0>] ? retint_restore_args+0x13/0x13
>> [ 1016.843165]  [<ffffffff810982e0>] ? __init_kthread_worker+0x70/0x70
>> [ 1016.918200]  [<ffffffff8167b140>] ? gs_change+0x13/0x13
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>>>
>>> static void
>>> unregister_memory(struct memory_block *memory)
>>> {
>>>     BUG_ON(memory->dev.bus != &memory_subsys);
>>>
>>>     /* drop the ref. we got in remove_memory_block() */
>>>     kobject_put(&memory->dev.kobj);
>>>     device_unregister(&memory->dev);
>>> }
>>>
>>
>>
>>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
