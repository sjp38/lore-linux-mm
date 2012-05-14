Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id D5FC76B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:46:03 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <0966a902-a35e-4c06-ab04-7d088bf25696@default>
Date: Mon, 14 May 2012 13:45:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] ramster: switch over to zsmalloc and crypto interface
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
 <20120514200659.GA15604@kroah.com>
In-Reply-To: <20120514200659.GA15604@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interfac=
e
>=20
> On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> > RAMster does many zcache-like things.  In order to avoid major
> > merge conflicts at 3.4, ramster used lzo1x directly for compression
> > and retained a local copy of xvmalloc, while zcache moved to the
> > new zsmalloc allocator and the crypto API.
> >
> > This patch moves ramster forward to use zsmalloc and crypto.
> >
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>=20

Hi Greg --

> I finally enabled building this one (didn't realize it required ZCACHE
> to be disabled, I can only build one or the other)

Yes, correct.  This overlap is explained in drivers/staging/ramster/TODO
(which IIRC you were the one that asked me to create that file).
In short the TODO says: ramster is a superset of zcache that also
"remotifies" zcache-compressed pages to another machine, and the overlap
with zcache will need to be rectified before either is promoted
from staging.

> and I noticed after
> this patch the following warnings in my build:
>=20
> drivers/staging/ramster/zcache-main.c:950:13: warning: =E2=80=98zcache_do=
_remotify_ops=E2=80=99 defined but not used
> [-Wunused-function]
> drivers/staging/ramster/zcache-main.c:1039:13: warning: =E2=80=98ramster_=
remotify_init=E2=80=99 defined but not used
> [-Wunused-function]

These are because CONFIG_FRONTSWAP isn't yet in your tree.  It is
in linux-next and will hopefully finally be in Linus' tree at
the next window.  Ramster (and zcache) has low value without
frontswap, so the correct fix, after frontswap is merged, is
to remove all the "ifdef CONFIG_FRONTSWAP" and force the
dependency in Kconfig... but I can't do that until frontswap
is merged. :-(

> drivers/staging/ramster/zcache-main.c: In function =E2=80=98zcache_put=E2=
=80=99:
> drivers/staging/ramster/zcache-main.c:1594:4: warning: =E2=80=98page=E2=
=80=99 may be used uninitialized in this
> function [-Wuninitialized]
> drivers/staging/ramster/zcache-main.c:1536:8: note: =E2=80=98page=E2=80=
=99 was declared here

Hmmm... this looks like an overzealous compiler.  The code
is correct and was unchanged by this patch.  My compiler
(gcc 4.4.4) doesn't even report it.  I think I could fix it
by assigning a superfluous NULL at the declaration and will
do that if you want but I can't test the fix with my compiler
since it doesn't report it.

> Care to please fix them up?

It looks like you've taken the patch... if my whining
above falls on deaf ears and you still want me to "fix"
one or both, let me know and I will submit a fixup patch.
(And then... what gcc are you using?)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
