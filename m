Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 355A76B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 03:18:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so24925613lfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 00:18:16 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 84si1626855wme.113.2016.07.08.00.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 00:18:14 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k123so3072326wme.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 00:18:14 -0700 (PDT)
Date: Fri, 8 Jul 2016 09:18:10 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160708071810.GA27457@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <577E924C.6010406@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk


* Dave Hansen <dave@sr71.net> wrote:

> > Applications that frequently get called will get hammed into the ground with 
> > serialisation on mmap_sem not to mention the cost of the syscall entry/exit.
>
> I think we can do both of them without mmap_sem, as long as we resign ourselves 
> to this just being fundamentally racy (which it is already, I think).  But, is 
> it worth performance-tuning things that we don't expect performance-sensitive 
> apps to be using in the first place?  They'll just use the RDPKRU/WRPKRU 
> instructions directly.
>
> Ingo, do you still feel strongly that these syscalls (pkey_set/get()) should be 
> included?  Of the 5, they're definitely the two with the weakest justification.

Firstly, I'd like to thank Mel for the review, having this kind of high level 
interface discussion was exactly what I was hoping for before we merged any ABI 
patches.

So my hope was that we'd also grow some debugging features: such as a periodic 
watchdog timer clearing all non-allocated pkeys of a task and re-setting them to 
their (kernel-)known values and thus forcing user-space to coordinate key 
allocation/freeing.

While allocation/freeing of keys is very likely a slow path in any reasonable 
workload, _setting_ the values of pkeys could easily be a fast path. The whole 
point of pkeys is to allow both thread local and dynamic mapping and unmapping of 
memory ranges, without having to touch any page table attributes in the hot path.

Now another, more fundamental question is that pkeys are per-CPU (per thread) on 
the hardware side - so why do we even care about the mmap_sem in the syscalls in 
the first place? If we want any serialization wouldn't a pair of 
get_cpu()/put_cpu() preemption control calls be enough? Those would also be much 
cheaper.

The idea behind my suggestion to manage all pkey details via a kernel interface 
and 'shadow' the pkeys state in the kernel was that if we don't even offer a 
complete system call interface then user-space is _forced_ into using the raw 
instructions and into implementing a (potentially crappy) uncoordinated API or not 
implementing any API at all but randomly using fixed pkey indices.

My hope was to avoid that, especially since currently _all_ memory mapping details 
on x86 are controlled via system calls. If we don't offer that kind of facility 
then we force user-space into using the raw instructions and will likely end up 
with a poor user-space interface.

So the question is, what is user-space going to do? Do any glibc patches exist? 
How are the user-space library side APIs going to look like?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
