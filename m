Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id D86676B006C
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:23:14 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id e131so305828oig.17
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:23:14 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id pp10si765019oeb.37.2014.11.25.04.23.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:23:13 -0800 (PST)
Received: by mail-oi0-f42.google.com with SMTP id v63so307455oia.15
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:23:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416852146-9781-8-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-8-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 25 Nov 2014 16:22:53 +0400
Message-ID: <CAA6XgkFPvHQE7LpZ=Q19e8sGAwOtWiVBXzjZA+7HXmNWL_genA@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] mm: slub: introduce metadata_access_enable()/metadata_access_disable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

LGTM

Does this mean we're going to sanitize the slub code itself?)

On Mon, Nov 24, 2014 at 9:02 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Wrap access to object's metadata in external functions with
> metadata_access_enable()/metadata_access_disable() function calls.
>
> This hooks separates payload accesses from metadata accesses
> which might be useful for different checkers (e.g. KASan).
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  mm/slub.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 0c01584..88ad8b8 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -467,13 +467,23 @@ static int slub_debug;
>  static char *slub_debug_slabs;
>  static int disable_higher_order_debug;
>
> +static inline void metadata_access_enable(void)
> +{
> +}
> +
> +static inline void metadata_access_disable(void)
> +{
> +}
> +
>  /*
>   * Object debugging
>   */
>  static void print_section(char *text, u8 *addr, unsigned int length)
>  {
> +       metadata_access_enable();
>         print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
>                         length, 1);
> +       metadata_access_disable();
>  }
>
>  static struct track *get_track(struct kmem_cache *s, void *object,
> @@ -503,7 +513,9 @@ static void set_track(struct kmem_cache *s, void *object,
>                 trace.max_entries = TRACK_ADDRS_COUNT;
>                 trace.entries = p->addrs;
>                 trace.skip = 3;
> +               metadata_access_enable();
>                 save_stack_trace(&trace);
> +               metadata_access_disable();
>
>                 /* See rant in lockdep.c */
>                 if (trace.nr_entries != 0 &&
> @@ -677,7 +689,9 @@ static int check_bytes_and_report(struct kmem_cache *s, struct page *page,
>         u8 *fault;
>         u8 *end;
>
> +       metadata_access_enable();
>         fault = memchr_inv(start, value, bytes);
> +       metadata_access_disable();
>         if (!fault)
>                 return 1;
>
> @@ -770,7 +784,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
>         if (!remainder)
>                 return 1;
>
> +       metadata_access_enable();
>         fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
> +       metadata_access_disable();
>         if (!fault)
>                 return 1;
>         while (end > fault && end[-1] == POISON_INUSE)
> --
> 2.1.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
