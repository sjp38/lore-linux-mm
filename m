Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF6C6B025E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 21:26:13 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so82525106wmp.0
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:26:13 -0700 (PDT)
Date: Sun, 20 Mar 2016 01:26:10 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: aio openat Re: [PATCH 07/13] aio: enabled thread based async
 fsync
Message-ID: <20160320012610.GX17997@ZenIV.linux.org.uk>
References: <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
 <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
 <20160120204449.GC12249@kvack.org>
 <20160120214546.GX6033@dastard>
 <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
 <20160123043922.GF6033@dastard>
 <20160314171737.GK17923@kvack.org>
 <CA+55aFx7JJdYNWRSs6Nbm_xyQjgUVoBQh=RuNDeavKS1Jr+-ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx7JJdYNWRSs6Nbm_xyQjgUVoBQh=RuNDeavKS1Jr+-ow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Sat, Mar 19, 2016 at 06:20:24PM -0700, Linus Torvalds wrote:
> On Mon, Mar 14, 2016 at 10:17 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> > I had some time last week to make an aio openat do what it can in
> > submit context.  The results are an improvement: when openat is handled
> > in submit context it completes in about half the time it takes compared
> > to the round trip via the work queue, and it's not terribly much code
> > either.
> 
> This looks good to me, and I do suspect that any of these aio paths
> should strive to have a synchronous vs threaded model. I think that
> makes the whole thing much more interesting from a performance
> standpoint.

Umm...  You do realize that LOOKUP_RCU in flags does *NOT* guarantee that
it won't block, right?  At the very least one would need to refuse to
fall back on non-RCU mode without a full restart.  Furthermore, vfs_open()
itself can easily block.

So this new LOOKUP flag makes no sense, and it's in the just about _the_
worst place possible for adding special cases with ill-defined semantics -
do_last() is already far too convoluted and needs untangling, not adding
half-assed kludges.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
