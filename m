Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 422FF6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:47:48 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so5296524wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:47:48 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id w9si34001wja.96.2016.02.23.14.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 14:47:47 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g62so221312910wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:47:47 -0800 (PST)
Message-ID: <56CCE190.4060408@plexistor.com>
Date: Wed, 24 Feb 2016 00:47:44 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56CA1CE7.6050309@plexistor.com> <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com> <56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com> <20160221223157.GC25832@dastard> <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com> <20160222174426.GA30110@infradead.org> <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com> <20160223095225.GB32294@infradead.org> <56CC686A.9040909@plexistor.com> <20160223172512.GC15877@linux.intel.com>
In-Reply-To: <20160223172512.GC15877@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/23/2016 07:25 PM, Ross Zwisler wrote:
<>
> 
> It seems like we are trying to solve a couple of different problems:
> 
> 1) Make page faults faster by skipping any radix tree insertions, tag updates,
> etc.
> 
> 2) Make fsync/msync faster by not flushing data that the application says it
> is already making durable from userspace.
> 

I fail to see how this is separate issues the reason you are keeping track
of pages in [1] is exactly because you want to know which are they in [2].
Only [2] matters and [1] is what you thought is a necessary cost.
If you remember I wanted to solve [1] differently by iterating over the
extent lists of the mmap range and cl_flushing all the "written" pages in the
range not only the written ones. In our testes we found that for  most real world
applications and benchmarks this works better then your approach. because
page-faults are fast.
There is however work loads that are much worse. In anyway your way was easier
because it had a generic solution instead of an FS specific implementation.

> I agree that your approach seems to improve both of these problems, but I
> would argue that it is an incomplete solution for problem #2 because a
> fsync/msync from the PMEM aware application would still flush any radix tree
> entries from *other* threads that were writing to the same file.
> 

No!! you meant applications. Because threads are from the same application if
a programmer is dumb enough to upgrade one mmap call site to new and keep
all other sites legacy without the flag and pmem_mecpy, then he can suffer, I do
not care for dumb programmers.

For the two applications one new one legacy writing to the same file each written
by a different team of programmers. For one they do not exist. But for two
this is an administrator issue. Yes if he allows such a setup he knows that the
performance will not be has if both apps upgraded but it will still be better then
two legacy apps. because at least all the pages from the new app will not slow-sync.

> It seems like a more direct solution for #2 above would be to have a
> metadata-only equivalent of fsync/fdatasync, say "fmetasync", which says "I'll
> make the writes I do to my mmaps durable from userspace, but I need you to
> sync all filesystem metadata for me, please".
> 
> This would allow a complete separation of data synchronization in userspace
> from metadata synchronization in kernel space by the filesystem code.
> 
> By itself a fmetasync() type solution of course would do nothing for issue #1
> - if that was a compelling issue you'd need something like the mmap tag you're
> proposing to skip work on page faults.
> 

Again a novelty solution to a theoretical only problem. With only very marginal
performance gains. And no users that I can see. And lots of work including FS
specific work.

> All that being said, though, I agree with others in the thread that we should
> still be focused on correctness, as we have a lot of correctness issues
> remaining.  When we eventually get to the place where we are trying to do
> performance optimizations, those optimizations should be measurement driven.
> 

What I'm hopping to do is establish a good practice for pmem aware apps
that everyone can agree on and will give us ground to optimize for.
That pmem apps can start to be written and experimented with.

The patch I sent is so simple and none intrusive that it can be easily
be carried in the noise and I cannot see how it breaks anything. And yes
I am measurement driven and is why I even bother.

And hence the RFC let us establish a programming model first.

> - Ross
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
