Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 66FFE6B0038
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 04:29:59 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so12819791iec.26
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 01:29:59 -0700 (PDT)
Received: from mx2.parallels.com ([199.115.105.18])
        by mx.google.com with ESMTPS id h17si2727011pde.5.2014.09.05.01.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 01:29:35 -0700 (PDT)
Date: Fri, 5 Sep 2014 12:28:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140905082846.GA25641@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5408E1CD.3090004@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Kamezawa,

Thanks for reading this :-)

On Fri, Sep 05, 2014 at 07:03:57AM +0900, Kamezawa Hiroyuki wrote:
> (2014/09/04 23:30), Vladimir Davydov wrote:
> >  - memory.limit - container can't use memory above this
> >  - memory.memsw.limit - container can't use swappable memory above this
> 
> If one hits anon+swap limit, it just means OOM. Hitting limit means
> process's death.

Basically yes. Hitting the memory.limit will result in swap out + cache
reclaim no matter if it's an anon charge or a page cache one. Hitting
the swappable memory limit (anon+swap) can only occur on anon charge and
if it happens we have no choice rather than invoking OOM.

Frankly, I don't see anything wrong in such a behavior. Why is it worse
than the current behavior where we also kill processes if a cgroup
reaches memsw.limit and we can't reclaim page caches?

I admit I may be missing something. So I'd appreciate if you could
provide me with a use case where we want *only* the current behavior and
my proposal is a no-go.

> Is it useful ?

I think so, at least, if we want to use soft limits. The point is we
will have to kill a process if it eats too much anon memory *anyway*
when it comes to global memory pressure, but before finishing it we'll
be torturing the culprit as well as *innocent* processes by issuing
massive reclaim, as I tried to point out in the example above. IMO, this
is no good.

Besides, I believe such a distinction between swappable memory and
caches would look more natural to users. Everyone got used to it
actually. For example, when an admin or user or any userspace utility
looks at the output of free(1), it primarily pays attention to free
memory "-/+ buffers/caches", because almost all memory is usually full
with file caches. And they know that caches easy come, easy go. IMO, for
them it'd be more useful to limit this to avoid nasty surprises in the
future, and only set some hints for page cache reclaim.

The only exception is strict sand-boxing, but AFAIU we can sand-box apps
perfectly well with this either, because we would still have a strict
memory limit and a limit on maximal swap usage.

Please sorry if the idea looks to you totally stupid (may be it is!),
but let's just try to consider every possibility we have in mind.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
