Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 3E84F6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 04:30:48 -0400 (EDT)
Received: by iajr24 with SMTP id r24so7595080iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 01:30:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120408233835.GC4839@panacea>
References: <20120408233550.GA3791@panacea>
	<20120408233835.GC4839@panacea>
Date: Mon, 9 Apr 2012 11:30:47 +0300
Message-ID: <CAOJsxLHQv3xaa3JGPxu0vpSxNvD5gxxGVa=87w_6K0UcSpukWQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement cross event type
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

On Mon, Apr 9, 2012 at 2:38 AM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> This patch implements a new event type, it will trigger whenever a
> value crosses a user-specified threshold. It works two-way, i.e. when
> a value crosses the threshold from a lesser values side to a greater
> values side, and vice versa.
>
> We use the event type in an userspace low-memory killer: we get a
> notification when memory becomes low, so we start freeing memory by
> killing unneeded processes, and we get notification when memory hits
> the threshold from another side, so we know that we freed enough of
> memory.
>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
> =A0include/linux/vmevent.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 ++++++++=
+
> =A0mm/vmevent.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 21 =
+++++++++++++++++++++
> =A0tools/testing/vmevent/vmevent-test.c | =A0 15 ++++++++++-----
> =A03 files changed, 40 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> index 64357e4..00cc04f 100644
> --- a/include/linux/vmevent.h
> +++ b/include/linux/vmevent.h
> @@ -22,6 +22,15 @@ enum {
> =A0 =A0 =A0 =A0 * Sample value is less than user-specified value
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0VMEVENT_ATTR_STATE_VALUE_LT =A0 =A0 =3D (1UL << 0),
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Sample value crossed user-specified value
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 VMEVENT_ATTR_STATE_VALUE_CROSS =A0=3D (1UL << 2),
> +
> + =A0 =A0 =A0 /* Last saved state, used internally by the kernel. */
> + =A0 =A0 =A0 __VMEVENT_ATTR_STATE_LAST =A0 =A0 =A0 =3D (1UL << 30),
> + =A0 =A0 =A0 /* Not first sample, used internally by the kernel. */
> + =A0 =A0 =A0 __VMEVENT_ATTR_STATE_NFIRST =A0 =A0 =3D (1UL << 31),
> =A0};
>
> =A0struct vmevent_attr {
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index a56174f..f8fd2d6 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -1,5 +1,6 @@
> =A0#include <linux/anon_inodes.h>
> =A0#include <linux/atomic.h>
> +#include <linux/compiler.h>
> =A0#include <linux/vmevent.h>
> =A0#include <linux/syscalls.h>
> =A0#include <linux/timer.h>
> @@ -94,6 +95,26 @@ static bool vmevent_match(struct vmevent_watch *watch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (attr->state & VMEVENT_ATTR_STATE_VALUE=
_LT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (value < attr->value)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return tru=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (attr->state & VMEVENT_ATTR_STATE=
_VALUE_CROSS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool fst =3D !(attr->state =
& __VMEVENT_ATTR_STATE_NFIRST);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool old =3D attr->state & =
__VMEVENT_ATTR_STATE_LAST;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool new =3D value < attr->=
value;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool chg =3D old ^ new;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool ret =3D chg;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This is not 'lt' or 'g=
t' match, so on the first
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sample assume we cross=
ed the threshold.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(fst)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 attr->state=
 |=3D __VMEVENT_ATTR_STATE_NFIRST;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D tru=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 attr->state &=3D ~__VMEVENT=
_ATTR_STATE_LAST;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 attr->state |=3D new ? __VM=
EVENT_ATTR_STATE_LAST : 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>

Can't we implement this by specifying both VMEVENT_ATTR_STATE_VALUE_LT
and VMEVENT_ATTR_STATE_VALUE_GT in userspace? I assume the problem
with current approach is that you get more than one notifications,
right? We can implement a "single-shot" flag to deal with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
