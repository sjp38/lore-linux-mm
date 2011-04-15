Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CAEB9900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:10:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2C2DF3EE0BD
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:10:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1133045DE96
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:10:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3F7C45DE95
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:10:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5785E08002
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:10:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 98493E08001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:10:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] define dummy BUILD_BUG_ON definition for sparse
In-Reply-To: <20110415121424.F7A6.A69D9226@jp.fujitsu.com>
References: <20110414234216.9E31DBD9@kernel> <20110415121424.F7A6.A69D9226@jp.fujitsu.com>
Message-Id: <20110415140952.F7AE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 15 Apr 2011 14:09:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

> Hello,
>=20
> > diff -puN include/linux/gfp.h~make-sparse-happy-with-gfp_h include/linu=
x/gfp.h
> > --- linux-2.6.git/include/linux/gfp.h~make-sparse-happy-with-gfp_h	2011=
-04-14 14:47:02.629275904 -0700
> > +++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-14 14:47:38.81327267=
4 -0700
> > @@ -249,14 +249,9 @@ static inline enum zone_type gfp_zone(gf
> > =20
> >  	z =3D (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
> >  					 ((1 << ZONES_SHIFT) - 1);
> > -
> > -	if (__builtin_constant_p(bit))
> > -		BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > -	else {
> >  #ifdef CONFIG_DEBUG_VM
> > -		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > +	BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> >  #endif
> > -	}
> >  	return z;
>=20
> Why don't you use VM_BUG_ON?

After while thinking, I decided to make another patch. If we take your
approach we will remove all BUILD_BUG_ON eventually. It's no happy result.


=46rom 2da32b2875a6bd0bb0166993b4663eac0c5d1d6d Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 15 Apr 2011 13:37:24 +0900
Subject: [PATCH] define dummy BUILD_BUG_ON definition for sparse

BUILD_BUG_ON() makes syntax error to detect coding error. Then it
naturally makes sparse error too. It reduce sparse usefulness.

Then, this patch makes dummy BUILD_BUG_ON() definition for sparse.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/kernel.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 00cec4d..9ac44b8 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -637,6 +637,14 @@ struct sysinfo {
 	char _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses this.. */
 };
=20
+#ifdef __CHECKER__
+#define BUILD_BUG_ON_NOT_POWER_OF_2(n)
+#define BUILD_BUG_ON_ZERO(e)
+#define BUILD_BUG_ON_NULL(e)
+#define BUILD_BUG_ON(condition)
+#else /* __CHECKER__ */
+
 /* Force a compilation error if a constant expression is not a power of 2 =
*/
 #define BUILD_BUG_ON_NOT_POWER_OF_2(n)			\
 	BUILD_BUG_ON((n) =3D=3D 0 || (((n) & ((n) - 1)) !=3D 0))
@@ -673,6 +681,7 @@ extern int __build_bug_on_failed;
 		if (condition) __build_bug_on_failed =3D 1;	\
 	} while(0)
 #endif
+#endif /* __CHECKER__ */
=20
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
--=20
1.7.3.1





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
