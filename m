Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B724F6B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:35:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c206so17273329qkb.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:35:31 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id f15si14335469qkf.265.2017.06.01.08.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:35:30 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id c13so39187382qtc.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:35:30 -0700 (PDT)
Date: Thu, 1 Jun 2017 11:35:28 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601153528.GB3494@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <longman@redhat.com>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Peter.

On Thu, Jun 01, 2017 at 05:10:45PM +0200, Peter Zijlstra wrote:
> I've not had time to look at any of this. But the question I'm most
> curious about is how cgroup-v2 preserves the container invariant.
> 
> That is, each container (namespace) should look like a 'real' machine.
> So just like userns allows to have a uid-0 (aka root) for each container
> and pidns allows a pid-1 for each container, cgroupns should provide a
> root group for each container.
> 
> And cgroup-v2 has this 'exception' (aka wart) for the root group which
> needs to be replicated for each namespace.

The goal has never been that a container must be indistinguishible
from a real machine.  For certain things, things simply don't have
exact equivalents due to sharing (memory stats or journal writes for
example) and those things are exactly why people prefer containers
over VMs for certain use cases.  If one wants full replication, VM
would be the way to go.

The goal is allowing enough container invariant so that appropriate
workloads can be contained and co-exist in useful ways.  This also
means that the contained workload is usually either a bit illiterate
w.r.t. to the system details (doesn't care) or makes some adjustments
for running inside a container (most quasi-full-system ones already
do).

System root is inherently different from all other nested roots.
Making some exceptions for the root isn't about taking away from other
roots but more reflecting the inherent differences - there are things
which are inherently system / bare-metal.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
