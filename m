Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C398C6B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 03:29:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p12so2531047pfn.13
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 00:29:04 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a17si9391535pgv.164.2018.04.09.00.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 00:29:03 -0700 (PDT)
Date: Mon, 9 Apr 2018 16:28:56 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 9/9] perf probe: Support SDT markers having reference
 counter (semaphore)
Message-Id: <20180409162856.df4c32b840eb5f2ef8c028f1@kernel.org>
In-Reply-To: <20180404083110.18647-10-ravi.bangoria@linux.vnet.ibm.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180404083110.18647-10-ravi.bangoria@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

Hi Ravi,

On Wed,  4 Apr 2018 14:01:10 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> With this, perf buildid-cache will save SDT markers with reference
> counter in probe cache. Perf probe will be able to probe markers
> having reference counter. Ex,
> 
>   # readelf -n /tmp/tick | grep -A1 loop2
>     Name: loop2
>     ... Semaphore: 0x0000000010020036
> 
>   # ./perf buildid-cache --add /tmp/tick
>   # ./perf probe sdt_tick:loop2
>   # ./perf stat -e sdt_tick:loop2 /tmp/tick
>     hi: 0
>     hi: 1
>     hi: 2
>     ^C
>      Performance counter stats for '/tmp/tick':
>                  3      sdt_tick:loop2
>        2.561851452 seconds time elapsed
> 
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
> ---
>  tools/perf/util/probe-event.c | 18 ++++++++++++++---
>  tools/perf/util/probe-event.h |  1 +
>  tools/perf/util/probe-file.c  | 34 ++++++++++++++++++++++++++------
>  tools/perf/util/probe-file.h  |  1 +
>  tools/perf/util/symbol-elf.c  | 46 ++++++++++++++++++++++++++++++++-----------
>  tools/perf/util/symbol.h      |  7 +++++++
>  6 files changed, 86 insertions(+), 21 deletions(-)
> 
> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
> index e1dbc98..b3a1330 100644
> --- a/tools/perf/util/probe-event.c
> +++ b/tools/perf/util/probe-event.c
> @@ -1832,6 +1832,12 @@ int parse_probe_trace_command(const char *cmd, struct probe_trace_event *tev)
>  			tp->offset = strtoul(fmt2_str, NULL, 10);
>  	}
>  
> +	if (tev->uprobes) {
> +		fmt2_str = strchr(p, '(');
> +		if (fmt2_str)
> +			tp->ref_ctr_offset = strtoul(fmt2_str + 1, NULL, 0);
> +	}
> +
>  	tev->nargs = argc - 2;
>  	tev->args = zalloc(sizeof(struct probe_trace_arg) * tev->nargs);
>  	if (tev->args == NULL) {
> @@ -2054,15 +2060,21 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
>  	}
>  
>  	/* Use the tp->address for uprobes */
> -	if (tev->uprobes)
> +	if (tev->uprobes) {
>  		err = strbuf_addf(&buf, "%s:0x%lx", tp->module, tp->address);
> -	else if (!strncmp(tp->symbol, "0x", 2))
> +		if (uprobe_ref_ctr_is_supported() &&
> +		    tp->ref_ctr_offset &&
> +		    err >= 0)
> +			err = strbuf_addf(&buf, "(0x%lx)", tp->ref_ctr_offset);

If the kernel doesn't support uprobe_ref_ctr but the event requires
to increment uprobe_ref_ctr, I think we should (at least) warn user here.

> +	} else if (!strncmp(tp->symbol, "0x", 2)) {
>  		/* Absolute address. See try_to_find_absolute_address() */
>  		err = strbuf_addf(&buf, "%s%s0x%lx", tp->module ?: "",
>  				  tp->module ? ":" : "", tp->address);
> -	else
> +	} else {
>  		err = strbuf_addf(&buf, "%s%s%s+%lu", tp->module ?: "",
>  				tp->module ? ":" : "", tp->symbol, tp->offset);
> +	}
> +
>  	if (err)
>  		goto error;
>  
> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
> index 45b14f0..15a98c3 100644
> --- a/tools/perf/util/probe-event.h
> +++ b/tools/perf/util/probe-event.h
> @@ -27,6 +27,7 @@ struct probe_trace_point {
>  	char		*symbol;	/* Base symbol */
>  	char		*module;	/* Module name */
>  	unsigned long	offset;		/* Offset from symbol */
> +	unsigned long	ref_ctr_offset;	/* SDT reference counter offset */
>  	unsigned long	address;	/* Actual address of the trace point */
>  	bool		retprobe;	/* Return probe flag */
>  };
> diff --git a/tools/perf/util/probe-file.c b/tools/perf/util/probe-file.c
> index 4ae1123..ca0e524 100644
> --- a/tools/perf/util/probe-file.c
> +++ b/tools/perf/util/probe-file.c
> @@ -697,8 +697,16 @@ int probe_cache__add_entry(struct probe_cache *pcache,
>  #ifdef HAVE_GELF_GETNOTE_SUPPORT
>  static unsigned long long sdt_note__get_addr(struct sdt_note *note)
>  {
> -	return note->bit32 ? (unsigned long long)note->addr.a32[0]
> -		 : (unsigned long long)note->addr.a64[0];
> +	return note->bit32 ?
> +		(unsigned long long)note->addr.a32[SDT_NOTE_IDX_LOC] :
> +		(unsigned long long)note->addr.a64[SDT_NOTE_IDX_LOC];
> +}
> +
> +static unsigned long long sdt_note__get_ref_ctr_offset(struct sdt_note *note)
> +{
> +	return note->bit32 ?
> +		(unsigned long long)note->addr.a32[SDT_NOTE_IDX_REFCTR] :
> +		(unsigned long long)note->addr.a64[SDT_NOTE_IDX_REFCTR];
>  }
>  
>  static const char * const type_to_suffix[] = {
> @@ -776,14 +784,21 @@ static char *synthesize_sdt_probe_command(struct sdt_note *note,
>  {
>  	struct strbuf buf;
>  	char *ret = NULL, **args;
> -	int i, args_count;
> +	int i, args_count, err;
> +	unsigned long long ref_ctr_offset;
>  
>  	if (strbuf_init(&buf, 32) < 0)
>  		return NULL;
>  
> -	if (strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
> -				sdtgrp, note->name, pathname,
> -				sdt_note__get_addr(note)) < 0)
> +	err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
> +			sdtgrp, note->name, pathname,
> +			sdt_note__get_addr(note));
> +
> +	ref_ctr_offset = sdt_note__get_ref_ctr_offset(note);
> +	if (uprobe_ref_ctr_is_supported() && ref_ctr_offset && err >= 0)
> +		err = strbuf_addf(&buf, "(0x%llx)", ref_ctr_offset);

We don't have to care about uprobe_ref_ctr support here, because
this information will be just cached, not directly written to
uprobe_events.

Other parts look good to me.

Thanks,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
