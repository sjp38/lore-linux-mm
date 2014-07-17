Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C87816B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:36:31 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so3944799pdj.35
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:36:31 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id fn1si3904634pbb.74.2014.07.17.16.36.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 16:36:30 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so3945477pdi.11
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:36:30 -0700 (PDT)
Date: Thu, 17 Jul 2014 16:34:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
In-Reply-To: <53C7F55B.8030307@suse.cz>
Message-ID: <alpine.LSU.2.11.1407171602370.2544@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 17 Jul 2014, Vlastimil Babka wrote:
> On 07/15/2014 12:28 PM, Hugh Dickins wrote:
> > In the end I decided that we had better look at it as two problems,
> > the trinity faulting starvation, and the indefinite punching loop,
> > so 1/2 and 2/2 present both solutions: belt and braces.
> 
> I tested that with my reproducer and it was OK, but as I already said, it's
> not trinity so I didn't observe the new problems in the first place.

Yes, but thanks for doing so anyway.

> 
> > Which may be the best for fixing, but the worst for ease of backporting.
> > Vlastimil, I have prepared (and lightly tested) a 3.2.61-based version
> > of the combination of f00cdc6df7d7 and 1/2 and 2/2 (basically, I moved
> > vmtruncate_range from mm/truncate.c to mm/shmem.c, since nothing but
> > shmem ever implemented the truncate_range method).  It should give a
> 
> I don't know how much stable kernel updates are supposed to care about
> out-of-tree modules,

I suggest that stable kernel updates do not need to care about
out-of-tree modules: for so long as they are out of tree, they have
to look after their own compatibility from one version to another.
I have no desire to break them gratuitously, but it's not for me
to spend more time accommodating them.

Now, SLES and RHEL and other distros may have different priorities
from that: if they distribute additional filesystems, which happen to
support the ->truncate_range() method, or work with partners who supply
such filesystems, then they may want to rework the shmem-specific
vmtruncate_range() to allow for those - that's up to them.

> but doesn't the change mean that an out-of-tree FS
> supporting truncate_range (if such thing exists) would effectively stop
> supporting madvise(MADV_REMOVE) after this change?

Yes, it would need to be reworked a little for them: I've not thought
through what more would need to be done.  But it seems odd to me that
an out-of-tree driver would support it, when it got no take up at all
from in-tree filesystems, even from those which went on to support
hole-punching in fallocate() (until the tmpfs series brought them in).

Or perhaps MADV_REMOVE-support is their secret sauce :-?  In that case
I would expect them to support FALLOC_FL_PUNCH_HOLE already, and prefer
a backport of v3.5's merging of the madvise and fallocate routes.

> But hey it's still madvise so maybe we don't need to care.

That's an argument I would not use, not in Linus's kernel anyway:
users may have come to rely upon the behaviour of madvise(MADV_REMOVE):
never mind that it says "advise", I would not be happy to break them.

> And I suppose kernels where
> FALLOC_FL_PUNCH_HOLE is supported, can be backported normally.

Yes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
