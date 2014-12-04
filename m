Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 098EC6B007D
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:52:10 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so29254422wiv.1
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:52:09 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id ei8si48593720wid.22.2014.12.04.12.52.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 12:52:09 -0800 (PST)
Date: Thu, 4 Dec 2014 20:52:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
Message-ID: <20141204205202.GP29748@ZenIV.linux.org.uk>
References: <547E3E57.3040908@ixiacom.com>
 <20141204175713.GE2995@htj.dyndns.org>
 <5480BFAA.2020106@ixiacom.com>
 <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Leonard Crestez <lcrestez@ixiacom.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, Dec 04, 2014 at 02:28:10PM -0600, Christoph Lameter wrote:
> On Thu, 4 Dec 2014, Leonard Crestez wrote:
> 
> > Yes, we are actually experiencing issues with this. We create lots of virtual
> > net_devices and routes, which means lots of percpu counters/pointers. In particular
> > we are getting worse performance than in older kernels because the net_device refcnt
> > is now a percpu counter. We could turn that back into a single integer but this
> > would negate an upstream optimization.
> 
> Well this is not a common use case and that is not what the per cpu
> allocator was designed for. There is bound to be signifcant fragmentation
> with the current design. The design was for rare allocations when
> structures are initialized.

... except that somebody has not known that and took refcounts on e.g.
vfsmounts into percpu.  With massive amounts of hilarity once docker folks
started to test the workloads that created/destroyed those in large amounts.

> > Having a "properly scalable" percpu allocator would be quite nice indeed.
> 
> I guess we would be looking at a redesign of the allocator then.

FWIW, I think I've already dealt with most of the crap, but I've no idea
if networking-related callers end up with similar use patterns.  For vfsmounts
it seems to suffice...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
