Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB266B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 08:48:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v9so3269654oif.15
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 05:48:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h15si1632828otd.302.2017.10.26.05.48.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 05:48:01 -0700 (PDT)
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
References: <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
 <20171025181106.GA14967@cmpxchg.org>
 <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz>
 <20171025211359.GA17899@cmpxchg.org>
 <xr931slqdery.fsf@gthelen.svl.corp.google.com>
 <20171026074958.tmtxkyymmsqtgr7w@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <37dfc087-200f-cc8c-b317-bd9c228636d5@I-love.SAKURA.ne.jp>
Date: Thu, 26 Oct 2017 21:45:56 +0900
MIME-Version: 1.0
In-Reply-To: <20171026074958.tmtxkyymmsqtgr7w@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 2017/10/26 16:49, Michal Hocko wrote:
> On Wed 25-10-17 15:49:21, Greg Thelen wrote:
>> Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>>> On Wed, Oct 25, 2017 at 09:00:57PM +0200, Michal Hocko wrote:
> [...]
>>>> So just to make it clear you would be OK with the retry on successful
>>>> OOM killer invocation and force charge on oom failure, right?
>>>
>>> Yeah, that sounds reasonable to me.
>>
>> Assuming we're talking about retrying within try_charge(), then there's
>> a detail to iron out...
>>
>> If there is a pending oom victim blocked on a lock held by try_charge() caller
>> (the "#2 Locks" case), then I think repeated calls to out_of_memory() will
>> return true until the victim either gets MMF_OOM_SKIP or disappears.
> 
> true. And oom_reaper guarantees that MMF_OOM_SKIP gets set in the finit
> amount of time.

Just a confirmation. You are talking about kmemcg, aren't you? And kmemcg
depends on CONFIG_MMU=y, doesn't it? If no, there is no such guarantee.

> 
>> So a force
>> charge fallback might be a needed even with oom killer successful invocations.
>> Or we'll need to teach out_of_memory() to return three values (e.g. NO_VICTIM,
>> NEW_VICTIM, PENDING_VICTIM) and try_charge() can loop on NEW_VICTIM.
> 
> No we, really want to wait for the oom victim to do its job. The only
> thing we should be worried about is when out_of_memory doesn't invoke
> the reaper. There is only one case like that AFAIK - GFP_NOFS request. I
> have to think about this case some more. We currently fail in that case
> the request.
> 

Do we really need to apply

	/*
	 * The OOM killer does not compensate for IO-less reclaim.
	 * pagefault_out_of_memory lost its gfp context so we have to
	 * make sure exclude 0 mask - all other users should have at least
	 * ___GFP_DIRECT_RECLAIM to get here.
	 */
	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
		return true;

unconditionally?

We can encourage !__GFP_FS allocations to use __GFP_NORETRY or
__GFP_RETRY_MAYFAIL if their allocations are not important.
Then, only important !__GFP_FS allocations will be checked here.
I think that we can allow such important allocations to invoke the OOM
killer (i.e. remove this check) because situation is already hopeless
if important !__GFP_FS allocations cannot make progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
