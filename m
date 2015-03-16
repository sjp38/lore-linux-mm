Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8E01E6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 13:33:56 -0400 (EDT)
Received: by wgra20 with SMTP id a20so45916013wgr.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:33:56 -0700 (PDT)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com. [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id eg10si19066180wjd.26.2015.03.16.10.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 10:33:55 -0700 (PDT)
Received: by webcq43 with SMTP id cq43so43601971web.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:33:54 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v4 3/5] stacktrace: add seq_print_stack_trace()
In-Reply-To: <19b2815dbb60bfd38d17596a3d466637ee44c9a5.1426521377.git.s.strogin@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com> <19b2815dbb60bfd38d17596a3d466637ee44c9a5.1426521377.git.s.strogin@partner.samsung.com>
Date: Mon, 16 Mar 2015 18:33:50 +0100
Message-ID: <xa1toansoni9.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Mon, Mar 16 2015, Stefan Strogin wrote:
> Add a function seq_print_stack_trace() which prints stacktraces to seq_fi=
les.
>
> Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
> Reviewed-by: SeongJae Park <sj38.park@gmail.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/linux/stacktrace.h |  4 ++++
>  kernel/stacktrace.c        | 17 +++++++++++++++++
>  2 files changed, 21 insertions(+)
>
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index 0a34489..d80f2e9 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -2,6 +2,7 @@
>  #define __LINUX_STACKTRACE_H
>=20=20
>  #include <linux/types.h>
> +#include <linux/seq_file.h>
>=20=20
>  struct task_struct;
>  struct pt_regs;
> @@ -22,6 +23,8 @@ extern void save_stack_trace_tsk(struct task_struct *ts=
k,
>  extern void print_stack_trace(struct stack_trace *trace, int spaces);
>  extern int snprint_stack_trace(char *buf, size_t size,
>  			struct stack_trace *trace, int spaces);
> +extern void seq_print_stack_trace(struct seq_file *m,
> +			struct stack_trace *trace, int spaces);
>=20=20
>  #ifdef CONFIG_USER_STACKTRACE_SUPPORT
>  extern void save_stack_trace_user(struct stack_trace *trace);
> @@ -35,6 +38,7 @@ extern void save_stack_trace_user(struct stack_trace *t=
race);
>  # define save_stack_trace_user(trace)			do { } while (0)
>  # define print_stack_trace(trace, spaces)		do { } while (0)
>  # define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
> +# define seq_print_stack_trace(m, trace, spaces)	do { } while (0)
>  #endif
>=20=20
>  #endif
> diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
> index b6e4c16..66ef6f4 100644
> --- a/kernel/stacktrace.c
> +++ b/kernel/stacktrace.c
> @@ -57,6 +57,23 @@ int snprint_stack_trace(char *buf, size_t size,
>  }
>  EXPORT_SYMBOL_GPL(snprint_stack_trace);
>=20=20
> +void seq_print_stack_trace(struct seq_file *m, struct stack_trace *trace,
> +			int spaces)
> +{
> +	int i;
> +
> +	if (WARN_ON(!trace->entries))
> +		return;
> +
> +	for (i =3D 0; i < trace->nr_entries; i++) {
> +		unsigned long ip =3D trace->entries[i];
> +
> +		seq_printf(m, "%*c[<%p>] %pS\n", 1 + spaces, ' ',
> +				(void *) ip, (void *) ip);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(seq_print_stack_trace);
> +
>  /*
>   * Architectures that do not implement save_stack_trace_tsk or
>   * save_stack_trace_regs get this weak alias and a once-per-bootup warni=
ng
> --=20
> 2.1.0
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
