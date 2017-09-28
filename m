Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9079E6B0261
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:47:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p126so2124388oih.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 07:47:18 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u31si1263508oti.358.2017.09.28.07.47.17
        for <linux-mm@kvack.org>;
        Thu, 28 Sep 2017 07:47:17 -0700 (PDT)
Date: Thu, 28 Sep 2017 15:45:38 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
Message-ID: <20170928144538.GA32487@leverpostej>
References: <20170928112727.GA11310@leverpostej>
 <59CD093A.6030201@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59CD093A.6030201@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, syzkaller@googlegroups.com, "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>

On Thu, Sep 28, 2017 at 04:37:46PM +0200, Daniel Borkmann wrote:
> On 09/28/2017 01:27 PM, Mark Rutland wrote:
> >Hi,
> >
> >While fuzzing v4.14-rc2 with Syzkaller, I found it was possible to trigger the
> >warning at mm/percpu.c:1361, on both arm64 and x86_64. This appears to require
> >increasing RLIMIT_MEMLOCK, so to the best of my knowledge this cannot be
> >triggered by an unprivileged user.
> >
> >I've included example splats for both x86_64 and arm64, along with a C
> >reproducer, inline below.
> >
> >It looks like dev_map_alloc() requests a percpu alloction of 32776 bytes, which
> >is larger than the maximum supported allocation size of 32768 bytes.
> >
> >I wonder if it would make more sense to pr_warn() for sizes that are too
> >large, so that callers don't have to roll their own checks against
> >PCPU_MIN_UNIT_SIZE?
> 
> Perhaps the pr_warn() should be ratelimited; or could there be an
> option where we only return NULL, not triggering a warn at all (which
> would likely be what callers might do anyway when checking against
> PCPU_MIN_UNIT_SIZE and then bailing out)?

Those both make sense to me; checking __GFP_NOWARN should be easy
enough.

Just to check, do you think that dev_map_alloc() should explicitly test
the size against PCPU_MIN_UNIT_SIZE, prior to calling pcpu_alloc()?

I can spin both patches if so.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
