Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l4A0lwqT025433
	for <linux-mm@kvack.org>; Wed, 9 May 2007 17:47:58 -0700
Received: from an-out-0708.google.com (ancc34.prod.google.com [10.100.29.34])
	by zps37.corp.google.com with ESMTP id l4A0lr9s029866
	for <linux-mm@kvack.org>; Wed, 9 May 2007 17:47:55 -0700
Received: by an-out-0708.google.com with SMTP id c34so114990anc
        for <linux-mm@kvack.org>; Wed, 09 May 2007 17:47:53 -0700 (PDT)
Message-ID: <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
Date: Wed, 9 May 2007 17:47:53 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <20070509164859.15dd347b.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
	 <20070509164859.15dd347b.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On 5/9/07, Paul Jackson <pj@sgi.com> wrote:
> Ken wrote:
> > I wonder why we don't check cpuset's mems_allowed node mask in the
> > sys_mbind() path?
>
> Looking back through the version history of mm/mempolicy.c, I see that
> we used to check the cpuset (by calling contextualize_policy), but then
> with the following patch (Christoph added to CC list above), this was
> changed.

oh, boy, never ending circle of fixing a bug by introduce another one.
 No wonder why number of kernel bugs never goes down because everyone
is running in circles.

I see Christoph's point that when two threads live in two disjoint
cpusets, they can affect each other's memory policy and cause
undesired oom behavior.

However, mbind shouldn't create discrepancy between what is allowed
and what is promised, especially with MPOL_BIND policy.  Since a
numa-aware app has already gone such a detail to request memory
placement on a specific nodemask, they fully expect memory to be
placed there for performance reason.  If kernel lies about it, we get
very unpleasant performance issue.

I suppose neither behavior is correct nor desired.  What if we "OR"
all the nodemask for all threads in a process group and use that
nodemask to check against what is being requested, is that reasonable?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
