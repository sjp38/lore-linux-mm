Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6234E6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:54:37 -0500 (EST)
Date: Fri, 19 Dec 2008 07:56:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081219065642.GE16268@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de> <1229668492.17206.594.camel@nimitz> <20081219065242.GD16268@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081219065242.GD16268@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19, 2008 at 07:52:42AM +0100, Nick Piggin wrote:
> On Thu, Dec 18, 2008 at 10:34:52PM -0800, Dave Hansen wrote:
> > Yes, I think it can tolerate it.  There's a lot of work to do, and we
> > already have to go touch all the other per-cpu objects.  There also
> > tends to be writeout when this happens, so I don't think a few seconds,
> > even, will be noticed.
> 
> That would be good. After the first patch, mnt_want_write still shows up
> on profiles and almost oall the hits come right after the msync from
> the smp_mb there.
> 
> It would be really nice to use RCU here. I think it might allow us to
> eliminate the memory barriers.

Actually we might be able to use a seqcounter to eliminate the most
expensive (smp_mb()) barrier. But that's more code and adds a couple
of smp_rmb()s which would be slower on some architectures.... Not to
mention more code and branches.

But I'll investigate that option if RCU is ruled out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
