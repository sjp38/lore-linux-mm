Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC1A6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 03:29:54 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so193694983pad.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 00:29:54 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o14si26775004pfj.121.2016.06.06.00.29.53
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 00:29:53 -0700 (PDT)
From: "Barczak, Mariusz" <mariusz.barczak@intel.com>
Subject: RE: [BUG] Possible silent data corruption in filesystems/page cache
Date: Mon, 6 Jun 2016 07:29:42 +0000
Message-ID: <842E055448A75D44BEB94DEB9E5166E91877C26F@irsmsx110.ger.corp.intel.com>
References: <842E055448A75D44BEB94DEB9E5166E91877AAF1@irsmsx110.ger.corp.intel.com>
 <A9F4ECA5-24EF-4785-BC8B-ECFE63F9B026@dilger.ca>
In-Reply-To: <A9F4ECA5-24EF-4785-BC8B-ECFE63F9B026@dilger.ca>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wysoczanski, Michal" <michal.wysoczanski@intel.com>, "Baldyga, Robert" <robert.baldyga@intel.com>, "Roman, Agnieszka" <agnieszka.roman@intel.com>

Hi, Let me elaborate problem in detail. =


For buffered IO data are copied into memory pages. For this case,
the write IO is not submitted (generally). In the background opportunistic
cleaning of dirty pages takes place and IO is generated to the
device. An IO error is observed on this path and application
is not informed about this. Summarizing flushing of dirty page fails.
And probably, this page is dropped but in fact it should not be.
So if above situation happens between application write and sync
then no error is reported. In addition after some time, when the
application reads the same LBA on which IO error occurred, old data
content is fetched.

We did own fault injector in order to do error in specific condition
described above.

Regards,
Mariusz.

-----Original Message-----
From: Andreas Dilger [mailto:adilger@dilger.ca] =

Sent: Thursday, June 2, 2016 21:32
To: Barczak, Mariusz <mariusz.barczak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>; Jens Axboe <axboe@kernel.dk>=
; Alexander Viro <viro@zeniv.linux.org.uk>; linux-mm@kvack.org; linux-block=
@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-kernel@vger.kernel.o=
rg; Wysoczanski, Michal <michal.wysoczanski@intel.com>; Baldyga, Robert <ro=
bert.baldyga@intel.com>; Roman, Agnieszka <agnieszka.roman@intel.com>
Subject: Re: [BUG] Possible silent data corruption in filesystems/page cache

On Jun 1, 2016, at 3:51 AM, Barczak, Mariusz <mariusz.barczak@intel.com> wr=
ote:
> =

> We run data validation test for buffered workload on filesystems:
> ext3, ext4, and XFS.
> In context of flushing page cache block device driver returned IO error.
> After dropping page cache our validation tool reported data corruption.

Hi Mariusz,
it isn't clear what you expect to happen here?  If there is an IO error the=
n the data is not written to disk and cannot be correct when read.

The expected behaviour is the IO error will either be returned immediately =
at write() time (this used to be more common with older filesystems), or it=
 will be returned when calling sync() on the file to flush cached data to d=
isk.

> We provided a simple patch in order to inject IO error in device mapper.
> We run test to verify md5sum of file during IO error.
> Test shows checksum mismatch.
> =

> Attachments:
> 0001-drivers-md-dm-add-error-injection.patch - device mapper patch

There is already the dm-flakey module that allows injecting errors into the=
 IO path.

Cheers, Andreas





--------------------------------------------------------------------

Intel Technology Poland sp. z o.o.
ul. Slowackiego 173 | 80-298 Gdansk | Sad Rejonowy Gdansk Polnoc | VII Wydz=
ial Gospodarczy Krajowego Rejestru Sadowego - KRS 101882 | NIP 957-07-52-31=
6 | Kapital zakladowy 200.000 PLN.

Ta wiadomosc wraz z zalacznikami jest przeznaczona dla okreslonego adresata=
 i moze zawierac informacje poufne. W razie przypadkowego otrzymania tej wi=
adomosci, prosimy o powiadomienie nadawcy oraz trwale jej usuniecie; jakiek=
olwiek
przegladanie lub rozpowszechnianie jest zabronione.
This e-mail and any attachments may contain confidential material for the s=
ole use of the intended recipient(s). If you are not the intended recipient=
, please contact the sender and delete all copies; any review or distributi=
on by
others is strictly prohibited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
