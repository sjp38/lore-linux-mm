Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id B1ECA6B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:38:50 -0500 (EST)
Received: by ykt10 with SMTP id 10so3825132ykt.11
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:38:50 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id k62si2290881ykb.31.2015.03.04.09.38.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 09:38:49 -0800 (PST)
Date: Wed, 4 Mar 2015 12:38:41 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304173841.GB15669@thunk.org>
References: <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <20150302202228.GA15089@phnom.home.cmpxchg.org>
 <20150302231206.GK18360@dastard>
 <20150303025023.GA22453@phnom.home.cmpxchg.org>
 <20150304065242.GR18360@dastard>
 <20150304150436.GA16442@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304150436.GA16442@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Mar 04, 2015 at 10:04:36AM -0500, Johannes Weiner wrote:
> Yes, we can make this work if you can tell us which allocations have
> limited/controllable lifetime.

It may be helpful to be a bit precise about definitions here.  There
are a number of different object lifetimes:

a) will be released before the kernel thread returns control to
userspace

b) will be released once the current I/O operation finishes.  (In the
case of nbd where the remote server has unexpectedy gone away might be
quite a while, but I'm not sure how much we care about that scenario)

c) can be trivially released if the mm subsystem asks via calling a
shrinker

d) can be released only after doing some amount of bounded work (i.e.,
cleaning a dirty page)

e) impossible to predict when it can be released (e.g., dcache, inodes
attached to an open file descriptors, buffer heads that won't be freed
until the file system is umounted, etc.)


I'm guessing that what you mean is (b), but what about cases such as
(c)?

Would the mm subsystem find it helpful if it had more information
about object lifetime?  For example, the CMA folks seem to really care
about know whether memory allocations falls in category (e) or not.

						- Ted
						

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
