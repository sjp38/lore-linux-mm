Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 57A5C6B0034
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:16:25 -0400 (EDT)
Date: Mon, 15 Jul 2013 10:16:23 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130715151623.GB3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712082756.GA4328@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Borislav Petkov <bp@alien8.de>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jul 12, 2013 at 10:27:56AM +0200, Ingo Molnar wrote:
> 
> * Robin Holt <holt@sgi.com> wrote:
> 
> > [...]
> > 
> > With this patch, we did boot a 16TiB machine.  Without the patches, the 
> > v3.10 kernel with the same configuration took 407 seconds for 
> > free_all_bootmem.  With the patches and operating on 2MiB pages instead 
> > of 1GiB, it took 26 seconds so performance was improved.  I have no feel 
> > for how the 1GiB chunk size will perform.
> 
> That's pretty impressive.

And WRONG!

That is a 15x speedup in the freeing of memory at the free_all_bootmem
point.  That is _NOT_ the speedup from memmap_init_zone.  I forgot to
take that into account as Nate pointed out this morning in a hallway
discussion.  Before, on the 16TiB machine, memmap_init_zone took 1152
seconds.  After, it took 50.  If it were a straight 1/512th, we would
have expected that 1152 to be something more on the line of 2-3 so there
is still significant room for improvement.

Sorry for the confusion.

> It's still a 15x speedup instead of a 512x speedup, so I'd say there's 
> something else being the current bottleneck, besides page init 
> granularity.
> 
> Can you boot with just a few gigs of RAM and stuff the rest into hotplug 
> memory, and then hot-add that memory? That would allow easy profiling of 
> remaining overhead.

Nate and I will be working on other things for the next few hours hoping
there is a better answer to the first question we asked about there
being a way to test a page other than comparing against all zeroes to
see if it has been initialized.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
