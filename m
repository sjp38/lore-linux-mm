Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 3A4CE6B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 22:59:21 -0400 (EDT)
Message-ID: <4F87967E.2080401@hitachi.com>
Date: Fri, 13 Apr 2012 11:59:10 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] perf/probe: verify instruction/offset in perf before
 adding a uprobe
References: <20120412085741.23484.55695.stgit@nprashan.in.ibm.com> <4F86A0B4.4050206@linux.vnet.ibm.com>
In-Reply-To: <4F86A0B4.4050206@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

(2012/04/12 18:30), Prashanth Nageshappa wrote:
> Read instructions from the library/executable and verify the
> uprobe location for instruction validity and offset into the function.
>
>
> Signed-off-by: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
> ---
>
>  tools/perf/arch/x86/Makefile           |    4 ++
>  tools/perf/arch/x86/util/probe-event.c |   83 ++++++++++++++++++++++++++++++++
>  tools/perf/util/include/linux/string.h |    1
>  tools/perf/util/probe-event.c          |   22 ++++++++
>  tools/perf/util/probe-event.h          |    2 +
>  tools/perf/util/symbol.c               |    2 +
>  tools/perf/util/symbol.h               |    1
>  7 files changed, 114 insertions(+), 1 deletions(-)
>  create mode 100644 tools/perf/arch/x86/util/probe-event.c
>
> diff --git a/tools/perf/arch/x86/Makefile b/tools/perf/arch/x86/Makefile
> index 744e629..beec155 100644
> --- a/tools/perf/arch/x86/Makefile
> +++ b/tools/perf/arch/x86/Makefile
> @@ -1,5 +1,9 @@
> +BASIC_CFLAGS += -I. -I../../arch/$(ARCH)/include
>  ifndef NO_DWARF
>  PERF_HAVE_DWARF_REGS := 1
>  LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/dwarf-regs.o
>  endif
>  LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/header.o
> +LIB_OBJS += $(OUTPUT)arch/$(ARCH)/util/probe-event.o
> +LIB_OBJS += $(OUTPUT)../../arch/$(ARCH)/lib/inat.o
> +LIB_OBJS += $(OUTPUT)../../arch/$(ARCH)/lib/insn.o

No, this will just link a *kernel binary* into perf.
We'd better re-build binary for tools.

> diff --git a/tools/perf/arch/x86/util/probe-event.c
b/tools/perf/arch/x86/util/probe-event.c
> new file mode 100644
> index 0000000..7a47b22
> --- /dev/null
> +++ b/tools/perf/arch/x86/util/probe-event.c
> @@ -0,0 +1,83 @@
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
> + * Copyright (C) IBM Corporation, 2008-2011
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
> +
> +/*
> + * Check if a given offset from start of a function is valid or not
> + */
> +bool can_probe(char *name, unsigned long long vaddr, unsigned long offset,
> +		u8 class)
> +{
> +	unsigned long long eaddr, saddr;
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
> +	if (buf == NULL) {
> +		pr_warning("Failed to allocate memory");
> +		goto out;
> +	}
> +	fileoffset = lseek(fd, vaddr, SEEK_SET);
> +	if (fileoffset != vaddr) {
> +		pr_warning("Failed to lseek %s: %s\n", name, strerror(errno));
> +		goto out;
> +	}
> +	saddr = (unsigned long long)buf;
> +	eaddr = (unsigned long long)buf + offset;
> +	readbytes = read(fd, buf, offset + MAX_INSN_SIZE);
> +	if (readbytes != offset+16) {

Could you use MAX_INSN_SIZE instead of 16 here?

> +		pr_warning("Failed to read %s: %s\n", name, strerror(errno));
> +		goto out;
> +	}
> +	while (saddr < eaddr) {
> +		insn_init(&insn, (void *)saddr, class - 1);

Also, could you use "class == ELFCLASS64" instread of "class - 1" ?

> +		insn_get_length(&insn);
> +		saddr += insn.length;
> +	}
> +	ret = (saddr == eaddr);
> +
> +out:
> +	if (buf)
> +		free(buf);
> +
> +	if (fd)
> +		close(fd);
> +
> +	return ret;
> +}
> diff --git a/tools/perf/util/include/linux/string.h
b/tools/perf/util/include/linux/string.h
> index 3b2f590..9d5eb21 100644
> --- a/tools/perf/util/include/linux/string.h
> +++ b/tools/perf/util/include/linux/string.h
> @@ -1 +1,2 @@
>  #include <string.h>
> +#include <perf.h>
> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
> index b7dec82..a2dd0b5 100644
> --- a/tools/perf/util/probe-event.c
> +++ b/tools/perf/util/probe-event.c
> @@ -2254,6 +2254,17 @@ int show_available_funcs(const char *target, struct
strfilter *_filter,
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
> @@ -2307,7 +2318,16 @@ static int convert_name_to_addr(struct perf_probe_event
*pev, const char *exec)
>
>  	if (map->start > sym->start)
>  		vaddr = map->start;
> -	vaddr += sym->start + pp->offset + map->pgoff;
> +
> +	vaddr += sym->start + map->pgoff;
> +	if (pp->offset)
> +		if ((vaddr+pp->offset > sym->end) ||

"vaddr + pp->offset" here.

> +			!can_probe(name, vaddr, pp->offset,
> +					map->dso->class)) {
> +			pr_err("Failed to insert probe, ensure offset is within function and on
insn boundary.\n");
> +			return -EINVAL;
> +		}
> +	vaddr += pp->offset;
>  	pp->offset = 0;
>
>  	if (!pev->event) {
> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
> index f9f3de8..e89b1bf 100644
> --- a/tools/perf/util/probe-event.h
> +++ b/tools/perf/util/probe-event.h
> @@ -137,4 +137,6 @@ extern int show_available_funcs(const char *module, struct
strfilter *filter,
>  /* Maximum index number of event-name postfix */
>  #define MAX_EVENT_INDEX	1024
>
> +extern bool can_probe(char *name, unsigned long long vaddr,
> +			unsigned long offset, u8 type);

the last argument should be (elf)class, shouldn't it?

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com--
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
