Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
References: <Pine.LNX.4.10.9911031736450.7408-100000@chiara.csoma.elte.hu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Nov 1999 12:55:14 -0600
In-Reply-To: Ingo Molnar's message of "Wed, 3 Nov 1999 17:46:59 +0100 (CET)"
Message-ID: <m1iu3jxv59.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Christoph Rohland <hans-christoph.rohland@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@chiara.csoma.elte.hu> writes:

> On 3 Nov 1999, Eric W. Biederman wrote:
> 
> > Not really.  I played with the idea, and the only really tricky aspect I saw
> > was how to write a version of copy_to/from_user that would handle the bigmem
> > case.   Because kmap ... copy .. kunmap  isn't safe as you can sleep due
> > to a page fault.
> 
> yes, i implemented a new 'kaddr = kmap_permanent(page)'
> 'kunmap_permanent(kaddr)' interface which is schedulable. This is now
> getting used in exec.c (argument pages can be significantly big) and the
> page cache.

Do you have a patch around that the rest of us can look at?

> that is a much more problematic issue, especially if you consider future
> 64-bit PCI DMAing. What i did was to change bh->b_data to bh->b_page,
> which b_page is a 32-bit value describing the physical address of the
> buffer, in 512-byte units. This also ment changing bazillion places where
> b_data was used (lowlevel fs, buffer-cache and block layer, device
> drivers) ... But it's working just fine on my box:

Click.
Which lets up access up to 2Terabytes of ram, on a 32 bit machine.
And you have to do something like that or you can't put buffers on
those high pages even temporarily.  I missed that trick.

> > I'll probably get back to shmfs in a kernel version or two.
> 
> looking forward to test it, i believe we could get some spectacular
> benchmark numbers with that thing and 2.4 ...

We'll see. I just want to get it functional first.
There are no binary compatibility constrainsts so after it works
any optimizations are easy :)

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
