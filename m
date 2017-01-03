Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1226B025E
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 05:25:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so78512597wmf.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 02:25:42 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id z80si73008316wmd.57.2017.01.03.02.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 02:25:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id A50EC1C2509
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 10:25:40 +0000 (GMT)
Date: Tue, 3 Jan 2017 10:24:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Message-ID: <20170103102439.4fienez2fkgqwbrd@techsingularity.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161229152615.2dad5402@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Thu, Dec 29, 2016 at 03:26:15PM +1000, Nicholas Piggin wrote:
> > And I fixed that too.
> > 
> > Of course, I didn't test the changes (apart from building it). But
> > I've been running the previous version since yesterday, so far no
> > issues.
> 
> It looks good to me.
> 

FWIW, I blindly queued a test of Nick's patch, Linus' patch on top and
PeterZ's patch using 4.9 as a baseline so all could be applied cleanly.
3 machines were used, one one of them NUMA with 2 sockets. The UMA
machines showed nothing unusual.

kernel building showed nothing unusual on any machine

git checkout in a loop showed;
	o minor gains with Nick's patch
	o no impact from Linus's patch
	o flat performance from PeterZ's

git test suite showed
	o close to flat performance on all patches
	o Linus' patch on top showed increased variability but not serious

will-it-scale pagefault tests
	o page_fault1 and page_fault2 showed no differences in processes

	o page_fault3 using processes did show some large losses at some
	  process counts on all patches. The losses were not consistent on
	  each run. There also was no consistently at loss with increasing
	  process counts. It did appear that Peter's patch had fewer
	  problems with only one thread count showing problems so it
	  *may* be more resistent to the problem but not completely and
	  it's not obvious why it might be so it could be a testing
	  anomaly

	o page_fault3 using threads didn't show anything unusual. It's
	  possible that any problem with the waitqueue lookups is hidden
	  by mmap_sem

I think I can see something similar to Dave but not consistently and not as
severe and only using processes for page_fault3. Linus's patch appears to
help a little but not eliminate the problem. Given the machine only had 2
sockets, it's prefectly possible that Dave can see a consistent problem that
I cannot. During the test run, I hadn't collected the profiles to see what
is going on as the test queueing was a drive-by bit of work while on holiday.

Reading both Nick's (which is already merged so somewhat moot) and
PeterZ's patch, I did find Nick's easier to understand with some minor
gripes about naming. 

None of the patches showed the same lost wakeup I'd seen once on earlier
prototypes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
