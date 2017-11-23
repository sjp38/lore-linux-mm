Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D02AE6B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:43:25 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id q192so5410583itc.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:43:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m62si6243003ith.36.2017.11.23.05.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 05:43:24 -0800 (PST)
Subject: Re: [PATCH] Add slowpath enter/exit trace events
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <640b7de7-c216-de34-18e8-dc1aacd19f35@I-love.SAKURA.ne.jp>
Date: Thu, 23 Nov 2017 22:43:03 +0900
MIME-Version: 1.0
In-Reply-To: <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: peter.enderborg@sony.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On 2017/11/23 22:36, Mel Gorman wrote:
> On Thu, Nov 23, 2017 at 01:25:30PM +0100, Michal Hocko wrote:
>> On Thu 23-11-17 11:43:36, peter.enderborg@sony.com wrote:
>>> From: Peter Enderborg <peter.enderborg@sony.com>
>>>
>>> The warning of slow allocation has been removed, this is
>>> a other way to fetch that information. But you need
>>> to enable the trace. The exit function also returns
>>> information about the number of retries, how long
>>> it was stalled and failure reason if that happened.
>>
>> I think this is just too excessive. We already have a tracepoint for the
>> allocation exit. All we need is an entry to have a base to compare with.
>> Another usecase would be to measure allocation latency. Information you
>> are adding can be (partially) covered by existing tracepoints.
>>
> 
> You can gather that by simply adding a probe to __alloc_pages_slowpath
> (like what perf probe does) and matching the trigger with the existing
> mm_page_alloc points. This is a bit approximate because you would need
> to filter mm_page_alloc hits that do not have a corresponding hit with
> __alloc_pages_slowpath but that is easy.
> 
> With that probe, it's trivial to use systemtap to track the latencies between
> those points on a per-processes basis and then only do a dump_stack from
> systemtap for the ones that are above a particular threshold. This can all
> be done without introducing state-tracking code into the page allocator
> that is active regardless of whether the tracepoint is in use. It also
> has the benefit of working with many older kernels.

Please see my attempt at
http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
Printing just current thread is not sufficient for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
