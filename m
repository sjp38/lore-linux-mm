Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF3016B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:38:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i196so3738656pgd.2
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:38:33 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u16si2438494pfl.163.2017.10.18.02.38.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 02:38:32 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy: add node_empty check in SYSC_migrate_pages
References: <1508290660-60619-1-git-send-email-xieyisheng1@huawei.com>
 <7086c6ea-b721-684e-fe3d-ff59ae1d78ed@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <20aac66a-7252-947c-355b-6da4be671dcf@huawei.com>
Date: Wed, 18 Oct 2017 17:34:15 +0800
MIME-Version: 1.0
In-Reply-To: <7086c6ea-b721-684e-fe3d-ff59ae1d78ed@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, tanxiaojun@huawei.com, Linux API <linux-api@vger.kernel.org>

Hi Vlastimil,

Thanks for your comment!
On 2017/10/18 15:54, Vlastimil Babka wrote:
> +CC linux-api
> 
> On 10/18/2017 03:37 AM, Yisheng Xie wrote:
>> As Xiaojun reported the ltp of migrate_pages01 will failed on ARCH arm64
>> system whoes has 4 nodes[0...3], all have memory and CONFIG_NODES_SHIFT=2:
>>
>> migrate_pages01    0  TINFO  :  test_invalid_nodes
>> migrate_pages01   14  TFAIL  :  migrate_pages_common.c:45: unexpected failure - returned value = 0, expected: -1
>> migrate_pages01   15  TFAIL  :  migrate_pages_common.c:55: call succeeded unexpectedly
>>
>> In this case the test_invalid_nodes of migrate_pages01 will call:
>> SYSC_migrate_pages as:
>>
>> migrate_pages(0, , {0x0000000000000001}, 64, , {0x0000000000000010}, 64) = 0
> 
> is 64 here the maxnode parameter of migrate_pages() ?

Yes, I have print it in the kernel.

> 
>> For MAX_NUMNODES is 4, so 0x10 nodemask will tread as empty set which makes
>> 	nodes_subset(*new, node_states[N_MEMORY])
> 
> According to manpage of migrate_pages:
> 
>         EINVAL The value specified by maxnode exceeds a kernel-imposed
> limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
> are greater than the maximum supported node ID.  Or, none of the node
> IDs specified by new_nodes are on-line and allowed by the process's
> current cpuset context, or none of the specified nodes contain memory.
> 
> if maxnode parameter is 64, but MAX_NUMNODES ("kernel-imposed limit") is
> 4, we should get EINVAL just because of that. I don't see such check in
> the migrate_pages implementation though.

Yes, that is what manpage said, but I have a question about this: if user
set maxnode exceeds a kernel-imposed and try to access node without enough
privilege, which errors values we should return ? For I have seen that all
of the ltp migrate_pages01 will set maxnode to 64 in my system.

> But then at least the
> "new_nodes specifies one or more node IDs that are greater than the
> maximum supported node ID" part should trigger here, because you have
> node number 8 set in the new_nodes nodemask, right?
> get_nodes() should be checking this according to comment:
> 
>         /* When the user specified more nodes than supported just check
>            if the non supported part is all zero. */
> 
> Somehow that doesn't seem to work then? I think we should look into
> this. Your patch may still be needed, or not, after that is resolved.

OK, I will check why get_nodes do not works as it comments.

Thanks
Yisheng Xie

> 
>> return true, as empty set is subset of any set.
>>
>> So this is a common issue which also can happens in X86_64 system eg. 8 nodes[0..7],
>> all with memory and CONFIG_NODES_SHIFT=3. Fix it by adding node_empty check in
>> SYSC_migrate_pages.
>>
>> Reported-by: Tan Xiaojun <tanxiaojun@huawei.com>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> ---
>>  mm/mempolicy.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index a2af6d5..1dfd3cc 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -1388,6 +1388,11 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
>>  	if (err)
>>  		goto out;
>>  
>> +	if (nodes_empty(*new)) {
>> +		err = -EINVAL;
>> +		goto out;
>> +	}
>> +
>>  	/* Find the mm_struct */
>>  	rcu_read_lock();
>>  	task = pid ? find_task_by_vpid(pid) : current;
>>
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
