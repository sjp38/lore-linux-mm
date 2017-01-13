Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFB86B0260
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 17:29:04 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p192so19106953wme.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 14:29:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v134si3567531wmd.126.2017.01.13.14.29.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 14:29:02 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sat, 14 Jan 2017 09:28:53 +1100
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170113160022.GC4981@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com> <87k2a2ig2c.fsf@notabene.neil.brown.name> <20170113110959.GA4981@noname.redhat.com> <20170113142154.iycjjhjujqt5u2ab@thunk.org> <20170113160022.GC4981@noname.redhat.com>
Message-ID: <87mveufvbu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>, Theodore Ts'o <tytso@mit.edu>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 14 2017, Kevin Wolf wrote:

> Am 13.01.2017 um 15:21 hat Theodore Ts'o geschrieben:
>> On Fri, Jan 13, 2017 at 12:09:59PM +0100, Kevin Wolf wrote:
>> > Now even if at the moment there were no storage backend where a write
>> > failure can be temporary (which I find hard to believe, but who knows),
>> > a single new driver is enough to expose the problem. Are you confident
>> > enough that no single driver will ever behave this way to make data
>> > integrity depend on the assumption?
>>=20
>> This is really a philosophical question.  It very much simplifiees
>> things if we can make the assumption that a driver that *does* behave
>> this way is **broken**.  If the I/O error is temporary, then the
>> driver should simply not complete the write, and wait.
>
> If we are sure that (at least we make it so that) every error is
> permanent, then yes, this simplifies things a bit because it saves you
> the retries that we know wouldn't succeed anyway.
>
> In that case, what's possibly left is modifying fsync() so that it
> consistently returns an error; or if not, we need to promise this
> behaviour to userspace so that on the first fsync() failure it can give
> up on the file without doing less for the user than it could do.

I think we can (and implicitly do) make that promise: if you get EIO
From=20fsync, then there is no credible recovery action you can try.

>
>> If it fails, it should only be because it has timed out on waiting and
>> has assumed that the problem is permanent.
>
> If a manual action is required to restore the functionality, how can you
> use a timeout for determining whether a problem is permanent or not?

If manual action is required, and can reasonably be expected, then the
device driver should block indefinitely.
As an example, the IBM s390 systems have a "dasd" storage driver, which
I think is a fiber-attached storage array.  If the connection to the
array stops working (and no more paths are available), it will (by
default) block indefinitely.  I presume it logs the problem and the
sysadmin can find out and fix things - or if "things" are unfixable,
they can change the configuration to report an error.

Similary the DM multipath module has an option "queue_if_no_path" (aka
"no_path_retry") which means that if no working paths are found, the
request should be queued and retried (no error reported).

If manual action is an option, then the driver must be configured to wait f=
or
manual action.

>
> This is exactly the kind of errors from which we want to recover in
> qemu instead of killing the VMs. Assuming that errors are permanent when
> they aren't, but just require some action before they can succeed, is
> not a solution to the problem, but it's pretty much the description of
> the problem that we had before we implemented the retry logic.
>
> So if you say that all errors are permanent, fine; but if some of them
> are actually temporary, we're back to square one.
>
>> Otherwise, every single application is going to have to learn how to
>> deal with temporary errors, and everything that implies (throwing up
>> dialog boxes to the user, who may not be able to do anything
>
> Yes, that's obviously not a realistic option.
>
>> --- this is why in the dm-thin case, if you think it should be
>> temporary, dm-thin should be calling out to a usr space program that
>> pages an system administrator; why do you think the process or the
>> user who started the process can do anything about it/)
>
> In the case of qemu, we can't do anything about it in terms of making
> the request work, but we can do something useful with the information:
> We limit the damage done, by pausing the VM and preventing it from
> seeing a broken hard disk from which it wouldn't recover without a
> reboot. So in our case, both the system administrator and the process
> want to be informed.

In theory, using aio_fsync() should allow the process to determine if
any writes are blocking indefinitely.   I have a suspicion that
aio_fsync() is not actually asynchronous, but that might be old
information.
Alternately a child process could call "fsync" and report when it completed.

>
> A timeout could serve as a trigger for qemu, but we could possibly do
> better for things like the dm-thin case where we know immediately that
> we'll have to wait for manual action.

A consistent way for devices to be able to report "operator
intervention required" would certainly be useful.  I'm not sure how easy
it would be for a particular application to determine if such a report
was relevant for any of its IO though.

It might not be too hard to add a flag to "sync_file_range()" to ask it to
report the status of queues, e.g.:
 0 - nothing queued, no data to sync
 1 - writes are being queued, and progress appears to be normal
 2 - queue appears to be stalled
 3 - queue reports that admin intervention is required.

The last one would require a fair bit of plumbing to get the information
to the right place.  The others are probably fairly easy if they can be
defined properly.
If you look in /sys/kernel/bdi/*/stats you will see statistic for each
bdi (backing device info) which roughly correspond to filesystems.  You
can easily map from a file descriptor to a bdi.
The "BdiWriteBandwidth" will (presumably) drop if there is data to be
written which cannot get out.  Monitoring these stats might give an
application a useful understanding about what is happening in a particular
storage device.
I don't suggest that qemu should access this file, because it is a
'debugfs' file and not part of the api.  But the information is there
and might be useful.  If you can show that it is directly useful to an
application in some way, that would a useful step towards making the
information more directly available in an api-stable way.

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh5VKUACgkQOeye3VZi
gbm/Sg//Zvq7qNvCyWGYWNjuOFnkd9xjeX0MIAYF55aJcqWeU6qDOXtKsULWR2GC
MJYcEGXrhOJMDD135den30p80sDRVFBmfWtpi2MVohRdQFVOudeMCVYn8Q/sxpd1
3WzX9w7Ya+5Ix4Dkl49Qbbf+rSj5jokc5rTa2e6URM+wbKSbjX3yVJN3OQYUs+M/
j6iYvdDYHET1qiekDW/fFF16Bu/wbzl2xGQu4biNaNnZk8C12uh/pPjKEi6LMPtH
Yo3wMFKH+RFAwrhQ6bZzCuhmrKdh2/Ba46UcsXSDyb/ZB+Az7XTwewaZ7DrlzjZJ
tdLnSLbMadWV4j5yy7/qnVUhya6kIsrp7ipreM19bxTwVULDKGZosM4tco0l/A3O
PIsMTjgKfadRh5HkWyalJYrhw9hBdZuMQRBPKn+HZUPFpF6eqVV+MAwNZ6m3ECZ9
04sfov4VGo1w7kxulDdcc4JysUfSv9rmMAChgQ2yWHQpv8szBMl7NSTgU/YaDqIy
8TDwegQXph/wbvtbgRzKPR9FBnnRTopzlcEVrPTL1Zo98frVCbMQIsOtFs+TZZhl
x0RTOVMqyvbGBMNNwB56hQAUaROw5St1jkEyl1BQgM2GQSJScU5yAfdky9LrZqR/
/q6jy8GROVpP53SKJ2a997X33VGmEJ7lPFLI2WUcAblTwvrMP6w=
=gdUU
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
