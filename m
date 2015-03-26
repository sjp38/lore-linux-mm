Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 45E556B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:10:09 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so64033010pdn.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:10:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id g12si8589071pat.3.2015.03.26.07.10.08
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 07:10:08 -0700 (PDT)
Date: Thu, 26 Mar 2015 11:10:10 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 6/6] perf kmem: Print gfp flags in human readable string
Message-ID: <20150326141010.GC21510@kernel.org>
References: <1427349636-9796-1-git-send-email-namhyung@kernel.org>
 <1427349636-9796-7-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427349636-9796-7-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Thu, Mar 26, 2015 at 03:00:36PM +0900, Namhyung Kim escreveu:
> Save libtraceevent output and print it in the header.
> 
>   # perf kmem stat --page --caller
>   # GFP flags
>   # ---------
>   # 00000010: GFP_NOIO
>   # 000000d0: GFP_KERNEL
>   # 00000200: GFP_NOWARN
>   # 000084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
>   # 000200d2: GFP_HIGHUSER
>   # 000200da: GFP_HIGHUSER_MOVABLE
>   # 000280da: GFP_HIGHUSER_MOVABLE|GFP_ZERO
>   # 002084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
>   # 0102005a: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE
> 
>   ---------------------------------------------------------------------------------------------------------
>    Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite
>   ---------------------------------------------------------------------------------------------------------
>                  60 |        15 |     0 |      UNMOVABLE |  002084d0 | pte_alloc_one
>                  40 |        10 |     0 |        MOVABLE |  000280da | handle_mm_fault
>                  24 |         6 |     0 |        MOVABLE |  000200da | do_wp_page
>                  24 |         6 |     0 |      UNMOVABLE |  000000d0 | __pollwait
>    ...

Perhaps you could compact it further by doing things like:

    # 00000010:      NIO: GFP_NOIO
    # 000000d0:        K: GFP_KERNEL
    # 00000200:       NW: GFP_NOWARN
    # 000084d0:    K|R|Z: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
    # 000200d2:       HU: GFP_HIGHUSER
    # 000200da:      HUM: GFP_HIGHUSER_MOVABLE
    # 000280da:    HUM|Z: GFP_HIGHUSER_MOVABLE|GFP_ZERO
    # 002084d0: K|R|Z|NT: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
    # 0102005a: NFS|HW|M: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE

    -------------------------------------------------------------------------
    Total(KB) | Hits | Ord | Migr.| GFP flg  | Callsite
    -------------------------------------------------------------------------
           60 |   15 |   0 | UNMV | K|R|Z|NT | pte_alloc_one
           40 |   10 |   0 |   MV |    HUM|Z | handle_mm_fault
           24 |    6 |   0 |   MV |      HUM | do_wp_page
           24 |    6 |   0 | UNMV |        K | __pollwait

I.e. using mnemonics instead of a hex number for the GFP flag, reducing
the need to lookup the header.

Just my 2 cents :-)

- Arnaldo

> 
> Requested-by: Joonsoo Kim <js1304@gmail.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> ---
>  tools/perf/builtin-kmem.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 81 insertions(+)
> 
> diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
> index c09e332f7f38..502f6944a04c 100644
> --- a/tools/perf/builtin-kmem.c
> +++ b/tools/perf/builtin-kmem.c
> @@ -545,6 +545,72 @@ static bool valid_page(u64 pfn_or_page)
>  	return true;
>  }
>  
> +struct gfp_flag {
> +	unsigned int flags;
> +	char *human_readable;
> +};
> +
> +static struct gfp_flag *gfps;
> +static int nr_gfps;
> +
> +static int gfpcmp(const void *a, const void *b)
> +{
> +	const struct gfp_flag *fa = a;
> +	const struct gfp_flag *fb = b;
> +
> +	return fa->flags - fb->flags;
> +}
> +
> +static int parse_gfp_flags(struct perf_evsel *evsel, struct perf_sample *sample,
> +			   unsigned int gfp_flags)
> +{
> +	struct pevent_record record = {
> +		.cpu = sample->cpu,
> +		.data = sample->raw_data,
> +		.size = sample->raw_size,
> +	};
> +	struct trace_seq seq;
> +	char *str;
> +
> +	if (nr_gfps) {
> +		struct gfp_flag key = {
> +			.flags = gfp_flags,
> +		};
> +
> +		if (bsearch(&key, gfps, nr_gfps, sizeof(*gfps), gfpcmp))
> +			return 0;
> +	}
> +
> +	trace_seq_init(&seq);
> +	pevent_event_info(&seq, evsel->tp_format, &record);
> +
> +	str = strtok(seq.buffer, " ");
> +	while (str) {
> +		if (!strncmp(str, "gfp_flags=", 10)) {
> +			struct gfp_flag *new;
> +
> +			new = realloc(gfps, (nr_gfps + 1) * sizeof(*gfps));
> +			if (new == NULL)
> +				return -ENOMEM;
> +
> +			gfps = new;
> +			new += nr_gfps++;
> +
> +			new->flags = gfp_flags;
> +			new->human_readable = strdup(str + 10);
> +			if (new->human_readable == NULL)
> +				return -ENOMEM;
> +
> +			qsort(gfps, nr_gfps, sizeof(*gfps), gfpcmp);
> +		}
> +
> +		str = strtok(NULL, " ");
> +	}
> +
> +	trace_seq_destroy(&seq);
> +	return 0;
> +}
> +
>  static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  						struct perf_sample *sample)
>  {
> @@ -577,6 +643,9 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  		return 0;
>  	}
>  
> +	if (parse_gfp_flags(evsel, sample, gfp_flags) < 0)
> +		return -1;
> +
>  	callsite = find_callsite(evsel, sample);
>  
>  	/*
> @@ -877,6 +946,16 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
>  	printf("%.105s\n", graph_dotted_line);
>  }
>  
> +static void print_gfp_flags(void)
> +{
> +	int i;
> +
> +	printf("# GFP flags\n");
> +	printf("# ---------\n");
> +	for (i = 0; i < nr_gfps; i++)
> +		printf("# %08x: %s\n", gfps[i].flags, gfps[i].human_readable);
> +}
> +
>  static void print_slab_summary(void)
>  {
>  	printf("\nSUMMARY (SLAB allocator)");
> @@ -946,6 +1025,8 @@ static void print_slab_result(struct perf_session *session)
>  
>  static void print_page_result(struct perf_session *session)
>  {
> +	if (caller_flag || alloc_flag)
> +		print_gfp_flags();
>  	if (caller_flag)
>  		__print_page_caller_result(session, caller_lines);
>  	if (alloc_flag)
> -- 
> 2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
