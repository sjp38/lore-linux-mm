Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A628E6002CC
	for <linux-mm@kvack.org>; Tue, 25 May 2010 13:20:11 -0400 (EDT)
Date: Wed, 26 May 2010 03:19:59 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525171959.GH20853@laptop>
References: <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
 <20100525081634.GE5087@laptop>
 <AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
 <20100525093410.GH5087@laptop>
 <AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
 <20100525101924.GJ5087@laptop>
 <AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
 <alpine.LFD.2.00.1005250812100.3689@i5.linux-foundation.org>
 <20100525154352.GB20853@laptop>
 <AANLkTilEIwPSN-stGGuu5wV4Q6Ty0GytNMpfq-vRpK_k@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTilEIwPSN-stGGuu5wV4Q6Ty0GytNMpfq-vRpK_k@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 08:02:32PM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Tue, May 25, 2010 at 6:43 PM, Nick Piggin <npiggin@suse.de> wrote:
> > As far as I can see, there was never a good reason to replace SLAB
> > rather than clean up its code and make incremental improvements.
> 
> I'm not totally convinced but I guess we're about to find that out.
> How do you propose we benchmark SLAB while we clean it up

Well the first pass will be code cleanups, bootstrap simplifications.
Then looking at what debugging features were implemented in SLUB but not
SLAB and what will be useful to bring over from there.

At this point the aim would be for actual allocation behaviour with
non-debug settings to be unchanged. Hopefully this removes everyone's
(apparently) largest gripe that code is crufty.

Next would be to add some options to tweak queue sizes and disable
cache reaping at runtime, for the benfit of the low jitter crowd,
see if any further hotplug fixes are required.

Then would be to propose incremental improvements to actual algorithm.
For example, replacing the alien cache crossbar with a lighter weight
or more scalable structure.


> and change
> things to make sure we don't make the same mistakes as we did with
> SLUB (i.e. miss an important workload like TPC-C)?

Obviously it is impossible to make forward progress and also catch
all regressions before release. This fact means that we have to be
able to cope with them as well as possible.

We get two benefits from starting with SLAB. Firstly, we get a larger
testing base. Secondly, we get a simple (ie. git revert) formula of how
to get from good behaviour to bad behaviour.

I don't anticipate a huge number of functional changes to SLAB here
though. It's surprisingly hard to do better than it. alien caches are
one area, maybe configurable higher order allocation support, jitter
reduction.

If we do get a big proposed change in the pipeline, then we have to
eat it somehow, but AFAIKS we've still got a better foundation than
starting with a completely new allocator and feeling around in the
dark trying to move it past SLAB in terms of performance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
