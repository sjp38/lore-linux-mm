Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 506976B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:43:17 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c69so17054455qkg.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:43:17 -0800 (PST)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [216.205.24.194])
        by mx.google.com with ESMTPS id j9si12232962qke.255.2017.01.04.05.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 05:43:15 -0800 (PST)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH 1/2] nfs: no PG_private waiters remain, remove waker
Date: Wed, 4 Jan 2017 13:43:10 +0000
Message-ID: <0562F017-2963-41E0-BE5B-62A07EC444CD@primarydata.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
 <20170103182234.30141-2-npiggin@gmail.com>
In-Reply-To: <20170103182234.30141-2-npiggin@gmail.com>
Content-Language: en-US
Content-ID: <20F2F3997BC3444EA0ACBF6BBE1EC512@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Neil
 Brown <neilb@suse.de>, Trond Myklebust <trondmy@primarydata.com>

Hi Nick,

> On Jan 3, 2017, at 13:22, Nicholas Piggin <npiggin@gmail.com> wrote:
>=20
> Since commit 4f52b6bb ("NFS: Don't call COMMIT in ->releasepage()"),
> no tasks wait on PagePrivate, so the wake introduced in commit 95905446
> ("NFS: avoid deadlocks with loop-back mounted NFS filesystems.") can
> be removed.
>=20
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
> fs/nfs/write.c | 2 --
> 1 file changed, 2 deletions(-)
>=20
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b00d53d13d47..006068526542 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -728,8 +728,6 @@ static void nfs_inode_remove_request(struct nfs_page =
*req)
> =09=09if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
> =09=09=09set_page_private(head->wb_page, 0);
> =09=09=09ClearPagePrivate(head->wb_page);
> -=09=09=09smp_mb__after_atomic();
> -=09=09=09wake_up_page(head->wb_page, PG_private);
> =09=09=09clear_bit(PG_MAPPED, &head->wb_flags);
> =09=09}
> =09=09nfsi->nrequests--;
> --=20
> 2.11.0
>=20

That looks fine to me. Do you want to push it through the linux-mm path or =
do you want me to take it?

Cheers
  Trond

Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
