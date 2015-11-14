Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 50B736B0253
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:43:36 -0500 (EST)
Received: by padhx2 with SMTP id hx2so115193072pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:43:36 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id il5si9405836pbc.198.2015.11.13.16.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 16:43:34 -0800 (PST)
Received: by padhx2 with SMTP id hx2so115192654pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:43:34 -0800 (PST)
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_1216766E-B738-4495-BFC0-CB153BFD6B45"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
Date: Fri, 13 Nov 2015 17:43:28 -0700
Message-Id: <22E0F870-C1FB-431E-BF6C-B395A09A2B0D@dilger.ca>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com> <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com> <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>


--Apple-Mail=_1216766E-B738-4495-BFC0-CB153BFD6B45
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 13, 2015, at 5:20 PM, Dan Williams <dan.j.williams@intel.com> =
wrote:
>=20
> On Fri, Nov 13, 2015 at 4:06 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
>> Currently the PMEM driver doesn't accept REQ_FLUSH or REQ_FUA bios.  =
These
>> are sent down via blkdev_issue_flush() in response to a fsync() or =
msync()
>> and are used by filesystems to order their metadata, among other =
things.
>>=20
>> When we get an msync() or fsync() it is the responsibility of the DAX =
code
>> to flush all dirty pages to media.  The PMEM driver then just has =
issue a
>> wmb_pmem() in response to the REQ_FLUSH to ensure that before we =
return all
>> the flushed data has been durably stored on the media.
>>=20
>> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>=20
> Hmm, I'm not seeing why we need this patch.  If the actual flushing of
> the cache is done by the core why does the driver need support
> REQ_FLUSH?  Especially since it's just a couple instructions.  REQ_FUA
> only makes sense if individual writes can bypass the "drive" cache,
> but no I/O submitted to the driver proper is ever cached we always
> flush it through to media.

If the upper level filesystem gets an error when submitting a flush
request, then it assumes the underlying hardware is broken and cannot
be as aggressive in IO submission, but instead has to wait for in-flight
IO to complete.  Since FUA/FLUSH is basically a no-op for pmem devices,
it doesn't make sense _not_ to support this functionality.

Cheers, Andreas






--Apple-Mail=_1216766E-B738-4495-BFC0-CB153BFD6B45
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVkaDsXKl2rkXzB/gAQibwBAAgoTcZevnn7sprjKcrySWAvw9bcubKzY8
W4c6wkFftY8858ROsblZ/0+OhZPFlf2zJ2G3g+8sJ4Upv1s0MpyGHYS6QVu/QLn3
xy4O7ivbLMtFOfMFWfheKAb8GxJxzpklB5yhyHaMnxtCxEg71K5D9mnqTi/jPIv6
L0yWugsuzeSVeJ423NsFCxRZkWN2wrSuT6PS7bPeN/VBUC8wfU+LMXnmye9+tl1Z
EkZWf11PQOz5kkEkN6Xk+ShgAVz7GR6w3jYHxDvNbZ+bDvlPGsV8Wvf+GZIo0Q4/
SdhfRfNG/D2KKQlCAfZyyEdcSRcoSvkhAPny+ocGW9+rUNd86LMllbvfGzkRNH9Y
pfocoQZHxcJ9G52XeqVVJvFzajQhPryzdOePg5YwnckY5h6Td0K46THztFKMN51K
vXNhhbV/EHy7EjgNOsu+4tTfWrVdSGB4AiKlJlZ4SU5e4FaJxLR00jzm5nVSZpbC
NW8NO+uE8deVLw1BJbVFq6S4qm1NshY0EZ4SYuksdJaAwo3kZtdjvbmnFq2Er+ta
PVoWA5oJl5pZ0WRxEckchTIXC7iqwgVdBtPBqiAOZ4u+X3caU7kx+hYpjCymozvy
6RdWl1hfgIv5lkJGf1SBOaLz1KSu2ElTtGDbWaQpxnKNnsE0Ye/gTd4m9bb86e+O
b5j4DzeyM0E=
=ibQq
-----END PGP SIGNATURE-----

--Apple-Mail=_1216766E-B738-4495-BFC0-CB153BFD6B45--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
