Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53DD26B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 17:52:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r83so15188602pfj.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:52:59 -0700 (PDT)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTPS id h13si4778021plk.269.2017.09.25.14.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 14:52:58 -0700 (PDT)
Subject: Re: [PATCH 0/2 v4] oom: capture unreclaimable slab info in oom
 message when kernel panic
References: <1505947132-4363-1-git-send-email-yang.s@alibaba-inc.com>
 <20170925142352.havlx6ikheanqyhj@dhcp22.suse.cz>
 <e773cd57-8df6-ee6e-d051-857b8f354a0a@alibaba-inc.com>
 <20170925203235.vhhiqxp72v67n76l@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <2a50d51e-1a36-aa44-3ee6-cb78ac9c7715@alibaba-inc.com>
Date: Tue, 26 Sep 2017 05:52:50 +0800
MIME-Version: 1.0
In-Reply-To: <20170925203235.vhhiqxp72v67n76l@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/25/17 1:32 PM, Michal Hocko wrote:
> On Mon 25-09-17 23:55:19, Yang Shi wrote:
>>
>>
>> On 9/25/17 7:23 AM, Michal Hocko wrote:
>>> On Thu 21-09-17 06:38:50, Yang Shi wrote:
>>>> Recently we ran into a oom issue, kernel panic due to no killable process.
>>>> The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.
>>>>
>>>> So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
>>>> Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.
>>>>
>>>> With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.
>>>>
>>>> And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.
>>>
>>> Well, I do undestand that this _might_ be useful but it also might
>>> generates a _lot_ of output. The oom report can be quite verbose already
>>> so is this something we want to have enabled by default?
>>
>> The uneclaimable slub message will be just printed out when kernel panic (no
>> killable process or panic_on_oom is set). So, it will not bother normal oom.
>> Since kernel is already panic, so it might be preferred to have more
>> information reported.
> 
> Well, this certainly depends. If you have a limited console output (e.g.
> no serial console) then the additional information can easily scroll the
> potentially much more useful information from the early oom report. We
> already do have a control to enable/disable tasks dumping which can be
> very long as well.
>   
>> We definitely can add a proc knob to control it if we want to disable the
>> message even if when kernel panic.
> 
> Well, I do not have a strong opinion on this. I can see cases where this
> kind of information would be useful but most OOM reports I have seen
> were simply user space pinned memory. Slab memory leaks are seen very
> seldom. Do you think a pr_dbg and slab stats for all ooms would be still
> useful?

It might be. But, we can use slabinfo to get all slab stats in non-panic 
oom case, patch 1/2 (tools: slabinfo: add "-U" option to show 
unreclaimable slabs only) should be used to cover this case.

Maybe we can set a unreclaimable slab/total mem ratio. For example, when 
unreclaimable slab size >= 50% total memory size, then we print out slab 
stats in oom? And, the ratio might be adjustable in /proc.

Or just replace pr_info to pr_debug. Once oom happens, if there are a 
lot unreclaimable slabs consumed, we can just enable the debug info then 
try to reproduce.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
