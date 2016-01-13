Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id D49796B026A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 06:01:17 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so362364895qgf.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:01:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si787083qgf.122.2016.01.13.03.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 03:01:16 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v4 1/2] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
	<1452617777-10598-2-git-send-email-vkuznets@redhat.com>
	<alpine.DEB.2.10.1601121535150.28831@chino.kir.corp.google.com>
Date: Wed, 13 Jan 2016 12:01:09 +0100
In-Reply-To: <alpine.DEB.2.10.1601121535150.28831@chino.kir.corp.google.com>
	(David Rientjes's message of "Tue, 12 Jan 2016 15:46:37 -0800 (PST)")
Message-ID: <87fuy168wa.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

David Rientjes <rientjes@google.com> writes:

> On Tue, 12 Jan 2016, Vitaly Kuznetsov wrote:
>
>> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
>> index ce2cfcf..ceaf40c 100644
>> --- a/Documentation/memory-hotplug.txt
>> +++ b/Documentation/memory-hotplug.txt
>> @@ -254,12 +254,23 @@ If the memory block is online, you'll read "online".
>>  If the memory block is offline, you'll read "offline".
>>  
>>  
>> -5.2. How to online memory
>> +5.2. Memory onlining
>
> Idk why you're changing this title since you didn't change it in the table 
> of contents and it already pairs with "6.2. How to offline memory".
>
> This makes it seem like you're covering all memory onlining operations in 
> the kernel (including xen onlining) rather than just memory onlined by 
> root.  It doesn't cover the fact that xen onlining can be done without 
> automatic onlining, so I would leave this section's title as it is and 
> only cover aspects of memory onlining that users are triggering 
> themselves.

Ok, I changed the title to reflect the fact that a special action to
online memory is not always required any more but as the global policy
stays 'offline' by default for now let's keep the original title.

[skip]

>>  
>> +	/* online pages if requested */
>> +	if (online)
>> +		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>> +			     MMOP_ONLINE_KEEP);
>> +
>>  	goto out;
>>  
>>  error:
>
> Well, shucks, what happens if online_pages() fails, such as if a memory 
> hot-add notifier returns an errno for MEMORY_GOING_ONLINE?  The memory was 
> added but not subsequently onlined, although auto onlining was set, so how 
> does userspace know the state it is in?

Bad ... we could have checked the return value but I don't see a proper
way to handling it here: if we managed to online some blocks we can't
revert back. We'll probably have to online pages block-by-block (e.g. by
utilizing memory_block_change_state()) handling possible failures.

>
>> @@ -1315,7 +1327,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
>>  	if (!res)
>>  		return -EEXIST;
>>  
>> -	ret = add_memory_resource(nid, res);
>> +	ret = add_memory_resource(nid, res, memhp_auto_online);
>>  	if (ret < 0)
>>  		release_memory_resource(res);
>>  	return ret;

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
