Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 87E7F6B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 14:51:56 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ts10so33538950obc.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 11:51:56 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id nv6si16048757obc.94.2016.02.21.11.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 11:51:55 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id xk3so150923285obc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 11:51:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C9EDCF.8010007@plexistor.com>
References: <56C9EDCF.8010007@plexistor.com>
Date: Sun, 21 Feb 2016 11:51:55 -0800
Message-ID: <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On Sun, Feb 21, 2016 at 9:03 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> Hi all
>
> Recent DAX code fixed the cl_flushing ie durability of mmap access
> of direct persistent-memory from applications. It uses the radix-tree
> per inode to track the indexes of a file that where page-faulted for
> write. Then at m/fsync time it would cl_flush these pages and clean
> the radix-tree, for the next round.
>
> Sigh, that is life, for legacy applications this is the price we must
> pay. But for NV aware applications like nvml library, we pay extra extra
> price, even if we do not actually call m/fsync eventually. For these
> applications these extra resources and especially the extra radix locking
> per page-fault, costs a lot, like x3 a lot.
>
> What we propose here is a way for those applications to enjoy the
> boost and still not sacrifice any correctness of legacy applications.
> Any concurrent access from legacy apps vs nv-aware apps even to the same
> file / same page, will work correctly.
>
> We do that by defining a new MMAP flag that is set by the nv-aware
> app. this flag is carried by the VMA. In the dax code we bypass any
> radix handling of the page if this flag is set. Those pages accessed *without*
> this flag will be added to the radix-tree, those with will not.
> At m/fsync time if the radix tree is then empty nothing will happen.
>
> These are very simple none intrusive patches with minimum risk. (I think)
> They are based on v4.5-rc5. If you need a rebase on any other tree please
> say.
>
> Please consider this new flag for those of us people who specialize in
> persistent-memory setups and want to extract any possible mileage out
> of our systems.
>
> Also attached for reference a 3rd patch to the nvml library to use
> the new flag. Which brings me to the issue of persistent_memcpy / persistent_flush.
> Currently this library is for x86_64 only, using the movnt instructions. The gcc
> compiler should have a per ARCH facility for durable memory accesses. So applications
> can be portable across systems.
>
> Please advise?

When this came up a couple weeks ago [1], the conclusion I came away
with is that if an application wants to avoid the overhead of DAX
semantics it needs to use an alternative to DAX access methods.  Maybe
a new pmem aware fs like Nova [2], or some other mechanism that
bypasses the semantics that existing applications on top of ext4 and
xfs expect.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2016-February/004411.html
[2]: http://sched.co/68kS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
