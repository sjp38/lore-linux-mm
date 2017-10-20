Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8E676B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:47:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o44so5298147wrf.0
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:47:20 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id m125si393723wma.246.2017.10.19.23.47.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 23:47:19 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy: add node_empty check in SYSC_migrate_pages
References: <1508290660-60619-1-git-send-email-xieyisheng1@huawei.com>
 <7086c6ea-b721-684e-fe3d-ff59ae1d78ed@suse.cz>
 <20aac66a-7252-947c-355b-6da4be671dcf@huawei.com>
 <f889d39f-ca1f-9239-dc95-4e1806a6345f@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <79f20d60-dd8d-2545-5a9b-09871ad8ee4e@huawei.com>
Date: Fri, 20 Oct 2017 14:42:38 +0800
MIME-Version: 1.0
In-Reply-To: <f889d39f-ca1f-9239-dc95-4e1806a6345f@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, tanxiaojun@huawei.com, Linux API <linux-api@vger.kernel.org>

Hi Vlastimil,

Thanks for your comment!
On 2017/10/18 18:46, Vlastimil Babka wrote:
> On 10/18/2017 11:34 AM, Yisheng Xie wrote:
>>>> For MAX_NUMNODES is 4, so 0x10 nodemask will tread as empty set which makes
>>>> 	nodes_subset(*new, node_states[N_MEMORY])
>>>
>>> According to manpage of migrate_pages:
>>>
>>>         EINVAL The value specified by maxnode exceeds a kernel-imposed
>>> limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
>>> are greater than the maximum supported node ID.  Or, none of the node
>>> IDs specified by new_nodes are on-line and allowed by the process's
>>> current cpuset context, or none of the specified nodes contain memory.
>>>
>>> if maxnode parameter is 64, but MAX_NUMNODES ("kernel-imposed limit") is
>>> 4, we should get EINVAL just because of that. I don't see such check in
>>> the migrate_pages implementation though.
>>
>> Yes, that is what manpage said, but I have a question about this: if user
>> set maxnode exceeds a kernel-imposed and try to access node without enough
>> privilege, which errors values we should return ? For I have seen that all
>> of the ltp migrate_pages01 will set maxnode to 64 in my system.
> 
> Hm I don't think it matters much and don't know if there's some commonly
> used priority. Personally I would do the checks resulting in EINVAL
> first, before EPERM, but if the code is structured differently, it may
> stay as it is.

I seei 1/4 ?and  I have checked the code of get_nodes, which seems treat
"kernel-imposed limit" as the meaning of
BITS_PER_LONG * BITS_TO_LONGS(MAX_NUMNODES) instead of MAX_NUMNODES,
which I have replied in another mail.

As we use unsigned long to store node bitmap, so the limit should be counted in
multiple of BITS_PER_LONG, fair?

Thanks
Yisheng Xie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
