Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3A0236B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:13:59 -0500 (EST)
Received: by eekc41 with SMTP id c41so8244102eek.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:13:57 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
Date: Wed, 21 Dec 2011 07:13:49 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6tsxbmb3l0zgt@mpn-glaptop>
In-Reply-To: <1324444679-9247-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Dec 2011 06:17:59 +0100, Minchan Kim <minchan@kernel.org> wro=
te:
> We don't like function body which include #ifdef.
> If we can, define null function to go out compile time.
> It's trivial, no functional change.

It actually adds =E2=80=9Cflush_tlb_kenel_range()=E2=80=9D call to the f=
unction so there
is functional change.

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmalloc.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0aca3ce..e1fa5a6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -505,6 +505,7 @@ static void unmap_vmap_area(struct vmap_area *va)
>  	vunmap_page_range(va->va_start, va->va_end);
>  }
>+#ifdef CONFIG_DEBUG_PAGEALLOC
>  static void vmap_debug_free_range(unsigned long start, unsigned long =
end)
>  {
>  	/*
> @@ -520,11 +521,15 @@ static void vmap_debug_free_range(unsigned long =
start, unsigned long end)
>  	 * debugging doesn't do a broadcast TLB flush so it is a lot
>  	 * faster).
>  	 */
> -#ifdef CONFIG_DEBUG_PAGEALLOC
>  	vunmap_page_range(start, end);
>  	flush_tlb_kernel_range(start, end);
> -#endif
>  }
> +#else
> +static inline void vmap_debug_free_range(unsigned long start,
> +					unsigned long end)
> +{
> +}
> +#endif
> /*
>   * lazy_max_pages is the maximum amount of virtual address space we g=
ather up

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
