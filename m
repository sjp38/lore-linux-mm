From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ebizzy performance with different allocators
Date: Tue, 25 Mar 2008 16:36:51 +1100
References: <200803172321.31572.nickpiggin@yahoo.com.au> <70b6f0bf0803171919t9ba6cbewbc03c9ddae63c255@mail.gmail.com>
In-Reply-To: <70b6f0bf0803171919t9ba6cbewbc03c9ddae63c255@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803251636.51474.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valerie Henson <val@vahconsulting.com>
Cc: opensource@google.com, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 18 March 2008 13:19, Valerie Henson wrote:
> [Cc'd current ebizzy maintainer, Rodrigo.]
>
> On Mon, Mar 17, 2008 at 5:21 AM, Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > Hi,
> >
> >  I was recently interested in ebizzy performance, and specifically the
> >  reason why Linux doesn't appear to scale very well versus FreeBSD.
>
> [snip]
>
> >  linux-glibc was the best single-threaded performer, with ~7000 r/s,
> >  however it starts running into system time which the profile shows up
> >  as unmapping pages and faulting in new pages. Is "fixing" this as simple
> >  as increasing hysteresis in glibc? Can that be done via environment? (I
> >  couldn't work out a way).
>
> Huh, yeah, that sounds like glibc is mmap()'ing your allocations.
> Check to see if your glibc version includes this patch:
>
> http://www.valhenson.org/patches/dynamic_mmap_threshold

Yes AFAIKS it does (went into glibc 2.5 I think?)


> If it does, you shouldn't see much in the way of mmap/munmap activity
> when running ebizzy.  It's possible that some other malloc() settings
> are interfering, maybe the trim threshold.  It's also worth noting
> that the self-tuning mmap threshold is disabled if the user sets the
> mmap threshold explicitly.

I didn't set any options.

Hmm, I see from the strace that mmap actually shouldn't be a problem. It
is just a high rate of madvise causing TLB shootdown IPIs I think. Which
means that jemalloc is probably not freeing memory back to the OS as
aggressively as glibc...

I guess glibc could keep around a few more free pages and free them in
batches to reduce this. We could provide some kind of vectored madvise
or munmap if this proves to be really beneficial.

FWIW, glibc malloc performs better than my jemalloc port on that
pathalogical MySQL workload...

> Oh, and is this 32-bit or 64-bit? 

64.


> If you want to tune the exact behavior of malloc with regard to mmap, check
> out:
>
> http://www.gnu.org/software/libtool/manual/libc/Malloc-Tunable-Parameters.h
>tml
>
> If you use the "-M" option to ebizzy, it will use mallopt() to turn
> off mmap()'d allocations entirely. (It'd be nice to have command line
> knobs for all the mallopt() tuning options, actually.)

Thanks for the help,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
