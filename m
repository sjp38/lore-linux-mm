Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 660966B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 19:50:08 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u126so7062972oia.19
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 16:50:08 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id h56si4218740otc.7.2017.12.03.16.50.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Dec 2017 16:50:07 -0800 (PST)
Subject: Re: [PATCH v4 3/3] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1512122128-6220-1-git-send-email-xieyisheng1@huawei.com>
 <305e9b37-0e58-a53d-55b7-f0815c1ba64f@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <b52cb4a7-50c9-4b77-503d-ba3add24d0c8@huawei.com>
Date: Mon, 4 Dec 2017 08:49:08 +0800
MIME-Version: 1.0
In-Reply-To: <305e9b37-0e58-a53d-55b7-f0815c1ba64f@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tan Xiaojun <tanxiaojun@huawei.com>

Hi Vlastimil,

On 2017/12/1 23:18, Vlastimil Babka wrote:
> On 12/01/2017 10:55 AM, Yisheng Xie wrote:
>> As in manpage of migrate_pages, the errno should be set to EINVAL when
>> none of the node IDs specified by new_nodes are on-line and allowed by the
>> process's current cpuset context, or none of the specified nodes contain
>> memory.  However, when test by following case:
>>
>> 	new_nodes = 0;
>> 	old_nodes = 0xf;
>> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
>>
>> The ret will be 0 and no errno is set.  As the new_nodes is empty, we
>> should expect EINVAL as documented.
>>
>> To fix the case like above, this patch check whether target nodes AND
>> current task_nodes is empty, and then check whether AND
>> node_states[N_MEMORY] is empty.
>>
>> Meanwhile,this patch also remove the check of EPERM on CAP_SYS_NICE. 
>> The caller of migrate_pages should be able to migrate the target process
>> pages anywhere the caller can allocate memory, if the caller can access
>> the mm_struct.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> Cc: Andi Kleen <ak@linux.intel.com>
>> Cc: Chris Salls <salls@cs.ucsb.edu>
>> Cc: Christopher Lameter <cl@linux.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Tan Xiaojun <tanxiaojun@huawei.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> ---
>> v3:
>>  * check whether node is empty after AND current task node, and then nodes
>>    which have memory
>> v4:
>>  * remove the check of EPERM on CAP_SYS_NICE.
>>
>> Hi Vlastimil and Christopher,
>>
>> Could you please help to review this version?
> 
> Hi, I think we should stay with v3 after all. What I missed when
> reviewing it, is that the EPERM check is for cpuset_mems_allowed(task)
> and in v3 you add EINVAL check for cpuset_mems_allowed(current), which
> may not be the same, and the intention of CAP_SYS_NICE is not whether we
> can bypass our own cpuset, but whether we can bypass the target task's
> cpuset. Sorry for the confusion.

Ok, so please ignore this version.

Thanks
Yisheng Xie
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
