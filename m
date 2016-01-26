Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F38A6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:07:56 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so141636817wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:07:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hi5si2920992wjc.236.2016.01.26.09.07.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 09:07:53 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] proposals for topics
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A7A7E8.3060801@suse.cz>
Date: Tue, 26 Jan 2016 18:07:52 +0100
MIME-Version: 1.0
In-Reply-To: <20160125184559.GE29291@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/25/2016 07:45 PM, Johannes Weiner wrote:
>> >- One of the long lasting issue related to the OOM handling is when to
>> >   actually declare OOM. There are workloads which might be trashing on
>> >   few last remaining pagecache pages or on the swap which makes the
>> >   system completely unusable for considerable amount of time yet the
>> >   OOM killer is not invoked. Can we finally do something about that?
> I'm working on this, but it's not an easy situation to detect.
>
> We can't decide based on amount of page cache, as you could have very
> little of it and still be fine. Most of it could still be used-once.
>
> We can't decide based on number or rate of (re)faults, because this
> spikes during startup and workingset changes, or can be even sustained
> when working with a data set that you'd never expect to fit into
> memory in the first place, while still making acceptable progress.

I would hope that workingset should help distinguish workloads thrashing 
due to low memory and those that can't fit there no matter what? Or 
would it require tracking lifetime of so many evicted pages that the 
memory overhead of that would be infeasible?

> The only thing that I could come up with as a meaningful metric here
> is the share of actual walltime that is spent waiting on refetching
> stuff from disk. If we know that in the last X seconds, the whole
> system spent more than idk 95% of its time waiting on the disk to read
> recently evicted data back into the cache, then it's time to kick the
> OOM killer, as this state is likely not worth maintaining.
>
> Such a "thrashing time" metric could be great to export to userspace
> in general as it can be useful in other situations, such as quickly
> gauging how comfortable a workload is (inside a container), and how
> much time is wasted due to underprovisioning of memory. Because it
> isn't just the pathological cases, you migh just wait a bit here and
> there and could it still add up to a sizable portion of a job's time.
>
> If other people think this could be a useful thing to talk about, I'd
> be happy to discuss it at the conference.

I think this discussion would be useful, yeah.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
