Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 315506B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 06:42:11 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so2259500pdj.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 03:42:10 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id f7si387600pdk.95.2015.06.11.03.42.09
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 03:42:10 -0700 (PDT)
Message-ID: <557965D1.7020009@cn.fujitsu.com>
Date: Thu, 11 Jun 2015 18:41:21 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memory hotplug: print the last vmemmap region at the
 end of hot add memory
References: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>	<20150608163053.c481d9a5057513130f760910@linux-foundation.org>	<55766068.9090809@cn.fujitsu.com> <20150609132908.c5a9d2c9714bd7a8f33ffde8@linux-foundation.org>
In-Reply-To: <20150609132908.c5a9d2c9714bd7a8f33ffde8@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, rientjes@google.com, n-horiguchi@ah.jp.nec.com, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, fabf@skynet.be


On 06/10/2015 04:29 AM, Andrew Morton wrote:
> On Tue, 9 Jun 2015 11:41:28 +0800 Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
>
>>>> --- a/mm/memory_hotplug.c
>>>> +++ b/mm/memory_hotplug.c
>>>> @@ -513,6 +513,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>>>>    			break;
>>>>    		err = 0;
>>>>    	}
>>>> +	vmemmap_populate_print_last();
>>>>    
>>>>    	return err;
>>>>    }
>>> vmemmap_populate_print_last() is only available on x86_64, when
>>> CONFIG_SPARSEMEM_VMEMMAP=y.  Are you sure this won't break builds?
>> I tried this on i386 and on x86_64 when CONFIG_SPARSEMEM_VMEMMAP=n ,
>> it builds ok.
> With powerpc:
>
> akpm3:/usr/src/25> make allmodconfig
> akpm3:/usr/src/25> make mm/memory_hotplug.o
> akpm3:/usr/src/25> nm mm/memory_hotplug.o | grep vmemmap_populate_print_last
> 	U .vmemmap_populate_print_last
> akpm3:/usr/src/25> grep -r vmemmap_populate_print_last arch/powerpc
> akpm3:/usr/src/25>
>
> So I think that's going to break.
>
> I expect ia64 will break also, but I didn't investigate.
> .
>

There is
void __weak __meminit vmemmap_populate_print last(void)
in /mm/sparse.c, so I think this won't break builds.

And I found the function was invoked in void __init sparse_init(void) 
without
CONFIG_SPARSEMEM_VMEMMAP=y.

I also tried this on arm, it builds ok too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
