Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B28096B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 19:50:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default>
Date: Thu, 10 May 2012 16:50:30 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FA33DF6.8060107@kernel.org> <20120509201918.GA7288@kroah.com>
 <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com>
 <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com>
 <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org>
 <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org>
 <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org>
In-Reply-To: <4FAC4E3B.3030909@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
>=20
> Okay. Now it works but zcache coupled with zsmalloc tightly.
> User of zsmalloc should never know internal of zs_handle.
>=20
> 3)
>=20
> - zsmalloc.h
> void *zs_handle_to_ptr(struct zs_handle handle)
> {
> =09return handle.hanle;
> }
>=20
> static struct zv_hdr *zv_create(..)
> {
> =09struct zs_handle handle;
> =09..
> =09handle =3D zs_malloc(pool, size);
> =09..
> =09return zs_handle_to_ptr(handle);
> }
>=20
> Why should zsmalloc support such interface?
> It's a zcache problem so it's desriable to solve it in zcache internal.
> And in future, if we can add/remove zs_handle's fields, we can't make
> sure such API.

Hi Minchan --

I'm confused so maybe I am misunderstanding or you can
explain further.  It seems like you are trying to redesign
zsmalloc so that it can be a pure abstraction in a library.
While I understand and value abstractions in software
designs, the primary use now of zsmalloc is in zcache.  If
there are other users that require a different interface
or a more precise abstract API, zsmalloc could then
evolve to meet the needs of multiple users.  But I think
zcache is going to need more access to the internals
of its allocator, not less.  Zsmalloc is currently missing
some important functionality that (I believe) will be
necessary to turn zcache into an enterprise-ready,
always-on kernel feature.  If it evolves to add that
functionality, then it may no longer be able to provide
generic abstract access... in which case generic zsmalloc
may then have zero users in the kernel.

So I'd suggest we hold off on trying to make zsmalloc
"pretty" until we better understand how it will be used
by zcache (and ramster) and, if there are any, any future
users.

That's just my opinion...
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
