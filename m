Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8566B0069
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 01:04:58 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id r2so10668797igi.11
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 22:04:58 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id r8si7899630icz.31.2014.10.08.22.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 22:04:56 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B22803EE1B6
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 14:04:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id C044AAC026A
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 14:04:53 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59A991DB8041
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 14:04:53 +0900 (JST)
Message-ID: <5436173A.1050002@jp.fujitsu.com>
Date: Thu, 9 Oct 2014 14:03:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] driver/base/node: remove unnecessary kfree of node struct
 from unregister_one_node
References: <542E750B.4000508@jp.fujitsu.com> <54360ABF.9030302@huawei.com>
In-Reply-To: <54360ABF.9030302@huawei.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2014/10/09 13:10), Xishi Qiu wrote:
> On 2014/10/3 18:06, Yasuaki Ishimatsu wrote:
> 
>> Commit 92d585ef067d ("numa: fix NULL pointer access and memory
>> leak in unregister_one_node()") added kfree() of node struct in
>> unregister_one_node(). But node struct is freed by node_device_release()
>> which is called in  unregister_node(). So by adding the kfree(),
> 
> Hi,
> 
> Is this path?
> unregister_node()
>    device_unregister()
>      device_del()
>        bus_remove_device()
>          device_release_driver()
>            __device_release_driver()
>              devres_release_all()
>                release_nodes()
>                  dr->node.release(dev, dr->data);
>                    then which function is be called?

node_device_release is called as follows:

unregister_one_node()
-> unregister_node()
  -> device_unregister()
    -> put_device()
      -> kobject_put()
        -> kref_put()
          -> kref_sub()
            -> kobject_release()
              -> kobject_cleanup()
                -> device_release()
                  -> node_device_release()

Thanks,
Yasuaki Ishimatsu

> 
> Thanks,
> Xishi Qiu
> 
>> node struct is freed two times.
>>
>> While hot removing memory, the commit leads the following BUG_ON():
>>
>>    kernel BUG at mm/slub.c:3346!
>>    invalid opcode: 0000 [#1] SMP
>>    [...]
>>    Call Trace:
>>     [...] unregister_one_node
>>     [...] try_offline_node
>>     [...] remove_memory
>>     [...] acpi_memory_device_remove
>>     [...] acpi_bus_trim
>>     [...] acpi_bus_trim
>>     [...] acpi_device_hotplug
>>     [...] acpi_hotplug_work_fn
>>     [...] process_one_work
>>     [...] worker_thread
>>     [...] ? rescuer_thread
>>     [...] kthread
>>     [...] ? kthread_create_on_node
>>     [...] ret_from_fork
>>     [...] ? kthread_create_on_node
>>
>> This patch removes unnecessary kfree() from unregister_one_node().
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Cc: Xishi Qiu <qiuxishi@huawei.com>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: stable@vger.kernel.org # v3.16+
>> Fixes: 92d585ef067d "numa: fix NULL pointer access and memory leak in unregister_one_node()"
>> ---
>>   drivers/base/node.c | 1 -
>>   1 file changed, 1 deletion(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index c6d3ae0..d51c49c 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -603,7 +603,6 @@ void unregister_one_node(int nid)
>>   		return;
>>
>>   	unregister_node(node_devices[nid]);
>> -	kfree(node_devices[nid]);
>>   	node_devices[nid] = NULL;
>>   }
>>
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
