Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6C46B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 14:07:22 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id v10so768136bkz.7
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 11:07:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l9si1460913bko.293.2013.12.07.11.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 11:07:21 -0800 (PST)
Date: Sat, 7 Dec 2013 14:06:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131207190653.GI21724@cmpxchg.org>
References: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org>
 <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206173438.GE21724@cmpxchg.org>
 <CAAAKZwsh3erB7PyG6FnvJRgrZhf2hDQCZDx3rMM7NdOdYNCzJw@mail.gmail.com>
 <20131207174039.GH21724@cmpxchg.org>
 <CAAAKZwvanMiz8QZVOU0-SUKYzqcaJAXn0HxYs5+=Zakmnbcfbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAAKZwvanMiz8QZVOU0-SUKYzqcaJAXn0HxYs5+=Zakmnbcfbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@hockin.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Dec 07, 2013 at 10:12:19AM -0800, Tim Hockin wrote:
> You more or less described the fundamental change - a score per memcg, with
> a recursive OOM killer which evaluates scores between siblings at the same
> level.
> 
> It gets a bit complicated because we have need if wider scoring ranges than
> are provided by default

If so, I'm sure you can make a convincing case to widen the internal
per-task score ranges.  The per-memcg score ranges have not even be
defined, so this is even easier.

> and because we score PIDs against mcgs at a given scope.

You are describing bits of a solution, not a problem.  And I can't
possibly infer a problem from this.

> We also have some tiebreaker heuristic (age).

Either periodically update the per-memcg score from userspace or
implement this in the kernel.  We have considered CPU usage
history/runtime etc. in the past when picking an OOM victim task.

But I'm again just speculating what your problem is, so this may or
may not be a feasible solution.

> We also have a handful of features that depend on OOM handling like the
> aforementioned automatically growing and changing the actual OOM score
> depending on usage in relation to various thresholds ( e.g. we sold you X,
> and we allow you to go over X but if you do, your likelihood of death in
> case of system OOM goes up.

You can trivially monitor threshold events from userspace with the
existing infrastructure and accordingly update the per-memcg score.

> Do you really want us to teach the kernel policies like this?  It would be
> way easier to do and test in userspace.

Maybe.  Providing fragments of your solution is not an efficient way
to communicate the problem.  And you have to sell the problem before
anybody can be expected to even consider your proposal as one of the
possible solutions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
