Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04A6F6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 21:41:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c132so93471945pfg.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 18:41:29 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y32si965205otd.17.2016.09.01.18.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 18:41:29 -0700 (PDT)
Message-ID: <57C8D71F.1080803@huawei.com>
Date: Fri, 2 Sep 2016 09:34:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] memory-hotplug: fix store_mem_state() return value
References: <1472743777-24266-1-git-send-email-arbab@linux.vnet.ibm.com> <20160901133717.8d753013cfbb640dd28c2783@linux-foundation.org>
In-Reply-To: <20160901133717.8d753013cfbb640dd28c2783@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly
 Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/9/2 4:37, Andrew Morton wrote:

> On Thu,  1 Sep 2016 10:29:37 -0500 Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> 
>> If store_mem_state() is called to online memory which is already online,
>> it will return 1, the value it got from device_online().
>>
>> This is wrong because store_mem_state() is a device_attribute .store
>> function. Thus a non-negative return value represents input bytes read.
>>
>> Set the return value to -EINVAL in this case.
>>
> 
> I actually made the mistake of reading this code.
> 
> What the heck are the return value semantics of bus_type.online? 
> Sometimes 0, sometimes 1 and apparently sometimes -Efoo values.  What
> are these things trying to tell the caller and why is "1" ever useful
> and why doesn't anyone document anything.  grr.
> 
> And now I don't understand this patch.  Because:
> 
> static int memory_subsys_online(struct device *dev)
> {
> 	struct memory_block *mem = to_memory_block(dev);
> 	int ret;
> 
> 	if (mem->state == MEM_ONLINE)
> 		return 0;
> 

I think we will not execute here, it will return from device_online(),
because "if (dev->offline)" is false and return 1.

But the two return vaules are different if we do online-to-online.
memory_subsys_online() return 0, and device_online() return 1,
this is a little confusion.

When device_online() return 1, online_store() return 1 and store_mem_state()
return -EINVAL even without this patch, as Reza described in v2.

1. store_mem_state() called with buf="online"
2. device_online() returns 1 because device is already online
3. store_mem_state() returns 1
4. calling code interprets this as 1-byte buffer read
5. store_mem_state() called again with buf="nline"
6. store_mem_state() returns -EINVAL

Thanks,
Xishi Qiu

> Doesn't that "return 0" contradict the changelog?
> 
> Also, is store_mem_state() the correct place to fix this?  Instead,
> should memory_block_change_state() detect an attempt to online
> already-online memory and itself return -EINVAL, and permit that to be
> propagated back?  Well, that depends on the bus_type.online rules which
> appear to be undocumented.  What is the bus implementation supposed to
> do when a request is made to online an already-online device?
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
