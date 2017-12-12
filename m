Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B322C6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 01:53:17 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d18so8468119oic.22
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 22:53:17 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s11si4200804oif.41.2017.12.11.22.53.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 22:53:16 -0800 (PST)
Message-ID: <5A2F7CAA.3070405@huawei.com>
Date: Tue, 12 Dec 2017 14:52:26 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RESEND] x86/numa: move setting parsed numa node to num_add_memblk
References: <1512123232-7263-1-git-send-email-zhongjiang@huawei.com> <20171211120304.GD4779@dhcp22.suse.cz> <5A2E8131.4000104@huawei.com> <20171211134539.GF4779@dhcp22.suse.cz>
In-Reply-To: <20171211134539.GF4779@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, minchan@kernel.org, vbabka@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2017/12/11 21:45, Michal Hocko wrote:
> On Mon 11-12-17 20:59:29, zhong jiang wrote:
>> On 2017/12/11 20:03, Michal Hocko wrote:
>>> On Fri 01-12-17 18:13:52, zhong jiang wrote:
>>>> The acpi table are very much like user input. it is likely to
>>>> introduce some unreasonable node in some architecture. but
>>>> they do not ingore the node and bail out in time. it will result
>>>> in unnecessary print.
>>>> e.g  x86:  start is equal to end is a unreasonable node.
>>>> numa_blk_memblk will fails but return 0.
>>>>
>>>> meanwhile, Arm64 node will double set it to "numa_node_parsed"
>>>> after NUMA adds a memblk successfully.  but X86 is not. because
>>>> numa_add_memblk is not set in X86.
>>> I am sorry but I still fail to understand wht the actual problem is.
>>> You said that x86 will print a message. Alright at least you know that
>>> the platform provides a nonsense ACPI/SRAT? tables and you can complain.
>>> But does the kernel misbehave? In what way?
>>   From the view of  the following code , we should expect that the node is reasonable.
>>   otherwise, if we only want to complain,  it should bail out in time after printing the
>>   unreasonable message.
>>
>>           node_set(node, numa_nodes_parsed);
>>
>>         pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
>>                 node, pxm,
>>                 (unsigned long long) start, (unsigned long long) end - 1,
>>                 hotpluggable ? " hotplug" : "",
>>                 ma->flags & ACPI_SRAT_MEM_NON_VOLATILE ? " non-volatile" : "");
>>
>>         /* Mark hotplug range in memblock. */
>>         if (hotpluggable && memblock_mark_hotplug(start, ma->length))
>>                 pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
>>                         (unsigned long long)start, (unsigned long long)end - 1);
>>
>>         max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
>>
>>         return 0;
>> out_err_bad_srat:
>>         bad_srat();
>>
>>  In addition.  Arm64  will double set node to numa_nodes_parsed after add a memblk
>> successfully.  Because numa_add_memblk will perform node_set(*, *).
>>
>>          if (numa_add_memblk(node, start, end) < 0) {
>>                 pr_err("SRAT: Failed to add memblk to node %u [mem %#010Lx-%#010Lx]\n",
>>                        node, (unsigned long long) start,
>>                        (unsigned long long) end - 1);
>>                 goto out_err_bad_srat;
>>         }
>>
>>         node_set(node, numa_nodes_parsed);
> I am sorry but I _do not_ understand how this answers my simple
> question. You are describing the code flow which doesn't really explain
> what is the _user_ or a _runtime_ visible effect. Anybody reading this
> changelog will have to scratch his head to understand what the heck does
> this fix and whether the patch needs to be considered for backporting.
> See my point?
 There  is not any visible effect to the user.  IMO,  it is  a better optimization.
 Maybe I put more words  to explain  how  the patch works.  :-[

 I found the code is messy when reading it without a real issue. 

 Thanks
 zhong jiang
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
