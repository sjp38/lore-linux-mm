Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 11C106B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 18:48:13 -0500 (EST)
Received: by eaal1 with SMTP id l1so2816837eaa.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 15:48:11 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: decode GFP flags in oom killer output.
References: <20120307233939.GB5574@redhat.com>
Date: Thu, 08 Mar 2012 00:48:08 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.watq2ixr3l0zgt@mpn-glaptop>
In-Reply-To: <20120307233939.GB5574@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org

On Thu, 08 Mar 2012 00:39:39 +0100, Dave Jones <davej@redhat.com> wrote:=


> Decoding these flags by hand in oom reports is tedious,
> and error-prone.
>
> Signed-off-by: Dave Jones <davej@redhat.com>
>
> diff -durpN '--exclude-from=3D/home/davej/.exclude' -u src/git-trees/k=
ernel/linux/include/linux/gfp.h linux-dj/include/linux/gfp.h
> --- linux/include/linux/gfp.h	2012-01-11 16:54:21.736395499 -0500
> +++ linux-dj/include/linux/gfp.h	2012-03-06 13:17:37.294692113 -0500
> @@ -10,6 +10,7 @@
>  struct vm_area_struct;
> /* Plain integer GFP bitmasks. Do not use this directly. */
> +/* Update mm/oom_kill.c gfp_flag_texts when adding to/changing this l=
ist */
>  #define ___GFP_DMA		0x01u
>  #define ___GFP_HIGHMEM		0x02u
>  #define ___GFP_DMA32		0x04u
> diff -durpN '--exclude-from=3D/home/davej/.exclude' -u src/git-trees/k=
ernel/linux/mm/oom_kill.c linux-dj/mm/oom_kill.c
> --- linux/mm/oom_kill.c	2012-01-17 17:54:14.541881964 -0500
> +++ linux-dj/mm/oom_kill.c	2012-03-06 13:17:44.071680535 -0500
> @@ -416,13 +416,40 @@ static void dump_tasks(const struct mem_
>  	}
>  }
>+static unsigned char *gfp_flag_texts[32] =3D {
> +	"DMA", "HIGHMEM", "DMA32", "MOVABLE",
> +	"WAIT", "HIGH", "IO", "FS",
> +	"COLD", "NOWARN", "REPEAT", "NOFAIL",
> +	"NORETRY", NULL, "COMP", "ZERO",
> +	"NOMEMALLOC", "HARDWALL", "THISNODE", "RECLAIMABLE",
> +	NULL, "NOTRACK", "NO_KSWAPD", "OTHER_NODE",
> +};
> +
> +static void decode_gfp_mask(gfp_t gfp_mask, char *out_string)
> +{
> +	unsigned int i;
> +
> +	for (i =3D 0; i < 32; i++) {
> +		if (gfp_mask & (1 << i)) {
> +			if (gfp_flag_texts[i])
> +				out_string +=3D sprintf(out_string, "%s ", gfp_flag_texts[i]);
> +			else
> +				out_string +=3D sprintf(out_string, "reserved! ");
> +		}
> +	}
> +	out_string =3D "\0";

Uh?  Did you mean =E2=80=9C*out_string =3D 0;=E2=80=9D which is redundan=
t anyway?

Also, this leaves a trailing space at the end of the string.

> +}
> +
>  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int or=
der,
>  			struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
> +	char gfp_string[80];

For ~0, the string will be 256 characters followed by a NUL byte byte at=
 the end.
This combination may make no sense, but the point is that you need to ta=
ke length
of the buffer into account, probably by using snprintf() and a counter.

>  	task_lock(current);
> -	pr_warning("%s invoked oom-killer: gfp_mask=3D0x%x, order=3D%d, "
> +	decode_gfp_mask(gfp_mask, gfp_string);
> +	pr_warning("%s invoked oom-killer: gfp_mask=3D0x%x [%s], order=3D%d,=
 "
>  		"oom_adj=3D%d, oom_score_adj=3D%d\n",
> -		current->comm, gfp_mask, order, current->signal->oom_adj,
> +		current->comm, gfp_mask, gfp_string,
> +		order, current->signal->oom_adj,
>  		current->signal->oom_score_adj);
>  	cpuset_print_task_mems_allowed(current);
>  	task_unlock(current);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stoptheme=
ter.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>


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
