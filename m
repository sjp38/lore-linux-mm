Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAE06B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c78so37554810wme.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:42:47 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id dd4si18041579wjb.54.2016.10.24.12.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 12:42:46 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] shmem: avoid maybe-uninitialized warning
Date: Mon, 24 Oct 2016 21:42:36 +0200
Message-ID: <4142781.4gMiS9Brv9@wuerfel>
In-Reply-To: <20161024162243.GA13148@dhcp22.suse.cz>
References: <20161024152511.2597880-1-arnd@arndb.de> <20161024162243.GA13148@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Monday, October 24, 2016 6:22:44 PM CEST Michal Hocko wrote:
> On Mon 24-10-16 17:25:03, Arnd Bergmann wrote:
> > After enabling -Wmaybe-uninitialized warnings, we get a false-postive
> > warning for shmem:
> >=20
> > mm/shmem.c: In function =E2=80=98shmem_getpage_gfp=E2=80=99:
> > include/linux/spinlock.h:332:21: error: =E2=80=98info=E2=80=99 may be u=
sed uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>=20
> Is this really a false positive? If we goto clear and then=20
>         if (sgp <=3D SGP_CACHE &&
>             ((loff_t)index << PAGE_SHIFT) >=3D i_size_read(inode)) {
>                 if (alloced) {
>=20
> we could really take a spinlock on an unitialized variable. But maybe
> there is something that prevents from that...

I did the patch a few weeks ago (I sent the more important
ones out first) and I think I concluded then that 'alloced'
would be false in that case.

> Anyway the whole shmem_getpage_gfp is really hard to follow due to gotos
> and labels proliferation.

Exactly. Maybe we should mark the patch for -stable backports after all
just to be sure.

Andreas also pointed out on IRC that there is another assignment
that can be removed in the function when the variable is initialized
upfront, so I'll resend anyway.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
