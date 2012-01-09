Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8EC726B006E
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 11:49:39 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1955664ghr.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 08:49:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBAMtT04n8p4ht4oCSOYKVcUcG0-hbSvmjrP-yhwBYhU1A@mail.gmail.com>
References: <CAJd=RBAMtT04n8p4ht4oCSOYKVcUcG0-hbSvmjrP-yhwBYhU1A@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 9 Jan 2012 11:49:14 -0500
Message-ID: <CAHGf_=ovR8Mwagaa2PpjEfjKpuqjvPdWX5Uy=Tyi2+B480WUBA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: recompute page status when putting back
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

> If unlikely the given page is isolated from lru list again, its status is
> recomputed before putting back to lru list, since the comment says page's
> status can change while we move it among lru.
>
>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
>
> --- a/mm/vmscan.c =A0 =A0 =A0 Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c =A0 =A0 =A0 Fri Jan =A06 21:31:56 2012
> @@ -633,12 +633,14 @@ int remove_mapping(struct address_space
> =A0void putback_lru_page(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0int lru;
> - =A0 =A0 =A0 int active =3D !!TestClearPageActive(page);
> - =A0 =A0 =A0 int was_unevictable =3D PageUnevictable(page);
> + =A0 =A0 =A0 int active;
> + =A0 =A0 =A0 int was_unevictable;
>
> =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page));
>
> =A0redo:
> + =A0 =A0 =A0 active =3D !!TestClearPageActive(page);
> + =A0 =A0 =A0 was_unevictable =3D PageUnevictable(page);
> =A0 =A0 =A0 =A0ClearPageUnevictable(page);

When and How do this race happen?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
