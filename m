Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 802B26B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:21:50 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id q107so22201408qgd.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:21:50 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id jz5si7751842qcb.10.2015.01.28.17.21.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 17:21:49 -0800 (PST)
Received: by mail-qg0-f48.google.com with SMTP id z60so22136083qgd.7
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:21:49 -0800 (PST)
Date: Wed, 28 Jan 2015 20:21:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET RFC 0/6] memcg: inode-based dirty-set controller
Message-ID: <20150129012146.GA20617@htj.dyndns.org>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

Hello, Konstantin.

Sorry about the delay.

On Thu, Jan 15, 2015 at 09:49:10PM +0300, Konstantin Khebnikov wrote:
> This is ressurection of my old RFC patch for dirty-set accounting cgroup [1]
> Now it's merged into memory cgroup and got bandwidth controller as a bonus.
> 
> That shows alternative solution: less accurate but much less monstrous than
> accurate page-based dirty-set controller from Tejun Heo.

I went over the whole patchset and ISTR having reviewed this a while
ago and the conclusion is the same.  This appears to be simpler on the
surface but this is a hackjob of a design to put it nicely.  You're
working around the complexity of pressure propagation from the lower
layer by building a separate pressure layer at the top most layer.  In
doing so, it's duplicating what already exist below in degenerate
forms but at the cost of fundamental crippling of the whole thing.

This, even in its current simplistic form, is already a dead end.
e.g. iops or bw aren't even the proper resources to distribute for
rotating disks, IO time is, which is what a large proportion of cfq is
trying to estimate and distribute.  What if there are multiple
filesystems on a single device?  Or if a cgroup accesses multiple
backing devices?  How would you guarantee low latency access to a high
priority cgroup while a huge inode from a low pri cgroup is being
written out when none of the lower layers have any idea what they're
doing?

Sure, these issues can be dealt with partially with various
workarounds and additions and I'm sure we'll be doing that if we go
down this path, but the only thing that'll lead to is duplicating more
of what's already in the lower layers with ever growing list of
behavioral and interface oddities which are inherent to the design.

Even in the absence of alternatives, I'd be strongly against this
direction.  I think this sort of ad-hoc "let's solve this one
immediate issue in the easiest way possible" is often worse than not
doing anything.  In the longer term, things like this paint us into a
corner of which we can't easily get out and memcg happens to be an
area where that sort of things took place quite a bit in the past and
people have been desparately trying to right the course, so, no, I
don't think this is happening.

I agree that propagating backpressure from the lower layer involves
more complexity but it is a full and conceptually and design-wise
straight-forward solution which doesn't need to get constantly papered
over.  This is the right thing to do.  It can be argued that the
amount of complexity can be reduced by tracking dirty pages per-inode,
but, if we're gonna do that, we should converting memcg itself to be
per address space too.  The arguments would be exactly the same for
memcg and memcg and writeback must be on the same foundation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
