Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 774C2280244
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:38:44 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id v31so470965otb.1
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:38:44 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g21si999989oic.271.2018.01.23.07.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 07:38:43 -0800 (PST)
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
Date: Tue, 23 Jan 2018 21:08:36 +0530
MIME-Version: 1.0
In-Reply-To: <20180123145506.GN1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz



On 1/23/2018 8:25 PM, Michal Hocko wrote:
> [Please cc linux-api when proposing user interface]
>
> On Mon 22-01-18 11:10:14, Vinayak Menon wrote:
>> Based on Kirill's patch [1].
>>
>> Currently, faultaround code produces young pte.  This can screw up
>> vmscan behaviour[2], as it makes vmscan think that these pages are hot
>> and not push them out on first round.
>>
>> During sparse file access faultaround gets more pages mapped and all of
>> them are young. Under memory pressure, this makes vmscan swap out anon
>> pages instead, or to drop other page cache pages which otherwise stay
>> resident.
>>
>> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
>> is set, so they can easily be reclaimed under memory pressure.
>>
>> This can to some extend defeat the purpose of faultaround on machines
>> without hardware accessed bit as it will not help us with reducing the
>> number of minor page faults.
> So we just want to add a knob to cripple the feature? Isn't it better to
> simply disable it than to have two distinct implementation which is
> rather non-intuitive and I would bet that most users will be clueless
> about how to set it or when to touch it at all. So we will end up with
> random cargo cult hints all over internet giving you your performance
> back...


If you are talking about non-HW access bit systems, then yes it would be better to disable faultaround
when want_old_faultaround_pte is set to 1, like MInchan did here https://patchwork.kernel.org/patch/9115901/
I can submit a patch for that.

> I really dislike this new interface. If the fault around doesn't work
> for you then disable it.


Faultaround works well for me on systems with HW access bit. But the benefit is reduced because of making the
faultaround ptes young [2]. Ideally they should be old as they are speculatively mapped and not really
accessed. But because of issues on certain architectures they need to be made young[3][4]. This patch is trying to
help the other architectures which can tolerate old ptes, by fixing the vmscan behaviour. And this is not a
theoretical problem that I am trying to fix. We have really seen the benefit of faultaround on arm mobile targets,
but the problem is the vmscan behaviour due to the young pte workaround. And this patch helps in fixing that.
Do you think something more needs to be added in the documentation to make things more clear on the flag usage ?

>
>> Making the faultaround ptes old results in a unixbench regression for some
>> architectures [3][4]. But on some architectures like arm64 it is not found
>> to cause any regression.
>>
>> unixbench shell8 scores on arm64 v8.2 hardware with CONFIG_ARM64_HW_AFDBM
>> enabled  (5 runs min, max, avg):
>> Base: (741,748,744)
>> With this patch: (739,748,743)
>>
>> So by default produce young ptes and provide a sysctl option to make the
>> ptes old.
>>
>> [1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
>> [2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
>> [3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
>> [4] https://marc.info/?l=linux-mm&m=146589376909424&w=2
>>
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
