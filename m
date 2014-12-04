Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 626116B0075
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:42:38 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id j7so12536044qaq.15
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:42:38 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com. [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id i5si32566240qcm.41.2014.12.04.12.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 12:42:37 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id v10so12608195qac.35
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:42:36 -0800 (PST)
Date: Thu, 4 Dec 2014 15:42:33 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
Message-ID: <20141204204233.GD4080@htj.dyndns.org>
References: <547E3E57.3040908@ixiacom.com>
 <20141204175713.GE2995@htj.dyndns.org>
 <5480BFAA.2020106@ixiacom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5480BFAA.2020106@ixiacom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonard Crestez <lcrestez@ixiacom.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, Dec 04, 2014 at 10:10:18PM +0200, Leonard Crestez wrote:
> Yes, we are actually experiencing issues with this. We create lots of virtual
> net_devices and routes, which means lots of percpu counters/pointers. In particular
> we are getting worse performance than in older kernels because the net_device refcnt
> is now a percpu counter. We could turn that back into a single integer but this
> would negate an upstream optimization.
> 
> We are working on top of linux_3.10. We already pulled some allocation optimizations.
> At least for simple allocation patterns pcpu_alloc does not appear to be unreasonably
> slow.

Yeah, it got better for simpler patterns with Al's recent
optimizations.  Is your use case suffering heavily from percpu
allocator overhead even with the recent optimizations?

> Having a "properly scalable" percpu allocator would be quite nice indeed.

Yeah, at the beginning, the expected (and existing at the time) use
cases were fairly static and limited and the dumb scanning allocator
worked fine.  The usages grew a lot over the years, so, yeah, we
prolly want something more scalable.  I haven't seriously thought
about the details yet tho.  The space overhead is a lot higher than
usual memory allocators, so we do want something which can pack things
tighter.  Given that there are a lot of smaller allocations anyway,
maybe just converting the current implementation to bitmap based one
is enough.  If we set the min alignment at 4 bytes which should be
fine, the bitmap overhead is slightly over 3% of the chunk size which
should be fine.  My hunch is that the current allocator is already
using more than that on average.  Are you interested in pursuing it?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
