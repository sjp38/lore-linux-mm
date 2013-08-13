Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A12756B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 13:51:38 -0400 (EDT)
Received: by mail-vb0-f42.google.com with SMTP id e12so6928514vbg.29
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 10:51:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <520A6DFC.1070201@sgi.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
	<1376344480-156708-1-git-send-email-nzimmer@sgi.com>
	<CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com>
	<520A6DFC.1070201@sgi.com>
Date: Tue, 13 Aug 2013 10:51:37 -0700
Message-ID: <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com>
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Tue, Aug 13, 2013 at 10:33 AM, Mike Travis <travis@sgi.com> wrote:
>
> Initially this patch set consisted of diverting a major portion of the
> memory to an "absent" list during e820 processing.  A very late initcall
> was then used to dispatch a cpu per node to add that nodes's absent
> memory.  By nature these ran in parallel so Nathan did the work to
> "parallelize" various global resource locks to become per node locks.

So quite frankly, I'm not sure how worthwhile it even is to
parallelize the thing. I realize that some environments may care about
getting up to full memory population very quicky, but I think it would
be very rare and specialized, and shouldn't necessarily be part of the
initial patches.

And it really doesn't have to be an initcall at all - at least not a
synchronous one. A late initcall to get the process *started*, but the
process itself could easily be done with a separate thread
asynchronously, and let the machine boot up while that thread is
going.

And in fact, I'd argue that instead of trying to make it fast and
parallelize things excessively, you might want to make the memory
initialization *slow*, and make all the rest of the bootup have higher
priority.

At that point, who cares if it takes 400 seconds to get all memory
initialized? In fact, who cares if it takes twice that? Let's assume
that the rest of the boot takes 30s (which is pretty aggressive for
some big server with terabytes of memory), even if the memory
initialization was running in the background and only during idle time
for probing, I'm sure you'd have a few hundred gigs of RAM initialized
by the time you can log in. And if it then takes another ten minutes
until you have the full 16TB initialized, and some things might be a
tad slower early on, does anybody really care?  The machine will be up
and running with plenty of memory, even if it may not be *all* the
memory yet.

I realize that benchmarking cares, and yes, I also realize that some
benchmarks actually want to reboot the machine between some runs just
to get repeatability, but if you're benchmarking a 16TB machine I'm
guessing any serious benchmark that actually uses that much memory is
going to take many hours to a few days to run anyway? Having some way
to wait until the memory is all done (which might even be just a silly
shell script that does "ps" and waits for the kernel threads to all go
away) isn't going to kill the benchmark - and the benchmark itself
will then not have to worry about hittinf the "oops, I need to
initialize 2GB of RAM now because I hit an uninitialized page".

Ok, so I don't know all the issues, and in many ways I don't even
really care. You could do it other ways, I don't think this is a big
deal. The part I hate is the runtime hook into the core MM page
allocation code, so I'm just throwing out any random thing that comes
to my mind that could be used to avoid that part.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
