Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id E5B2B6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 19:04:25 -0500 (EST)
Message-ID: <1331165061.20565.19.camel@joe2Laptop>
Subject: Re: decode GFP flags in oom killer output.
From: Joe Perches <joe@perches.com>
Date: Wed, 07 Mar 2012 16:04:21 -0800
In-Reply-To: <20120307233939.GB5574@redhat.com>
References: <20120307233939.GB5574@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 2012-03-07 at 18:39 -0500, Dave Jones wrote:
> Decoding these flags by hand in oom reports is tedious,
> and error-prone.

trivial notes...

> diff -durpN '--exclude-from=/home/davej/.exclude' -u src/git-trees/kernel/linux/mm/oom_kill.c linux-dj/mm/oom_kill.c
[]
> @@ -416,13 +416,40 @@ static void dump_tasks(const struct mem_
>  	}
>  }
>  
> +static unsigned char *gfp_flag_texts[32] = {

static const char *gfp_flags_text[sizeof(gfp_t) * 8)

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
> +	for (i = 0; i < 32; i++) {

< sizeof(gfp_t * 8)

> +		if (gfp_mask & (1 << i)) {

(gfp_t)1 << i

> +			if (gfp_flag_texts[i])
> +				out_string += sprintf(out_string, "%s ", gfp_flag_texts[i]);
> +			else
> +				out_string += sprintf(out_string, "reserved! ");

	not much use to exclamation points.

> +		}
> +	}
> +	out_string = "\0";

	out_string[-1] = 0;
> +}
> +
>  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  			struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
> +	char gfp_string[80];

maybe a static buffer instead of stack?

>  	task_lock(current);
> -	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
> +	decode_gfp_mask(gfp_mask, gfp_string);
> +	pr_warning("%s invoked oom-killer: gfp_mask=0x%x [%s], order=%d, "
>  		"oom_adj=%d, oom_score_adj=%d\n",

Maybe nicer to coalesce the format.

> -		current->comm, gfp_mask, order, current->signal->oom_adj,
> +		current->comm, gfp_mask, gfp_string,
> +		order, current->signal->oom_adj,
>  		current->signal->oom_score_adj);
>  	cpuset_print_task_mems_allowed(current);
>  	task_unlock(current);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
