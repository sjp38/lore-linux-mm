Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2B03C6B00C0
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:49:52 -0400 (EDT)
Received: by ywh14 with SMTP id 14so4731575ywh.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:49:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200908241007.58273.ngupta@vflare.org>
References: <200908241007.58273.ngupta@vflare.org>
Date: Mon, 24 Aug 2009 12:10:20 +0530
Message-ID: <d760cf2d0908232340pd8bef7byc76c4d07f09e7d63@mail.gmail.com>
Subject: Re: [PATCH 3/4] compcache: send callback when swap slot is freed
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 10:07 AM, Nitin Gupta<ngupta@vflare.org> wrote:

<snip>

> +/*
> + * Sets callback for event when swap_map[offset] =3D=3D 0
> + * i.e. page at this swap offset is no longer used.
> + */
> +void set_swap_free_notify(struct block_device *bdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap_free_notify_fn *notify=
_fn)
> +{
> + =A0 =A0 =A0 unsigned int i;
> + =A0 =A0 =A0 struct swap_info_struct *sis;
> +
> + =A0 =A0 =A0 spin_lock(&swap_lock);
> + =A0 =A0 =A0 for (i =3D 0; i <=3D nr_swapfiles; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sis =3D &swap_info[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(sis->flags & SWP_USED))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sis->bdev =3D=3D bdev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +

> + =A0 =A0 =A0 /* swap device not found */
> + =A0 =A0 =A0 if (i > nr_swapfiles)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

How could I miss this! We need to unlock before this return. I will
send revised diffs once I get additional reviews.


> +
> + =A0 =A0 =A0 BUG_ON(!sis || sis->swap_free_notify_fn);
> + =A0 =A0 =A0 sis->swap_free_notify_fn =3D notify_fn;
> + =A0 =A0 =A0 spin_unlock(&swap_lock);
> +
> + =A0 =A0 =A0 return;
> +}
> +EXPORT_SYMBOL_GPL(set_swap_free_notify);
> +


Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
