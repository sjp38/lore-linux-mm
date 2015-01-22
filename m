Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EEA956B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:16:25 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x12so2316847wgg.7
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:16:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si6908832wjy.43.2015.01.22.07.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 07:16:24 -0800 (PST)
Message-ID: <54C11444.2020300@suse.cz>
Date: Thu, 22 Jan 2015 16:16:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org> <54BC879C.90505@codeaurora.org> <20150121143920.GD23700@dhcp22.suse.cz>
In-Reply-To: <20150121143920.GD23700@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Vinayak Menon <vinmenon@codeaurora.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On 01/21/2015 03:39 PM, Michal Hocko wrote:
> On Mon 19-01-15 09:57:08, Vinayak Menon wrote:
>> On 01/18/2015 01:18 AM, Christoph Lameter wrote:
>>> On Sat, 17 Jan 2015, Vinayak Menon wrote:
>>>
>>>> which had not updated the vmstat_diff. This CPU was in idle for around 30
>>>> secs. When I looked at the tvec base for this CPU, the timer associated with
>>>> vmstat_update had its expiry time less than current jiffies. This timer had
>>>> its deferrable flag set, and was tied to the next non-deferrable timer in the
>>>
>>> We can remove the deferrrable flag now since the vmstat threads are only
>>> activated as necessary with the recent changes. Looks like this could fix
>>> your issue?
>>>
>>
>> Yes, this should fix my issue.
>
> Does it? Because I would prefer not getting into un-synced state much
> more than playing around one specific place which shows the problems
> right now.
>
>> But I think we may need the fix in too_many_isolated, since there can still
>> be a delay of few seconds (HZ by default and even more because of reasons
>> pointed out by Michal) which will result in reclaimers unnecessarily
>> entering congestion_wait. No ?
>
> I think we can solve this as well. We can stick vmstat_shepherd into a
> kernel thread with a loop with the configured timeout and then create a
> mask of CPUs which need the update and run vmstat_update from
> IPI context (smp_call_function_many).
> We would have to drop cond_resched from refresh_cpu_vm_stats of
> course. The nr_zones x NR_VM_ZONE_STAT_ITEMS in the IPI context
> shouldn't be excessive but I haven't measured that so I might be easily
> wrong.
>
> Anyway, that should work more reliably than the current scheme and
> should help to reduce pointless wakeups which the original patchset was
> addressing.  Or am I missing something?

Maybe to further reduce wakeups, a CPU could check and update its 
counters before going idle? (unless that already happens)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
