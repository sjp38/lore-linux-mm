Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id BF92F6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 06:59:56 -0400 (EDT)
Message-ID: <4F97D917.6090101@hitachi.com>
Date: Wed, 25 Apr 2012 19:59:35 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH-V3] perf/probe: verify instruction/offset in perf before
 adding a uprobe
References: <4F9791A8.4010505@linux.vnet.ibm.com>
In-Reply-To: <4F9791A8.4010505@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Cc: peterz@infradead.org, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, torvalds@linux-foundation.org, ananth@in.ibm.com, jkenisto@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com, andi@firstfloor.org, hch@infradead.org, rostedt@goodmis.org, acme@infradead.org, tglx@linutronix.de, anton@redhat.com, srikar@linux.vnet.ibm.com

(2012/04/25 14:54), Prashanth Nageshappa wrote:
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
> v3 addresses Arnaldo's review comments.
> 
> v2 addresses Masami's review comments: Rebuild insn.c and inat.c while
> building perf and a few other minor ones.

This looks good for me :)

> 
> Signed-off-by: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>

Acked-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>

Thanks!

> ---
> 
>  tools/perf/Makefile                    |    1 
>  tools/perf/arch/x86/Makefile           |   20 ++++++++
>  tools/perf/arch/x86/util/probe-event.c |   81 ++++++++++++++++++++++++++++++++
>  tools/perf/util/include/linux/string.h |    1 
>  tools/perf/util/probe-event.c          |   23 +++++++++
>  tools/perf/util/probe-event.h          |    2 +
>  tools/perf/util/symbol.c               |    2 +
>  tools/perf/util/symbol.h               |    1 
>  8 files changed, 130 insertions(+), 1 deletions(-)
>  create mode 100644 tools/perf/arch/x86/util/probe-event.c
> 
> diff --git a/tools/perf/Makefile b/tools/perf/Makefile
> index 820371f..94879b9 100644
> --- a/tools/perf/Makefile
> +++ b/tools/perf/Makefile
> @@ -61,6 +61,7 @@ ARCH ?= $(shell echo $(uname_M) | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ \
>  
>  CC = $(CROSS_COMPILE)gcc
>  AR = $(CROSS_COMPILE)ar
> +AWK = awk
>  
>  # Additional ARCH settings for x86
>  ifeq ($(ARCH),i386)
> diff --git a/tools/perf/arch/x86/Makefile b/tools/perf/arch/x86/Makefile
> index 744e629..1a7215b 100644
> --- a/tools/perf/arch/x86/Makefile
> +++ b/tools/perf/arch/x86/Makefile
> @@ -1,5 +1,25 @@
> +inat_tables_script = ../../arch/$(ARCH)/tools/gen-insn-attr-x86.awk
> +inat_tables_maps = ../../arch/$(ARCH)/lib/x86-opcode-map.txt
> +cmd_inat_tables = $(AWK) -f $(inat_tables_script) $(inat_tables_maps) > $@ || rm -f $@
> +
> +BASIC_CFLAGS += -I. -I../../arch/$(ARCH)/include
> +
>  ifndef NO_DWARF
>  PERF_HAVE_DWARF_REGS := 1
>  LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/dwarf-regs.o
>  endif
>  LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/header.o
> +LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/probe-event.o
> +LIB_OBJS += $(OUTPUT)arch/$(ARCH)/inat.o
> +LIB_OBJS += $(OUTPUT)arch/$(ARCH)/insn.o
> +
> +$(OUTPUT)arch/$(ARCH)/inat.o:../../arch/$(ARCH)/lib/inat-tables.c
> +
> +../../arch/$(ARCH)/lib/inat-tables.c: $(inat_tables_script) $(inat_tables_maps)
> +	$(cmd_inat_tables)
> +
> +$(OUTPUT)arch/$(ARCH)/inat.o:../../arch/$(ARCH)/lib/inat.c $(OUTPUT)PERF-CFLAGS
> +	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) $<
> +
> +$(OUTPUT)arch/$(ARCH)/insn.o:../../arch/$(ARCH)/lib/insn.c $(OUTPUT)PERF-CFLAGS
> +	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) $<
> diff --git a/tools/perf/arch/x86/util/probe-event.c b/tools/perf/arch/x86/util/probe-event.c
> new file mode 100644
> index 0000000..f1ebf90
> --- /dev/null
> +++ b/tools/perf/arch/x86/util/probe-event.c
> @@ -0,0 +1,81 @@
> +/*
> + * probe-event.c : x86 specific perf-probe definition
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + *
> + * Copyright (C) IBM Corporation, 2011-2012
> + * Authors:
> + *	Prashanth Nageshappa
> + */
> +
> +#include <util/types.h>
> +#include <util/probe-event.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <unistd.h>
> +#include <fcntl.h>
> +#include <string.h>
> +#include <errno.h>
> +#include <asm/insn.h>
> +#include <elf.h>
> +
> +/*
> + * Check if a given offset from start of a function is valid or not
> + */
> +bool can_probe(char *name, u64 vaddr, unsigned long offset,
> +		u8 class)
> +{
> +	u64 eaddr, saddr;
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
> +	buf = malloc(offset + MAX_INSN_SIZE);
> +	if (buf == NULL) {
> +		pr_warning("Failed to allocate memory");
> +		goto out_close;
> +	}
> +	fileoffset = lseek(fd, vaddr, SEEK_SET);
> +	if (fileoffset != vaddr) {
> +		pr_warning("Failed to lseek %s: %s\n", name, strerror(errno));
> +		goto out_free;
> +	}
> +	saddr = (u64)buf;
> +	eaddr = (u64)buf + offset;
> +	readbytes = read(fd, buf, offset + MAX_INSN_SIZE);
> +	if (readbytes != offset + MAX_INSN_SIZE) {
> +		pr_warning("Failed to read %s: %s\n", name, strerror(errno));
> +		goto out_free;
> +	}
> +	while (saddr < eaddr) {
> +		insn_init(&insn, (void *)saddr, class == ELFCLASS64);
> +		insn_get_length(&insn);
> +		saddr += insn.length;
> +	}
> +	ret = (saddr == eaddr);
> +
> +out_free:
> +	free(buf);
> +out_close:
> +	close(fd);
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
> index b7dec82..57f9eae 100644
> --- a/tools/perf/util/probe-event.c
> +++ b/tools/perf/util/probe-event.c
> @@ -2254,6 +2254,17 @@ int show_available_funcs(const char *target, struct strfilter *_filter,
>  }
>  
>  /*
> + * Check if a given offset from start of a function is valid or not
> + */
> +bool __attribute__((weak)) can_probe(char *name __used,
> +					u64 vaddr __used,
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
> @@ -2307,7 +2318,17 @@ static int convert_name_to_addr(struct perf_probe_event *pev, const char *exec)
>  
>  	if (map->start > sym->start)
>  		vaddr = map->start;
> -	vaddr += sym->start + pp->offset + map->pgoff;
> +
> +	vaddr += sym->start + map->pgoff;
> +	if (pp->offset) {
> +		if ((vaddr + pp->offset > sym->end) ||
> +			!can_probe(name, vaddr, pp->offset,
> +					map->dso->class)) {
> +			pr_err("Failed to insert probe, ensure offset is within function and on insn boundary.\n");
> +			return -EINVAL;
> +		}
> +	}
> +	vaddr += pp->offset;
>  	pp->offset = 0;
>  
>  	if (!pev->event) {
> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
> index f9f3de8..9ec2f8c 100644
> --- a/tools/perf/util/probe-event.h
> +++ b/tools/perf/util/probe-event.h
> @@ -137,4 +137,6 @@ extern int show_available_funcs(const char *module, struct strfilter *filter,
>  /* Maximum index number of event-name postfix */
>  #define MAX_EVENT_INDEX	1024
>  
> +extern bool can_probe(char *name, u64 vaddr, unsigned long offset,
> +			u8 class);
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
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
