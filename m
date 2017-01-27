Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 549096B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 01:04:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so44291962wjc.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 22:04:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 74si1561160wmi.91.2017.01.26.22.04.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 22:04:11 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 27 Jan 2017 17:03:24 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170127032318.rkdiwu6nog3nifdo@thunk.org>
References: <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com> <878tq1ia6l.fsf@notabene.neil.brown.name> <1485228841.8987.1.camel@primarydata.com> <20170125183542.557drncuktc5wgzy@thunk.org> <87ziieu06k.fsf@notabene.neil.brown.name> <20170126092542.GA17099@quack2.suse.cz> <87r33ptqg1.fsf@notabene.neil.brown.name> <20170127032318.rkdiwu6nog3nifdo@thunk.org>
Message-ID: <87a8adt4yb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

--=-=-=
Content-Type: text/plain

On Thu, Jan 26 2017, Theodore Ts'o wrote:

> On Fri, Jan 27, 2017 at 09:19:10AM +1100, NeilBrown wrote:
>> I don't think it has.
>> The original topic was about gracefully handling of recoverable IO errors.
>> The question was framed as about retrying fsync() is it reported an
>> error, but this was based on a misunderstand.  fsync() doesn't report
>> an error for recoverable errors.  It hangs.
>> So the original topic is really about gracefully handling IO operations
>> which currently can hang indefinitely.
>
> Well, the problem is that it is up to the device driver to decide when
> an error is recoverable or not.  This might include waiting X minutes,
> and then deciding that the fibre channel connection isn't coming back,
> and then turning it into an unrecoverable error.  Or for other
> devices, the timeout might be much smaller.
>
> Which is fine --- I think that's where the decision ought to live, and
> if users want to tune a different timeout before the driver stops
> waiting, that should be between the system administrator and the
> device driver /sys tuning knob.

Completely agree.  Whether a particular condition should be treated as
recoverable or unrecoverable is a question and that driver authors and
sysadmins could reasonably provide input to.
But once that decision has been made, the application must accept the
decision.  EIO means unrecoverable.  There is never any point retrying.
Recoverable manifests as a hang, awaiting recovery.

I recently noticed that PG_error is effectively meaningless for write
errors.  filemap_fdatawait_range() can clear it, and the return value is
often ignored. AS_EIO is the really meaningful flag for write errors,
and it is per-file, not per-page.

>
>> >> When combined with O_DIRECT, it effectively means "no retries".  For
>> >> block devices and files backed by block devices,
>> >> REQ_FAILFAST_DEV|REQ_FAILFAST_TRANSPORT is used and a failure will be
>> >> reported as EWOULDBLOCK, unless it is obvious that retrying wouldn't
>> >> help.
>
> Absolutely no retries?  Even TCP retries in the case of iSCSI?  I
> don't think turning every TCP packet drop into EWOULDBLOCK would make
> sense under any circumstances.  What might make sense is to have a
> "short timeout" where it's up to the block device to decide what
> "short timeout" means.

The implemented semantics of REQ_FAILFAST_* are to disable retries on
certain types of fail.  That is what I was meaning to refer to.
There are retries are many levels in the protocol stack, from the
collision detection retries at the data-link layer, to packet-level and
connection level and command level.  Some have predefined timeouts and
should be left alone.  Others have no timeouts and need to be disabled.
There are probably others in the middle.
I was looking for a semantic that could be implemented on top of current
interfaces, which means working with the REQ_FAILFAST_* semantic.

>
> EWOULDBLOCK is also a little misleading, because even if the I/O
> request is submitted immediately to the block device and immediately
> serviced and returned, the I/O request would still be "blocking".
> Maybe ETIMEDOUT instead?

Maybe - I won't argue.

>
>> And aio_write() isn't non-blocking for O_DIRECT already because .... oh,
>> it doesn't even try.  Is there something intrinsically hard about async
>> O_DIRECT writes, or is it just that no-one has written acceptable code
>> yet?
>
> AIO/DIO writes can indeed be non-blocking, if the file system doesn't
> need to do any metadata operations.  So if the file is preallocated,
> you should be able to issue an async DIO write without losing the CPU.

Yes, I see that now.  I misread some of the code.
Thanks.

NeilBrown


>
>> A truly async O_DIRECT aio_write() combined with a working io_cancel()
>> would probably be sufficient.  The block layer doesn't provide any way
>> to cancel a bio though, so that would need to be wired up.
>
> Kent Overstreet worked up io_cancel for AIO/DIO writes when he was at
> Google.  As I recall the patchset did get posted a few times, but it
> never ended up getted accepted for upstream adoption.
>
> We even had some very rough code that would propagate the cancellation
> request to the hard drive, for those hard drives that had a facility
> for accepting a cancellation request for an I/O which was queued via
> NCQ but which hadn't executed yet.  It sort-of worked, but it never
> hit a state where it could be published before the project was
> abandoned.
>
> 						- Ted

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliK4qwACgkQOeye3VZi
gbnhqxAAiTAadmka/QhghN1nfep5O4td8R3FBrpSu+zSgmcbsgGilGqcFVd0zGkb
FqmIQL7dy0NWamB7seKfBH8x3+D03K2t0ODqWBgFIrPOGUXS+5ac6t9t9kcCkUci
hsQQ0noHRkz5QjTRxv3gUx3HTkbFODnspsZWCOGg8rWTxHeDxvUi3rshrXcT+o5t
OibbpvcgVwFGsbuTRppueDTEnYnai8shTfR5WzO2iw98XazCVoiHZr28zZArBMJk
UKeaXWXfTiVFt6PVWASlHLaGsUo/BHeND5/TvBJPKMcsJceBrB6pBvzvADtpv3AU
J2u5mZT8medoeMj8EeH4VtV05M0GB177UTgol/aIBKqLNZRgX84alxcBovl0SCMq
q0zOjWEvehEU3khnkx8Z6sh5mHJDy0K5lFKTayNIN9KMx7gJbP2NWehk3nUwNeX3
EQi7q+IgTpd88fPbZSngisMWhrX7yIRLzeNdyL2txFRJDJshQvSFNAuJfunZgX8V
CFOt1j2LZFgAA2/54PKoMj7uLT2i2kUXzGznScFldgyTZIXNPur4ivlt2HzSJKC6
K1Qo2dR9fTMT6hH0U39VHEglGChVCb+Gz9R/RqYwbr379xn+LXHiySOlKo5sREGf
raed6c5kUgvVGOXE/+BastAwD9CmQBNUXnImOjRaO3wd8g20ZpM=
=5t4J
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
