Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8CD536B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 02:22:31 -0400 (EDT)
Received: by eekb47 with SMTP id b47so2329270eek.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 23:22:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120605055150.GF4347@dastard>
References: <20120515224805.GA25577@quack.suse.cz>
	<20120516021423.GO25351@dastard>
	<20120516130445.GA27661@quack.suse.cz>
	<20120517074308.GQ25351@dastard>
	<20120517232829.GA31028@quack.suse.cz>
	<20120518101210.GX25351@dastard>
	<20120518133250.GC5589@quack.suse.cz>
	<20120519014024.GZ25351@dastard>
	<20120524123538.GA5632@quack.suse.cz>
	<20120605055150.GF4347@dastard>
Date: Tue, 5 Jun 2012 08:22:29 +0200
Message-ID: <CANGUGtBnhRjWGK2v-+ExhZExNbYkF9nTBzQNd7-0f6G5sn51Sg@mail.gmail.com>
Subject: Re: Hole punching and mmap races
From: Marco Stornelli <marco.stornelli@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

2012/6/5 Dave Chinner <david@fromorbit.com>:
> On Thu, May 24, 2012 at 02:35:38PM +0200, Jan Kara wrote:
>> On Sat 19-05-12 11:40:24, Dave Chinner wrote:
>> > So let's step back a moment and have a look at how we've got here.
>> > The problem is that we've optimised ourselves into a corner with the
>> > way we handle page cache truncation - we don't need mmap
>> > serialisation because of the combination of i_size and page locks
>> > mean we can detect truncated pages safely at page fault time. With
>> > hole punching, we don't have that i_size safety blanket, and so we
>> > need some other serialisation mechanism to safely detect whether a
>> > page is valid or not at any given point in time.
>> >
>> > Because it needs to serialise against IO operations, we need a
>> > sleeping lock of some kind, and it can't be the existing IO lock.
>> > And now we are looking at needing a new lock for hole punching, I'm
>> > really wondering if the i_size/page lock truncation optimisation
>> > should even continue to exist. i.e. replace it with a single
>> > mechanism that works for both hole punching, truncation and other
>> > functions that require exclusive access or exclusion against
>> > modifications to the mapping tree.
>> >
>> > But this is only one of the problems in this area.The way I see it
>> > is that we have many kludges in the area of page invalidation w.r.t.
>> > different types of IO, the page cache and mmap, especially when we
>> > take into account direct IO. What we are seeing here is we need
>> > some level of _mapping tree exclusion_ between:
>> >
>> > =A0 =A0 1. mmap vs hole punch (broken)
>> > =A0 =A0 2. mmap vs truncate (i_size/page lock)
>> > =A0 =A0 3. mmap vs direct IO (non-existent)
>> > =A0 =A0 4. mmap vs buffered IO (page lock)
>> > =A0 =A0 5. writeback vs truncate (i_size/page lock)
>> > =A0 =A0 6. writeback vs hole punch (page lock, possibly broken)
>> > =A0 =A0 7. direct IO vs buffered IO (racy - flush cache before/after D=
IO)
>> =A0 Yes, this is a nice summary of the most interesting cases. For compl=
eteness,
>> here are the remaining cases:
>> =A0 8. mmap vs writeback (page lock)
>> =A0 9. writeback vs direct IO (as direct IO vs buffered IO)
>> =A010. writeback vs buffered IO (page lock)
>> =A011. direct IO vs truncate (dio_wait)
>> =A012. direct IO vs hole punch (dio_wait)
>> =A013. buffered IO vs truncate (i_mutex for writes, i_size/page lock for=
 reads)
>> =A014. buffered IO vs hole punch (fs dependent, broken for ext4)
>> =A015. truncate vs hole punch (fs dependent)
>> =A016. mmap vs mmap (page lock)
>> =A017. writeback vs writeback (page lock)
>> =A018. direct IO vs direct IO (i_mutex or fs dependent)
>> =A019. buffered IO vs buffered IO (i_mutex for writes, page lock for rea=
ds)
>> =A020. truncate vs truncate (i_mutex)
>> =A021. punch hole vs punch hole (fs dependent)
>

I think we have even the xip cases here.

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
