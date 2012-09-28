Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1D8776B0069
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 20:25:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 324753EE0C5
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:24:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 17FCB45DE4E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:24:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7EB745DD78
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:24:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB1521DB803C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:24:57 +0900 (JST)
Received: from G01JPEXCHKW28.g01.fujitsu.local (G01JPEXCHKW28.g01.fujitsu.local [10.0.193.111])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 315BF1DB8038
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:24:57 +0900 (JST)
Message-ID: <5064EE3F.3080606@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 09:24:31 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] memory-hotplug: add memory_block_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-2-git-send-email-wency@cn.fujitsu.com> <CAEkdkmVW5wwG4_cy0yHFNVmk2bzAqzo2adRsMn1yHOW9Ex98_g@mail.gmail.com>
In-Reply-To: <CAEkdkmVW5wwG4_cy0yHFNVmk2bzAqzo2adRsMn1yHOW9Ex98_g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Chen,

2012/09/27 19:20, Ni zhan Chen wrote:
> Hi Congyang,
>
> 2012/9/27 <wency@cn.fujitsu.com>
>
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> When calling remove_memory_block(), the function shows following message at
>> device_release().
>>
>> Device 'memory528' does not have a release() function, it is broken and
>> must
>> be fixed.
>>
>
> What's the difference between the patch and original implemetation?

The implementation is for removing a memory_block. So the purpose is
same as original one. But original code is bad manner. kobject_cleanup()
is called by remove_memory_block() at last. But release function for
releasing memory_block is not registered. As a result, the kernel message
is shown. IMHO, memory_block should be release by the releae function.

Thanks,
Yasuaki Ishimatsu

>
>
>> remove_memory_block() calls kfree(mem). I think it shouled be called from
>> device_release(). So the patch implements memory_block_release()
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>   drivers/base/memory.c |    9 ++++++++-
>>   1 files changed, 8 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 7dda4f7..da457e5 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(struct
>> notifier_block *nb)
>>   }
>>   EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>>
>> +static void release_memory_block(struct device *dev)
>> +{
>> +       struct memory_block *mem = container_of(dev, struct memory_block,
>> dev);
>> +
>> +       kfree(mem);
>> +}
>> +
>>   /*
>>    * register_memory - Setup a sysfs device for a memory block
>>    */
>> @@ -80,6 +87,7 @@ int register_memory(struct memory_block *memory)
>>
>>          memory->dev.bus = &memory_subsys;
>>          memory->dev.id = memory->start_section_nr / sections_per_block;
>> +       memory->dev.release = release_memory_block;
>>
>>          error = device_register(&memory->dev);
>>          return error;
>> @@ -630,7 +638,6 @@ int remove_memory_block(unsigned long node_id, struct
>> mem_section *section,
>>                  mem_remove_simple_file(mem, phys_device);
>>                  mem_remove_simple_file(mem, removable);
>>                  unregister_memory(mem);
>> -               kfree(mem);
>>          } else
>>                  kobject_put(&mem->dev.kobj);
>>
>> --
>> 1.7.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
