Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60F066B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 07:44:47 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p144so7327320itc.9
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 04:44:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z8si6386363iob.94.2017.12.09.04.44.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Dec 2017 04:44:46 -0800 (PST)
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
References: <20171208012305.83134-1-surenb@google.com>
 <alpine.DEB.2.10.1712081259520.47087@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <f0f67f05-7efb-0e2a-071c-2ef87530bb79@I-love.SAKURA.ne.jp>
Date: Sat, 9 Dec 2017 21:44:20 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1712081259520.47087@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On 2017/12/09 6:02, David Rientjes wrote:
> On Thu, 7 Dec 2017, Suren Baghdasaryan wrote:
> 
>> Slab shrinkers can be quite time consuming and when signal
>> is pending they can delay handling of the signal. If fatal
>> signal is pending there is no point in shrinking that process
>> since it will be killed anyway. This change checks for pending
>> fatal signals inside shrink_slab loop and if one is detected
>> terminates this loop early.
>>
> 
> I've proposed a similar patch in the past, but for a check on TIF_MEMDIE, 
> which would today be a tsk_is_oom_victim(current), since we had observed 
> lengthy stalls in reclaim that would have been prevented if the oom victim 
> had exited out, returned back to the page allocator, allocated with 
> ALLOC_NO_WATERMARKS, and proceeded to quickly exit.
> 
> I'm not sure that all fatal_signal_pending() tasks should get the same 
> treatment, but I understand the point that the task is killed and should 
> free memory when it fully exits.  How much memory is unknown.
> 
We can use __GFP_KILLABLE. Unless there is performance impact for checking
fatal_siganl_pending(), allowing only fatal_signal_pending() threads with
__GFP_KILLABLE to bail out (without using memory reserves) should be safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
