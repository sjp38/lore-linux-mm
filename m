Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5DA96B0338
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 16:38:18 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id h82so35181430ywb.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 13:38:18 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id 132si5384928ybd.60.2017.06.01.13.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 13:38:17 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id 5so3481249ywe.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 13:38:17 -0700 (PDT)
Date: Thu, 1 Jun 2017 16:38:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601203815.GA13390@htj.duckdns.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Thu, Jun 01, 2017 at 03:27:35PM -0400, Waiman Long wrote:
> As said in an earlier email, I agreed that masking it on the kernel side
> may not be the best solution. I offer 2 other alternatives:
> 1) Document on how to work around the resource domains issue by proper
> setup of the cgroup hierarchy.

We can definitely improve documentation.

> 2) Mark those controllers that require the no internal process
> competition constraint and disallow internal process only when those
> controllers are active.

We *can* do that but wouldn't this be equivalent to enabling thread
mode implicitly when only thread aware controllers are enabled?

> I prefer the first alternative, but I can go with the second if necessary.
> 
> The major rationale behind my enhanced thread mode patch was to allow
> something like
> 
>      R -- A -- B
>      \
>       T1 -- T2
> 
> where you can have resource domain controllers enabled in the thread
> root as well as some child cgroups of the thread root. As no internal
> process rule is currently not applicable to the thread root, this
> creates the dilemma that we need to deal with internal process competition.
> 
> The container invariant that PeterZ talked about will also be a serious
> issue here as I don't think we are going to set up a container root
> cgroup that will have no process allowed in it because it has some child
> cgroups. IMHO, I don't think cgroup v2 will get wide adoption without
> getting rid of that no internal process constraint.

The only thing which is necessary from inside a container is putting
the management processes into their own cgroups so that they can be
controlled (ie. the same thing you did with your patch but doing that
explicitly from userland) and userland management sw can do the same
thing whether it's inside a container or on a bare system.  BTW,
systemd already does so and works completely fine in terms of
containerization on cgroup2.  It is arguable whether we should make
this more convenient from kernel side but using cgroup2 for resource
control already requires the userspace tools to be adapted to it, so
I'm not sure how much benefit we'd gain from adding that compared to
explicitly documenting it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
