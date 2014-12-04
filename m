Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 82C4B6B006E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:10:45 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so12860045pde.26
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:10:45 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0095.outbound.protection.outlook.com. [157.56.110.95])
        by mx.google.com with ESMTPS id bw5si13253627pdb.241.2014.12.04.12.10.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Dec 2014 12:10:43 -0800 (PST)
Message-ID: <5480BFAA.2020106@ixiacom.com>
Date: Thu, 4 Dec 2014 22:10:18 +0200
From: Leonard Crestez <lcrestez@ixiacom.com>
MIME-Version: 1.0
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
References: <547E3E57.3040908@ixiacom.com> <20141204175713.GE2995@htj.dyndns.org>
In-Reply-To: <20141204175713.GE2995@htj.dyndns.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Sorin Dumitru <sdumitru@ixiacom.com>

On 12/04/2014 07:57 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Dec 03, 2014 at 12:33:59AM +0200, Leonard Crestez wrote:
>> It seems that free_percpu performance is very bad when working with small 
>> objects. The easiest way to reproduce this is to allocate and then free a large 
>> number of percpu int counters in order. Small objects (reference counters and 
>> pointers) are common users of alloc_percpu and I think this should be fast.
>> This particular issue can be encountered with very large number of net_device
>> structs.
> 
> Do you actually experience this with an actual workload?  The thing is
> allocation has the same quadratic complexity.  If this is actually an
> issue (which can definitely be the case), I'd much prefer implementing
> a properly scalable area allocator than mucking with the current
> implementation.

Yes, we are actually experiencing issues with this. We create lots of virtual
net_devices and routes, which means lots of percpu counters/pointers. In particular
we are getting worse performance than in older kernels because the net_device refcnt
is now a percpu counter. We could turn that back into a single integer but this
would negate an upstream optimization.

We are working on top of linux_3.10. We already pulled some allocation optimizations.
At least for simple allocation patterns pcpu_alloc does not appear to be unreasonably
slow.

Having a "properly scalable" percpu allocator would be quite nice indeed.

Regards,
Leonard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
