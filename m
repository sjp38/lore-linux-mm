Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E17F36B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:18:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so80180963wmu.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:18:29 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id jw9si77921498wjb.145.2017.01.03.09.18.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 09:18:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 3DB4099122
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 17:18:28 +0000 (UTC)
Date: Tue, 3 Jan 2017 17:18:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Message-ID: <20170103171827.mj6bpclerz2xwesx@techsingularity.net>
References: <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com>
 <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <20161228135358.59f47204@roar.ozlabs.ibm.com>
 <CA+55aFz-evT+NiZY0GhO719M+=u==TbCqxTJTjp+pJevhDnRrw@mail.gmail.com>
 <20161229140837.5fff906d@roar.ozlabs.ibm.com>
 <CA+55aFxGz8R8J9jLvKpLUgyhWVYcgtObhbHBP7eZzZyc05AODw@mail.gmail.com>
 <20161229152615.2dad5402@roar.ozlabs.ibm.com>
 <20170103102439.4fienez2fkgqwbrd@techsingularity.net>
 <20170103222958.4a2ce0e6@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170103222958.4a2ce0e6@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Tue, Jan 03, 2017 at 10:29:58PM +1000, Nicholas Piggin wrote:
> > kernel building showed nothing unusual on any machine
> > 
> > git checkout in a loop showed;
> > 	o minor gains with Nick's patch
> > 	o no impact from Linus's patch
> > 	o flat performance from PeterZ's
> > 
> > git test suite showed
> > 	o close to flat performance on all patches
> > 	o Linus' patch on top showed increased variability but not serious
> 
> I'd be really surprised if Linus's patch is actually adding variability
> unless it is just some random cache or branch predictor or similar change
> due to changed code sizes. Testing on skylake CPU showed the old sequence
> takes a big stall with the load-after-lock;op hazard.
> 
> So I wouldn't worry about it too much, but maybe something interesting to
> look at for someone who knows x86 microarchitectures well.
> 

Agreed, it looked like a testing artifact. Later in the day it was obvious
that different results were obtained between boots and minor changes
in timing.

It's compounded by the fact that this particular test is based on /tmp so
different people will get different results depending on the filesystem. In
my case, that was btrfs.

> > 
> > will-it-scale pagefault tests
> > 	o page_fault1 and page_fault2 showed no differences in processes
> > 
> > 	o page_fault3 using processes did show some large losses at some
> > 	  process counts on all patches. The losses were not consistent on
> > 	  each run. There also was no consistently at loss with increasing
> > 	  process counts. It did appear that Peter's patch had fewer
> > 	  problems with only one thread count showing problems so it
> > 	  *may* be more resistent to the problem but not completely and
> > 	  it's not obvious why it might be so it could be a testing
> > 	  anomaly
> 
> Okay. page_fault3 has each process doing repeated page faults on their
> own 128MB file in /tmp. Unless they fill memory and start to reclaim,
> (which I believe must be happening in Dave's case) there should be no
> contention on page lock. After the patch, the uncontended case should
> be strictly faster when there is no contention.
> 

It's possible in the test that I setup that it's getting screwed by the
filesystem used. It's writing that array and on a COW filesystem there
is a whole bucket of variables such as new block allocations, writeback
timing etc. The writeback timing alone means that this test is questionable
because the results will depend on when background writeback triggers. I'm
not sure how Dave is controlling for these factors.

As an aside, will-it-scale page_fault was one of the tests I had dropped way
down on my list of priorities to watch a long time ago.  It's a short-lived
filesystem-based test vunerable to timing issues and highly variable that
didn't seem worth controlling for at the time. I queued the test for a look
on the rough offchance your patches were falling over something obvious. If
it is, I haven't spotted it yet. Profiles are very similar. Separate
runs with lock stat show detectable but negligable contentions on
page_wait_table. The bulk of the contention is within the filesystem.

> When there is contention, there is an added cost of setting and clearing
> page waiters bit. Maybe there is some other issue there... are you seeing
> the losses in uncontended case, contended, or both?
> 

I couldn't determine from the profile whether it was uncontended or not.
The fact that there are boot-to-boot variations makes it difficult
to determine if a profile vs !profile run is equivalent without using
debugging patches to gather stats. lock_stat does show large numbers of
contentions all right but the vast bulk of them are internal to btrfs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
