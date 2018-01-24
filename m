Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFA9800DD
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:06:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 205so2602849pfw.4
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 01:06:04 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 99-v6si5868170plc.368.2018.01.24.01.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 01:06:03 -0800 (PST)
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
 <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
 <20180123160509.GT1526@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <218a11e6-766c-d8f6-a266-cbd0852de1c8@codeaurora.org>
Date: Wed, 24 Jan 2018 14:35:54 +0530
MIME-Version: 1.0
In-Reply-To: <20180123160509.GT1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz


On 1/23/2018 9:35 PM, Michal Hocko wrote:
> On Tue 23-01-18 21:08:36, Vinayak Menon wrote:
>>
>> On 1/23/2018 8:25 PM, Michal Hocko wrote:
>>> [Please cc linux-api when proposing user interface]
>>>
>>> On Mon 22-01-18 11:10:14, Vinayak Menon wrote:
>>>> Based on Kirill's patch [1].
>>>>
>>>> Currently, faultaround code produces young pte.  This can screw up
>>>> vmscan behaviour[2], as it makes vmscan think that these pages are hot
>>>> and not push them out on first round.
>>>>
>>>> During sparse file access faultaround gets more pages mapped and all of
>>>> them are young. Under memory pressure, this makes vmscan swap out anon
>>>> pages instead, or to drop other page cache pages which otherwise stay
>>>> resident.
>>>>
>>>> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
>>>> is set, so they can easily be reclaimed under memory pressure.
>>>>
>>>> This can to some extend defeat the purpose of faultaround on machines
>>>> without hardware accessed bit as it will not help us with reducing the
>>>> number of minor page faults.
>>> So we just want to add a knob to cripple the feature? Isn't it better to
>>> simply disable it than to have two distinct implementation which is
>>> rather non-intuitive and I would bet that most users will be clueless
>>> about how to set it or when to touch it at all. So we will end up with
>>> random cargo cult hints all over internet giving you your performance
>>> back...
>>
>> If you are talking about non-HW access bit systems, then yes it would be better to disable faultaround
>> when want_old_faultaround_pte is set to 1, like MInchan did here https://patchwork.kernel.org/patch/9115901/
>> I can submit a patch for that.
>>
>>> I really dislike this new interface. If the fault around doesn't work
>>> for you then disable it.
>>
>> Faultaround works well for me on systems with HW access bit. But
>> the benefit is reduced because of making the faultaround ptes young
>> [2]. Ideally they should be old as they are speculatively mapped and
>> not really accessed. But because of issues on certain architectures
>> they need to be made young[3][4]. This patch is trying to help the
>> other architectures which can tolerate old ptes, by fixing the vmscan
>> behaviour. And this is not a theoretical problem that I am trying to
>> fix. We have really seen the benefit of faultaround on arm mobile
>> targets, but the problem is the vmscan behaviour due to the young
>> pte workaround. And this patch helps in fixing that.  Do you think
>> something more needs to be added in the documentation to make things
>> more clear on the flag usage ?
> No, I would either prefer auto-tuning or document that fault around
> can lead to this behavior and recommend to disable it rather than add a
> new knob.


One of the objectives of making it a sysctl was to let user space tune it based on vmpressure [5]. But I am not
sure how effective it would be. The vmpressure increase itself can be because of making faultaround ptes
young [6] and it could be difficult to find a heuristic to enable/disable faultaround. And with the way vmpressure
works, it can happen that vmpressure values don't indicate exact vmscan behavior always. Same is the case with
auto-tuning based on vmpressure. Any other suggestions on how auto tuning can be implemented ?

Could you elaborate a bit on why you think sysctl is not a good option ? Is it because of the difficulty for the
user to figure out how and when to use the interface ? If the document clearly explains what the knob is, wouldn't
be easy for the user to just try the knob and see if his workload benefits or not. It's not just non-x86 devices that can
benefit. There may be x86 workloads where the vmscan behavior masks the benefit of avoiding micro faults.

Or if you think sysctl is not the right place for such knobs, do you think it should be an expert level config option or a
kernel command line param ?
Since there are lots of mobile and embedded devices that can get the full benefits of faultaround with such an option,
I really don't think it is a good option to just document the problem and disable faultaround on those devices.

[5] https://www.spinics.net/lists/arm-kernel/msg622070.html
[6] https://lkml.org/lkml/2016/5/9/134

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
