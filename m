Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 857016B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 19:37:49 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so36108426wjc.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:37:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si24434854wmf.48.2017.01.25.16.37.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 16:37:47 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Thu, 26 Jan 2017 11:36:35 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170125183542.557drncuktc5wgzy@thunk.org>
References: <87mveufvbu.fsf@notabene.neil.brown.name> <1484568855.2719.3.camel@poochiereds.net> <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com> <878tq1ia6l.fsf@notabene.neil.brown.name> <1485228841.8987.1.camel@primarydata.com> <20170125183542.557drncuktc5wgzy@thunk.org>
Message-ID: <87ziieu06k.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trondmy@primarydata.com>
Cc: "kwolf@redhat.com" <kwolf@redhat.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 25 2017, Theodore Ts'o wrote:

> On Tue, Jan 24, 2017 at 03:34:04AM +0000, Trond Myklebust wrote:
>> The reason why I'm thinking open() is because it has to be a contract
>> between a specific application and the kernel. If the application
>> doesn't open the file with the O_TIMEOUT flag, then it shouldn't see
>> nasty non-POSIX timeout errors, even if there is another process that
>> is using that flag on the same file.
>>=20
>> The only place where that is difficult to manage is when the file is
>> mmap()ed (no file descriptor), so you'd presumably have to disallow
>> mixing mmap and O_TIMEOUT.
>
> Well, technically there *is* a file descriptor when you do an mmap.
> You can close the fd after you call mmap(), but the mmap bumps the
> refcount on the struct file while the memory map is active.
>
> I would argue though that at least for buffered writes, the timeout
> has to be property of the underlying inode, and if there is an attempt
> to set timeout on an inode that already has a timeout set to some
> other non-zero value, the "set timeout" operation should fail with a
> "timeout already set".  That's becuase we really don't want to have to
> keep track, on a per-page basis, which struct file was responsible for
> dirtying a page --- and what if it is dirtied by two different file
> descriptors?

You seem to have a very different idea to the one that is forming in my
mind.  In my vision, once the data has entered the page cache, it
doesn't matter at all where it came from.  It will remain in the page
cache, as a dirty page, until it is successfully written or until an
unrecoverable error occurs.  There are no timeouts once the data is in
the page cache.

Actually, I'm leaning away from timeouts in general.  I'm not against
them, but not entirely sure they are useful.

To be more specific, I imagine a new open flag "O_IO_NDELAY".  It is a
bit like O_NDELAY, but it explicitly affects IO, never the actual open()
call, and it is explicitly allowed on regular files and block devices.

When combined with O_DIRECT, it effectively means "no retries".  For
block devices and files backed by block devices,
REQ_FAILFAST_DEV|REQ_FAILFAST_TRANSPORT is used and a failure will be
reported as EWOULDBLOCK, unless it is obvious that retrying wouldn't
help.
Non-block-device filesystems would behave differently.  e.g. NFS would
probably use a RPC_TASK_SOFT call instead of the normal 'hard' call.

When used without O_DIRECT:
 - read would trigger read-ahead much as it does now (which can do
   nothing if there are resource issues) and would only return data
   if it was already in the cache.
 - write would try to allocate a page, tell the filesystem that it
   is dirty so that journal space is reserved or whatever is needed,
   and would tell the dirty_pages rate-limiting that another page was
   dirty.  If the rate-limiting reported that we cannot dirty a page
   without waiting, or if any other needed resources were not available,
   then the write would fail (-EWOULDBLOCK).
 - fsync would just fail if there were any dirty pages.  It might also
   do the equivalent of sync_file_range(SYNC_FILE_RANGE_WRITE) without
   any *WAIT* flags. (alternately, fsync could remain unchanged, and
   sync_file_range() could gain a SYNC_FILE_RANGE_TEST flag).


With O_DIRECT there would be a delay, but it would be limited and there
would be no retry.  There is not currently any way to impose a specific
delay on REQ_FAILFAST* requests.
Without O_DIRECT, there could be no significant delay, though code might
have to wait for a mutex or similar.
There are a few places that a timeout could usefully be inserted, but
I'm not sure that would be better than just having the app try again in
a little while - it would have to be prepared for that anyway.

I would like O_DIRECT|O_IO_NDELAY for mdadm so we could safely work with
devices that block when no paths are available.

>
> That being said, I suspect that for many applications, the timeout is
> going to be *much* more interesting for O_DIRECT writes, and there we
> can certainly have different timeouts on a per-fd basis.  This is
> especially for cases where the timeout is implemented in storage
> device, using multi-media extensions, and where the timout might be
> measured in milliseconds (e.g., no point reading a video frame if its
> been delayed too long).  That being said, it block layer would need to
> know about this as well, since the timeout needs to be relative to
> when the read(2) system call is issued, not to when it is finally
> submitted to the storage device.

Yes. If a deadline could be added to "struct bio", and honoured by
drivers, then that would make a timeout much more interesting for
O_DIRECT.

Thanks,
NeilBrown


>
> And if the process has suitable privileges, perhaps the I/O scheduler
> should take the timeout into account, so that reads with a timeout
> attached should be submitted, with the presumption that reads w/o a
> timeout can afford to be queued.  If the process doesn't have suitable
> privileges, or if cgroup has exceeded its I/O quota, perhaps the right
> answer would be to fail the read right away.  In the case of a cluster
> file system such, if a particular server knows its can't serve a
> particular low latency read within the SLO, it might be worthwhile to
> signal to the cluster file system client that it should start doing an
> erasure code reconstruction right away (or read from one of the
> mirrors if the file is stored with n=3D3 replication, etc.)
>
> So depending on what the goals of userspace are, there are number of
> different kernel policies that might be the best match for the
> particular application in question.  In particular, if you are trying
> to provide low latency reads to assure decent response time for web
> applications, it may be *reads* that are much more interesting for
> timeout purposes rather than *writes*.
>
> (Especially in a distributed system, you're going to be using some
> kind of encoding with redundancy, so as long as enough of the writes
> have completed, it doesn't matter if the other writes take a long time
> --- although if you eventually decide that the write's never going to
> make it, it's ideal if you can reshard the chunk more aggressively,
> instead of waiting for the scurbbing pass to notice that some of the
> redundant copies of the chunk had gotten corrupted or were never
> written out.)
>
> Cheers,
>
> 					- Ted

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliJRJMACgkQOeye3VZi
gbkN4BAAvplPbYSw7onIlKMxCfWQUbAp+M1NkRy9kAZR4jA0it2Hb5zptMl5ONFY
GhQLupwV1lg1wasvwFNWn+MOb+FfysPBmOJSHdKrWIKqAR2BMiAoeRlkZkesRYbM
ha16SS+6yLegs5dJikTHwh+ER3unl3Wo7rPAqD9AVsYrbr9lZ6B9bxQmgoi0MhTi
H3+jSi/+49rBrl1ApfCwEgmFkGVNgJ+XeFSpl6AkG2zH8i/byKCEWfwYle/EiIWo
f1NJsUQDFhC4of1WaAiNkqGR9c2NtgxeNnBsTMGIM7mLO/BvOWqv3tDahnWAPwjD
Y4dZgtR0g9k7vvDnSu+uGOv9w4AHmG0OB6/odro8/y0171fFlWqOdaDXMIA9xQZB
Adt5z9u7ABxZQrPKX77f1mJE2iqb6D7Aph8H1sRcu3MqHgozNLF6iRzTadQWM5pI
x3kY4tcfg2Pf4Lt3ievS/dkACkPRlvfHIiIRw8r68Jqm6OdqYCWrJugksyeZLMSh
rlr7eDnPHe8t+vtf47Kw7Yc3MfgYa0oV1Qn/Tz1Z3PpZfLc/TvYg6iSblUokF4Ag
wBh+Zv9oXxOXvmlNWl7w8JjDsiaIo1Hk1yaEoDuBGakLQwjBdi0q7SuYqIOEQsCJ
DuN7gAY38h1LN83upfd3ChcFnryp5Y50CHr/bD2cIxkWlfrLOPA=
=10NT
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
