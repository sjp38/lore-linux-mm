Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 585B86B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:05:12 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so3027541wgh.1
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:05:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mw6si1882142wib.99.2014.07.18.01.05.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 01:05:09 -0700 (PDT)
Message-ID: <53C8D532.70305@suse.cz>
Date: Fri, 18 Jul 2014 10:05:06 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <alpine.LSU.2.11.1407171602370.2544@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407171602370.2544@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/18/2014 01:34 AM, Hugh Dickins wrote:
> On Thu, 17 Jul 2014, Vlastimil Babka wrote:
>> On 07/15/2014 12:28 PM, Hugh Dickins wrote:
>> > In the end I decided that we had better look at it as two problems,
>> > the trinity faulting starvation, and the indefinite punching loop,
>> > so 1/2 and 2/2 present both solutions: belt and braces.
>> 
>> I tested that with my reproducer and it was OK, but as I already said, it's
>> not trinity so I didn't observe the new problems in the first place.
> 
> Yes, but thanks for doing so anyway.

Now also tested vanilla 3.2.61, also OK.

>> 
>> > Which may be the best for fixing, but the worst for ease of backporting.
>> > Vlastimil, I have prepared (and lightly tested) a 3.2.61-based version
>> > of the combination of f00cdc6df7d7 and 1/2 and 2/2 (basically, I moved
>> > vmtruncate_range from mm/truncate.c to mm/shmem.c, since nothing but
>> > shmem ever implemented the truncate_range method).  It should give a
>> 
>> I don't know how much stable kernel updates are supposed to care about
>> out-of-tree modules,
> 
> I suggest that stable kernel updates do not need to care about
> out-of-tree modules: for so long as they are out of tree, they have
> to look after their own compatibility from one version to another.
> I have no desire to break them gratuitously, but it's not for me
> to spend more time accommodating them.

Fair enough.

> Now, SLES and RHEL and other distros may have different priorities
> from that: if they distribute additional filesystems, which happen to
> support the ->truncate_range() method, or work with partners who supply
> such filesystems, then they may want to rework the shmem-specific
> vmtruncate_range() to allow for those - that's up to them.

Sure, it wasn't my intention to raise any enterprise kernel specific concerns here.

>> but doesn't the change mean that an out-of-tree FS
>> supporting truncate_range (if such thing exists) would effectively stop
>> supporting madvise(MADV_REMOVE) after this change?
> 
> Yes, it would need to be reworked a little for them: I've not thought
> through what more would need to be done.  But it seems odd to me that
> an out-of-tree driver would support it, when it got no take up at all
> from in-tree filesystems, even from those which went on to support
> hole-punching in fallocate() (until the tmpfs series brought them in).
> 
> Or perhaps MADV_REMOVE-support is their secret sauce :-?  In that case
> I would expect them to support FALLOC_FL_PUNCH_HOLE already, and prefer
> a backport of v3.5's merging of the madvise and fallocate routes.
> 
>> But hey it's still madvise so maybe we don't need to care.
> 
> That's an argument I would not use, not in Linus's kernel anyway:
> users may have come to rely upon the behaviour of madvise(MADV_REMOVE):
> never mind that it says "advise", I would not be happy to break them.

Right.

>> And I suppose kernels where
>> FALLOC_FL_PUNCH_HOLE is supported, can be backported normally.
> 
> Yes.
> 
> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
