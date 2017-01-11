Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDA46B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 19:41:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so1839101wmd.4
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 16:41:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r129si3331252wmr.28.2017.01.10.16.41.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 16:41:24 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Wed, 11 Jan 2017 11:41:15 +1100
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170110160224.GC6179@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com>
Message-ID: <87k2a2ig2c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain

On Wed, Jan 11 2017, Kevin Wolf wrote:

> Hi all,
>
> when I mentioned the I/O error handling problem especially with fsync()
> we have in QEMU to Christoph Hellwig, he thought it would be great topic
> for LSF/MM, so here I am. This came up a few months ago on qemu-devel [1]
> and we managed to ignore it for a while, but it's a real and potentially
> serious problem, so I think I agree with Christoph that it makes sense
> to get it discussed at LSF/MM.
>
>
> At the heart of it is the semantics of fsync(). A few years ago, fsync()
> was fixed to actually flush data to the disk, so we now have a defined
> and useful meaning of fsync() as long as all your fsync() calls return
> success.
>
> However, as soon as one fsync() call fails, even if the root problem is
> solved later (network connection restored, some space freed for thin
> provisioned storage, etc.), the state we're in is mostly undefined. As
> Ric Wheeler told me back in the qemu-devel discussion, when a writeout
> fails, you get an fsync() error returned (once), but the kernel page
> cache simply marks the respective page as clean and consequently won't
> ever retry the writeout. Instead, it can evict it from the cache even
> though it isn't actually consistent with the state on disk, which means
> throwing away data that was written by some process.
>
> So if you do another fsync() and it returns success, this doesn't
> currently mean that all of the data you wrote is on disk, but if
> anything, it's just about the data you wrote after the failed fsync().
> This isn't very helpful, to say the least, because you called fsync() in
> order to get a consistent state on disk, and you still don't have that.
>
> Essentially this means that once you got a fsync() failure, there is no
> hope to recover for the application and it has to stop using the file.

This is not strictly correct.  The application could repeat all the
recent writes.  It might fsync after each write so it can find out
exactly where the problem is.
So it could a a lot of work to recover, but it is not intrinsically
impossible.


>
>
> To give some context about my perspective as the maintainer for the QEMU
> block subsystem: QEMU has a mode (which is usually enabled in
> production) where I/O failure isn't communicated to the guest, which
> would probably offline the filesystem, thinking its hard disk has died,
> but instead QEMU pauses the VM and allows the administrator to resume
> when the problem has been fixed. Often the problem is only temporary,
> e.g. a network hiccup when a disk image is stored on NFS, so this is a
> quite helpful approach.

If the disk image is stored over NFS, the write should hang, not cause
an error. (Of course if you mount with '-o soft' you will get an error,
but if you mount with '-o soft', then "you get to keep both halves").

Is there a more realistic situation where you might get a write error
that might succeed if the write is repeated?

>
> When QEMU is told to resume the VM, the request is just resubmitted.
> This works fine for read/write, but not so much for fsync, because after
> the first failure all bets are off even if a subsequent fsync()
> succeeds.
>
> So this is the aspect that directly affects me, even though the problem
> is much broader and by far doesn't only affect QEMU.
>
>
> This leads to a few invidivual points to be discussed:
>
> 1. Fix the data corruption problem that follows from the current
>    behaviour. Imagine the following scenario:
>
>    Process A writes to some file, calls fsync() and gets a failure. The
>    data it wrote is marked clean in the page cache even though it's
>    inconsistent with the disk. Process A knows that fsync() fails, so
>    maybe it can deal with it, at least by stop using the file.
>
>    Now process B opens the same file, reads the updated data that
>    process A wrote, makes some additional changes based on that and
>    calls fsync() again.  Now fsync() return success. The data written by
>    B is on disk, but the data written by A isn't. Oops, this is data
>    corruption, and process B doesn't even know about it because all its
>    operations succeeded.

Can that really happen? I would expect the filesystem to call
SetPageError() if there was a write error, then I would expect a read to
report an error for that page if it were still in cache (or maybe flush
it out).  I admit that I haven't traced through the code in detail, but
I did find some examples for SetPageError after a write error.

>
> 2. Define fsync() semantics that include the state after a failure (this
>    probably goes a long way towards fixing 1.).
>
>    The semantics that QEMU uses internally (and which it needs to map)
>    is that after a successful flush, all writes to the disk image that
>    have successfully completed before the flush was issued are stable on
>    disk (no matter whether a previous flush failed).
>
>    A possible adaption to Linux, which considers that unlike QEMU
>    images, files can be opened more than once, might be that a
>    succeeding fsync() on a file descriptor means that all data that has
>    been read or written through this file descriptor is consistent
>    between the page cache and the disk (the read part is for avoiding
>    the scenario from 1.; it means that fsync flushes data written on a
>    different file descriptor if it has been seen by this one; hence, the
>    page cache can't contain non-dirty pages which aren't consistent with
>    the disk).

I think it would be useful to try to describe the behaviour of page
flags, particularly PG_error PG_uptodate PG_dirty in the different
scenarios.

For example, a successful read sets PG_uptodate and a successful write
clears PG_dirty.
A failed read doesn't set PG_uptodate, and maybe sets PG_error.
A failed read probably shouldn't clear PG_dirty but should set PG_error.

If background-write finds a PG_dirty|PG_error page, should it try to
write it out again?  Or should only a foreground (fsync) write?

If we did this, PG_error|PG_dirty pages would be pinned in memory until
a write was successful.  We would need a way to purge these pages
without writing them.  We would also need a way to ensure they didn't
consume a large fraction of memory.

It isn't clear to me that the behaviour can be different for different
file descriptors.  Once the data has been written to the page cache, it
belongs to the file, not to any particular fd.  So enabling
"keep-data-after-write-error" would need to be per-file rather than
per-fd, and would probably need to be a privileged operations due to the
memory consumption concerns.

>
> 3. Actually make fsync() failure recoverable.
>
>    You can implement 2. by making sure that a file descriptor for which
>    pages have been thrown away always returns an error and never goes
>    back to suceeding (it can't succeed according to the definition of 2.
>    because the data that would have to be written out is gone). This is
>    already a much better interface, but it doesn't really solve the
>    actual problem we have.
>
>    We also need to make sure that after a failed fsync() there is a
>    chance to recover. This means that the pages shouldn't be thrown away
>    immediately; but at the same time, you probably also don't want to
>    keep pages indefinitely when there is a permanent writeout error.
>    However, if we can make sure that these pages are only evicted in
>    case of actual memory pressure, and only if there are no actually
>    clean page to evict, I think a lot would be already won.

I think this would make behaviour unpredictable, being dependent on how
much memory pressure there is.  Predictability is nice!

>
>    In the common case, you could then recover from a temporary failure,
>    but if this state isn't maintainable, at least we get consistent
>    fsync() failure telling us that the data is gone.
>
>
> I think I've summarised most aspects here, but if something is unclear
> or you'd like to see some more context, please refer to the qemu-devel
> discussion [1] that I mentioned, or feel free to just ask.

Definitely an interesting question!

Thanks,
NeilBrown

>
> Thanks,
> Kevin
>
> [1] https://lists.gnu.org/archive/html/qemu-block/2016-04/msg00576.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh1fysACgkQOeye3VZi
gbnHsBAAma1rUFLGwr3P5iW9wJmLAWkmDAOIUZqD/pJxMF+xzHAZfHXT/+F0byfR
M1IN3SI2iy+Rqgyx01HXuq+oq4Oz+mzHKJPa/s2/DBh1StSBLov19bhZJbQ/Tbiv
k2kxb+jOcIiZuO72lbn5NMwgc7Htxv+rFVwxLOsmhNE/5GT0omUUCF8lQei62r1l
pI7GkZzBtCUEtWbeDsdrHbzpOsuAInAcj0O5rfXsngmaXEZCwKTDhOGlhW7ynXjf
TPvTWAznw/KUF/0Ovn1G85ZKYU4giY7Lsif2nvOS0cXGTlglwfqDGuxjRc+Sve8U
MKPOm0hAvt8Trz5uvpB6/ewQ8vqnl10MIC4IF54HAq5fNI+awHwW06G3V6ZzGXR/
ZDoNpOy2VlDEXzqkmYZRBcR/XDyAHJ0DYeimN0LQVQH6wuHFEoBZ5BpIwNQOmehQ
OymMBxAYaRRRyMC3Z3dAI2P2eu5Rk1N81viTJa4Dh/qnRIZnmsFyB/B7caS6pf1V
Rkj2g8cYt2rPRIAgGr0M8NwpKPi4OhKm/Oc+9lH+Rso5Ma6HKv1spiBl7D8+ezy7
MSLrrbagEVuiUalbHVlf/jNsbLrOkvWHgNqi7x1eimVreX3tNZAdqmZXCyq1TWow
kPlvGLT4gnev1t+7oCzg5XhDPTDaE7EKtwL81MrOIYST62khxIs=
=O1dR
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
