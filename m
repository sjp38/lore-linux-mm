Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCDD6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 05:32:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r187so89121743pfr.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 02:32:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z62si4408718pgd.107.2017.08.07.02.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 02:32:48 -0700 (PDT)
Message-ID: <59883464.700@intel.com>
Date: Mon, 07 Aug 2017 17:35:32 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com> <9ac31505-0996-2822-752e-8ec055373aa0@redhat.com>
In-Reply-To: <9ac31505-0996-2822-752e-8ec055373aa0@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mhocko@kernel.org, mst@redhat.com, zhenwei.pi@youruncloud.com
Cc: dave.hansen@intel.com, akpm@linux-foundation.org, mawilcox@microsoft.com, Andrea Arcangeli <aarcange@redhat.com>

On 08/07/2017 04:44 PM, David Hildenbrand wrote:
> On 03.08.2017 13:59, Wei Wang wrote:
>> This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
>> enqueue zero page to balloon device")'
>>
>> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
>> shouldn't be given to the host ksmd to scan. Therefore, it is not
>> necessary to zero ballooned pages, which is very time consuming when
>> the page amount is large. The ongoing fast balloon tests show that the
>> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
>> __GFP_ZERO added. So, this patch removes the flag.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>   mm/balloon_compaction.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index 9075aa5..b06d9fe 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -24,7 +24,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
>>   {
>>   	unsigned long flags;
>>   	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
>> -				__GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_ZERO);
>> +				       __GFP_NOMEMALLOC | __GFP_NORETRY);
>>   	if (!page)
>>   		return NULL;
>>   
>>
> Your assumption here is, that the hypervisor will always supply a zero
> page. Unfortunately, this assumption is wrong (and it stems from the
> lack of different page size support in virtio-balloon).

I think this would be something that we can improve the balloon.

For example, the balloon request from the device should be aligned
to the host page size before sending to the guest driver:
On PPC, if the command requests for 140K memory to inflate, it can
be aligned to 128K.


>
> Think about these examples:
>
> 1. Guest is backed by huge pages (hugetbfs). Ballooning kicks in.
>
> MADV_DONTNEED is simply ignored in the hypervisor (hugetlbfs requires
> fallocate punshhole). Also, trying to zap 4k on e.g. 1MB pages will
> simply be ignored.

For the hugetlbfs case, I think the balloon size can be aligned to
the huge page size (i.e 2M or 1GB).


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
