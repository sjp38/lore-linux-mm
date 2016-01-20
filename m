Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF8E6B0254
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 00:02:31 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id x67so676871943ykd.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 21:02:31 -0800 (PST)
Date: Wed, 20 Jan 2016 00:02:25 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160120050225.GA28031@thunk.org>
References: <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard>
 <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
 <20160112022548.GD6033@dastard>
 <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
 <20160112033708.GE6033@dastard>
 <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
 <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 19, 2016 at 07:59:35PM -0800, Linus Torvalds wrote:
> 
> After thinking it over some more, I guess I'm ok with your approach.
> The table-driven patch makes me a bit happier, and I guess not very
> many people end up ever wanting to do async system calls anyway.
> 
> Are there other users outside of Solace? It would be good to get comments..

For async I/O?  We're using it inside Google, for networking and for
storage I/O's.  We don't need async fsync/fdatasync, but we do need
very fast, low overhead I/O's.  To that end, we have some patches to
batch block layer completion handling, which Kent tried upstreaming a
few years back but which everyone thought was too ugly to live.

(It *was* ugly, but we had access to some very fast storage devices
where it really mattered.  With upcoming NVMe devices, that sort of
hardware should be available to more folks, so it's something that
I've been meaning to revisit from an upstreaming perspective,
especially if I can get my hands on some publically available hardware
for benchmarking purposes to demonstrate why it's useful, even if it
is ugly.)

The other thing which we have which is a bit more experimental is that
we've plumbed through the aio priority bits to the block layer, as
well as aio_cancel.  The idea for the latter is if you are are
interested in low latency access to a clustered file system, where
sometimes a read request can get stuck behind other I/O requests if a
server has a long queue of requests to service.  So the client for
which low latency is very important fires off the request to more than
one server, and as soon as it gets an answer it sends a "never mind"
message to the other server(s).

The code to do aio_cancellation in the block layer is fairly well
tested, and was in Kent's git trees, but never got formally pushed
upstream.  The code to push the cancellation request all the way to
the HDD (for those hard disks / storage devices that support I/O
cancellation) is even more experimental, and needs a lot of cleanup
before it could be sent for review (it was done by someone who isn't
used to upstream coding standards).

The reason why we haven't tried to pushed more of these changes
upsream has been lack of resources, and the fact that the AIO code
*is* ugly, which means extensions tend to make the code at the very
least, more complex.  Especially since some of the folks working on
it, such as Kent, were really worried about performance at all costs,
and Kerningham's "it's twice as hard to debug code as to write it"
comment really applies here.  And since very few people outside of
Google seem to use AIO, and even fewer seem eager to review or work on
AIO, and our team is quite small for the work we need to do, it just
hasn't risen to the top of the priority list.

Still, it's fair to say that if you are using Google Hangouts, or
Google Mail, or Google Docs, AIO is most definitely getting used to
process your queries.

As far as comments, aside from the "we really care about performance",
and "the code is scary complex and barely on the edge of being
maintainable", the other comment I'd make is libaio is pretty awful,
and so as a result a number (most?) of our AIO users have elected to
use the raw system call interfaces and are *not* using the libaio
abstractions --- which, as near as I can tell, don't really buy you
much anyway.  (Do we really need to keep code that provides backwards
compatibility with kernels over 10+ years old at this point?)

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
