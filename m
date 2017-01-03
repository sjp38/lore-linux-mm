Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 802576B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 07:30:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so1282180266pgn.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 04:30:32 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b35si57842883plh.218.2017.01.03.04.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 04:30:31 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 127so15713268pfg.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 04:30:31 -0800 (PST)
Date: Tue, 3 Jan 2017 22:29:58 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting
 for a page bit
Message-ID: <20170103222958.4a2ce0e6@roar.ozlabs.ibm.com>
In-Reply-To: <20170103102439.4fienez2fkgqwbrd@techsingularity.net>
References: <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
	<20161226111654.76ab0957@roar.ozlabs.ibm.com>
	<CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
	<20161227211946.3770b6ce@roar.ozlabs.ibm.com>
	<CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
	<20161228135358.59f47204@roar.ozlabs.ibm.com>
	<CA+55aFz-evT+NiZY0GhO719M+=u==TbCqxTJTjp+pJevhDnRrw@mail.gmail.com>
	<20161229140837.5fff906d@roar.ozlabs.ibm.com>
	<CA+55aFxGz8R8J9jLvKpLUgyhWVYcgtObhbHBP7eZzZyc05AODw@mail.gmail.com>
	<20161229152615.2dad5402@roar.ozlabs.ibm.com>
	<20170103102439.4fienez2fkgqwbrd@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Tue, 3 Jan 2017 10:24:39 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Thu, Dec 29, 2016 at 03:26:15PM +1000, Nicholas Piggin wrote:
> > > And I fixed that too.
> > > 
> > > Of course, I didn't test the changes (apart from building it). But
> > > I've been running the previous version since yesterday, so far no
> > > issues.  
> > 
> > It looks good to me.
> >   
> 
> FWIW, I blindly queued a test of Nick's patch, Linus' patch on top and
> PeterZ's patch using 4.9 as a baseline so all could be applied cleanly.
> 3 machines were used, one one of them NUMA with 2 sockets. The UMA
> machines showed nothing unusual.

Hey thanks Mel.

> 
> kernel building showed nothing unusual on any machine
> 
> git checkout in a loop showed;
> 	o minor gains with Nick's patch
> 	o no impact from Linus's patch
> 	o flat performance from PeterZ's
> 
> git test suite showed
> 	o close to flat performance on all patches
> 	o Linus' patch on top showed increased variability but not serious

I'd be really surprised if Linus's patch is actually adding variability
unless it is just some random cache or branch predictor or similar change
due to changed code sizes. Testing on skylake CPU showed the old sequence
takes a big stall with the load-after-lock;op hazard.

So I wouldn't worry about it too much, but maybe something interesting to
look at for someone who knows x86 microarchitectures well.

> 
> will-it-scale pagefault tests
> 	o page_fault1 and page_fault2 showed no differences in processes
> 
> 	o page_fault3 using processes did show some large losses at some
> 	  process counts on all patches. The losses were not consistent on
> 	  each run. There also was no consistently at loss with increasing
> 	  process counts. It did appear that Peter's patch had fewer
> 	  problems with only one thread count showing problems so it
> 	  *may* be more resistent to the problem but not completely and
> 	  it's not obvious why it might be so it could be a testing
> 	  anomaly

Okay. page_fault3 has each process doing repeated page faults on their
own 128MB file in /tmp. Unless they fill memory and start to reclaim,
(which I believe must be happening in Dave's case) there should be no
contention on page lock. After the patch, the uncontended case should
be strictly faster when there is no contention.

When there is contention, there is an added cost of setting and clearing
page waiters bit. Maybe there is some other issue there... are you seeing
the losses in uncontended case, contended, or both?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
