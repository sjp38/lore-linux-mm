Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id BFA9F6B0038
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 01:16:09 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so9423355wiv.2
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 22:16:09 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id jw4si14913030wjc.105.2014.12.14.22.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 22:16:08 -0800 (PST)
Date: Mon, 15 Dec 2014 06:16:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/8] swap: don't add ITER_BVEC flag to direct_IO rw
Message-ID: <20141215061601.GT22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <5f9e8a7dcdf08bd2dd433f1a42690ab8e67e7915.1418618044.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5f9e8a7dcdf08bd2dd433f1a42690ab8e67e7915.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Dec 14, 2014 at 09:26:57PM -0800, Omar Sandoval wrote:
> The rw argument to direct_IO has some ill-defined semantics. Some
> filesystems (e.g., ext4, FAT) decide whether they're doing a write with
> rw == WRITE, but others (e.g., XFS) check rw & WRITE. Let's set a good
> example in the swap file code and say ITER_BVEC belongs in
> iov_iter->flags but not in rw. This caters to the least common
> denominator and avoids a sweeping change of every direct_IO
> implementation for now.

Frankly, this is bogus.  If anything, let's just kill the first argument
completely - ->direct_IO() can always pick it from iter->type.

As for catering to the least common denominator...  To hell with the lowest
common denominator.  How many instances of ->direct_IO() do we have, anyway?
24 in the mainline (and we don't give a flying fuck for out-of-tree code, as
a matter of policy).  Moreover, several are of "do nothing" variety.

FWIW, 'rw' is a mess.  We used to have this:
	READ: O_DIRECT read
	WRITE: O_DIRECT write
	KERNEL_WRITE: swapout

These days KERNEL_WRITE got replaced with ITER_BVEC | WRITE.  The thing is,
we have a bunch of places where we explicitly checked for being _equal_ to
WRITE.  I.e. the checks that gave a negative on swapouts.  I suspect that most
of them are wrong and should trigger on all writes, including swapouts, but
I really didn't want to dig into that pile of fun back then.  That's the
main reason why 'rw' argument has survived at all...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
