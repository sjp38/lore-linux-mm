Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 58C8E6B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 13:49:53 -0400 (EDT)
Received: by mail-vb0-f47.google.com with SMTP id fr13so1336448vbb.34
        for <linux-mm@kvack.org>; Wed, 16 May 2012 10:49:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337034597-1826-1-git-send-email-pshelar@nicira.com>
References: <1337034597-1826-1-git-send-email-pshelar@nicira.com>
Date: Wed, 16 May 2012 10:49:52 -0700
Message-ID: <CALnjE+pbsS3W8G7yN82fdnchmXDxGkTo+Gy2b4kj6DkuQ=Z+wQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix slab->page _count corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, mpm@selenic.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com, Pravin B Shelar <pshelar@nicira.com>

Hi Christoph,
Can you comment on this patch. I have changed it according to your comments=
.

Thanks,
Pravin.

On Mon, May 14, 2012 at 3:29 PM, Pravin B Shelar <pshelar@nicira.com> wrote=
:
> On arches that do not support this_cpu_cmpxchg_double slab_lock is used
> to do atomic cmpxchg() on double word which contains page->_count.
> page count can be changed from get_page() or put_page() without taking
> slab_lock. That corrupts page counter.
>
> Following patch fixes it by moving page->_count out of cmpxchg_double
> data. So that slub does no change it while updating slub meta-data in
> struct page.
>
> Reported-by: Amey Bhide <abhide@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> =A0include/linux/mm_types.h | =A0 =A08 ++++++++
> =A01 file changed, 8 insertions(+)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index dad95bd..5f558dc 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -57,8 +57,16 @@ struct page {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0union {
> +#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
> + =A0 =A0defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Used for cmpxchg_double=
 in slub */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long counters;
> +#else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep _count separate fro=
m slub cmpxchg_double data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* As rest of double word=
 is protected by slab_lock
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* but _count is not. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned counters;
> +#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct {
>
> --
> 1.7.10
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
