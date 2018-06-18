Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8D516B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:17:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u21-v6so9296345pfn.0
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:17:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u16-v6si12565714pgv.409.2018.06.18.16.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:17:37 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:17:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 200105] New: High paging activity as soon as the swap is
 touched (with steps and code to reproduce it)
Message-Id: <20180618161735.72a1c9036057ee08d17aaaf4@linux-foundation.org>
In-Reply-To: <bug-200105-27@https.bugzilla.kernel.org/>
References: <bug-200105-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, terragonjohn@yahoo.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 17 Jun 2018 21:56:23 +0000 bugzilla-daemon@bugzilla.kernel.org wrot=
e:

> https://bugzilla.kernel.org/show_bug.cgi?id=3D200105
>=20
>             Bug ID: 200105
>            Summary: High paging activity as soon as the swap is touched
>                     (with steps and code to reproduce it)
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.14 4.15 4.16 4.17
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: terragonjohn@yahoo.com
>         Regression: No
>=20
> Hi.
>=20
> Under any desktop environment, as soon as the swap is touched the kernel =
starts
> paging out gigabytes of memory for no apparent reason causing the system =
to
> freeze for at least a minute.
>=20
>=20
> This happens with normal desktop usage but I'm able to reproduce this beh=
avior
> systematically by using the code included at the end of this report, let'=
s call
> it "memeater". memeater takes three parameters: totalmem, chunksize, slee=
ptime.
> It allocates (and initializes to 0) totalmem bytes of memory in chunks of
> chunksize bytes each. After each chunk allocation it sleeps for sleeptime
> seconds. If sleeptime=3D0, it does not sleep in between chunk allocations.
> After totalmem bytes of memory have been allocated it sleeps indefinitely.
>=20
> To reproduce the behaviour using memeater:
>=20
> 1) start a desktop environment (in my case KDE plasma).
> 2) invoke "memeater x y 0" to bring the system to the brink of swapping. I
> usually execute "memeater x y 0" multiple times where x is 4 gigs and y i=
s 20
> megs.(I've got 16GB of memory so I usually go up to 14/15 GB of used memo=
ry).
> 3) invoke "memeater x y 1" one last time so that it slowly fills up the m=
emory
> with small chunks of a few megs each (again, I tried it with x=3D4 gigs a=
nd y=3D20
> megs).
>=20
> When the last memeater fills the memory (and keeps allocating chunks) I w=
ould
> expect the mm system to swap out few megabytes worth of pages to accomoda=
te the
> new requests slowly coming from the last memeater.=20
> However, what actually happens is that the mm starts to swap out gigabytes
> worth of pages completely freezing the system for one or two minutes.
>=20
> I've verified this on various desktop systems, all using SSDs.
> Obviously, I'm willing to provide more info and to test patches.
>=20
>=20
> ####### memeater #######################=E0
>=20
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
>=20
>=20
>=20
> int main(int argc, char** argv) {
>     long int max =3D -1;
>     int mb =3D 0;
>     long int size =3D 0;
>     long int total =3D 0;
>     int sleep_time =3D 0;
>     char* buffer;
>=20
>     if(argc > 1)
>       {
>         max =3D atol(argv[1]);
>         size =3D atol(argv[2]);
>         sleep_time =3D atoi(argv[3]);
>       }
>     printf("Max: %lu bytes\n", max);
>     while((buffer=3Dmalloc(size)) !=3D NULL && total < max) {
>         memset(buffer, 0, size);
>         mb++;
>         total=3Dmb*size;
>         printf("Allocated %lu bytes\n", total);
>         if (sleep_time) sleep(sleep_time);
>     }     =20
> sleep(3000000);
> return 0;
> }
>=20
> --=20
> You are receiving this mail because:
> You are the assignee for the bug.
