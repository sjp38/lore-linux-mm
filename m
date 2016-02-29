Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7026B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:32:56 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id y89so125590014qge.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:32:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d9si27451960qgf.7.2016.02.29.12.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:32:55 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<56CCD54C.3010600@plexistor.com>
	<CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
	<x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
	<x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
	<x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
	<20160224225623.GL14668@dastard>
	<x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
	<20160225212059.GB30721@dastard>
Date: Mon, 29 Feb 2016 15:32:51 -0500
In-Reply-To: <20160225212059.GB30721@dastard> (Dave Chinner's message of "Fri,
	26 Feb 2016 08:20:59 +1100")
Message-ID: <x4937sbl0jw.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dave Chinner <david@fromorbit.com> writes:

> On Thu, Feb 25, 2016 at 11:24:57AM -0500, Jeff Moyer wrote:
>> But, it seems plausible to me that no matter how well you
>> optimize your msync implementation, it will still be more expensive than
>> an application that doesn't call msync at all.  This obviously depends
>> on how the application is using the programming model, among other
>> things.  I agree that we would need real data to back this up.  However,
>> I don't see any reason to preclude such an implementation, or to leave
>> it as a last resort.  I think it should be part of our planning process
>> if it's reasonably feasible.
>
> Essentially I see this situation/request as conceptually the same as
> O_DIRECT for read/write - O_DIRECT bypasses the kernel dirty range
> tracking and, as such, has nasty cache coherency issues when you mix
> it with buffered IO. Nor does it play well with mmap, it has
> different semantics for every filesystem and the kernel code has
> been optimised to the point of fragility.
>
> And, of course, O_DIRECT requires applications to do exactly the
> right things to extract performance gains and maintain data
> integrity. If they get it right, they will be faster than using the
> page cache, but we know that applications often get it very wrong.
> And even when they get it right, data corruption can still occur
> because some thrid party accessed file in a different manner (e.g. a
> backup) and triggered one of the known, fundamentally unfixable
> coherency problems.
>
> However, despite the fact we are stuck with O_DIRECT and it's
> deranged monkeys (which I am one of), we should not be ignoring the
> problems that bypassing the kernel infrastructure has caused us and
> continues to cause us. As such, we really need to think hard about
> whether we should be repeating the development of such a bypass
> feature. If we do, we stand a very good chance of ending up in the
> same place - a bunch of code that does not play well with others,
> and a nightmare to test because it's expected to work and not
> corrupt data...
>
> We should try very hard not to repeat the biggest mistake O_DIRECT
> made: we need to define and document exactly what behaviour we
> guarantee, how it works and exaclty what responsisbilities the
> kernel and userspace have in *great detail* /before/ we add the
> mechanism to the kernel.
>
> Think it through carefully - API changes and semantics are forever.
> We don't want to add something that in a couple of years we are
> wishing we never added....

I agree with everything you wrote, there.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
