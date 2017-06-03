Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0828D6B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 06:33:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v195so35482453qka.1
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 03:33:12 -0700 (PDT)
Received: from mail-qt0-x22b.google.com (mail-qt0-x22b.google.com. [2607:f8b0:400d:c0d::22b])
        by mx.google.com with ESMTPS id s18si26050074qta.121.2017.06.03.03.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 03:33:10 -0700 (PDT)
Received: by mail-qt0-x22b.google.com with SMTP id c13so74817503qtc.1
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 03:33:10 -0700 (PDT)
Date: Sat, 3 Jun 2017 06:33:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170603103303.GA28145@wtj.duckdns.org>
References: <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
 <20170601184740.GC3494@htj.duckdns.org>
 <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
 <20170601203815.GA13390@htj.duckdns.org>
 <e65745c2-3b07-eb8b-b638-04e9bb1ed1e6@redhat.com>
 <20170601205203.GB13390@htj.duckdns.org>
 <1e775dcf-61b2-29d5-a214-350dc81c632b@redhat.com>
 <20170601211823.GC13390@htj.duckdns.org>
 <cf47d637-204c-49ea-94ec-c2bf0cf10614@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf47d637-204c-49ea-94ec-c2bf0cf10614@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Fri, Jun 02, 2017 at 04:36:22PM -0400, Waiman Long wrote:
> I wouldn't argue further on that if you insist. However, I still want to

Oh, please don't get me wrong.  I'm not trying to shut down the
discussion or anything.  It's just that whole-scope discussions can
get very meandering and time-consuming when these two issues can be
decoupled from each other without compromising on either.  Let's
approach these issues separately.

> relax the constraint somewhat by abandoning the no internal process
> constraint  when only threaded controllers (non-resource domains) are
> enabled even when thread mode has not been explicitly enabled. It is a
> modified version my second alternative. Now the question is which
> controllers are considered to be resource domains. I think memory and
> blkio are in the list. What else do you think should be considered
> resource domains?

And we're now a bit into repeating ourselves but for controlling of
any significant resources (mostly cpu, memory, io), there gotta be
significant portion of resource consumption which isn't tied to
spcific processes or threads that should be accounted for.  Both
memory and io already do this to a certain extent, but not completely.
cpu doesn't do it at all yet but we usually can't / shouldn't declare
a resource category to be domain-free.

There are exceptions - controllers which are only used for membership
identification (perf and the old net controllers), pids which is
explicitly tied to tasks (note that CPU cycles aren't), cpuset which
is an attribute propagating / restricting controller.

Out of those, the identification uses already aren't affected by the
constraint as they're now all either direct membership test against
the hierarchy or implicit controllers which aren't subject to the
constraint.  That leaves pids and cpuset.  We can exempt them from the
constraint but I'm not quite sure what that buys us given that neither
is affected by requiring explicit leaf nodes.  It'd just make the
rules more complicated without actual benefits.

That said, we can exempt those two.  I don't see much point in it but
we can definitely discuss the pros and cons, and it's likely that it's
not gonna make much difference wichever way we choose.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
