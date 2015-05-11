Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 597B66B006E
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:35:42 -0400 (EDT)
Received: by iecmd7 with SMTP id md7so31604978iec.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:35:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id c101si9595239iod.46.2015.05.11.07.35.41
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 07:35:41 -0700 (PDT)
Date: Mon, 11 May 2015 11:35:36 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 4/6] perf kmem: Print gfp flags in human readable string
Message-ID: <20150511143536.GP28183@kernel.org>
References: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
 <1429592107-1807-5-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1429592107-1807-5-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Em Tue, Apr 21, 2015 at 01:55:05PM +0900, Namhyung Kim escreveu:
> Save libtraceevent output and print it in the header.

<SNIP>

> +static int parse_gfp_flags(struct perf_evsel *evsel, struct perf_sample *sample,
> +			   unsigned int gfp_flags)
> +{
> +	struct pevent_record record = {
> +		.cpu = sample->cpu,
> +		.data = sample->raw_data,
> +		.size = sample->raw_size,
> +	};
> +	struct trace_seq seq;
> +	char *str, *pos;
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
> +	str = strtok_r(seq.buffer, " ", &pos);


This introduced a problem I only now noticed, possibly because my
compiler was upgraded:

[acme@zoo linux]$ git bisect good 
0e11115644b39ff9e986eb308b6c44ca75cd475f is the first bad commit
commit 0e11115644b39ff9e986eb308b6c44ca75cd475f
Author: Namhyung Kim <namhyung@kernel.org>
Date:   Tue Apr 21 13:55:05 2015 +0900

    perf kmem: Print gfp flags in human readable string
    
    Save libtraceevent output and print it in the header.

-------------------------------------------------


  GEN      /tmp/build/perf/common-cmds.h
  PERF_VERSION = 4.1.rc2.ga20d87
  CC       /tmp/build/perf/builtin-kmem.o
builtin-kmem.c: In function a??perf_evsel__process_page_alloc_eventa??:
builtin-kmem.c:743:427: error: a??posa?? may be used uninitialized in this
function [-Werror=maybe-uninitialized]
    new->human_readable = strdup(str + 10);
                                                                                                                                                                                                                                                                                                                                                                                                                                           ^
builtin-kmem.c:716:14: note: a??posa?? was declared here
  char *str, *pos;
              ^
cc1: all warnings being treated as errors
/home/git/linux/tools/build/Makefile.build:68: recipe for target
'/tmp/build/perf/builtin-kmem.o' failed
make[2]: *** [/tmp/build/perf/builtin-kmem.o] Error 1
Makefile.perf:330: recipe for target '/tmp/build/perf/builtin-kmem.o'
failed
make[1]: *** [/tmp/build/perf/builtin-kmem.o] Error 2
Makefile:87: recipe for target 'builtin-kmem.o' failed
make: *** [builtin-kmem.o] Error 2
make: Leaving directory '/home/git/linux/tools/perf'

------

Trying to fix it by initializing it to NULL.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
