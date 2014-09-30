Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C40B26B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 17:25:21 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so3593507pdj.3
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 14:25:21 -0700 (PDT)
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
        by mx.google.com with ESMTPS id w9si27092060pdn.172.2014.09.30.14.25.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 14:25:20 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so1407887pde.6
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 14:25:20 -0700 (PDT)
Content-Type: multipart/signed; boundary="Apple-Mail=_71D336C4-DDA5-4E4B-B7BB-D6F0544313BF"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <15704.1412109476@turing-police.cc.vt.edu>
Date: Tue, 30 Sep 2014 15:25:17 -0600
Message-Id: <A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx> <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx> <15704.1412109476@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--Apple-Mail=_71D336C4-DDA5-4E4B-B7BB-D6F0544313BF
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Sep 30, 2014, at 2:37 PM, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 30 Sep 2014 12:08:41 -0400, Matthew Wilcox said:
>=20
>> The more I think about this, the more I think this is a bad idea.
>> When you have a file open with O_DIRECT, your I/O has to be done in
>> 512-byte multiples, and it has to be aligned to 512-byte boundaries
>> in memory.  If an unsuspecting application has O_DIRECT forced on it,
>> it isn't going to know to do that, and so all its I/Os will fail.
>=20
> I'm thinking of more than one place where that would be a feature, not =
a bug. :)

We prototyped a feature like this for Lustre - so the admins could
turn IO into O_DIRECT, because the HPC compute nodes have relatively
small RAM per core and don't want to have file data cache consuming
RAM that the compute jobs need.

Unfortunately, the O_DIRECT semantics are a killer for poorly written
applications that end up doing small synchronous writes.  We didn't
have any IO size problems, because Lustre client have to copy the data
to the servers anyway, so arbitrary IO sizes are fine.

While this _might_ be OK for NVRAM mapped directly into the filesystem,
even for local disk based storage with 512-byte writes at 100 IOPS is
only 50KB/s instead of ~100MB/s for a cached writes to a single disk.

I think you would be much better off having more aggressive "use once"
semantics in the page cache, so that page cache pages for streaming
writes are evicted more aggressively from cache rather than going down
the "automatic O_DIRECT" hole.

Cheers, Andreas

>> What problem are you really trying to solve?  Some big files hogging
>> the page cache?
>=20
> I'm officially a storage admin.  I mostly support HPC and research. As
> such, I'm always looking to add tools to my toolkit. :)
>=20
> (And yes, I fully recognize that *in general*, this is a Bad Idea.  =
However,
> when you've got That One Problem Data File that *should* always be =
access
> via O_DIRECT, and *usually* is accessed via O_DIRECT, and bad things =
happen
> if something accesses it without it (for instance, when the file is =
1.5X the
> actual RAM), you start looking for fixes.  If you've got another, more
> sustainable way to say "do not let file /X/Y/Z hog the page cache" =
(and
> no, LD_PRELOAD isn't sustainable the way chattr is, in my book), feel =
free to
> recommend something. :)


Cheers, Andreas






--Apple-Mail=_71D336C4-DDA5-4E4B-B7BB-D6F0544313BF
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVCsfvXKl2rkXzB/gAQLEVw/9HBf3RC6J9vwNg4umD9M94JJkdSWwSY/k
pHRrpT+4v5SQlC3SKX/VV4P+/aXoBVRq/6IeUHQnFaEfYy8x39dkckLX2GzH70Tg
0fO8sAfr+XDzLbxDJYJzu8R1XnbNhopwuV8BXAOmIaUe3dJqee74PG+egAVF7uWX
lNGeh32VQ5/ypuxEG5CbHTH7P/DFwl1L+kANEvbnMBhG/x4pA6BRlRCFUctDewEU
XSc+0drJeXRuxtLX30kycGrpJyvuwOF+j0VxKWCQWatkERon0JyObluie/cHnWvK
SUgU92l5/UbhZo06XiKhrFdrVF7O0HkZ1C7nMGSlI+iCqaupAnsL2tCTE/zlzBbh
oso2kZeCxdcvG6yzBgTGmF/YhFzS88YSiIDHhLytyEusf/KhipbE6SrQ8MjuvfaR
WRdChpMC+RO/cSPjqETT/CxvPmjb/NcWso0pcFH0CV+hAt6EYLiI66n6/WlNGhJK
3/0mZmjb9VefcEqc2mU1nZW6mPINQi+KVX6eqtLRajofQb9HXA9XAbXdO/JEkZn/
JU7crpjhqOJmSgb6U+8c+g+nuPRxgafQJUDH3A9Vt91BQOADGwUM3EOuKEVoa3mh
UgWYL2hUJGeiwad0tAF7Ghx20duNawrtUT5Kk1CmKFvjdLoseCmq8N/TSwuEb+oF
cMCqJ5wUNWM=
=+Ecu
-----END PGP SIGNATURE-----

--Apple-Mail=_71D336C4-DDA5-4E4B-B7BB-D6F0544313BF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
