Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B0346B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 19:44:40 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1947948ywm.26
        for <linux-mm@kvack.org>; Mon, 08 Jun 2009 16:57:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090608222904.GA18437@csn.ul.ie>
References: <20090608132950.GB15070@csn.ul.ie>
	 <20090608135906.GA6027@infradead.org>
	 <20090608222904.GA18437@csn.ul.ie>
Date: Tue, 9 Jun 2009 08:57:12 +0900
Message-ID: <28c262360906081657o3fb7d825w227aad54f4d0c1af@mail.gmail.com>
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
	allocation failure reports
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Let's CCed Steven Rostedt :)

On Tue, Jun 9, 2009 at 7:29 AM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Mon, Jun 08, 2009 at 09:59:06AM -0400, Christoph Hellwig wrote:
>> On Mon, Jun 08, 2009 at 02:29:50PM +0100, Mel Gorman wrote:
>> > The page allocation failure messages include a line that looks like
>> >
>> > page allocation failure. order:1, mode:0x4020
>> >
>> > The mode is easy to translate but irritating for the lazy and a bit er=
ror
>> > prone. This patch adds a very simple helper script gfp-translate for t=
he mode:
>> > portion of the page allocation failure messages. An example usage look=
s like
>>
>> Maybe we just just print the symbolic flags directly?
>
> It'd be nice if it was possible, not ugly and didn't involve declaring
> maps twice.
>
> Even with such hypothetical support, I believe there is scope for having
> the script readily available for use with reports from older kernels,
> particularly distro kernels.
>
>> The even tracer
>> in the for-2.6.23 queue now has a __print_flags helper to translate the
>> bitmask back into symbolic flags, and we even have a kmalloc tracer
>> using it for the GFP flags. =C2=A0Maybe we should add a printk_flags var=
iant
>> for regular printks and just do the right thing?
>>
>
> The problem I found with a printk_flags variant was that there was no
> buffer for it to easily print to for use with printk("%s"). We can't "see=
"
> the printk buffer, we can't kmalloc() one and I suspect it's too large to
> place on the stack. What had you in mind?
>
> I haven't looked at the trace implementation before so I have very little
> idea as to how best approach this problem. That didn't stop me attempting=
 a
> hatchet-job on the implementation of printk support for the bitflags->str=
ing
> maps declared within ftrace - particularly the GFP flags.
>
> The following patch is what it ended up looking like. I recommend goggles
> because even if we go with printk support, this could be implemented bett=
er.
>
> =3D=3D=3D CUT HERE =3D=3D=3D
>
> Add support for %f for the printing of string representation of bit flags
>
> This patch is a prototype to see if the tracing infrastructure used for
> the outputting of symbolic representation of bits set in a flag can be
> reused for printk. With it applied, a page allocation failure report
> looks like
>
> [ =C2=A0171.284889] cat: page allocation failure. order:9, mode:0xd1
> [ =C2=A0171.284948] mode:|GFP_KERNEL|0x1
> [ =C2=A0171.295114] Pid: 2383, comm: cat Not tainted 2.6.30-rc8-tip-02066=
-g800cfbb-dirty #38
>
> Not-signed-off-yet-by: Mel Gorman <mel@csn.ul.ie>
>
> diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
> index 5c093ff..8f8e86c 100644
> --- a/include/linux/ftrace_event.h
> +++ b/include/linux/ftrace_event.h
> @@ -16,6 +16,11 @@ struct trace_print_flags {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*name;
> =C2=A0};
>
> +struct trace_printf_spec {
> + =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 flags;
> + =C2=A0 =C2=A0 =C2=A0 struct trace_print_flags =C2=A0 =C2=A0 =C2=A0 =C2=
=A0*flag_array;
> +};
> +
> =C2=A0const char *ftrace_print_flags_seq(struct trace_seq *p, const char =
*delim,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long flags,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct trace_print_flag=
s *flag_array);
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index 9baba50..e2404ad 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -17,8 +17,7 @@
> =C2=A0*
> =C2=A0* Thus most bits set go first.
> =C2=A0*/
> -#define show_gfp_flags(flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> - =C2=A0 =C2=A0 =C2=A0 (flags) ? __print_flags(flags, "|", =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 \
> +#define gfp_flags_printf_map =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)GFP_HIGHUSER_MOVABLE, =C2=A0 "=
GFP_HIGHUSER_MOVABLE"}, \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)GFP_HIGHUSER, =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 "GFP_HIGHUSER"}, =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)GFP_USER, =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "GFP_USER"}, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0\
> @@ -42,6 +41,11 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)__GFP_THISNODE, =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 "GFP_THISNODE"}, =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)__GFP_RECLAIMABLE, =C2=A0 =C2=
=A0 =C2=A0"GFP_RECLAIMABLE"}, =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{(unsigned long)__GFP_MOVABLE, =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0"GFP_MOVABLE"} =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> +
> +
> +#define show_gfp_flags(flags, map) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 (flags) ? __print_flags(flags, "|", =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 map =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0) : "GFP_NOWAIT"
>
> =C2=A0TRACE_EVENT(kmalloc,
> @@ -75,7 +79,7 @@ TRACE_EVENT(kmalloc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_req=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_all=
oc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags, gfp_flags_printf_map))
> =C2=A0);
>
> =C2=A0TRACE_EVENT(kmem_cache_alloc,
> @@ -109,7 +113,7 @@ TRACE_EVENT(kmem_cache_alloc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_req=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_all=
oc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags, gfp_flags_printf_map))
> =C2=A0);
>
> =C2=A0TRACE_EVENT(kmalloc_node,
> @@ -146,7 +150,7 @@ TRACE_EVENT(kmalloc_node,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_req=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_all=
oc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags, gfp_flags_printf_map),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->node)
> =C2=A0);
>
> @@ -184,7 +188,7 @@ TRACE_EVENT(kmem_cache_alloc_node,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_req=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->bytes_all=
oc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 show_gfp_flags(__entry=
->gfp_flags, gfp_flags_printf_map),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->node)
> =C2=A0);
>
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 756ccaf..acb20e0 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -25,6 +25,7 @@
> =C2=A0#include <linux/kallsyms.h>
> =C2=A0#include <linux/uaccess.h>
> =C2=A0#include <linux/ioport.h>
> +#include <linux/ftrace_event.h>
>
> =C2=A0#include <asm/page.h> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* for PAGE=
_SIZE */
> =C2=A0#include <asm/div64.h>
> @@ -403,6 +404,7 @@ enum format_type {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_CHAR,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_STR,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_PTR,
> + =C2=A0 =C2=A0 =C2=A0 FORMAT_TYPE_TRACE_FLAGS,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_PERCENT_CHAR,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_INVALID,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0FORMAT_TYPE_LONG_LONG,
> @@ -574,6 +576,44 @@ static char *string(char *buf, char *end, char *s, s=
truct printf_spec spec)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return buf;
> =C2=A0}
>
> +/*
> + * Support a %f thing storing a struct trace_print_flags
> + */
> +static char *trace_flags(char *buf, char *end,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct trace_printf_spec *trace_flags_sp=
ec,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct printf_spec spec)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long mask;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags =3D trace_flags_spec->flags;
> + =C2=A0 =C2=A0 =C2=A0 struct trace_print_flags *flag_array =3D trace_fla=
gs_spec->flag_array;
> + =C2=A0 =C2=A0 =C2=A0 char *str;
> + =C2=A0 =C2=A0 =C2=A0 char *delim =3D "|";
> + =C2=A0 =C2=A0 =C2=A0 char *ret =3D buf;
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; =C2=A0flag_array[i].name && flags; i=
++) {
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mask =3D flag_array[i]=
.mask;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((flags & mask) !=
=3D mask)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 str =3D (char *)flag_a=
rray[i].name;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 flags &=3D ~mask;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret < end && delim=
)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D string(ret, end, delim, spec);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D string(ret, en=
d, str, spec);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 if (flags) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D string(ret, en=
d, delim, spec);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spec.flags |=3D SPECIA=
L|SMALL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spec.base =3D 16;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D number(ret, en=
d, flags, spec);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> =C2=A0static char *symbol_string(char *buf, char *end, void *ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct printf_spec spec, char ext)
> =C2=A0{
> @@ -888,6 +928,11 @@ qualifier:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return fmt - start=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* skip alnum */
>
> + =C2=A0 =C2=A0 =C2=A0 case 'f':
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spec->qualifier =3D 'l=
';
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spec->type =3D FORMAT_=
TYPE_TRACE_FLAGS;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ++fmt - start;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case 'n':
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spec->type =3D FOR=
MAT_TYPE_NRCHARS;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ++fmt - sta=
rt;
> @@ -1058,6 +1103,12 @@ int vsnprintf(char *buf, size_t size, const char *=
fmt, va_list args)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fmt++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case FORMAT_TYPE_TRACE=
_FLAGS:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 str =3D trace_flags(str, end,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 va_arg(args, struct trace_printf_spec *)=
,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spec);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case FORMAT_TYPE_P=
ERCENT_CHAR:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (str < end)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*str =3D '%';
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ed766b5..714b5c2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -47,6 +47,7 @@
> =C2=A0#include <linux/page-isolation.h>
> =C2=A0#include <linux/page_cgroup.h>
> =C2=A0#include <linux/debugobjects.h>
> +#include <linux/ftrace_event.h>
>
> =C2=A0#include <asm/tlbflush.h>
> =C2=A0#include <asm/div64.h>
> @@ -172,6 +173,11 @@ static void set_pageblock_migratetype(struct page *p=
age, int migratetype)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0PB_migrat=
e, PB_migrate_end);
> =C2=A0}
>
> +struct trace_print_flags trace_print_flags_gfp[] =3D {
> + =C2=A0 =C2=A0 =C2=A0 gfp_flags_printf_map,
> + =C2=A0 =C2=A0 =C2=A0 { -1, NULL }
> +};
> +
> =C2=A0#ifdef CONFIG_DEBUG_VM
> =C2=A0static int page_outside_zone_boundaries(struct zone *zone, struct p=
age *page)
> =C2=A0{
> @@ -1675,9 +1681,15 @@ nofail_alloc:
>
> =C2=A0nopage:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(gfp_mask & __GFP_NOWARN) && printk_ratel=
imit()) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 static struct trace_pr=
intf_spec gfpmask_printspec;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gfpmask_printspec.flag=
s =3D gfp_mask;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gfpmask_printspec.flag=
_array =3D trace_print_flags_gfp;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNIN=
G "%s: page allocation failure."
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 " order:%d, mode:0x%x\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 p->comm, order, gfp_mask);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 " order:%d, mode:0x%x\nmode:%f\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 p->comm, order, gfp_mask,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 &gfpmask_printspec);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dump_stack();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0show_mem();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
