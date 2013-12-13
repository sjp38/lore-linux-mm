Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA676B0085
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:47:39 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so1459613qeb.12
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 03:47:39 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id q7si1929745qev.25.2013.12.13.03.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 03:47:38 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id r5so1371474qcx.14
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 03:47:38 -0800 (PST)
Date: Fri, 13 Dec 2013 06:47:34 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131213114734.GA22074@htj.dyndns.org>
References: <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org>
 <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org>
 <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
 <20131212142156.GB32683@htj.dyndns.org>
 <CAAAKZwtuydFdiiSsKMuOUv3nr9trjuKvKoDO2aM0QsJKu1TMZA@mail.gmail.com>
 <20131212192319.GL32683@htj.dyndns.org>
 <CAAAKZwtQc212_-oqf56ToxjSG7f9bsNcBwwurSezpGKiPDT+nQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAAKZwtQc212_-oqf56ToxjSG7f9bsNcBwwurSezpGKiPDT+nQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@hockin.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, Victor Marmol <vmarmol@google.com>

Hello, Tim.

On Thu, Dec 12, 2013 at 04:23:18PM -0800, Tim Hockin wrote:
> Just to be clear - I say this because it doesn't feel right to impose
> my craziness on others, and it sucks when we try and are met with
> "you're crazy, go away".  And you have to admit that happens to
> Google. :)  Punching an escape valve that allows us to be crazy
> without hurting anyone else sounds ideal, IF and ONLY IF that escape
> valve is itself maintainable.

I don't think google being considered crazy is a good thing in
general, highly likely not something to be proud of.  It sure is
partly indicative of the specialization that you guys need but I
suspect is a much stronger signal for room for better engineering.

I'm fairly certain the blame is abundant for everybody to share.  The
point I'm trying to make is "let's please stop diverging".  It hurts
everybody.

> If the escape valve is userspace it's REALLY easy to iterate on our
> craziness.  If it is kernel space, it's somewhat less easy, but not
> impossible.

As I'm sure you've gathered from this thread, even punching the
initial hole is a sizable burden and contortion to the general memory
management and I'm sure as you guys develop further down the path
you'll encounter cases where you need further support or holes from
the kernel.  I can't anticipate the details but the fact that those
will follow is as evident as the day to me, especially given the
mindset leading to the current situation in the first place.

Please note that this part of discussion is more abstract than
necessary for this particular patchset or hole.  I'm quite doubtful
that system-level OOM handling with separate physical reserve is
likely to survive even just on technical details.  The reason why I'm
keeping at this abstract point is because this seems to be a
continuing trend rather than a single occurrence and I really hope it
changes.

> Well that's an awesome start.  We have or had patches to do a lot of
> this.  I don't know how well scrubbed they are for pushing or whether
> they apply at all to current head, though.

Awesome, this looks like something everyone agrees on. :)

> As an aside: mucking about with extra nesting levels to achieve a
> stable OOM semantic sounds doable, but it certainly sucks in a unified
> hierarchy.  We'll end up with 1, 2, or 3 (or more in esoteric cases?
> not sure) extra nesting levels for every other resource dimension.
> And lawd help us if we ever need to do something similar in a
> different resource dimension - the cross product is mind-bending.
> What we do with split-hierarchies is this but on a smaller scale.

Yes, agreed but I believe there are substantial benefits to having
certain level of structural constraints.  It encourages people to
ponder the underlying issues and make active trade-offs.  Not that
going off that extreme would be good either but we've gone too far
towards the other end.

This being a special issue with memcg, if this turns out to be a big
enough problem, I don't think having a provision to be able to handle
it without further nesting would be too crazy - e.g. the ability to
mark a single cgroup at the root level as for OOM handler or whatever
- as long as we stay within the boundaries of memcg and cgroup proper,
but we seem to have ways to go before worrying about that one.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
