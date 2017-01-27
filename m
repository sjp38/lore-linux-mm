Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E92A6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 22:23:25 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id f67so353388527ybc.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 19:23:25 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id p67si46225ybp.172.2017.01.26.19.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 19:23:23 -0800 (PST)
Date: Thu, 26 Jan 2017 22:23:18 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170127032318.rkdiwu6nog3nifdo@thunk.org>
References: <20170123002158.xe7r7us2buc37ybq@thunk.org>
 <20170123100941.GA5745@noname.redhat.com>
 <1485210957.2786.19.camel@poochiereds.net>
 <1485212994.3722.1.camel@primarydata.com>
 <878tq1ia6l.fsf@notabene.neil.brown.name>
 <1485228841.8987.1.camel@primarydata.com>
 <20170125183542.557drncuktc5wgzy@thunk.org>
 <87ziieu06k.fsf@notabene.neil.brown.name>
 <20170126092542.GA17099@quack2.suse.cz>
 <87r33ptqg1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r33ptqg1.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Fri, Jan 27, 2017 at 09:19:10AM +1100, NeilBrown wrote:
> I don't think it has.
> The original topic was about gracefully handling of recoverable IO errors.
> The question was framed as about retrying fsync() is it reported an
> error, but this was based on a misunderstand.  fsync() doesn't report
> an error for recoverable errors.  It hangs.
> So the original topic is really about gracefully handling IO operations
> which currently can hang indefinitely.

Well, the problem is that it is up to the device driver to decide when
an error is recoverable or not.  This might include waiting X minutes,
and then deciding that the fibre channel connection isn't coming back,
and then turning it into an unrecoverable error.  Or for other
devices, the timeout might be much smaller.

Which is fine --- I think that's where the decision ought to live, and
if users want to tune a different timeout before the driver stops
waiting, that should be between the system administrator and the
device driver /sys tuning knob.

> >> When combined with O_DIRECT, it effectively means "no retries".  For
> >> block devices and files backed by block devices,
> >> REQ_FAILFAST_DEV|REQ_FAILFAST_TRANSPORT is used and a failure will be
> >> reported as EWOULDBLOCK, unless it is obvious that retrying wouldn't
> >> help.

Absolutely no retries?  Even TCP retries in the case of iSCSI?  I
don't think turning every TCP packet drop into EWOULDBLOCK would make
sense under any circumstances.  What might make sense is to have a
"short timeout" where it's up to the block device to decide what
"short timeout" means.

EWOULDBLOCK is also a little misleading, because even if the I/O
request is submitted immediately to the block device and immediately
serviced and returned, the I/O request would still be "blocking".
Maybe ETIMEDOUT instead?

> And aio_write() isn't non-blocking for O_DIRECT already because .... oh,
> it doesn't even try.  Is there something intrinsically hard about async
> O_DIRECT writes, or is it just that no-one has written acceptable code
> yet?

AIO/DIO writes can indeed be non-blocking, if the file system doesn't
need to do any metadata operations.  So if the file is preallocated,
you should be able to issue an async DIO write without losing the CPU.

> A truly async O_DIRECT aio_write() combined with a working io_cancel()
> would probably be sufficient.  The block layer doesn't provide any way
> to cancel a bio though, so that would need to be wired up.

Kent Overstreet worked up io_cancel for AIO/DIO writes when he was at
Google.  As I recall the patchset did get posted a few times, but it
never ended up getted accepted for upstream adoption.

We even had some very rough code that would propagate the cancellation
request to the hard drive, for those hard drives that had a facility
for accepting a cancellation request for an I/O which was queued via
NCQ but which hadn't executed yet.  It sort-of worked, but it never
hit a state where it could be published before the project was
abandoned.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
