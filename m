Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1CA2A6B00EC
	for <linux-mm@kvack.org>; Thu,  3 May 2012 06:33:51 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so1560206vbb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 03:33:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120501132620.GC24226@lizard>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
Date: Thu, 3 May 2012 13:33:50 +0300
Message-ID: <CAOJsxLGu3xqTry=Rf62Ly+jkCH16b+6gereoxDrg98E9TFvVfw@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, Minchan Kim <minchan@kernel.org>

On Tue, May 1, 2012 at 4:26 PM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> This is specially "blended" attribute, the event triggers when kernel
> decides that we're close to the low memory threshold. Userspace should
> not expect very precise meaning of low memory situation, mostly, it's
> just a guess on the kernel's side.
>
> Well, this is the same as userland should not know or care how exactly
> kernel manages the memory, or assume that memory management behaviour
> is a part of the "ABI". So, all the 'low memory' is just guessing, but
> we're trying to do our best. It might be that we will end up with two
> or three variations of 'low memory' thresholds, and all of them would
> be useful for different use cases.
>
> For this implementation, we assume that there's a low memory situation
> for the N pages threshold when we have neither N pages of completely
> free pages, nor we have N reclaimable pages in the cache. This
> effectively means, that if userland expects to allocate N pages, it
> would consume all the free pages, and any further allocations (above
> N) would start draining caches.
>
> In the worst case, prior to hitting the threshold, we might have only
> N pages in cache, and nearly no memory as free pages.
>
> The same 'low memory' meaning is used in the current Android Low
> Memory Killer driver.
>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

I don't see why we couldn't add this. Minchan, thoughts?

> ---
> =A0include/linux/vmevent.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A07 ++++++
> =A0mm/vmevent.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 40 =
++++++++++++++++++++++++++++++++++
> =A0tools/testing/vmevent/vmevent-test.c | =A0 12 +++++++++-
> =A03 files changed, 58 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> index aae0d24..9bfa244 100644
> --- a/include/linux/vmevent.h
> +++ b/include/linux/vmevent.h
> @@ -10,6 +10,13 @@ enum {
> =A0 =A0 =A0 =A0VMEVENT_ATTR_NR_AVAIL_PAGES =A0 =A0 =3D 1UL,
> =A0 =A0 =A0 =A0VMEVENT_ATTR_NR_FREE_PAGES =A0 =A0 =A0=3D 2UL,
> =A0 =A0 =A0 =A0VMEVENT_ATTR_NR_SWAP_PAGES =A0 =A0 =A0=3D 3UL,
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* This is specially blended attribute, the event trigger=
s
> + =A0 =A0 =A0 =A0* when kernel decides that we're close to the low memory=
 threshold.
> + =A0 =A0 =A0 =A0* Don't expect very precise meaning of low memory situat=
ion, mostly,
> + =A0 =A0 =A0 =A0* it's just a guess on the kernel's side.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 VMEVENT_ATTR_LOWMEM_PAGES =A0 =A0 =A0 =3D 4UL,
>
> =A0 =A0 =A0 =A0VMEVENT_ATTR_MAX =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* non-ABI=
 */
> =A0};
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index b312236..d278a25 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -68,10 +68,50 @@ static u64 vmevent_attr_avail_pages(struct vmevent_wa=
tch *watch,
> =A0 =A0 =A0 =A0return totalram_pages;
> =A0}
>
> +/*
> + * Here's some implementation details for the "low memory" meaning.
> + *
> + * (The explanation is not in the header file as userland should not
> + * know these details, nor it should assume that the meaning will
> + * always be the same. As well as it should not know how exactly kernel
> + * manages the memory, or assume that memory management behaviour is a
> + * part of the "ABI". So, all the 'low memory' is just guessing, but
> + * we're trying to do our best.)
> + *
> + * For this implementation, we assume that there's a low memory situatio=
n
> + * for the N pages threshold when we have neither N pages of completely
> + * free pages, nor we have N reclaimable pages in the cache. This
> + * effectively means, that if userland expects to allocate N pages, it
> + * would consume all the free pages, and any further allocations (above
> + * N) would start draining caches.
> + *
> + * In the worst case, prior hitting the threshold, we might have only
> + * N pages in cache, and nearly no memory as free pages.
> + */
> +static u64 vmevent_attr_lowmem_pages(struct vmevent_watch *watch,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct vmevent_attr *attr)
> +{
> + =A0 =A0 =A0 int free =3D global_page_state(NR_FREE_PAGES);
> + =A0 =A0 =A0 int file =3D global_page_state(NR_FILE_PAGES) -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_SHMEM); /* TODO=
: account locked pages */
> + =A0 =A0 =A0 int val =3D attr->value;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* For convenience we return 0 or attr value (instead of =
0/1), it
> + =A0 =A0 =A0 =A0* makes it easier for vmevent_match() to cope with blend=
ed
> + =A0 =A0 =A0 =A0* attributes, plus userland might use the value to find =
out which
> + =A0 =A0 =A0 =A0* threshold triggered.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (free < val && file < val)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return val;
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static vmevent_attr_sample_fn attr_samplers[] =3D {
> =A0 =A0 =A0 =A0[VMEVENT_ATTR_NR_AVAIL_PAGES] =A0 =3D vmevent_attr_avail_p=
ages,
> =A0 =A0 =A0 =A0[VMEVENT_ATTR_NR_FREE_PAGES] =A0 =A0=3D vmevent_attr_free_=
pages,
> =A0 =A0 =A0 =A0[VMEVENT_ATTR_NR_SWAP_PAGES] =A0 =A0=3D vmevent_attr_swap_=
pages,
> + =A0 =A0 =A0 [VMEVENT_ATTR_LOWMEM_PAGES] =A0 =A0 =3D vmevent_attr_lowmem=
_pages,
> =A0};
>
> =A0static u64 vmevent_sample_attr(struct vmevent_watch *watch, struct vme=
vent_attr *attr)
> diff --git a/tools/testing/vmevent/vmevent-test.c b/tools/testing/vmevent=
/vmevent-test.c
> index fd9a174..c61aed7 100644
> --- a/tools/testing/vmevent/vmevent-test.c
> +++ b/tools/testing/vmevent/vmevent-test.c
> @@ -33,7 +33,7 @@ int main(int argc, char *argv[])
>
> =A0 =A0 =A0 =A0config =3D (struct vmevent_config) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.sample_period_ns =A0 =A0 =A0 =3D 10000000=
00L,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .counter =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 6,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .counter =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 7,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.attrs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.type =A0 =
=3D VMEVENT_ATTR_NR_FREE_PAGES,
> @@ -59,6 +59,13 @@ int main(int argc, char *argv[])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.type =A0 =
=3D VMEVENT_ATTR_NR_SWAP_PAGES,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =A0 =
=3D VMEVENT_ATTR_LOWMEM_PAGES,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .state =A0=
=3D VMEVENT_ATTR_STATE_VALUE_LT |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 VMEVENT_ATTR_STATE_VALUE_EQ |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 VMEVENT_ATTR_STATE_ONE_SHOT,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .value =A0=
=3D phys_pages / 2,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.type =A0 =
=3D 0xffff, /* invalid */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> @@ -108,6 +115,9 @@ int main(int argc, char *argv[])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case VMEVENT_ATTR_NR_SWAP_=
PAGES:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf(" =
=A0VMEVENT_ATTR_NR_SWAP_PAGES: %Lu\n", attr->value);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case VMEVENT_ATTR_LOWMEM_PA=
GES:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf(" =
=A0VMEVENT_ATTR_LOWMEM_PAGES: %Lu\n", attr->value);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf(" =
=A0Unknown attribute: %Lu\n", attr->value);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> --
> 1.7.9.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
