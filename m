Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC5EB6B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 16:45:14 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so14238025pab.2
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 13:45:14 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id tl7si10418386pbc.203.2015.01.08.13.45.11
        for <linux-mm@kvack.org>;
        Thu, 08 Jan 2015 13:45:13 -0800 (PST)
Date: Fri, 9 Jan 2015 08:45:09 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Message-ID: <20150108214509.GH25000@dastard>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <20150108122448.GA18034@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150108122448.GA18034@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 08, 2015 at 04:24:48AM -0800, Christoph Hellwig wrote:
> > This patchset passes xfstests and various benchmarks and stress
> > workloads, so the real question is now:
> > 
> > 	What have I missed?
> > 
> > Comments, thoughts, flames?
> 
> Why is this done in XFS and not in generic code?

We might be able to do that. Indeed, if the concept is considered
sound, then this was the next question I was going to ask everyone.
I just don't know enough about other filesystem locking to be able
to say "this will always work", hence the wide distribution of the
RFC.  Different filesystems have different locking heirarchies, and
so there may be some are not able to use this technique
(cluster/network fs?)....

In the end, however, the main reason I decided on doing it in XFS
first was things like that swap extent operation that requires us to
lock multiple locks on two inodes in a specific order. We already
have all the infrastructure in XFS to enforce and *validate at
runtime* the specific lock ordering required, so it just made it a
no-brainer to do it this way first.

We also have several entry points in XFS that don't go through the
VFS that needed this page fault serialisation and they currently
only use XFS internal locks to serialise against IO.  Again, doing
it in XFS first is the easy-to-validate solution.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
