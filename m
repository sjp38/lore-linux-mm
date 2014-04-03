Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id C11BD6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:57:55 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hu19so1931874vcb.15
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 05:57:55 -0700 (PDT)
Received: from fnord.ir.bbn.com (fnord.ir.bbn.com. [2001:4978:1fb:6400::d2])
        by mx.google.com with ESMTPS id tq2si1212676vdc.201.2014.04.03.05.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 05:57:54 -0700 (PDT)
From: Greg Troxel <gdt@ir.bbn.com>
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com> <20140402111032.GA27551@infradead.org>
	<1396439119.2726.29.camel@menhir> <533CA0F6.2070100@bbn.com>
	<CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com>
Date: Thu, 03 Apr 2014 08:57:52 -0400
In-Reply-To: <CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com>
	(Michael Kerrisk's message of "Thu, 3 Apr 2014 10:25:01 +0200")
Message-ID: <rmivbuqy3hr.fsf@fnord.ir.bbn.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Richard Hansen <rhansen@bbn.com>, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


"Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:

> I think the only reasonable solution is to better document existing
> behavior and what the programmer should do. With that in mind, I've
> drafted the following text for the msync(2) man page:
>
>     NOTES
>        According to POSIX, exactly one of MS_SYNC and MS_ASYNC  must  be
>        specified  in  flags.   However,  Linux permits a call to msync()
>        that specifies neither of these flags, with  semantics  that  are
>        (currently)  equivalent  to  specifying  MS_ASYNC.   (Since Linux
>        2.6.19, MS_ASYNC is in fact a no-op, since  the  kernel  properly
>        tracks  dirty  pages  and  flushes them to storage as necessary.)
>        Notwithstanding the Linux behavior, portable, future-proof appli=
=E2=80=90
>        cations  should  ensure  that they specify exactly one of MS_SYNC
>        and MS_ASYNC in flags.
>
> Comments on this draft welcome.

I think it's a step backwards to document unspecified behavior.  If
anything, the man page should make it clear that providing neither flag
results in undefined behavior and will lead to failure on systems on
than Linux.  While I can see the point of not changing the previous
behavior to protect buggy code, there's no need to document it in the
man page and further enshrine it.

There's a larger point, which is that people write code for Linux when
they should be writing code for POSIX.  Therefore, Linux has an
obligation to the larger free software community to avoid encouraging
non-portable code.  This is somewhat similar (except for the key point
that it's unintentional) to bash's allowing "=3D=3D" in test, which is a
gratuitous extension to the standard that has led to large amounts of
nonportable code.  To mitigate this, it would be reasonable to syslog a
warning the first time a process makes a call with flags that POSIX says
leads to undefined behavior.  That would meet the
portability-citizenzhip goals and not break existing systems.

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlM9WtAACgkQ+vesoDJhHiV7HwCfdOu6gMykiZY3L5gYuaaAmD6k
/vIAmwb5o33ETiVujuJmg5qcHzbU9sVx
=JpEp
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
