Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8916B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:03:26 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v25so12337404pfg.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 00:03:26 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id az5si8857965plb.16.2017.12.18.00.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 00:03:25 -0800 (PST)
Message-ID: <5A3776C8.1040801@intel.com>
Date: Mon, 18 Dec 2017 16:05:28 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
References: <5A34F193.5040700@intel.com>	<201712162028.FEB87079.FOJFMQHVOSLtFO@I-love.SAKURA.ne.jp>	<5A35FF89.8040500@intel.com>	<201712171921.IBB30790.VOOOFMQHFSLFJt@I-love.SAKURA.ne.jp>	<286AC319A985734F985F78AFA26841F739387B68@shsmsx102.ccr.corp.intel.com> <201712180016.GHD34301.MQOLOFFJHOVFtS@I-love.SAKURA.ne.jp>
In-Reply-To: <201712180016.GHD34301.MQOLOFFJHOVFtS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/17/2017 11:16 PM, Tetsuo Handa wrote:
> Wang, Wei W wrote:
>>> Wei Wang wrote:
>>>>> But passing GFP_NOWAIT means that we can handle allocation failure.
>>>>> There is no need to use preload approach when we can handle allocation failure.
>>>> I think the reason we need xb_preload is because radix tree insertion
>>>> needs the memory being preallocated already (it couldn't suffer from
>>>> memory failure during the process of inserting, probably because
>>>> handling the failure there isn't easy, Matthew may know the backstory
>>>> of
>>>> this)
>>> According to https://lwn.net/Articles/175432/ , I think that preloading is
>>> needed only when failure to insert an item into a radix tree is a significant
>>> problem.
>>> That is, when failure to insert an item into a radix tree is not a problem, I
>>> think that we don't need to use preloading.
>> It also mentions that the preload attempts to allocate sufficient memory to *guarantee* that the next radix tree insertion cannot fail.
>>
>> If we check radix_tree_node_alloc(), the comments there says "this assumes that the caller has performed appropriate preallocation".
> If you read what radix_tree_node_alloc() is doing, you will find that
> radix_tree_node_alloc() returns NULL when memory allocation failed.
>
> I think that "this assumes that the caller has performed appropriate preallocation"
> means "The caller has to perform appropriate preallocation if the caller does not
> want radix_tree_node_alloc() to return NULL".

For the radix tree, I agree that we may not need preload. But 
ida_bitmap, which the xbitmap is based on, is allocated via preload, so 
I think we cannot bypass preload, otherwise, we get no ida_bitmap to use.

Best,
Wei




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
