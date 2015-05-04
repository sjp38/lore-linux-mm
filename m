Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 501446B006C
	for <linux-mm@kvack.org>; Mon,  4 May 2015 16:55:03 -0400 (EDT)
Received: by iejt8 with SMTP id t8so140161812iej.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 13:55:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id 79si11185431iod.4.2015.05.04.13.55.02
        for <linux-mm@kvack.org>;
        Mon, 04 May 2015 13:55:02 -0700 (PDT)
Date: Mon, 4 May 2015 13:15:39 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 6/6] perf kmem: Show warning when trying to run stat
 without record
Message-ID: <20150504161539.GG10475@kernel.org>
References: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
 <1429592107-1807-7-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429592107-1807-7-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Em Tue, Apr 21, 2015 at 01:55:07PM +0900, Namhyung Kim escreveu:
> Sometimes one can mistakenly run perf kmem stat without perf kmem
> record before or different configuration like recoding --slab and stat
> --page.  Show a warning message like below to inform user:
> 
>   # perf kmem stat --page --caller
>   Not found page events.  Have you run 'perf kmem record --page' before?
> 
> Acked-by: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> ---
>  tools/perf/builtin-kmem.c | 31 ++++++++++++++++++++++++++++---
>  1 file changed, 28 insertions(+), 3 deletions(-)
> 
> diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
> index 828b7284e547..f29a766f18f8 100644
> --- a/tools/perf/builtin-kmem.c
> +++ b/tools/perf/builtin-kmem.c
> @@ -1882,6 +1882,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
>  	};
>  	struct perf_session *session;
>  	int ret = -1;
> +	const char errmsg[] = "Not found %s events.  Have you run 'perf kmem record --%s' before?\n";
>  
>  	perf_config(kmem_config, NULL);
>  	argc = parse_options_subcommand(argc, argv, kmem_options,
> @@ -1908,11 +1909,35 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
>  	if (session == NULL)
>  		return -1;
>  
> +	if (kmem_slab) {
> +		struct perf_evsel *evsel;
> +		bool found = false;
> +
> +		evlist__for_each(session->evlist, evsel) {
> +			if (!strcmp(perf_evsel__name(evsel), "kmem:kmalloc")) {
> +				found = true;
> +				break;
> +			}
> +		}

We have:

struct perf_evsel *
perf_evlist__find_tracepoint_by_name(struct perf_evlist *evlist,
                                     const char *name);

Example of it being used in 'perf trace':

        evsel = perf_evlist__find_tracepoint_by_name(session->evlist,
                                                     "raw_syscalls:sys_enter");
        /* older kernels have syscalls tp versus raw_syscalls */
        if (evsel == NULL)
                evsel = perf_evlist__find_tracepoint_by_name(session->evlist,
                                                             "syscalls:sys_enter");


Applied 1-5, can you please resubmit this one with this change?

- Arnaldo

> +		if (!found) {
> +			pr_err(errmsg, "slab", "slab");
> +			return -1;
> +		}
> +	}
> +
>  	if (kmem_page) {
> -		struct perf_evsel *evsel = perf_evlist__first(session->evlist);
> +		struct perf_evsel *evsel;
> +		bool found = false;
>  
> -		if (evsel == NULL || evsel->tp_format == NULL) {
> -			pr_err("invalid event found.. aborting\n");
> +		evlist__for_each(session->evlist, evsel) {
> +			if (!strcmp(perf_evsel__name(evsel),
> +				    "kmem:mm_page_alloc")) {
> +				found = true;
> +				break;
> +			}
> +		}
> +		if (!found) {
> +			pr_err(errmsg, "page", "page");
>  			return -1;
>  		}
>  
> -- 
> 2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
