Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68CC68E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 12:06:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so3124000pfn.3
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:06:11 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id v3-v6si2294734ply.358.2018.09.27.09.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 09:06:10 -0700 (PDT)
Subject: Re: [v2 PATCH 2/2 -mm] mm: brk: dwongrade mmap_sem to read when
 shrinking
References: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537985434-22655-2-git-send-email-yang.shi@linux.alibaba.com>
 <33d52132-546f-3c8a-3445-cdbc9068589a@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <4bcdb16d-902e-55ed-5f5d-12c5ba7cbdfd@linux.alibaba.com>
Date: Thu, 27 Sep 2018 09:05:37 -0700
MIME-Version: 1.0
In-Reply-To: <33d52132-546f-3c8a-3445-cdbc9068589a@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/18 5:14 AM, Vlastimil Babka wrote:
> On 9/26/18 8:10 PM, Yang Shi wrote:
>
> Again, "downgrade" in the subject
>
>> brk might be used to shinrk memory mapping too other than munmap().
>                         ^ shrink
>
>> So, it may hold write mmap_sem for long time when shrinking large
>> mapping, as what commit ("mm: mmap: zap pages with read mmap_sem in
>> munmap") described.
>>
>> The brk() will not manipulate vmas anymore after __do_munmap() call for
>> the mapping shrink use case. But, it may set mm->brk after
>> __do_munmap(), which needs hold write mmap_sem.
>>
>> However, a simple trick can workaround this by setting mm->brk before
>> __do_munmap(). Then restore the original value if __do_munmap() fails.
>> With this trick, it is safe to downgrade to read mmap_sem.
>>
>> So, the same optimization, which downgrades mmap_sem to read for
>> zapping pages, is also feasible and reasonable to this case.
>>
>> The period of holding exclusive mmap_sem for shrinking large mapping
>> would be reduced significantly with this optimization.
>>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Same nit for the "bool downgrade" name as for patch 1/2.

Will solve in next version.

Thanks,
Yang

>
> Thanks,
> Vlastimil
