Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAF3C6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 03:37:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u67so72170149pfu.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 00:37:04 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id di2si9865251pad.176.2016.06.07.00.37.02
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 00:37:03 -0700 (PDT)
From: "Barczak, Mariusz" <mariusz.barczak@intel.com>
Subject: RE: [BUG] Possible silent data corruption in filesystems/page cache
Date: Tue, 7 Jun 2016 07:36:55 +0000
Message-ID: <842E055448A75D44BEB94DEB9E5166E91877C830@irsmsx110.ger.corp.intel.com>
References: <842E055448A75D44BEB94DEB9E5166E91877AAF1@irsmsx110.ger.corp.intel.com>
 <A9F4ECA5-24EF-4785-BC8B-ECFE63F9B026@dilger.ca>
 <842E055448A75D44BEB94DEB9E5166E91877C26F@irsmsx110.ger.corp.intel.com>
 <20160606133539.GE22108@thunk.org>
In-Reply-To: <20160606133539.GE22108@thunk.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wysoczanski,
 Michal" <michal.wysoczanski@intel.com>, "Baldyga, Robert" <robert.baldyga@intel.com>, "Roman, Agnieszka" <agnieszka.roman@intel.com>

Hi Ted,
Thanks for your explanation which convinced me.
Regards,
Mariusz.

-----Original Message-----
From: Theodore Ts'o [mailto:tytso@mit.edu] =

Sent: Monday, June 6, 2016 15:36
To: Barczak, Mariusz <mariusz.barczak@intel.com>
Cc: Andreas Dilger <adilger@dilger.ca>; Andrew Morton <akpm@linux-foundatio=
n.org>; Jens Axboe <axboe@kernel.dk>; Alexander Viro <viro@zeniv.linux.org.=
uk>; linux-mm@kvack.org; linux-block@vger.kernel.org; linux-fsdevel@vger.ke=
rnel.org; linux-kernel@vger.kernel.org; Wysoczanski, Michal <michal.wysocza=
nski@intel.com>; Baldyga, Robert <robert.baldyga@intel.com>; Roman, Agniesz=
ka <agnieszka.roman@intel.com>
Subject: Re: [BUG] Possible silent data corruption in filesystems/page cache

On Mon, Jun 06, 2016 at 07:29:42AM +0000, Barczak, Mariusz wrote:
> Hi, Let me elaborate problem in detail. =

> =

> For buffered IO data are copied into memory pages. For this case, the =

> write IO is not submitted (generally). In the background opportunistic =

> cleaning of dirty pages takes place and IO is generated to the device. =

> An IO error is observed on this path and application is not informed =

> about this. Summarizing flushing of dirty page fails.
> And probably, this page is dropped but in fact it should not be.
> So if above situation happens between application write and sync then =

> no error is reported. In addition after some time, when the =

> application reads the same LBA on which IO error occurred, old data =

> content is fetched.

The application will be informed about it if it asks --- if it calls fsync(=
), the I/O will be forced and if there is an error it will be returned to t=
he user.  But if the user has not asked, there is no way for the user space=
 to know that there is a problem --- for that matter, it may have exited al=
ready by the time we do the buffered writeback, so there may be nobody to i=
nform.

If the error hapepns between the write and sync, then the address space map=
ping's AS_EIO bit will be set.  (See filemap_check_errors() and do a git gr=
ep on AS_EIO.)  So the user will be informed when they call fsync(2).

The problem with simply not dropping the page is that if we do that, the pa=
ge will never be cleaned, and in the worst case, this can lead to memory ex=
haustion.  Consider the case where a user is writing huge numbers of pages,=
 (e.g., dd if=3D/dev/zero
of=3D/dev/device-that-will-go-away) if the page is never dropped, then the =
memory will never go away.

In other words, the current behavior was carefully considered, and delibera=
tely chosen as the best design.

The fact that you need to call fsync(2), and then check the error returns o=
f both fsync(2) *and* close(2) if you want to know for sure whether or not =
there was an I/O error is a known, docmented part of Unix/Linux and has bee=
n true for literally decades.  (With Emacs learning and fixing this back in=
 the late-1980's to avoid losing user data if the user goes over quota on t=
heir Andrew File System on a BSD
4.3 system, for example.  If you're using some editor that comes with some =
desktop package or some whizzy IDE, all bets are off, of course.
But if you're using such tools, you probably care about eye candy way more =
than you care about your data; certainly the authors of such programs seem =
to have this tendency, anyway.  :-)

Cheers,

						- Ted
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
