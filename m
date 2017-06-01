Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAD06B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 15:27:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w1so7527554qtg.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 12:27:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o17si7789774qta.238.2017.06.01.12.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 12:27:40 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
 <20170601184740.GC3494@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
Date: Thu, 1 Jun 2017 15:27:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170601184740.GC3494@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 06/01/2017 02:47 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Thu, Jun 01, 2017 at 02:44:48PM -0400, Waiman Long wrote:
>>> And cgroup-v2 has this 'exception' (aka wart) for the root group whic=
h
>>> needs to be replicated for each namespace.
>> One of the changes that I proposed in my patches was to get rid of the=

>> no internal process constraint. I think that will solve a big part of
>> the container invariant problem that we have with cgroup v2.
> I'm not sure.  It just masks it without actually solving it.  I mean,
> the constraint is thereq for a reason.  "Solving" it would defeat one
> of the main capabilities for resource domains and masking it from
> kernel side doesn't make whole lot of sense to me given that it's
> something which can be easily done from userland.  If we take out that
> part, for controllers which don't care about resource domains,
> wouldn't thread mode be a sufficient solution?

As said in an earlier email, I agreed that masking it on the kernel side
may not be the best solution. I offer 2 other alternatives:
1) Document on how to work around the resource domains issue by proper
setup of the cgroup hierarchy.
2) Mark those controllers that require the no internal process
competition constraint and disallow internal process only when those
controllers are active.

I prefer the first alternative, but I can go with the second if necessary=
=2E

The major rationale behind my enhanced thread mode patch was to allow
something like

     R -- A -- B
     \
      T1 -- T2

where you can have resource domain controllers enabled in the thread
root as well as some child cgroups of the thread root. As no internal
process rule is currently not applicable to the thread root, this
creates the dilemma that we need to deal with internal process competitio=
n.

The container invariant that PeterZ talked about will also be a serious
issue here as I don't think we are going to set up a container root
cgroup that will have no process allowed in it because it has some child
cgroups. IMHO, I don't think cgroup v2 will get wide adoption without
getting rid of that no internal process constraint.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
