Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5B966B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 16:09:46 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g12-v6so10989683ioh.5
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 13:09:46 -0700 (PDT)
Received: from sonic301-32.consmr.mail.ne1.yahoo.com (sonic301-32.consmr.mail.ne1.yahoo.com. [66.163.184.201])
        by mx.google.com with ESMTPS id b3-v6si1089286ioa.51.2018.07.21.13.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jul 2018 13:09:45 -0700 (PDT)
Date: Sat, 21 Jul 2018 20:09:43 +0000 (UTC)
From: john terragon <terragonjohn@yahoo.com>
Message-ID: <1114810711.347852.1532203783155@mail.yahoo.com>
In-Reply-To: <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
References: <bug-200105-8545@https.bugzilla.kernel.org/> <bug-200105-8545-FomWhXSVhq@https.bugzilla.kernel.org/> <191624267.262238.1532074743289@mail.yahoo.com> <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
Subject: Re: [Bug 200105] High paging activity as soon as the swap is
 touched (with steps and code to reproduce it)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Jordan <lkmldmj@gmail.com>
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Michal Hocko <mhocko@kernel.org>

I'll add a couple of points to Daniel's summary:
=C2=A0

1) initially I performed the test with the memeaters within a gui (KDE, but=
 I tried gnome too). The system freezes occur when the
test is performed within a gui.


2) Then, to isolate what seemed to be more symptoms (the freezes) than the =
problem itself, I started to perform the test using just text consoles. In =
these conditions there are no big, visible, system freezes. Although one of=
 the tools used to snapshot vmstat (Michal's read_vmstat) complains with me=
ssages like "it took 28s to snapshot!" or something like that, so maybe the=
re are still slowdowns.


3) Anyways,=C2=A0 both in gui and text "mode", the test always causes a hug=
e swap activity which seems to be disproportionate given the low pressure t=
he vm is put under (tried as low as 4Mb/s allocation rate).


4) These are the swap configurations in which the huge swap activity occurs=
:


-luks encrypted swap partition


-dmcrypt plain swap partition


-unencrypted swapfile located inside an encrypted, luks or dmcrypt plain, f=
ilesystem


5) The test does not cause any huge swap activity under these swap configs =
*when performed without a gui*:


a) unencrypted swap partition


b) encrypted swap file located inside and unencryted ext4 filesystem (that =
is ext4 directly on=C2=A0 the partition and the directory
in which the swapfile resides is encrypted with fs-level encryption, thus n=
o dm-crypt involved).


6) I was particularly happy about b) above because it seemed to be a viable=
 workaround, but sadly I have to report that, although the
test does not causes large swap activity with b), minute-long system freeze=
s are occurring during normal usage even with b).
These seem to be the same kind of freezes that prompted me to find a way to=
 reliably reproduce them under controlled conditions.
I haven't yet performed the test with b)+gui, though, only b)+text console =
as I wrote in 5.
