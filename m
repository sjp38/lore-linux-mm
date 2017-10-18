Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2F66B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:46:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q18so1935764wmg.18
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:46:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1si9833418wrf.391.2017.10.18.03.46.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 03:46:44 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy: add node_empty check in SYSC_migrate_pages
References: <1508290660-60619-1-git-send-email-xieyisheng1@huawei.com>
 <7086c6ea-b721-684e-fe3d-ff59ae1d78ed@suse.cz>
 <20aac66a-7252-947c-355b-6da4be671dcf@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f889d39f-ca1f-9239-dc95-4e1806a6345f@suse.cz>
Date: Wed, 18 Oct 2017 12:46:41 +0200
MIME-Version: 1.0
In-Reply-To: <20aac66a-7252-947c-355b-6da4be671dcf@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, tanxiaojun@huawei.com, Linux API <linux-api@vger.kernel.org>

On 10/18/2017 11:34 AM, Yisheng Xie wrote:
>>> For MAX_NUMNODES is 4, so 0x10 nodemask will tread as empty set which makes
>>> 	nodes_subset(*new, node_states[N_MEMORY])
>>
>> According to manpage of migrate_pages:
>>
>>         EINVAL The value specified by maxnode exceeds a kernel-imposed
>> limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
>> are greater than the maximum supported node ID.  Or, none of the node
>> IDs specified by new_nodes are on-line and allowed by the process's
>> current cpuset context, or none of the specified nodes contain memory.
>>
>> if maxnode parameter is 64, but MAX_NUMNODES ("kernel-imposed limit") is
>> 4, we should get EINVAL just because of that. I don't see such check in
>> the migrate_pages implementation though.
> 
> Yes, that is what manpage said, but I have a question about this: if user
> set maxnode exceeds a kernel-imposed and try to access node without enough
> privilege, which errors values we should return ? For I have seen that all
> of the ltp migrate_pages01 will set maxnode to 64 in my system.

Hm I don't think it matters much and don't know if there's some commonly
used priority. Personally I would do the checks resulting in EINVAL
first, before EPERM, but if the code is structured differently, it may
stay as it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
