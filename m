Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C13436B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 11:30:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d7588a48-9f47-4f3a-852c-3fac916de75c@default>
Date: Thu, 1 Nov 2012 08:30:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
 <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
 <50915A5C.8000303@linux.vnet.ibm.com>
In-Reply-To: <50915A5C.8000303@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem=
 backends to build/run as
> modules
>=20
> >  static int __init init_frontswap(void)
> >  {
> > +=09int i;
> >  #ifdef CONFIG_DEBUG_FS
> >  =09struct dentry *root =3D debugfs_create_dir("frontswap", NULL);
> >  =09if (root =3D=3D NULL)
> > @@ -364,6 +414,10 @@ static int __init init_frontswap(void)
> >  =09debugfs_create_u64("invalidates", S_IRUGO,
> >  =09=09=09=09root, &frontswap_invalidates);
> >  #endif
> > +=09for (i =3D 0; i < MAX_INITIALIZABLE_SD; i++)
> > +=09=09sds[i] =3D -1;
> > +
> > +=09frontswap_enabled =3D 1;
>=20
> If frontswap_enabled is going to be on all the time, then what point
> does it serve?  By extension, can all of the static inline wrappers in
> frontswap.h be done away with?

The intent of frontswap_enabled and cleancache_enabled was
to avoid the overhead of a function call at the point where
each frontswap/cleancache "hooks" is placed, using a global
variable check instead.  I'm not sure if this minor
performance tuning effort is worth preserving:  If not,
I agree frontswap_enabled and the static inline wrappers (as
well as their cleancache brethren) could be done away with **;
if worth preserving, then I think frontswap_enabled could
be set in the init method instead but the check for enabled
in the frontswap init method and the cleancache init_fs
method would need to be removed else lazy initialization
wouldn't work.

Dan

** Note to anyone that tries this:  There is a subtle but
clever hack in the wrappers suggested by Jeremy Fitzhardinge
that disables the wrappers at compile-time as well as
runtime.  IOW, make sure you test-compile both with
CONFIG_{CLEANCACHE|FRONTSWAP} _and_ with them unconfig'd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
