Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBA526B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:36:57 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j18so37140090ioe.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:36:57 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id k185si11499901itb.12.2017.01.26.01.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 01:36:57 -0800 (PST)
Message-ID: <5889C331.7020101@iogearbox.net>
Date: Thu, 26 Jan 2017 10:36:49 +0100
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6 v3] kvmalloc
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com> <588907AA.1020704@iogearbox.net> <20170126074354.GB8456@dhcp22.suse.cz>
In-Reply-To: <20170126074354.GB8456@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On 01/26/2017 08:43 AM, Michal Hocko wrote:
> On Wed 25-01-17 21:16:42, Daniel Borkmann wrote:
>> On 01/25/2017 07:14 PM, Alexei Starovoitov wrote:
>>> On Wed, Jan 25, 2017 at 5:21 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>>> On Wed 25-01-17 14:10:06, Michal Hocko wrote:
>>>>> On Tue 24-01-17 11:17:21, Alexei Starovoitov wrote:
>> [...]
>>>>>>> Are there any more comments? I would really appreciate to hear from
>>>>>>> networking folks before I resubmit the series.
>>>>>>
>>>>>> while this patchset was baking the bpf side switched to use bpf_map_area_alloc()
>>>>>> which fixes the issue with missing __GFP_NORETRY that we had to fix quickly.
>>>>>> See commit d407bd25a204 ("bpf: don't trigger OOM killer under pressure with map alloc")
>>>>>> it covers all kmalloc/vmalloc pairs instead of just one place as in this set.
>>>>>> So please rebase and switch bpf_map_area_alloc() to use kvmalloc().
>>>>>
>>>>> OK, will do. Thanks for the heads up.
>>>>
>>>> Just for the record, I will fold the following into the patch 1
>>>> ---
>>>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>>>> index 19b6129eab23..8697f43cf93c 100644
>>>> --- a/kernel/bpf/syscall.c
>>>> +++ b/kernel/bpf/syscall.c
>>>> @@ -53,21 +53,7 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
>>>>
>>>>    void *bpf_map_area_alloc(size_t size)
>>>>    {
>>>> -       /* We definitely need __GFP_NORETRY, so OOM killer doesn't
>>>> -        * trigger under memory pressure as we really just want to
>>>> -        * fail instead.
>>>> -        */
>>>> -       const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
>>>> -       void *area;
>>>> -
>>>> -       if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
>>>> -               area = kmalloc(size, GFP_USER | flags);
>>>> -               if (area != NULL)
>>>> -                       return area;
>>>> -       }
>>>> -
>>>> -       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
>>>> -                        PAGE_KERNEL);
>>>> +       return kvzalloc(size, GFP_USER);
>>>>    }
>>>>
>>>>    void bpf_map_area_free(void *area)
>>>
>>> Looks fine by me.
>>> Daniel, thoughts?
>>
>> I assume that kvzalloc() is still the same from [1], right? If so, then
>> it would unfortunately (partially) reintroduce the issue that was fixed.
>> If you look above at flags, they're also passed to __vmalloc() to not
>> trigger OOM in these situations I've experienced.
>
> Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
> think it would. It can still trigger the OOM killer becauset the flags
> are no propagated all the way down to all allocations requests (e.g.
> page tables). This is the same reason why GFP_NOFS is not supported in
> vmalloc.

Ok, good to know, is that somewhere clearly documented (like for the
case with kmalloc())? If not, could we do that for non-mm folks, or
at least add a similar WARN_ON_ONCE() as you did for kvmalloc() to make
it obvious to users that a given flag combination is not supported all
the way down?

>> This is effectively the
>> same requirement as in other networking areas f.e. that 5bad87348c70
>> ("netfilter: x_tables: avoid warn and OOM killer on vmalloc call") has.
>> In your comment in kvzalloc() you eventually say that some of the above
>> modifiers are not supported. So there would be two options, i) just leave
>> out the kvzalloc() chunk for BPF area to avoid the merge conflict and tackle
>> it later (along with similar code from 5bad87348c70), or ii) implement
>> support for these modifiers as well to your original set. I guess it's not
>> too urgent, so we could also proceed with i) if that is easier for you to
>> proceed (I don't mind either way).
>
> Could you clarify why the oom killer in vmalloc matters actually?

For both mentioned commits, (privileged) user space can potentially
create large allocation requests, where we thus switch to vmalloc()
flavor eventually and then OOM starts killing processes to try to
satisfy the allocation request. This is bad, because we want the
request to just fail instead as it's non-critical and f.e. not kill
ssh connection et al. Failing is totally fine in this case, whereas
triggering OOM is not. In my testing, __GFP_NORETRY did satisfy this
just fine, but as you say it seems it's not enough. Given there are
multiple places like these in the kernel, could we instead add an
option such as __GFP_NOOOM, or just make __GFP_NORETRY supported?

Thanks,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
