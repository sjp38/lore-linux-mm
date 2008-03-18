Received: by el-out-1112.google.com with SMTP id y26so2851038ele.4
        for <linux-mm@kvack.org>; Mon, 17 Mar 2008 19:19:20 -0700 (PDT)
Message-ID: <70b6f0bf0803171919t9ba6cbewbc03c9ddae63c255@mail.gmail.com>
Date: Mon, 17 Mar 2008 19:19:19 -0700
From: "Valerie Henson" <val@vahconsulting.com>
Subject: Re: ebizzy performance with different allocators
In-Reply-To: <200803172321.31572.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803172321.31572.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: opensource@google.com, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
List-ID: <linux-mm.kvack.org>

[Cc'd current ebizzy maintainer, Rodrigo.]

On Mon, Mar 17, 2008 at 5:21 AM, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Hi,
>
>  I was recently interested in ebizzy performance, and specifically the
>  reason why Linux doesn't appear to scale very well versus FreeBSD.

[snip]

>  linux-glibc was the best single-threaded performer, with ~7000 r/s,
>  however it starts running into system time which the profile shows up
>  as unmapping pages and faulting in new pages. Is "fixing" this as simple
>  as increasing hysteresis in glibc? Can that be done via environment? (I
>  couldn't work out a way).

Huh, yeah, that sounds like glibc is mmap()'ing your allocations.
Check to see if your glibc version includes this patch:

http://www.valhenson.org/patches/dynamic_mmap_threshold

If it does, you shouldn't see much in the way of mmap/munmap activity
when running ebizzy.  It's possible that some other malloc() settings
are interfering, maybe the trim threshold.  It's also worth noting
that the self-tuning mmap threshold is disabled if the user sets the
mmap threshold explicitly.  Oh, and is this 32-bit or 64-bit?

If you want to tune the exact behavior of malloc with regard to mmap, check out:

http://www.gnu.org/software/libtool/manual/libc/Malloc-Tunable-Parameters.html

If you use the "-M" option to ebizzy, it will use mallopt() to turn
off mmap()'d allocations entirely. (It'd be nice to have command line
knobs for all the mallopt() tuning options, actually.)

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
