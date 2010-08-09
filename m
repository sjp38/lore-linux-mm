Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 60BBA6B02D0
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:57:45 -0400 (EDT)
Received: by gwj16 with SMTP id 16so4581671gwj.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 11:57:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-5-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-5-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 21:57:42 +0300
Message-ID: <AANLkTin7_fKxTzE2rngh1Ew5Ss8F_Aw0s9Gz6ySug6SX@mail.gmail.com>
Subject: Re: [PATCH 04/10] Use percpu buffers
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> @@ -303,38 +307,41 @@ static int zram_write(struct zram *zram, struct bio=
 *bio)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zram_test_=
flag(zram, index, ZRAM_ZERO))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zram_free_page(zram, index=
);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&zram->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zbuffer =3D __get_cpu_var(compress_buffer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zworkmem =3D __get_cpu_var(compress_workmem=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!zbuffer || !zworkmem)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

The per-CPU buffer thing with this preempt_disable() trickery looks
overkill to me. Most block device drivers seem to use mempool_alloc()
for this sort of thing. Is there some reason you can't use that here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
