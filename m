Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 843C96B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:20:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so47837756wme.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:20:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m80si492235wmi.31.2017.01.26.14.20.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 14:20:26 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 27 Jan 2017 09:19:10 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170126092542.GA17099@quack2.suse.cz>
References: <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com> <878tq1ia6l.fsf@notabene.neil.brown.name> <1485228841.8987.1.camel@primarydata.com> <20170125183542.557drncuktc5wgzy@thunk.org> <87ziieu06k.fsf@notabene.neil.brown.name> <20170126092542.GA17099@quack2.suse.cz>
Message-ID: <87r33ptqg1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 26 2017, Jan Kara wrote:

> On Thu 26-01-17 11:36:35, NeilBrown wrote:
>> On Wed, Jan 25 2017, Theodore Ts'o wrote:
>> > On Tue, Jan 24, 2017 at 03:34:04AM +0000, Trond Myklebust wrote:
>> >> The reason why I'm thinking open() is because it has to be a contract
>> >> between a specific application and the kernel. If the application
>> >> doesn't open the file with the O_TIMEOUT flag, then it shouldn't see
>> >> nasty non-POSIX timeout errors, even if there is another process that
>> >> is using that flag on the same file.
>> >>=20
>> >> The only place where that is difficult to manage is when the file is
>> >> mmap()ed (no file descriptor), so you'd presumably have to disallow
>> >> mixing mmap and O_TIMEOUT.
>> >
>> > Well, technically there *is* a file descriptor when you do an mmap.
>> > You can close the fd after you call mmap(), but the mmap bumps the
>> > refcount on the struct file while the memory map is active.
>> >
>> > I would argue though that at least for buffered writes, the timeout
>> > has to be property of the underlying inode, and if there is an attempt
>> > to set timeout on an inode that already has a timeout set to some
>> > other non-zero value, the "set timeout" operation should fail with a
>> > "timeout already set".  That's becuase we really don't want to have to
>> > keep track, on a per-page basis, which struct file was responsible for
>> > dirtying a page --- and what if it is dirtied by two different file
>> > descriptors?
>>=20
>> You seem to have a very different idea to the one that is forming in my
>> mind.  In my vision, once the data has entered the page cache, it
>> doesn't matter at all where it came from.  It will remain in the page
>> cache, as a dirty page, until it is successfully written or until an
>> unrecoverable error occurs.  There are no timeouts once the data is in
>> the page cache.
>
> Heh, this has somehow drifted away from the original topic of handling IO
> errors :)

I don't think it has.
The original topic was about gracefully handling of recoverable IO errors.
The question was framed as about retrying fsync() is it reported an
error, but this was based on a misunderstand.  fsync() doesn't report
an error for recoverable errors.  It hangs.
So the original topic is really about gracefully handling IO operations
which currently can hang indefinitely.


>
>> Actually, I'm leaning away from timeouts in general.  I'm not against
>> them, but not entirely sure they are useful.
>>=20
>> To be more specific, I imagine a new open flag "O_IO_NDELAY".  It is a
>> bit like O_NDELAY, but it explicitly affects IO, never the actual open()
>> call, and it is explicitly allowed on regular files and block devices.
>>=20
>> When combined with O_DIRECT, it effectively means "no retries".  For
>> block devices and files backed by block devices,
>> REQ_FAILFAST_DEV|REQ_FAILFAST_TRANSPORT is used and a failure will be
>> reported as EWOULDBLOCK, unless it is obvious that retrying wouldn't
>> help.
>> Non-block-device filesystems would behave differently.  e.g. NFS would
>> probably use a RPC_TASK_SOFT call instead of the normal 'hard' call.
>>=20
>> When used without O_DIRECT:
>>  - read would trigger read-ahead much as it does now (which can do
>>    nothing if there are resource issues) and would only return data
>>    if it was already in the cache.
>
> There was a patch set which did this [1]. Not on per-fd basis but rather =
on
> per-IO basis. Andrew blocked it because he was convinced that mincore() is
> good enough interface for this.

Thanks for the link.  mincore() won't trigger read-ahead of course, but
fadvise() can do that.  I don't see how it can provide a hard guarantee
that a subsequent read won't block though.
Still, interesting to be reminded of the history, thanks.

>
>>  - write would try to allocate a page, tell the filesystem that it
>>    is dirty so that journal space is reserved or whatever is needed,
>>    and would tell the dirty_pages rate-limiting that another page was
>>    dirty.  If the rate-limiting reported that we cannot dirty a page
>>    without waiting, or if any other needed resources were not available,
>>    then the write would fail (-EWOULDBLOCK).
>>  - fsync would just fail if there were any dirty pages.  It might also
>>    do the equivalent of sync_file_range(SYNC_FILE_RANGE_WRITE) without
>>    any *WAIT* flags. (alternately, fsync could remain unchanged, and
>>    sync_file_range() could gain a SYNC_FILE_RANGE_TEST flag).
>>=20
>>=20
>> With O_DIRECT there would be a delay, but it would be limited and there
>> would be no retry.  There is not currently any way to impose a specific
>> delay on REQ_FAILFAST* requests.
>> Without O_DIRECT, there could be no significant delay, though code might
>> have to wait for a mutex or similar.
>> There are a few places that a timeout could usefully be inserted, but
>> I'm not sure that would be better than just having the app try again in
>> a little while - it would have to be prepared for that anyway.
>>=20
>> I would like O_DIRECT|O_IO_NDELAY for mdadm so we could safely work with
>> devices that block when no paths are available.
>
> For O_DIRECT writes, there are database people who want to do non-blocking
> AIO writes. Although the problem they want to solve is different - rather
> similar to the one patch set [1] is trying to solve for buffered reads -
> they want to do AIO write and they want it really non-blocking so they can
> do IO submission directly from computation thread without the cost of the
> offload to a different process which normally does the IO.

And aio_write() isn't non-blocking for O_DIRECT already because .... oh,
it doesn't even try.  Is there something intrinsically hard about async
O_DIRECT writes, or is it just that no-one has written acceptable code
yet?

>
> Now you need something different for mdadm but interfaces should probably
> be consistent...

A truly async O_DIRECT aio_write() combined with a working io_cancel()
would probably be sufficient.  The block layer doesn't provide any way
to cancel a bio though, so that would need to be wired up.

I'm not sure the two cases are all that similar though.
In one case the app doesn't want to wait at all.  In the other it is
happy to wait, but would prefer an error to indefinite retries.

>
>> > That being said, I suspect that for many applications, the timeout is
>> > going to be *much* more interesting for O_DIRECT writes, and there we
>> > can certainly have different timeouts on a per-fd basis.  This is
>> > especially for cases where the timeout is implemented in storage
>> > device, using multi-media extensions, and where the timout might be
>> > measured in milliseconds (e.g., no point reading a video frame if its
>> > been delayed too long).  That being said, it block layer would need to
>> > know about this as well, since the timeout needs to be relative to
>> > when the read(2) system call is issued, not to when it is finally
>> > submitted to the storage device.
>>=20
>> Yes. If a deadline could be added to "struct bio", and honoured by
>> drivers, then that would make a timeout much more interesting for
>> O_DIRECT.
>
> Timeouts are nice but IMO a lot of work and I suspect you'd really need a
> dedicated "real-time" IO scheduler for this.

While such a scheduler might be nice, I think it would solve a different
problem.
There is a difference between:
 "please do your best to complete before this time"
and
 "don't even bother trying to complete after this time".

Both could be useful.  We shouldn't reject one because the other is too
hard.

Thanks,
NeilBrown

>
> 								Honza
>
> [1] https://lwn.net/Articles/636955/
>
> --=20
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliKdd4ACgkQOeye3VZi
gbmYBA//Z0F6Ft7/aBrlNIhKVPsKbUbyFaf/OrHCeSM/1bF8FsatQHoyO+Rpfs5x
fWON5Yjao71hi4dQH9/gPnPK5QF++BUcw9AQxYu+z2Uw22V8In+UGZJA450iyp39
v5GW7wTSoA5U+qN4xuD7/o8E0Gxyh8LL5Xr9Hf8TReKf1ihHKGjlY4wdsCu7G9gC
YGt4VhV4PNdEcFLEQgjqSOZMQ2/GZDWGqs+1PLgO60QFaYgUBBbvRl3lYakFModV
4fTiumbdNf9hK7+W6qED7rqnvw1rXu00k8pVPvXNp/MSs//byn1L3UcnT6B3peJH
R5mZ1ZB97aaRgcwr3rd2BZTzi1UGarnOcdevjkqZctqWu7KLAH5raklVdiuodWkp
dpe0nWokSc6Cj++kbKatnAoxDm8K97JUIZ7PGHBsXNrVUO1MiAh8afCo5PhOhTtw
1DK+oGa9upoG789jjXc1lWC77JQ1OpyrTYFkXS/dGmLG5h6FrBDX/jwkHduQPeBo
T3ffjimD76sjExv8EWFCqnDiShs//y5V5bLha2LDK+SVaveymYafVRKO407qrqxu
8iUxsKaeVHqg6J9dBNjrgBvyKxplMo2tKGu6AJQHjKQGgE8GBFu0XuOpLp3cr+RG
UNwCHVkEtSA/j5stNsE6FnhvpIveuN53l6IDfI8dju3pI1M01tY=
=NE5P
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
