Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF4516B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 09:35:28 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y200so7413493itc.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 06:35:28 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h79si3697443ioi.96.2017.12.07.06.35.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 06:35:27 -0800 (PST)
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
References: <20171206192026.25133-1-surenb@google.com>
 <20171207083436.GC20234@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <aea5a298-c1a8-3967-099e-91d6bd894b29@I-love.SAKURA.ne.jp>
Date: Thu, 7 Dec 2017 23:34:53 +0900
MIME-Version: 1.0
In-Reply-To: <20171207083436.GC20234@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On 2017/12/07 17:34, Michal Hocko wrote:
> On Wed 06-12-17 11:20:26, Suren Baghdasaryan wrote:
>> Slab shrinkers can be quite time consuming and when signal
>> is pending they can delay handling of the signal. If fatal
>> signal is pending there is no point in shrinking that process
>> since it will be killed anyway. This change checks for pending
>> fatal signals inside shrink_slab loop and if one is detected
>> terminates this loop early.
> 
> This is not enough. You would have to make sure the direct reclaim will
> bail out immeditally which is not at all that simple. We do check fatal
> signals in throttle_direct_reclaim and conditionally in shrink_inactive_list
> so even if you bail out from shrinkers we could still finish the full
> reclaim cycle.
> 
> Besides that shrinkers shouldn't really take very long so this looks
> like it papers over a real bug somewhere else. I am not saying the patch
> is wrong but it would deserve much more details to judge wether this is
> the right way to go for your particular problem.
> 

I wish that normal threads do not invoke direct reclaim operation.
Only dedicated kernel threads (such as filesystem's writeback) invoke
direct reclaim operation. Then, we can implement __GFP_KILLABLE for
normal threads, and hopefully get rid of distinction between GFP_NOIO/
GFP_NOFS/GFP_KERNEL because reclaim (and locking) dependency becomes
simpler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
