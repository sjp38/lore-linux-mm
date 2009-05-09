Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D154E6B009E
	for <linux-mm@kvack.org>; Sat,  9 May 2009 00:04:49 -0400 (EDT)
Date: Fri, 8 May 2009 21:04:18 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090509040418.GA29306@eskimo.com>
References: <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <alpine.DEB.1.10.0905070935530.24528@qirst.com> <1241705702.11251.156.camel@twins> <alpine.DEB.1.10.0905071016410.24528@qirst.com> <1241712000.18617.7.camel@lts-notebook> <alpine.DEB.1.10.0905071231090.10171@qirst.com> <4A03164D.90203@redhat.com> <20090508034054.GB1202@eskimo.com> <4A04580B.5050501@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A04580B.5050501@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Elladan <elladan@eskimo.com>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 08, 2009 at 12:04:27PM -0400, Rik van Riel wrote:
> Elladan wrote:
>
>>> Nobody (except you) is proposing that we completely disable
>>> the eviction of executable pages.  I believe that your idea
>>> could easily lead to a denial of service attack, with a user
>>> creating a very large executable file and mmaping it.
>>>
>>> Giving executable pages some priority over other file cache
>>> pages is nowhere near as dangerous wrt. unexpected side effects
>>> and should work just as well.
>>
>> I don't think this sort of DOS is relevant for a single user or trusted user
>> system.  
>
> Which not all systems are, meaning that the mechanism
> Christoph proposes can never be enabled by default and
> would have to be tweaked by the user.
>
> I prefer code that should work just as well 99% of the
> time, but can be enabled by default for everybody.
> That way people automatically get the benefit.

I read Christopher's proposal as essentially, "have a desktop switch which
won't evict executable pages unless they're using more than some huge
percentage of RAM" (presumably, he wants anonymous pages to get special
treatment too) -- this would essentially be similar to mlocking all your
executables, only with a safety net if you go above x% and without affecting
non-executable file maps.

Given that, the DOS possibility you proposed seemed to just be one where a user
could push a lot of unprotected pages out quickly and make the system run slow.

I don't see how that's any different than just asking malloc() for a lot of ram
and then touching it a lot to make it appear very hot to the VM.  Any user can
trivially do that already, and some apps (eg. a jvm) happily do that for you.
The pathology is the same, and if anything an executable mmap is harder.

-E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
