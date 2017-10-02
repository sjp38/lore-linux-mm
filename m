Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13A6B6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 18:29:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so3842314wmb.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 15:29:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z188sor2988115wmc.56.2017.10.02.15.29.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 15:29:22 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <4BE3C848-6295-471C-A635-E89A28919C41@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_443B2AFE-2273-409D-968B-6F48DB4AD1C7";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
Date: Tue, 3 Oct 2017 00:29:01 +0200
In-Reply-To: <dcb23e5d-81b9-9a6c-b7ac-bbad2ef77fd8@yandex-team.ru>
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
 <dcb23e5d-81b9-9a6c-b7ac-bbad2ef77fd8@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>


--Apple-Mail=_443B2AFE-2273-409D-968B-6F48DB4AD1C7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Oct 2, 2017, at 10:58 PM, Konstantin Khlebnikov =
<khlebnikov@yandex-team.ru> wrote:
>=20
> On 02.10.2017 22:54, Linus Torvalds wrote:
>> On Mon, Oct 2, 2017 at 2:54 AM, Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>>>=20
>>> This patch implements write-behind policy which tracks sequential =
writes
>>> and starts background writeback when have enough dirty pages in a =
row.
>> This looks lovely to me.
>> I do wonder if you also looked at finishing the background
>> write-behind at close() time, because it strikes me that once you
>> start doing that async writeout, it would probably be good to make
>> sure you try to do the whole file.
>=20
> Smaller files or tails is lesser problem and forced writeback here
> might add bigger overhead due to small requests or too random IO.
> Also open+append+close pattern could generate too much IO.
>=20
>> I'm thinking of filesystems that do delayed allocation etc - I'd
>> expect that you'd want the whole file to get allocated on disk
>> together, rather than have the "first 256kB aligned chunks" allocated
>> thanks to write-behind, and then the final part allocated much later
>> (after other files may have triggered their own write-behind). Think
>> loads like copying lots of pictures around, for example.
>=20
> As far as I know ext4 preallocates space beyond file end for writing
> patterns like append + fsync. Thus allocated extents should be bigger
> than 256k. I haven't looked into this yet.
>=20
>> I don't have any particularly strong feelings about this, but I do
>> suspect that once you have started that IO, you do want to finish it
>> all up as the file write is done. No?
>=20
> I'm aiming into continuous file operations like downloading huge file
> or writing verbose log. Original motivation came from low-latency =
server
> workloads which suffers from parallel bulk operations which generates
> tons of dirty pages. Probably for general-purpose usage thresholds
> should be increased significantly to cover only really bulky patterns.
>=20
>> It would also be really nice to see some numbers. Perhaps a =
comparison
>> of "vmstat 1" or similar when writing a big file to some slow medium
>> like a USB stick (which is something we've done very very badly at,
>> and this should help smooth out)?
>=20
> I'll try to find out some real cases with numbers.
>=20
> For now I see that massive write + fdatasync (dd conf=3Dfdatasync, =
fio)
> always ends earlier because writeback now starts earlier too.
> Without fdatasync it's obviously slower.
>=20
> Cp to usb stick + umount should show same result, plus cp could be
> interrupted at any point without contaminating cache with dirty pages.
>=20
> Kernel compilation tooks almost the same time because most files are
> smaller than 256k.

For what it's worth, Lustre clients have been doing "early writes" =
forever,
when at least a full/contiguous RPC worth (1MB) of dirty data is =
available,
because network bandwidth is a terrible thing to waste.  The oft-cited =
case
of "app writes to a file that only lives a few seconds on disk before it =
is
deleted" is IMHO fairly rare in real life, mostly dbench and back in the
days of disk based /tmp.

Delaying data writes for large files means that 30s * bandwidth of data
could have been written before VM page aging kicks in, unless memory
pressure causes writeout first.  With fast devices/networks, this might
be many GB of data filling up memory that could have been written out.

Cheers, Andreas






--Apple-Mail=_443B2AFE-2273-409D-968B-6F48DB4AD1C7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZ0r2vpIg59Q01vtYRAn5dAJ4+ifYfr0GM7EdGMvMnIrxAnnNQ5QCfdgjI
CRxPRnwWkU+26r7IrHEo5+Q=
=UVF7
-----END PGP SIGNATURE-----

--Apple-Mail=_443B2AFE-2273-409D-968B-6F48DB4AD1C7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
