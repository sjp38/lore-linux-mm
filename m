Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 069F56B0035
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:55:44 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so2165811eek.38
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 14:55:44 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id z2si33527249eeo.274.2014.03.26.14.55.42
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 14:55:43 -0700 (PDT)
Date: Wed, 26 Mar 2014 22:55:18 +0100
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140326215518.GH9066@alap3.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@anarazel.de

On 2014-03-26 14:41:31 -0700, Andy Lutomirski wrote:
> On Wed, Mar 26, 2014 at 12:11 PM, Andres Freund <andres@anarazel.de> wrote:
> > Hi,
> >
> > At LSF/MM there was a slot about postgres' problems with the kernel. Our
> > top#1 concern is frequent slow read()s that happen while another process
> > calls fsync(), even though we'd be perfectly fine if that fsync() took
> > ages.
> > The "conclusion" of that part was that it'd be very useful to have a
> > demonstration of the problem without needing a full blown postgres
> > setup. I've quickly hacked something together, that seems to show the
> > problem nicely.
> >
> > For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
> > and the "IO Scheduling" bit in
> > http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
> >
> 
> For your amusement: running this program in KVM on a 2GB disk image
> failed, but it caused the *host* to go out to lunch for several
> seconds while failing.  In fact, it seems to have caused the host to
> fall over so badly that the guest decided that the disk controller was
> timing out.  The host is btrfs, and I think that btrfs is *really* bad
> at this kind of workload.

Also, unless you changed the parameters, it's a) using a 48GB disk file,
and writes really rather fast ;)

> Even using ext4 is no good.  I think that dm-crypt is dying under the
> load.  So I won't test your program for real :/

Try to reduce data_size to RAM * 2, NUM_RANDOM_READERS to something
smaller. If it still doesn't work consider increasing the two nsleep()s...

I didn't have a good idea how to scale those to the current machine in a
halfway automatic fashion.

> > Possible solutions:
> > * Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
> >   sync_file_range() does.
> > * Make IO triggered by writeback regard IO priorities and add it to
> >   schedulers other than CFQ
> > * Add a tunable that allows limiting the amount of dirty memory before
> >   writeback on a per process basis.
> > * ...?
> 
> I thought the problem wasn't so much that priorities weren't respected
> but that the fsync call fills up the queue, so everything starts
> contending for the right to enqueue a new request.

I think it's both actually. If I understand correctly there's not even a
correct association to the originator anymore during a fsync triggered
flush?

> Since fsync blocks until all of its IO finishes anyway, what if it
> could just limit itself to a much smaller number of outstanding
> requests?

Yea, that could already help. If you remove the fsync()s, the problem
will periodically appear anyway, because writeback is triggered with
vengeance. That'd need to be fixed in a similar way.

> I'm not sure I understand the request queue stuff, but here's an idea.
>  The block core contains this little bit of code:

I haven't read enough of the code yet, to comment intelligently ;)

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
