Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id EEB756B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 12:45:43 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so16791226wgb.26
        for <linux-mm@kvack.org>; Mon, 26 Dec 2011 09:45:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1324900599-20804-1-git-send-email-consul.kautuk@gmail.com>
References: <1324900599-20804-1-git-send-email-consul.kautuk@gmail.com>
Date: Mon, 26 Dec 2011 12:45:41 -0500
Message-ID: <CAFPAmTRJix3hYitz3V=__Wsc70px3mXUx9TXHC+QK5UYcKwxag@mail.gmail.com>
Subject: Re: [PATCH 1/1] swapfile: swap_info_get: Check for swap_info[type] == NULL
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cesar Eduardo Barros <cesarb@cesarb.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric B Munson <emunson@mgebm.net>, Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

Hi,

Sorry, please ignore the patch file below.

I made a mistake in understanding the code logic.
I now understand that the first "bad_nofile" validation check
is good enough for checking the validity of the value in the "type" variabl=
e.


On Mon, Dec 26, 2011 at 6:56 AM, Kautuk Consul <consul.kautuk@gmail.com> wr=
ote:
> From: Kautuk Consul <consul.kautuk@gmail.com>
>
> If the swapfile type encoded within entry.val is corrupted in
> such a way that the swap_info[type] =3D=3D NULL, then the code in
> swap_info_get will cause a NULL pointer exception.
>
> Assuming that the code in swap_info_get attempts to validate the
> swapfile type by checking its range, another bad_nofile check would
> be to check for check whether the swap_info[type] pointer is NULL.
>
> Adding a NULL check for swap_info[type] to be reagrded as a "bad_nofile"
> error scenario.
>
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> ---
> =A0mm/swapfile.c | =A0 =A02 ++
> =A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index b1cd120..7bdbe91 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -483,6 +483,8 @@ static struct swap_info_struct *swap_info_get(swp_ent=
ry_t entry)
> =A0 =A0 =A0 =A0if (type >=3D nr_swapfiles)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad_nofile;
> =A0 =A0 =A0 =A0p =3D swap_info[type];
> + =A0 =A0 =A0 if (!p)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_nofile;
> =A0 =A0 =A0 =A0if (!(p->flags & SWP_USED))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad_device;
> =A0 =A0 =A0 =A0offset =3D swp_offset(entry);
> --
> 1.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
