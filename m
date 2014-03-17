Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEC76B0088
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 06:00:54 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id to1so5161820ieb.14
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 03:00:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pg8si6936411icb.59.2014.03.17.03.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 03:00:53 -0700 (PDT)
Message-ID: <5326C690.4090107@oracle.com>
Date: Mon, 17 Mar 2014 10:55:28 +0100
From: Vegard Nossum <vegard.nossum@oracle.com>
MIME-Version: 1.0
Subject: Re: kmemcheck: OS boot failed because NMI handlers access the memory
 tracked by kmemcheck
References: <5326BE25.9090201@huawei.com> <20140317095141.GA4777@dhcp22.suse.cz>
In-Reply-To: <20140317095141.GA4777@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On 03/17/2014 10:51 AM, Michal Hocko wrote:
> On Mon 17-03-14 17:19:33, Xishi Qiu wrote:
>> OS boot failed when set cmdline kmemcheck=1. The reason is that
>> NMI handlers will access the memory from kmalloc(), this will cause
>> page fault, because memory from kmalloc() is tracked by kmemcheck.
>>
>> watchdog_nmi_enable()
>> 	perf_event_create_kernel_counter()
>> 		perf_event_alloc()
>> 			event = kzalloc(sizeof(*event), GFP_KERNEL);
>
> Where is this path called from an NMI context?
>
> Your trace bellow points at something else and it doesn't seem to
> allocate any memory either. It looks more like x86_perf_event_update
> sees an invalid perf_event or something like that...
>

It's not important that the kzalloc() is called from NMI context, it's 
important that the memory that was allocated is touched (read/written) 
from NMI context.

I'm currently looking into the possibility of handling recursive faults 
in kmemcheck (using the approach outlined by peterz; see 
https://lkml.org/lkml/2014/2/26/141).


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
