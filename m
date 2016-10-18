Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E807A6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:26:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b75so4908665lfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 00:26:59 -0700 (PDT)
Received: from special.m3.smtp.beget.ru (special.m3.smtp.beget.ru. [5.101.158.90])
        by mx.google.com with ESMTPS id x135si400305lfa.52.2016.10.18.00.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 00:26:58 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Subject: Re: [Bug 177821] New: NULL pointer dereference in list_rcu
From: Alexander Polakov <apolyakov@beget.ru>
In-Reply-To: <20161017171038.924cbbcfc0a23652d2d2b8b4@linux-foundation.org>
Date: Tue, 18 Oct 2016 10:26:55 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <FA3391F9-B333-451D-8415-CB5B62030A9D@beget.ru>
References: <bug-177821-27@https.bugzilla.kernel.org/>
 <20161017171038.924cbbcfc0a23652d2d2b8b4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>


> On 18 Oct 2016, at 03:10, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
>=20
> (resend due to "vdavydov@virtuozzo.com Unrouteable address")
>=20
> (switched to email.  Please respond via emailed reply-to-all, not via =
the
> bugzilla web interface).
>=20
> On Mon, 17 Oct 2016 13:08:17 +0000 bugzilla-daemon@bugzilla.kernel.org =
wrote:
>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D177821
>>=20
>>            Bug ID: 177821
>>           Summary: NULL pointer dereference in list_rcu
>=20
> Fair enough, I suppose.
>=20
> Please don't submit patches via bugzilla - it is quite
> painful.  Documentation/SubmittingPatches explains the
> way to do it.
>=20
> Here's what I put together.  Note that we do not have your
> signed-off-by: for this.  Please send it?

Sorry for the bugzilla thing, here's the patch with Signed-off-by added.
Hope I did it right.

From: Alexander Polakov <apolyakov@beget.ru>
Subject: mm/list_lru.c: avoid error-path NULL pointer deref

As described in https://bugzilla.kernel.org/show_bug.cgi?id=3D177821:

After some analysis it seems to be that the problem is in alloc_super().=20=

In case list_lru_init_memcg() fails it goes into destroy_super(), which
calls list_lru_destroy().

And in list_lru_init() we see that in case memcg_init_list_lru() fails,
lru->node is freed, but not set NULL, which then leads =
list_lru_destroy()
to believe it is initialized and call memcg_destroy_list_lru().=20
memcg_destroy_list_lru() in turn can access lru->node[i].memcg_lrus, =
which
is NULL.

[akpm@linux-foundation.org: add comment]
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Alexander Polakov <apolyakov@beget.ru>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

mm/list_lru.c |    2 ++
1 file changed, 2 insertions(+)

diff -puN mm/list_lru.c~a mm/list_lru.c
--- a/mm/list_lru.c~a
+++ a/mm/list_lru.c
@@ -554,6 +554,8 @@ int __list_lru_init(struct list_lru *lru
	err =3D memcg_init_list_lru(lru, memcg_aware);
	if (err) {
		kfree(lru->node);
+		/* Do this so a list_lru_destroy() doesn't crash: */
+		lru->node =3D NULL;
		goto out;
	}

_


>=20
>=20
>=20
> From: Alexander Polakov <apolyakov@beget.ru>
> Subject: mm/list_lru.c: avoid error-path NULL pointer deref
>=20
> As described in https://bugzilla.kernel.org/show_bug.cgi?id=3D177821:
>=20
> After some analysis it seems to be that the problem is in =
alloc_super().=20
> In case list_lru_init_memcg() fails it goes into destroy_super(), =
which
> calls list_lru_destroy().
>=20
> And in list_lru_init() we see that in case memcg_init_list_lru() =
fails,
> lru->node is freed, but not set NULL, which then leads =
list_lru_destroy()
> to believe it is initialized and call memcg_destroy_list_lru().=20
> memcg_destroy_list_lru() in turn can access lru->node[i].memcg_lrus, =
which
> is NULL.
>=20
> [akpm@linux-foundation.org: add comment]
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>=20
> mm/list_lru.c |    2 ++
> 1 file changed, 2 insertions(+)
>=20
> diff -puN mm/list_lru.c~a mm/list_lru.c
> --- a/mm/list_lru.c~a
> +++ a/mm/list_lru.c
> @@ -554,6 +554,8 @@ int __list_lru_init(struct list_lru *lru
> 	err =3D memcg_init_list_lru(lru, memcg_aware);
> 	if (err) {
> 		kfree(lru->node);
> +		/* Do this so a list_lru_destroy() doesn't crash: */
> +		lru->node =3D NULL;
> 		goto out;
> 	}
>=20
> _
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
