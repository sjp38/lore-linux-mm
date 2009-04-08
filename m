Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4825F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 02:18:35 -0400 (EDT)
Date: Wed, 8 Apr 2009 08:21:07 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090408062107.GE17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407224709.742376ff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407224709.742376ff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 10:47:09PM -0700, Andrew Morton wrote:
> On Tue,  7 Apr 2009 17:09:56 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Upcoming Intel CPUs have support for recovering from some memory errors. This
> > requires the OS to declare a page "poisoned", kill the processes associated
> > with it and avoid using it in the future. This patchkit implements
> > the necessary infrastructure in the VM.
> 
> Seems that this feature is crying out for a testing framework (perhaps
> it already has one?). 

Multiple ones in fact.

One of them is 

git://git.kernel.org/pub/scm/utils/cpu/mce/mce-test.git
(test suite covering various cases)

git://git.kernel.org/pub/scm/utils/cpu/mce/mce-inject.git
(injector using the x86 specific error injection hooks I posted
earlier)

Then i have some tests using the madvise MADV_POISON hook
(which tests the various cases from a process stand points
and recovers). This is still a little hackish, but if there's
interest I can put it out. It has at least one test case
that is known to hang (non linear mappings), still looking
at that.

Long term plan was to put both mce-test above and the
MADV_POISON test into LTP.

And a few random hacks. But coverage is still not 100%

> A simplistic approach would be

Random kill anywhere is hard to test because your system will
die regularly and randomly. mce-test.git does some automated
testing of fatal errors by catching them using kexec, but we haven't
tried that for full recovery.

> 
> 	echo some-pfn > /proc/bad-pfn-goes-here
> 
> A slightly more sophisticated version might do the deed from within a
> timer interrupt, just to get a bit more coverage.

mce-test/inject does it from other CPUs with smp_function_call_single,
so it's really relatively random. I've considered to use NMIs too,
but at least the high level recovery code synchronizes first
to work queue context anyways, so it doesn't buy us too much for that.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
