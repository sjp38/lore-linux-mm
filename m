Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B74E26B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 07:23:37 -0400 (EDT)
Date: Tue, 24 Apr 2012 08:23:27 -0300
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH-V2] perf/probe: verify instruction/offset in perf before
 adding a uprobe
Message-ID: <20120424112327.GA17992@infradead.org>
References: <20120424061439.14593.97404.stgit@nprashan.in.ibm.com>
 <4F9649FE.6060104@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9649FE.6060104@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Cc: peterz@infradead.org, mingo@elte.hu, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, ananth@in.ibm.com, jkenisto@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com, andi@firstfloor.org, hch@infradead.org, rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com, tglx@linutronix.de, anton@redhat.com, srikar@linux.vnet.ibm.com

Em Tue, Apr 24, 2012 at 12:06:46PM +0530, Prashanth Nageshappa escreveu:
> This patch is to augment Srikar's perf support for uprobes patch
> (https://lkml.org/lkml/2012/4/11/191) with the following features:
> 
> a. Instruction verification for user space tracing
> b. Function boundary validation support to uprobes as its kernel
> counterpart (Commit-ID: 1c1bc922).
> 
> This will help in ensuring uprobe is placed at right location inside
> the intended function.
> 
> To verify instructions in perf before adding a uprobe, we need to use
> arch/x86/lib/insn.c. Since perf Makefile enables -Wswitch-default flag
> it causes build warnings/failures. Masami's patch
> https://lkml.org/lkml/2012/4/12/598 addresses those warnings and it is
> a pre-req for this patch.
> 
> v2 addresses Masami's review comments: Rebuild insn.c and inat.c while
> building perf and a few other minor ones.

Some minor nits below
 
> --- /dev/null
> +++ b/tools/perf/arch/x86/util/probe-event.c
> @@ -0,0 +1,84 @@
> +bool can_probe(char *name, unsigned long long vaddr, unsigned long offset,
> +		u8 class)
> +{
> +	unsigned long long eaddr, saddr;

Why not the much shorter 'u64'?

> +	unsigned long fileoffset, readbytes;
> +	int fd = 0;
> +	bool ret = false;
> +	char *buf = NULL;
> +	struct insn insn;
> +
> +	fd = open(name, O_RDONLY);
> +	if (fd == -1) {
> +		pr_warning("Failed to open %s: %s\n", name, strerror(errno));
> +		return ret;
> +	}
> +	buf = (char *)malloc(offset + MAX_INSN_SIZE);

No need to cast malloc's return

> +	if (buf == NULL) {
> +		pr_warning("Failed to allocate memory");
> +		goto out;
> +	}
> +	fileoffset = lseek(fd, vaddr, SEEK_SET);
> +	if (fileoffset != vaddr) {
> +		pr_warning("Failed to lseek %s: %s\n", name, strerror(errno));
> +		goto out;

Goto out_close and...

> +	}
> +	saddr = (unsigned long long)buf;
> +	eaddr = (unsigned long long)buf + offset;
> +	readbytes = read(fd, buf, offset + MAX_INSN_SIZE);
> +	if (readbytes != offset + MAX_INSN_SIZE) {
> +		pr_warning("Failed to read %s: %s\n", name, strerror(errno));
> +		goto out;

out_close

> +	}
> +	while (saddr < eaddr) {
> +		insn_init(&insn, (void *)saddr, class == ELFCLASS64);
> +		insn_get_length(&insn);
> +		saddr += insn.length;
> +	}
> +	ret = (saddr == eaddr);
> +
> +out:
> +	if (buf)
> +		free(buf);

free can handle NULL pointers just fine

> +
> +	if (fd)
> +		close(fd);

You can move this to before 'free' and label it out_close,
avoiding the test.

> +
> +	return ret;
> +}
> diff --git a/tools/perf/util/include/linux/string.h b/tools/perf/util/include/linux/string.h
> index 3b2f590..9d5eb21 100644
> --- a/tools/perf/util/include/linux/string.h
> +++ b/tools/perf/util/include/linux/string.h
> @@ -1 +1,2 @@
>  #include <string.h>
> +#include <perf.h>
> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
> index b7dec82..8f3de61 100644
> --- a/tools/perf/util/probe-event.c
> +++ b/tools/perf/util/probe-event.c
> @@ -2254,6 +2254,17 @@ int show_available_funcs(const char *target, struct strfilter *_filter,
>  }
> 
>  /*
> + * Check if a given offset from start of a function is valid or not
> + */
> +bool __attribute__((weak)) can_probe(char *name __used,
> +					unsigned long long vaddr __used,
> +					unsigned long offset __used,
> +					u8 class __used)
> +{
> +	return true;
> +}
> +
> +/*
>   * uprobe_events only accepts address:
>   * Convert function and any offset to address
>   */
> @@ -2307,7 +2318,16 @@ static int convert_name_to_addr(struct perf_probe_event *pev, const char *exec)
> 
>  	if (map->start > sym->start)
>  		vaddr = map->start;
> -	vaddr += sym->start + pp->offset + map->pgoff;
> +
> +	vaddr += sym->start + map->pgoff;
> +	if (pp->offset)
> +		if ((vaddr + pp->offset > sym->end) ||
> +			!can_probe(name, vaddr, pp->offset,
> +					map->dso->class)) {
> +			pr_err("Failed to insert probe, ensure offset is within function and on insn boundary.\n");
> +			return -EINVAL;
> +		}


Multi line if bodies gets visually nicer when enclosed with {}

> +	vaddr += pp->offset;
>  	pp->offset = 0;
> 
>  	if (!pev->event) {
> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
> index f9f3de8..af96594 100644
> --- a/tools/perf/util/probe-event.h
> +++ b/tools/perf/util/probe-event.h
> @@ -137,4 +137,6 @@ extern int show_available_funcs(const char *module, struct strfilter *filter,
>  /* Maximum index number of event-name postfix */
>  #define MAX_EVENT_INDEX	1024
> 
> +extern bool can_probe(char *name, unsigned long long vaddr,
> +			unsigned long offset, u8 class);
>  #endif /*_PROBE_EVENT_H */
> diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
> index caaf75a..be58b06 100644
> --- a/tools/perf/util/symbol.c
> +++ b/tools/perf/util/symbol.c
> @@ -1184,6 +1184,7 @@ static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
>  		goto out_close;
>  	}
> 
> +	dso->class = gelf_getclass(elf);
>  	if (gelf_getehdr(elf, &ehdr) == NULL) {
>  		pr_debug("%s: cannot get elf header.\n", __func__);
>  		goto out_elf_end;
> @@ -1326,6 +1327,7 @@ static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
>  				curr_dso->kernel = dso->kernel;
>  				curr_dso->long_name = dso->long_name;
>  				curr_dso->long_name_len = dso->long_name_len;
> +				curr_dso->class = dso->class;
>  				curr_map = map__new2(start, curr_dso,
>  						     map->type);
>  				if (curr_map == NULL) {
> diff --git a/tools/perf/util/symbol.h b/tools/perf/util/symbol.h
> index 9e7742c..1d0cc28 100644
> --- a/tools/perf/util/symbol.h
> +++ b/tools/perf/util/symbol.h
> @@ -174,6 +174,7 @@ struct dso {
>  	char	 	 *long_name;
>  	u16		 long_name_len;
>  	u16		 short_name_len;
> +	u8		 class;
>  	char		 name[0];
>  };
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
