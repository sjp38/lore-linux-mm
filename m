From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003202058.MAA47885@google.engr.sgi.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
Date: Mon, 20 Mar 2000 12:58:23 -0800 (PST)
In-Reply-To: <14546.9883.575748.695740@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Mar 17, 2000 12:35:39 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 13 Mar 2000 17:50:50 -0500 (EST), Ben LaHaise <bcrl@redhat.com>
> said:
> 
> > This is the first little bit of a few vm balancing patches I've been
> > working on.  
> 
> Just out of interest, is anyone working on fixing the zone balancing?
> 
> The current behaviour is highly suboptimal: if you have two zones to
> pick from for a given alloc_page(), and the first zone is at its
> pages_min threshold, then we will always allocate from that first zone
> and push it into kswap activation no matter how much free space there is
> in the next zone.

Hmm, I disagree for 2.3.50 and pre1 ... note that the decision of 
low-memoryness is taken based on _cumulative_ free and number of pages, 
so whether you allocate from the regular or dma zone, you should be 
stealing and poking kswapd roughly the same number of times. As far as 
I can see, spreading the allocation over lower class zones does not seem 
to have advantages in this case.

With Linus' change to the page alloc code in pre2, yes, spreading
the allocation is an option, but I would be real careful before 
putting that in 2.4.

Kanoj

> 
> The net effect of this is that we may not _ever_ end up using the next
> zone for allocations if the request trickle in slowly enough; and that
> either way, the memory use between the two zones is unbalanced.  On an
> 8GB box it may be reasonable to keep the lomem zone for non-himem
> allocations, but on 2GB we probably want to allocate page cache and user
> pages as fairly as possible above and below 1GB.
> 
> --Stephen
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
