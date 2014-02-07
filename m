Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D28796B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 05:36:37 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wn1so3748806obc.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 02:36:37 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id iz10si2250500obb.130.2014.02.07.02.36.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 02:36:36 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 7 Feb 2014 16:06:30 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id D6090394005C
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:06:25 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s17AaE6V35062004
	for <linux-mm@kvack.org>; Fri, 7 Feb 2014 16:06:14 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s17AaMLW008664
	for <linux-mm@kvack.org>; Fri, 7 Feb 2014 16:06:23 +0530
Message-ID: <52F4B8A4.70405@linux.vnet.ibm.com>
Date: Fri, 07 Feb 2014 16:12:44 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org> <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 05:28 AM, David Rientjes wrote:
> On Thu, 6 Feb 2014, David Rientjes wrote:
>
>>>>>> +#define MAX_REMOTE_READAHEAD   4096UL
>
>> Normally it wouldn't matter because there's no significant downside to it
>> racing, things like mempolicies which use numa_node_id() extensively would
>> result in, oops, a page allocation on the wrong node.
>>
>> This stands out to me, though, because you're expecting the calculation to
>> be correct for a specific node.
>>
>> The patch is still wrong, though, it should just do
>>
>> 	int node = ACCESS_ONCE(numa_mem_id());
>> 	return min(nr, (node_page_state(node, NR_INACTIVE_FILE) +
>> 		        node_page_state(node, NR_FREE_PAGES)) / 2);
>>
>> since we want to readahead based on the cpu's local node, the comment
>> saying we're reading ahead onto "remote memory" is wrong since a
>> memoryless node has local affinity to numa_mem_id().
>>
>
> Oops, forgot about the MAX_REMOTE_READAHEAD which needs to be factored in
> as well, but this handles the bound on local node's statistics.
>

So following discussion TODO for my patch is:

1) Update the changelog with user visible impact of the patch.
(Andrew's suggestion)
2) Add ACCESS_ONCE to numa_node_id().
3) Change the "readahead into remote memory" part of the documentation
which is misleading.

( I feel no need to add numa_mem_id() since we would specifically limit
the readahead with MAX_REMOTE_READAHEAD in memoryless cpu cases).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
