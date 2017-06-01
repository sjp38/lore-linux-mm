Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0348D6B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 16:48:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s33so1718018qtg.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 13:48:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v1si20592539qtc.54.2017.06.01.13.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 13:48:51 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
 <20170601184740.GC3494@htj.duckdns.org>
 <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
 <20170601203815.GA13390@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <e65745c2-3b07-eb8b-b638-04e9bb1ed1e6@redhat.com>
Date: Thu, 1 Jun 2017 16:48:48 -0400
MIME-Version: 1.0
In-Reply-To: <20170601203815.GA13390@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 06/01/2017 04:38 PM, Tejun Heo wrote:
> Hello,
>
> On Thu, Jun 01, 2017 at 03:27:35PM -0400, Waiman Long wrote:
>> As said in an earlier email, I agreed that masking it on the kernel side
>> may not be the best solution. I offer 2 other alternatives:
>> 1) Document on how to work around the resource domains issue by proper
>> setup of the cgroup hierarchy.
> We can definitely improve documentation.
>
>> 2) Mark those controllers that require the no internal process
>> competition constraint and disallow internal process only when those
>> controllers are active.
> We *can* do that but wouldn't this be equivalent to enabling thread
> mode implicitly when only thread aware controllers are enabled?
>
>> I prefer the first alternative, but I can go with the second if necessary.
>>
>> The major rationale behind my enhanced thread mode patch was to allow
>> something like
>>
>>      R -- A -- B
>>      \
>>       T1 -- T2
>>
>> where you can have resource domain controllers enabled in the thread
>> root as well as some child cgroups of the thread root. As no internal
>> process rule is currently not applicable to the thread root, this
>> creates the dilemma that we need to deal with internal process competition.
>>
>> The container invariant that PeterZ talked about will also be a serious
>> issue here as I don't think we are going to set up a container root
>> cgroup that will have no process allowed in it because it has some child
>> cgroups. IMHO, I don't think cgroup v2 will get wide adoption without
>> getting rid of that no internal process constraint.
> The only thing which is necessary from inside a container is putting
> the management processes into their own cgroups so that they can be
> controlled (ie. the same thing you did with your patch but doing that
> explicitly from userland) and userland management sw can do the same
> thing whether it's inside a container or on a bare system.  BTW,
> systemd already does so and works completely fine in terms of
> containerization on cgroup2.  It is arguable whether we should make
> this more convenient from kernel side but using cgroup2 for resource
> control already requires the userspace tools to be adapted to it, so
> I'm not sure how much benefit we'd gain from adding that compared to
> explicitly documenting it.

I think we are on agreement here. I should we should just document how
userland can work around the internal process competition issue by
setting up the cgroup hierarchy properly. Then we can remove the no
internal process constraint.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
