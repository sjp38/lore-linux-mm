Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23E9C6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 21:57:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so214767961pfa.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 18:57:39 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id r81si33045066pfg.157.2016.10.17.18.57.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 18:57:38 -0700 (PDT)
Message-ID: <580580AE.6070200@huawei.com>
Date: Tue, 18 Oct 2016 09:53:50 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] z3fold: fix the potential encode bug in encod_handle
References: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com> <5804305F.4030302@huawei.com> <CAMJBoFMcnH3ZPQpG=oAjD=K64O7MX_BdFvHvccvgCV4nFSfxXA@mail.gmail.com> <5804C88F.7040000@huawei.com> <CALZtONC8frCrF_v1bm_+HePfLMypL7Z6DNJor8Z6NCMzeG5ERQ@mail.gmail.com>
In-Reply-To: <CALZtONC8frCrF_v1bm_+HePfLMypL7Z6DNJor8Z6NCMzeG5ERQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil
 Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 2016/10/17 23:30, Dan Streetman wrote:
> On Mon, Oct 17, 2016 at 8:48 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>> On 2016/10/17 20:03, Vitaly Wool wrote:
>>> Hi Zhong Jiang,
>>>
>>> On Mon, Oct 17, 2016 at 3:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>>>> Hi,  Vitaly
>>>>
>>>> About the following patch,  is it right?
>>>>
>>>> Thanks
>>>> zhongjiang
>>>> On 2016/10/13 12:02, zhongjiang wrote:
>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>
>>>>> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
>>>>> in encode_handle, it will lead to the the caller handle_to_buddy
>>>>> return the error value.
>>>>>
>>>>> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
>>>>> it will be consistent with handle_to_z3fold_header. At the same time,
>>>>> change the BUDDY_MASK to PAGE_MASK in handle_to_buddy is better.
>>> are you seeing problems with the existing code? first_num should wrap around
>>> BUDDY_MASK and this should be ok because it is way bigger than the number
>>> of buddies.
>>>
>>> ~vitaly
>>>
>>> .
>>>
>>  first_num plus buddies can exceed the BUDDY_MASK. is it right?
> yes.
>
>>  (first_num + buddies) & BUDDY_MASK may be a smaller value than first_num.
> yes, but that doesn't matter; the value stored in the handle is never
> accessed directly.
>
>>   but (handle - zhdr->first_num) & BUDDY_MASK will return incorrect value
>>   in handle_to_buddy.
> the subtraction and masking will result in the correct buddy number,
> even if (handle & BUDDY_MASK) < zhdr->first_num.
 yes, I see. it is hard to read.
> However, I agree it's nonobvious, and tying the first_num size to
> NCHUNKS_ORDER is confusing - the number of chunks is completely
> unrelated to the number of buddies.
 yes. indeed.
> Possibly a better way to handle first_num is to limit it to the order
> of enum buddy to the actual range of possible buddy indexes, which is
> 0x3, i.e.:
>
> #define BUDDY_MASK      (0x3)
>
> and
>
>        unsigned short first_num:2;
>
> with that and a small bit of explanation in the encode_handle or
> handle_to_buddy comments, it should be clear how the first_num and
> buddy numbering work, including that overflow/underflow are ok (due to
> the masking)...
 yes, It is better and clearer. Thanks for your relpy and advice. I will
 resend the patch.
>>   Thanks
>>   zhongjiang
>>
>>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
