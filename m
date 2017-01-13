Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 758AC6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:10:04 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so35478025qte.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:10:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b67si8154531qkg.291.2017.01.13.03.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 03:10:03 -0800 (PST)
Date: Fri, 13 Jan 2017 12:09:59 +0100
From: Kevin Wolf <kwolf@redhat.com>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170113110959.GA4981@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com>
 <87k2a2ig2c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <87k2a2ig2c.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Am 11.01.2017 um 01:41 hat NeilBrown geschrieben:
> On Wed, Jan 11 2017, Kevin Wolf wrote:
>=20
> > Hi all,
> >
> > when I mentioned the I/O error handling problem especially with fsync()
> > we have in QEMU to Christoph Hellwig, he thought it would be great topic
> > for LSF/MM, so here I am. This came up a few months ago on qemu-devel [=
1]
> > and we managed to ignore it for a while, but it's a real and potentially
> > serious problem, so I think I agree with Christoph that it makes sense
> > to get it discussed at LSF/MM.
> >
> >
> > At the heart of it is the semantics of fsync(). A few years ago, fsync()
> > was fixed to actually flush data to the disk, so we now have a defined
> > and useful meaning of fsync() as long as all your fsync() calls return
> > success.
> >
> > However, as soon as one fsync() call fails, even if the root problem is
> > solved later (network connection restored, some space freed for thin
> > provisioned storage, etc.), the state we're in is mostly undefined. As
> > Ric Wheeler told me back in the qemu-devel discussion, when a writeout
> > fails, you get an fsync() error returned (once), but the kernel page
> > cache simply marks the respective page as clean and consequently won't
> > ever retry the writeout. Instead, it can evict it from the cache even
> > though it isn't actually consistent with the state on disk, which means
> > throwing away data that was written by some process.
> >
> > So if you do another fsync() and it returns success, this doesn't
> > currently mean that all of the data you wrote is on disk, but if
> > anything, it's just about the data you wrote after the failed fsync().
> > This isn't very helpful, to say the least, because you called fsync() in
> > order to get a consistent state on disk, and you still don't have that.
> >
> > Essentially this means that once you got a fsync() failure, there is no
> > hope to recover for the application and it has to stop using the file.
>=20
> This is not strictly correct.  The application could repeat all the
> recent writes.  It might fsync after each write so it can find out
> exactly where the problem is.
> So it could a a lot of work to recover, but it is not intrinsically
> impossible.

You are right, I probably overgeneralised from our situation. qemu
doesn't have the written data any more, and basically duplicating the
page cache by keeping a second copy of all data in qemu until the next
flush isn't really practicable and would both consume a considerable
amount of memory (if we don't add artificial flushes that the guest
didn't request, potentially unbounded) and impact performance because we
wouldn't be zero-copy any more.

So it is not intrinsically impossible, but practically impossible for at
least some applications. As you say, it's probably also too much extra
code to deal with an unlikely corner case for applications where it
would be possible, so it's still unlikely they will do this.

> > To give some context about my perspective as the maintainer for the QEMU
> > block subsystem: QEMU has a mode (which is usually enabled in
> > production) where I/O failure isn't communicated to the guest, which
> > would probably offline the filesystem, thinking its hard disk has died,
> > but instead QEMU pauses the VM and allows the administrator to resume
> > when the problem has been fixed. Often the problem is only temporary,
> > e.g. a network hiccup when a disk image is stored on NFS, so this is a
> > quite helpful approach.
>=20
> If the disk image is stored over NFS, the write should hang, not cause
> an error. (Of course if you mount with '-o soft' you will get an error,
> but if you mount with '-o soft', then "you get to keep both halves").

Yes, bad example. (The hanging write is a problem of its own, and I
think one of the reasons why '-o soft' is bad is the behaviour of the
page cache if we let it fail, but while possibly related, it's a
separate problem.)

> Is there a more realistic situation where you might get a write error
> that might succeed if the write is repeated?

So where we noticed this problem in practice wasn't the kernel page
cache, but the userspace gluster implementation, which exposed a similar
behaviour: It threw away the cache contents on a failed fsync() and the
next fsync() would report success again.

In the following discussion we came to think of the kernel and that the
same problem exists there in theory. This was confirmed by Ric Wheeler
and Rik van Riel, who I trust to have some knowledge about this, and my
own superificial read of some kernel code didn't contradict. Neither did
anyone in this thread disagree, so I assume that the problem does exist
on the page cache level.

Now even if at the moment there were no storage backend where a write
failure can be temporary (which I find hard to believe, but who knows),
a single new driver is enough to expose the problem. Are you confident
enough that no single driver will ever behave this way to make data
integrity depend on the assumption?

Now to answer your question a bit more directly: The other example we
had in mind was ENOSPC in thin provisioned block devices, which can be
fixed by freeing up some space. I also still see potential for such
behaviour in things using the network, but I haven't checked them in
detail.

> > When QEMU is told to resume the VM, the request is just resubmitted.
> > This works fine for read/write, but not so much for fsync, because after
> > the first failure all bets are off even if a subsequent fsync()
> > succeeds.
> >
> > So this is the aspect that directly affects me, even though the problem
> > is much broader and by far doesn't only affect QEMU.
> >
> >
> > This leads to a few invidivual points to be discussed:
> >
> > 1. Fix the data corruption problem that follows from the current
> >    behaviour. Imagine the following scenario:
> >
> >    Process A writes to some file, calls fsync() and gets a failure. The
> >    data it wrote is marked clean in the page cache even though it's
> >    inconsistent with the disk. Process A knows that fsync() fails, so
> >    maybe it can deal with it, at least by stop using the file.
> >
> >    Now process B opens the same file, reads the updated data that
> >    process A wrote, makes some additional changes based on that and
> >    calls fsync() again.  Now fsync() return success. The data written by
> >    B is on disk, but the data written by A isn't. Oops, this is data
> >    corruption, and process B doesn't even know about it because all its
> >    operations succeeded.
>=20
> Can that really happen? I would expect the filesystem to call
> SetPageError() if there was a write error, then I would expect a read to
> report an error for that page if it were still in cache (or maybe flush
> it out).  I admit that I haven't traced through the code in detail, but
> I did find some examples for SetPageError after a write error.

To be honest, I kept the proposal intentionally on the high-level
userspace API semantics level because I'm not familiar with the
internals. I did have a look and could have been lucky enough to spot
something that contradicts the theoretical considerations (which I
didn't), but by far didn't spend enough time to make the opposite
statement, whether there isn't something that prevents it from
happening. I took Rik's word on this.

Anyway, it would probably be good if someone had a closer look.

> >
> > 2. Define fsync() semantics that include the state after a failure (this
> >    probably goes a long way towards fixing 1.).
> >
> >    The semantics that QEMU uses internally (and which it needs to map)
> >    is that after a successful flush, all writes to the disk image that
> >    have successfully completed before the flush was issued are stable on
> >    disk (no matter whether a previous flush failed).
> >
> >    A possible adaption to Linux, which considers that unlike QEMU
> >    images, files can be opened more than once, might be that a
> >    succeeding fsync() on a file descriptor means that all data that has
> >    been read or written through this file descriptor is consistent
> >    between the page cache and the disk (the read part is for avoiding
> >    the scenario from 1.; it means that fsync flushes data written on a
> >    different file descriptor if it has been seen by this one; hence, the
> >    page cache can't contain non-dirty pages which aren't consistent with
> >    the disk).
>=20
> I think it would be useful to try to describe the behaviour of page
> flags, particularly PG_error PG_uptodate PG_dirty in the different
> scenarios.
>=20
> For example, a successful read sets PG_uptodate and a successful write
> clears PG_dirty.
> A failed read doesn't set PG_uptodate, and maybe sets PG_error.
> A failed read probably shouldn't clear PG_dirty but should set PG_error.
>=20
> If background-write finds a PG_dirty|PG_error page, should it try to
> write it out again?  Or should only a foreground (fsync) write?

That's a good question. I think a background write (if that includes
anything not coming from userspace) needs to be able to retry writing
out pages at least sometimes, specifically as the final attempt when we
need the memory and are about to throw the data away for good.

> If we did this, PG_error|PG_dirty pages would be pinned in memory until
> a write was successful.  We would need a way to purge these pages
> without writing them.  We would also need a way to ensure they didn't
> consume a large fraction of memory.

Yes, at some point throwing them away is unavoidable. If we do, a good
fsync() behaviour is important to communicate this to userspace.

> It isn't clear to me that the behaviour can be different for different
> file descriptors.  Once the data has been written to the page cache, it
> belongs to the file, not to any particular fd.  So enabling
> "keep-data-after-write-error" would need to be per-file rather than
> per-fd, and would probably need to be a privileged operations due to the
> memory consumption concerns.

Note that I didn't think of a "keep-data-after-write-error" flag,
neither per-fd nor per-file, because I assumed that everyone would want
it as long as there is some hope that the data could still be
successfully written out later.

The per-fd thing I envisioned was a flag that basically tells "this fd
has gone bad, fsync() won't ever return success for it again" and that
would be set for all open file descriptors for a file when we release
PG_error|PG_dirty pages in it without having written them.

I had assumed that there is a way to get back from the file to all file
descriptors that are open for it, but looking at the code I don't see
one indeed. Is this an intentional design decision or is it just that
nobody needed it?

You could still mark the whole file as "gone bad", but then this would
also affect new file descriptors that never saw the content that we
threw away. If I understand correctly, you would have to close all file
descriptors on the file first to get rid of the "gone bad" flag (is this
enough or are files kept around for longer than their fds?), and only
then you could get a working new one again. This sounds a bit too heavy
to me.

> >
> > 3. Actually make fsync() failure recoverable.
> >
> >    You can implement 2. by making sure that a file descriptor for which
> >    pages have been thrown away always returns an error and never goes
> >    back to suceeding (it can't succeed according to the definition of 2.
> >    because the data that would have to be written out is gone). This is
> >    already a much better interface, but it doesn't really solve the
> >    actual problem we have.
> >
> >    We also need to make sure that after a failed fsync() there is a
> >    chance to recover. This means that the pages shouldn't be thrown away
> >    immediately; but at the same time, you probably also don't want to
> >    keep pages indefinitely when there is a permanent writeout error.
> >    However, if we can make sure that these pages are only evicted in
> >    case of actual memory pressure, and only if there are no actually
> >    clean page to evict, I think a lot would be already won.
>=20
> I think this would make behaviour unpredictable, being dependent on how
> much memory pressure there is.  Predictability is nice!

Yes, predictability is nice. Recovering from errors and not losing data
is nice, too. I think I would generally value the latter higher, but I
see that there may be cases where a different tradeoff might make sense.
A sign that it should be an option?

On the other hand, I wouldn't really consider page cache writeouts
particularly predictable for userspace anyway.

> >
> >    In the common case, you could then recover from a temporary failure,
> >    but if this state isn't maintainable, at least we get consistent
> >    fsync() failure telling us that the data is gone.
> >
> >
> > I think I've summarised most aspects here, but if something is unclear
> > or you'd like to see some more context, please refer to the qemu-devel
> > discussion [1] that I mentioned, or feel free to just ask.
>=20
> Definitely an interesting question!
>=20
> Thanks,
> NeilBrown

Kevin

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJYeLWHAAoJEH8JsnLIjy/WEV4P/0yCVFG1TD6esktrZIcV20BA
tXxwRmoMJYtaQpu7YuYkYwnW9CNUex7TJgv9slHSo4ueDelxfQHjjTYuKmFdlR59
KuqBw++Bk/wcyB+7fOKcW39TLspTFPlFOtEUC/WY/LEyRlDVVY+oLFyP7dLIWPOw
YqI/S3DPK0izC3oKSnAN+zYBEK37yrR6EmM+393XDSpw956dId38p8k020Wd2UUF
sDjb2weC6F5C6CssX0ZhlKUsHyZlFaRYfLcysMt9+ZwvQ2MsRR8BaKn3xDYIiL1A
6h8FNM9jefRH53OLoSGxm6GNuR0s9q6Nkce6nukKEzIMt4WPXgq2LwHpMhJylOiy
ERIr1T92IPgSib5ZwIuglQuKtV2Mf71Vxigi5xXr8dGpBJ27o/ici4YOVJ9e62hq
TLEdie87bYnwv9buu/ODIo0cTdwLUrY8r/yxJz2ZQ5b4ze5UqoS1SlYQdplqblbY
m+jJWZ9uJao1GGiUR4ALK6igKnN/oevqoPIzUl4xTcM5O8UGLtS4puxvlw2DAzSo
3+Ac/2If+m0dJmrq+3LpA1W2f0oGeqOnXV6coeVkFyKEr0z/+HPT0qRBlDyKeMKt
KZvFVkWAYO0hh0bNOLsvtCu4ByuAmaT7makrKfUzFE4NqnBnzHQQ0qqeXX3Hqgcv
ePXvhH/FdljGGOm/s7Tf
=vb1j
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
