Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91BE76B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:00:23 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id at7so24831194obd.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:00:23 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 6si1910794otu.32.2016.06.22.04.00.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 04:00:22 -0700 (PDT)
Subject: Re: [PATCH v2] more mapcount page as kpage could reduce total
 replacement times than fewer mapcount one in probability.
References: <1465955818-101898-1-git-send-email-zhouxianrong@huawei.com>
 <2460b794-92f0-d115-c729-bcfe33663e48@huawei.com>
 <alpine.LSU.2.11.1606211807330.6589@eggly.anvils>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <465acd72-557b-d079-a38b-2d06dc31cbe2@huawei.com>
Date: Wed, 22 Jun 2016 19:00:02 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1606211807330.6589@eggly.anvils>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com

hey hugh:
	thank you for your reply and supplied more information.
i spent lots of time to study your questions mentioned.
i state my idea in detail, for exmple,
page1 with map count 7 and page2 with map count 9 are equal.
choosing page1 for ksm page will do 9 times heavily merg and 6 times lightly merg
choosing page2 for ksm page will do 7 times heavily merg and 8 times lightly merg
so choose page1 for ksm page.

the modification that swapping them around underneath try_to_merge_two_pages still has problem.
i am not going to modify the patch but i hope you would consider the idea later.

i have watched the problem about unmapping the more mapcount ksm page.
another case is that, for a more mapcount ksm page, not all of the forked page has been lightly merg
only with a rmap_item in diffrent mm and vma for now, so we can not find all the forked vmas via reverse map,
in which case we can not unmap the ksm page completely. so such ksm page could not be reclaimed or migrated.


i think the page being mapped also into non-VM_MERGEABLE areas due to MADV_MERGEABLE would meet same problem mentioned above.
that is we can not find all the forked vmas via reverse map.

is this a problem ? do you think about this ?



On 2016/6/22 9:39, Hugh Dickins wrote:
> On Tue, 21 Jun 2016, zhouxianrong wrote:
>
>> hey hugh:
>>     could you please give me some suggestion about this ?
>
> I must ask you to be more patient: everyone would like me to be
> quicker, but I cannot; and this does not appear to be urgent.
>
> Your idea makes sense to me; but if your patch seems obvious to you,
> sorry, it isn't obvious to me.  The two pages are not symmetrical,
> the caller of try_to_merge_two_pages() thinks it knows which is which,
> swapping them around underneath it like this is not obviously correct.
>
> Your patch may be fine, but I've not had time to think it through:
> will do, but not immediately.
>
> Your idea may not make so much sense to Andrea: he has been troubled
> by the difficulty in unmapping a KSM page with a very high mapcount.
>
> And you would be maximizing a buggy case, if we think of that page
> being mapped also into non-VM_MERGEABLE areas; but I think we can
> ignore that aspect, it's buggy already, and I don't think anyone
> really cares deeply about madvise(,,MADV_UNMERGEABLE) correctness
> on forked areas.  KSM was not originally written with fork in mind.
>
> I have never seen such a long title for a patch: maybe
> "[PATCH] ksm: choose the more mapped for the KSM page".
>
>>
>> On 2016/6/15 9:56, zhouxianrong@huawei.com wrote:
>>> From: z00281421 <z00281421@notesmail.huawei.com>
>>>
>>> more mapcount page as kpage could reduce total replacement times
>>> than fewer mapcount one when ksmd scan and replace among
>>> forked pages later.
>>>
>>> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
>
> And I doubt that z00281421 is your real name:
> see Documentation/SubmittingPatches.
>
> Hugh
>
>>> ---
>>>  mm/ksm.c |    8 ++++++++
>>>  1 file changed, 8 insertions(+)
>>>
>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>> index 4786b41..4d530af 100644
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -1094,6 +1094,14 @@ static struct page *try_to_merge_two_pages(struct
>>> rmap_item *rmap_item,
>>>  {
>>>  	int err;
>>>
>>> +	/*
>>> +	 * select more mapcount page as kpage
>>> +	 */
>>> +	if (page_mapcount(page) < page_mapcount(tree_page)) {
>>> +		swap(page, tree_page);
>>> +		swap(rmap_item, tree_rmap_item);
>>> +	}
>>> +
>>>  	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
>>>  	if (!err) {
>>>  		err = try_to_merge_with_ksm_page(tree_rmap_item,
>>>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
