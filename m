Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 96FE96B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:01:37 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so7879795ieb.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 00:01:37 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id h38si70541ioi.92.2015.04.14.00.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 00:01:36 -0700 (PDT)
Message-ID: <552CBB49.5000308@codeaurora.org>
Date: Tue, 14 Apr 2015 12:31:29 +0530
From: Susheel Khiani <skhiani@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Question] ksm: rmap_item pointing to some stale vmas
References: <55268741.8010301@codeaurora.org> <alpine.LSU.2.11.1504101047200.28925@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1504101047200.28925@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/10/15 23:26, Hugh Dickins wrote:
> On Thu, 9 Apr 2015, Susheel Khiani wrote:
>
>> Hi,
>>
>> We are seeing an issue during try_to_unmap_ksm where in call to
>> try_to_unmap_one is failing.
>>
>> try_to_unmap_ksm in this particular case is trying to go through vmas
>> associated with each rmap_item->anon_vma. What we see is this that the
>> corresponding page is not mapped to any of the vmas associated with 2
>> rmap_item.
>>
>> The associated rmap_item in this case looks like pointing to some valid vma
>> but the said page is not found to be mapped under it. try_to_unmap_one thus
>> fails to find valid ptes for these vmas.
>>
>> At the same time we can see that the page actually is mapped in 2 separate
>> and different vmas which are not part of rmap_item associated with page.
>>
>> So whether rmap_item is pointing to some stale vmas and now the mapping has
>> changed? Or there is something else going on here.
>> p
>> Any pointer would be appreciated.
>
> I expected to be able to argue this away, but no: I think you've found
> a bug, and I think I get it too.  I have no idea what's wrong at this
> point, will set aside some time to investigate, and report back.
>
> Which kernel are you using?  try_to_unmap_ksm says v3.13 or earlier.
> Probably doesn't affect the bug, but may affect the patch you'll need.
>
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

We are using kernel-3.10.49 and I have gone through patches of ksm above 
this kernel version but didn't find anything relevant w.r.t issue. The 
latest patch which we have for KSM on our tree is

668f9abb: mm: close PageTail race

The issue otherwise is difficult to reproduce and is appearing after 
days of testing on 512MB Android platform. What I am not able to figure 
out is which code path in ksm could actually land us in situation where 
in stable_node we still have stale rmap_items with old vmas which are 
now unmapped.

In the dumps we can see the new vmas mapping to the page but the new 
rmap_items with these new vmas which maps the page are still not updated 
in stable_node.


-- 
Susheel Khiani QUALCOMM INDIA, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
