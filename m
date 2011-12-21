Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1C3356B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 23:44:56 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so2366423wib.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 20:44:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF15F42.4070104@oracle.com>
References: <201112210054.46995.rjw@sisk.pl> <CA+55aFzee7ORKzjZ-_PrVy796k2ASyTe_Odz=ji7f1VzToOkKw@mail.gmail.com>
 <4EF15F42.4070104@oracle.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 20 Dec 2011 20:44:33 -0800
Message-ID: <CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com>
Subject: Re: [Resend] 3.2-rc6+: Reported regressions from 3.0 and 3.1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Kernel Testers List <kernel-testers@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Maciej Rutecki <maciej.rutecki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Mickler <florian@mickler.org>, davem@davemloft.net, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

On Tue, Dec 20, 2011 at 8:23 PM, Dave Kleikamp <dave.kleikamp@oracle.com> w=
rote:
>
> I don't think this is a regression. =A0It's been seen before, but the
> patch never got submitted, or was lost somewhere. I believe this
> will fix it.

Hmm. This patch looks obviously correct. But it looks *so* obviously
correct that it just makes me suspicious - this is not new or seldom
used code, it's been this way for ages and used all the time. That
line literally goes back to 2007, commit eb2be189317d0. And it looks
like even before that we had a GFP_KERNEL for the add_to_page_cache()
case and that goes back to before the git history. So this is
*ancient*.

Maybe almost nobody uses __read_cache_page() with a non-GFP_KERNEL gfp
and as a result we've not noticed.

Or maybe there is some crazy reason why it calls "add_to_page_cache()"
with GFP_KERNEL.

Adding the usual suspects for mm/filemap.c to the cc line (Andrew is
already cc'd, but Al and Hugh should comment).

Ack's, people? Is it really as obvious as it looks, and we've just had
this bug forever?

            Linus

--- snip snip ---
> vfs: __read_cache_page should use gfp argument rather than GFP_KERNEL
>
> lockdep reports a deadlock in jfs because a special inode's rw semaphore
> is taken recursively. The mapping's gfp mask is GFP_NOFS, but is not used
> when __read_cache_page() calls add_to_page_cache_lru().
>
> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c106d3b..c9ea3df 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1828,7 +1828,7 @@ repeat:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D __page_cache_alloc(gfp | __GFP_CO=
LD);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-ENOMEM);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_to_page_cache_lru(page, mapping=
, index, GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_to_page_cache_lru(page, mapping=
, index, gfp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(err)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page_cache_release(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err =3D=3D -EEXIST)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
