Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080728162922.SFPG1572.tomts5-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 28 Jul 2008 12:29:22 -0400
Date: Mon, 28 Jul 2008 12:29:17 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080728162916.GD17823@Krystal>
References: <1216751808-14428-1-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-2-git-send-email-eduard.munteanu@linux360.ro> <1217237084.5998.5.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1217237084.5998.5.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

* Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> Hi,
> 
> [I'm cc'ing Mathieu if he wants to comment on this.]
> 
> On Tue, 2008-07-22 at 21:36 +0300, Eduard - Gabriel Munteanu wrote:
> > kmemtrace provides tracing for slab allocator functions, such as kmalloc,
> > kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
> > to the userspace application in order to analyse allocation hotspots,
> > internal fragmentation and so on, making it possible to see how well an
> > allocator performs, as well as debug and profile kernel code.
> 
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > ---
> >  Documentation/ABI/testing/debugfs-kmemtrace |   58 +++++++
> >  Documentation/kernel-parameters.txt         |   10 +
> >  Documentation/vm/kmemtrace.txt              |  126 ++++++++++++++
> >  MAINTAINERS                                 |    6 +
> >  include/linux/kmemtrace.h                   |  110 ++++++++++++
> >  init/main.c                                 |    2 +
> >  lib/Kconfig.debug                           |   28 +++
> >  mm/Makefile                                 |    2 +-
> >  mm/kmemtrace.c                              |  244 +++++++++++++++++++++++++++
> >  9 files changed, 585 insertions(+), 1 deletions(-)
> >  create mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
> >  create mode 100644 Documentation/vm/kmemtrace.txt
> >  create mode 100644 include/linux/kmemtrace.h
> >  create mode 100644 mm/kmemtrace.c
> > 
> > diff --git a/Documentation/ABI/testing/debugfs-kmemtrace b/Documentation/ABI/testing/debugfs-kmemtrace
> > new file mode 100644
> > index 0000000..466c2bb
> > --- /dev/null
> > +++ b/Documentation/ABI/testing/debugfs-kmemtrace

Documentation should probably come in a separate patch.

> > @@ -0,0 +1,58 @@
> > +What:		/sys/kernel/debug/kmemtrace/
> > +Date:		July 2008
> > +Contact:	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > +Description:
> > +
> > +In kmemtrace-enabled kernels, the following files are created:
> > +
> > +/sys/kernel/debug/kmemtrace/
> > +	cpu<n>		(0400)	Per-CPU tracing data, see below. (binary)
> > +	total_overruns	(0400)	Total number of bytes which were dropped from
> > +				cpu<n> files because of full buffer condition,
> > +				non-binary. (text)
> > +	abi_version	(0400)	Kernel's kmemtrace ABI version. (text)
> > +
> > +Each per-CPU file should be read according to the relay interface. That is,
> > +the reader should set affinity to that specific CPU and, as currently done by
> > +the userspace application (though there are other methods), use poll() with
> > +an infinite timeout before every read(). Otherwise, erroneous data may be
> > +read. The binary data has the following _core_ format:
> > +	Event id	(1 byte)	Unsigned integer, one of:
> > +		0 - erroneous event, this is illegal/invalid data and must
> > +		    not occur (KMEMTRACE_EVENT_NULL)

Hmm ? why record an invalid event ?? I see it's not used in the code, is
that actually used in some way because the memory is set to 0 ?


> > +		1 - represents an allocation (KMEMTRACE_EVENT_ALLOC)
> > +		2 - represents a freeing of previously allocated memory
> > +		    (KMEMTRACE_EVENT_FREE)
> > +	Type id		(1 byte)	Unsigned integer, one of:
> > +		0 - this is a kmalloc() / kfree()
> > +		1 - this is a kmem_cache_alloc() / kmem_cache_free()
> > +		2 - this is a __get_free_pages() et al.
> > +	Event size	(2 bytes)	Unsigned integer representing the
> > +					size of this event. Used to extend
> > +					kmemtrace. Discard the bytes you
> > +					don't know about.
> > +	Target CPU	(4 bytes)	Signed integer, valid for event id 1.
> > +					If equal to -1, target CPU is the same
> > +					as origin CPU, but the reverse might
> > +					not be true.

If only valid for event ID 1 and only in NUMA case, please don't waste
space in each event header and make that a event-specific field... ?

> > +	Caller address	(8 bytes)	Return address to the caller.

Not true on 32 bits machines. You are wasting 4 bytes on those archs.

> > +	Pointer to mem	(8 bytes)	Pointer to allocated memory, must not
> > +					be NULL.

Same here.

> > +	Requested bytes	(8 bytes)	Total number of requested bytes,
> > +					unsigned, must not be zero.

Same here.

> > +	Allocated bytes (8 bytes)	Total number of actually allocated
> > +					bytes, unsigned, must not be lower
> > +					than requested bytes.

And here.

> > +	Requested flags	(8 bytes)	GFP flags supplied by the caller.

8 bytes for GFP flags ?? Whoah, that's a lot of one-hot bits ! :) I knew
that some allocators were bloated, bit not that much. :)

> > +	Timestamp	(8 bytes)	Signed integer representing timestamp.
> > +

With a heartbeat, as lttng does, you can cut that to a 4 bytes field.

> > +The data is made available in the same endianness the machine has.
> > +

Using a magic number in the trace header lets you deal with
cross-endianness.

Saving the type sizes in the trace header lets you deal with different
int/long/pointer type sizes.

> > +Other event ids and type ids may be defined and added. Other fields may be
> > +added by increasing event size. Every modification to the ABI, including
> > +new id definitions, are followed by bumping the ABI version by one.
> > +

I personally prefer a self-describing trace :)

> > +
> > +Users:
> > +	kmemtrace-user - git://repo.or.cz/kmemtrace-user.git
> > +
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index b52f47d..446a257 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -49,6 +49,7 @@ parameter is applicable:
> >  	ISAPNP	ISA PnP code is enabled.
> >  	ISDN	Appropriate ISDN support is enabled.
> >  	JOY	Appropriate joystick support is enabled.
> > +	KMEMTRACE kmemtrace is enabled.
> >  	LIBATA  Libata driver is enabled
> >  	LP	Printer support is enabled.
> >  	LOOP	Loopback device support is enabled.
> > @@ -941,6 +942,15 @@ and is between 256 and 4096 characters. It is defined in the file
> >  			use the HighMem zone if it exists, and the Normal
> >  			zone if it does not.
> >  
> > +	kmemtrace.enable=	[KNL,KMEMTRACE] Format: { yes | no }
> > +				Controls whether kmemtrace is enabled
> > +				at boot-time.
> > +
> > +	kmemtrace.subbufs=n	[KNL,KMEMTRACE] Overrides the number of
> > +			subbufs kmemtrace's relay channel has. Set this
> > +			higher than default (KMEMTRACE_N_SUBBUFS in code) if
> > +			you experience buffer overruns.
> > +

That kind of stuff would be nice to have in lttng.

> >  	movablecore=nn[KMG]	[KNL,X86-32,IA-64,PPC,X86-64] This parameter
> >  			is similar to kernelcore except it specifies the
> >  			amount of memory used for migratable allocations.
> > diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
> > new file mode 100644
> > index 0000000..75360b1
> > --- /dev/null
> > +++ b/Documentation/vm/kmemtrace.txt
> > @@ -0,0 +1,126 @@
> > +			kmemtrace - Kernel Memory Tracer
> > +
> > +			  by Eduard - Gabriel Munteanu
> > +			     <eduard.munteanu@linux360.ro>
> > +
> > +I. Introduction
> > +===============
> > +
> > +kmemtrace helps kernel developers figure out two things:
> > +1) how different allocators (SLAB, SLUB etc.) perform
> > +2) how kernel code allocates memory and how much
> > +
> > +To do this, we trace every allocation and export information to the userspace
> > +through the relay interface. We export things such as the number of requested
> > +bytes, the number of bytes actually allocated (i.e. including internal
> > +fragmentation), whether this is a slab allocation or a plain kmalloc() and so
> > +on.
> > +
> > +The actual analysis is performed by a userspace tool (see section III for
> > +details on where to get it from). It logs the data exported by the kernel,
> > +processes it and (as of writing this) can provide the following information:
> > +- the total amount of memory allocated and fragmentation per call-site
> > +- the amount of memory allocated and fragmentation per allocation
> > +- total memory allocated and fragmentation in the collected dataset
> > +- number of cross-CPU allocation and frees (makes sense in NUMA environments)
> > +
> > +Moreover, it can potentially find inconsistent and erroneous behavior in
> > +kernel code, such as using slab free functions on kmalloc'ed memory or
> > +allocating less memory than requested (but not truly failed allocations).
> > +
> > +kmemtrace also makes provisions for tracing on some arch and analysing the
> > +data on another.
> > +
> > +II. Design and goals
> > +====================
> > +
> > +kmemtrace was designed to handle rather large amounts of data. Thus, it uses
> > +the relay interface to export whatever is logged to userspace, which then
> > +stores it. Analysis and reporting is done asynchronously, that is, after the
> > +data is collected and stored. By design, it allows one to log and analyse
> > +on different machines and different arches.
> > +
> > +As of writing this, the ABI is not considered stable, though it might not
> > +change much. However, no guarantees are made about compatibility yet. When
> > +deemed stable, the ABI should still allow easy extension while maintaining
> > +backward compatibility. This is described further in Documentation/ABI.
> > +
> > +Summary of design goals:
> > +	- allow logging and analysis to be done across different machines

Not currently true : cross-endianness/wastes space for 32 bits archs.

> > +	- be fast and anticipate usage in high-load environments (*)

LTTng will be faster though : per-cpu atomic ops instead of interrupt
disable makes the probe faster.

> > +	- be reasonably extensible

Automatic description of markers and dynamic assignation of IDs to
markers should provide a bit more flexibility here.


> > +	- make it possible for GNU/Linux distributions to have kmemtrace
> > +	included in their repositories
> > +
> > +(*) - one of the reasons Pekka Enberg's original userspace data analysis
> > +    tool's code was rewritten from Perl to C (although this is more than a
> > +    simple conversion)
> > +
> > +
> > +III. Quick usage guide
> > +======================
> > +
> > +1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
> > +CONFIG_KMEMTRACE and CONFIG_DEFAULT_ENABLED).
> > +
> > +2) Get the userspace tool and build it:
> > +$ git-clone git://repo.or.cz/kmemtrace-user.git		# current repository
> > +$ cd kmemtrace-user/
> > +$ ./autogen.sh
> > +$ ./configure
> > +$ make
> > +
> > +3) Boot the kmemtrace-enabled kernel if you haven't, preferably in the
> > +'single' runlevel (so that relay buffers don't fill up easily), and run
> > +kmemtrace:
> > +# '$' does not mean user, but root here.

Change the documentation to prefix a root command line by "#" instead of
leaving this weird comment.

> > +$ mount -t debugfs none /sys/kernel/debug
> > +$ mount -t proc none /proc
> > +$ cd path/to/kmemtrace-user/
> > +$ ./kmemtraced
> > +Wait a bit, then stop it with CTRL+C.
> > +$ cat /sys/kernel/debug/kmemtrace/total_overruns	# Check if we didn't
> > +							# overrun, should
> > +							# be zero.
> > +$ (Optionally) [Run kmemtrace_check separately on each cpu[0-9]*.out file to
> > +		check its correctness]
> > +$ ./kmemtrace-report
> > +
> > +Now you should have a nice and short summary of how the allocator performs.
> > +
> > +IV. FAQ and known issues
> > +========================
> > +
> > +Q: 'cat /sys/kernel/debug/kmemtrace/total_overruns' is non-zero, how do I fix
> > +this? Should I worry?
> > +A: If it's non-zero, this affects kmemtrace's accuracy, depending on how
> > +large the number is. You can fix it by supplying a higher
> > +'kmemtrace.subbufs=N' kernel parameter.
> > +---
> > +
> > +Q: kmemtrace_check reports errors, how do I fix this? Should I worry?
> > +A: This is a bug and should be reported. It can occur for a variety of
> > +reasons:
> > +	- possible bugs in relay code
> > +	- possible misuse of relay by kmemtrace
> > +	- timestamps being collected unorderly
> > +Or you may fix it yourself and send us a patch.
> > +---
> > +
> > +Q: kmemtrace_report shows many errors, how do I fix this? Should I worry?
> > +A: This is a known issue and I'm working on it. These might be true errors
> > +in kernel code, which may have inconsistent behavior (e.g. allocating memory
> > +with kmem_cache_alloc() and freeing it with kfree()). Pekka Enberg pointed
> > +out this behavior may work with SLAB, but may fail with other allocators.
> > +
> > +It may also be due to lack of tracing in some unusual allocator functions.
> > +
> > +We don't want bug reports regarding this issue yet.

What in the world can be causing that ? Shouldn't it be fixed ? It might
be due to unexpected allocator behavior, non-instrumented alloc/free
code or broken tracer....


> > +---
> > +
> > +V. See also
> > +===========
> > +
> > +Documentation/kernel-parameters.txt
> > +Documentation/ABI/testing/debugfs-kmemtrace
> > +
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 56a2f67..e967bc2 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -2425,6 +2425,12 @@ M:	jason.wessel@windriver.com
> >  L:	kgdb-bugreport@lists.sourceforge.net
> >  S:	Maintained
> >  
> > +KMEMTRACE
> > +P:	Eduard - Gabriel Munteanu
> > +M:	eduard.munteanu@linux360.ro
> > +L:	linux-kernel@vger.kernel.org
> > +S:	Maintained
> > +
> >  KPROBES
> >  P:	Ananth N Mavinakayanahalli
> >  M:	ananth@in.ibm.com
> > diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
> > new file mode 100644
> > index 0000000..48746ee
> > --- /dev/null
> > +++ b/include/linux/kmemtrace.h
> > @@ -0,0 +1,110 @@
> > +/*
> > + * Copyright (C) 2008 Eduard - Gabriel Munteanu
> > + *
> > + * This file is released under GPL version 2.
> > + */
> > +
> > +#ifndef _LINUX_KMEMTRACE_H
> > +#define _LINUX_KMEMTRACE_H
> > +
> > +#ifdef __KERNEL__
> > +
> > +#include <linux/types.h>
> > +#include <linux/marker.h>
> > +
> > +/* ABI definition starts here. */
> > +
> > +#define KMEMTRACE_ABI_VERSION		1
> > +
> > +enum kmemtrace_event_id {
> > +	KMEMTRACE_EVENT_NULL = 0,	/* Erroneous event. */
> > +	KMEMTRACE_EVENT_ALLOC,
> > +	KMEMTRACE_EVENT_FREE,
> > +};
> > +
> > +enum kmemtrace_type_id {
> > +	KMEMTRACE_TYPE_KMALLOC = 0,	/* kmalloc() / kfree(). */
> > +	KMEMTRACE_TYPE_CACHE,		/* kmem_cache_*(). */
> > +	KMEMTRACE_TYPE_PAGES,		/* __get_free_pages() and friends. */
> > +};
> > +
> > +struct kmemtrace_event {
> > +	u8		event_id;	/* Allocate or free? */
> > +	u8		type_id;	/* Kind of allocation/free. */
> > +	u16		event_size;	/* Size of event */
> > +	s32		node;		/* Target CPU. */
> > +	u64		call_site;	/* Caller address. */
> > +	u64		ptr;		/* Pointer to allocation. */
> > +	u64		bytes_req;	/* Number of bytes requested. */
> > +	u64		bytes_alloc;	/* Number of bytes allocated. */
> > +	u64		gfp_flags;	/* Requested flags. */
> > +	s64		timestamp;	/* When the operation occured in ns. */
> > +} __attribute__ ((__packed__));
> > +

See below for detail, but this event record is way too big and not
adapted to 32 bits architectures.

> > +/* End of ABI definition. */
> > +
> > +#ifdef CONFIG_KMEMTRACE
> > +
> > +extern void kmemtrace_init(void);
> > +
> > +static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
> > +					     unsigned long call_site,
> > +					     const void *ptr,
> > +					     size_t bytes_req,
> > +					     size_t bytes_alloc,
> > +					     gfp_t gfp_flags,
> > +					     int node)
> > +{
> > +	trace_mark(kmemtrace_alloc, "type_id %d call_site %lu ptr %lu "
> > +		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
> > +		   type_id, call_site, (unsigned long) ptr,
> > +		   bytes_req, bytes_alloc, (unsigned long) gfp_flags, node);
> > +}
> > +
> > +static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_id,
> > +				       unsigned long call_site,
> > +				       const void *ptr)
> > +{
> > +	trace_mark(kmemtrace_free, "type_id %d call_site %lu ptr %lu",
> > +		   type_id, call_site, (unsigned long) ptr);
> > +}

This could be trivially turned into a tracepoint probe.

> > +
> > +#else /* CONFIG_KMEMTRACE */
> > +
> > +static inline void kmemtrace_init(void)
> > +{
> > +}
> > +
> > +static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
> > +					     unsigned long call_site,
> > +					     const void *ptr,
> > +					     size_t bytes_req,
> > +					     size_t bytes_alloc,
> > +					     gfp_t gfp_flags,
> > +					     int node)
> > +{
> > +}
> > +
> > +static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_id,
> > +				       unsigned long call_site,
> > +				       const void *ptr)
> > +{
> > +}
> > +
> > +#endif /* CONFIG_KMEMTRACE */
> > +
> > +static inline void kmemtrace_mark_alloc(enum kmemtrace_type_id type_id,
> > +					unsigned long call_site,
> > +					const void *ptr,
> > +					size_t bytes_req,
> > +					size_t bytes_alloc,
> > +					gfp_t gfp_flags)
> > +{
> > +	kmemtrace_mark_alloc_node(type_id, call_site, ptr,
> > +				  bytes_req, bytes_alloc, gfp_flags, -1);
> > +}
> > +
> > +#endif /* __KERNEL__ */
> > +
> > +#endif /* _LINUX_KMEMTRACE_H */
> > +
> > diff --git a/init/main.c b/init/main.c
> > index 057f364..c00659c 100644
> > --- a/init/main.c
> > +++ b/init/main.c
> > @@ -66,6 +66,7 @@
> >  #include <asm/setup.h>
> >  #include <asm/sections.h>
> >  #include <asm/cacheflush.h>
> > +#include <linux/kmemtrace.h>
> >  
> >  #ifdef CONFIG_X86_LOCAL_APIC
> >  #include <asm/smp.h>
> > @@ -641,6 +642,7 @@ asmlinkage void __init start_kernel(void)
> >  	enable_debug_pagealloc();
> >  	cpu_hotplug_init();
> >  	kmem_cache_init();
> > +	kmemtrace_init();
> >  	debug_objects_mem_init();
> >  	idr_init_cache();
> >  	setup_per_cpu_pageset();
> > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > index d2099f4..0ade2ae 100644
> > --- a/lib/Kconfig.debug
> > +++ b/lib/Kconfig.debug
> > @@ -674,6 +674,34 @@ config FIREWIRE_OHCI_REMOTE_DMA
> >  
> >  	  If unsure, say N.
> >  
> > +config KMEMTRACE
> > +	bool "Kernel memory tracer (kmemtrace)"
> > +	depends on RELAY && DEBUG_FS && MARKERS
> > +	help
> > +	  kmemtrace provides tracing for slab allocator functions, such as
> > +	  kmalloc, kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected
> > +	  data is then fed to the userspace application in order to analyse
> > +	  allocation hotspots, internal fragmentation and so on, making it
> > +	  possible to see how well an allocator performs, as well as debug
> > +	  and profile kernel code.
> > +
> > +	  This requires an userspace application to use. See
> > +	  Documentation/vm/kmemtrace.txt for more information.
> > +
> > +	  Saying Y will make the kernel somewhat larger and slower. However,
> > +	  if you disable kmemtrace at run-time or boot-time, the performance
> > +	  impact is minimal (depending on the arch the kernel is built for).
> > +
> > +	  If unsure, say N.
> > +
> > +config KMEMTRACE_DEFAULT_ENABLED
> > +	bool "Enabled by default at boot"
> > +	depends on KMEMTRACE
> > +	help
> > +	  Say Y here to enable kmemtrace at boot-time by default. Whatever
> > +	  the choice, the behavior can be overridden by a kernel parameter,
> > +	  as described in documentation.
> > +
> >  source "samples/Kconfig"
> >  
> >  source "lib/Kconfig.kgdb"
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 18c143b..d88a3bc 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> > @@ -33,4 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
> >  obj-$(CONFIG_SMP) += allocpercpu.o
> >  obj-$(CONFIG_QUICKLIST) += quicklist.o
> >  obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
> > -
> > +obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
> > diff --git a/mm/kmemtrace.c b/mm/kmemtrace.c
> > new file mode 100644
> > index 0000000..4b33ace
> > --- /dev/null
> > +++ b/mm/kmemtrace.c
> > @@ -0,0 +1,244 @@
> > +/*
> > + * Copyright (C) 2008 Pekka Enberg, Eduard - Gabriel Munteanu
> > + *
> > + * This file is released under GPL version 2.
> > + */
> > +
> > +#include <linux/string.h>
> > +#include <linux/debugfs.h>
> > +#include <linux/relay.h>
> > +#include <linux/module.h>
> > +#include <linux/marker.h>
> > +#include <linux/gfp.h>
> > +#include <linux/kmemtrace.h>
> > +
> > +#define KMEMTRACE_SUBBUF_SIZE	(8192 * sizeof(struct kmemtrace_event))
> > +#define KMEMTRACE_N_SUBBUFS	20
> > +

Isn't this overridable by a command line param ? Shouldn't it be called
"DEFAULT_KMEMTRACE_*" then ?

> > +static struct rchan *kmemtrace_chan;
> > +static u32 kmemtrace_buf_overruns;
> > +
> > +static unsigned int kmemtrace_n_subbufs;
> > +#ifdef CONFIG_KMEMTRACE_DEFAULT_ENABLED
> > +static unsigned int kmemtrace_enabled = 1;
> > +#else
> > +static unsigned int kmemtrace_enabled = 0;
> > +#endif

Hrm, I'd leave that as a kernel command line option, not config option.
If you ever want to _aways_ have it on, then change your lilo/grub file.

> > +
> > +static u32 kmemtrace_abi_version __read_mostly = KMEMTRACE_ABI_VERSION;
> > +
> > +static inline void kmemtrace_log_event(struct kmemtrace_event *event)
> > +{
> > +	relay_write(kmemtrace_chan, event, sizeof(struct kmemtrace_event));
> > +}
> > +
> > +static void kmemtrace_probe_alloc(void *probe_data, void *call_data,
> > +				  const char *format, va_list *args)
> > +{
> > +	unsigned long flags;
> > +	struct kmemtrace_event ev;
> > +
> > +	/*
> > +	 * Don't convert this to use structure initializers,
> > +	 * C99 does not guarantee the rvalues evaluation order.
> > +	 */
> > +	ev.event_id = KMEMTRACE_EVENT_ALLOC;
> > +	ev.type_id = va_arg(*args, int);
> > +	ev.event_size = sizeof(struct kmemtrace_event);
> > +	ev.call_site = va_arg(*args, unsigned long);
> > +	ev.ptr = va_arg(*args, unsigned long);

Argh, and you do a supplementary copy here. You could simply alias the
buffers and write directly to them after reserving the correct amount of
space.

> > +	/* Don't trace ignored allocations. */
> > +	if (!ev.ptr)
> > +		return;
> > +	ev.bytes_req = va_arg(*args, unsigned long);
> > +	ev.bytes_alloc = va_arg(*args, unsigned long);
> > +	/* ev.timestamp set below, to preserve event ordering. */
> > +	ev.gfp_flags = va_arg(*args, unsigned long);
> > +	ev.node = va_arg(*args, int);
> > +
> > +	/* We disable IRQs for timestamps to match event ordering. */
> > +	local_irq_save(flags);
> > +	ev.timestamp = ktime_to_ns(ktime_get());

ktime_get is monotonic, but with potentially coarse granularity. I see
that you use ktime_to_ns here, which gives you a resolution of 1 timer
tick in the case where the TSCs are not synchronized. While it should be
"good enough" for the scheduler, I doubt it's enough for a tracer.

It also takes the xtime seqlock, which adds a potentially big delay to
the tracing code (if you read the clock while the writer lock is taken).

Also, when NTP modifies the clock, although it stays monotonic, the rate
at which it increments can dramatically change. I doubt you want to use
that as a reference for performance analysis.


> > +	kmemtrace_log_event(&ev);
> > +	local_irq_restore(flags);
> > +}
> > +
> > +static void kmemtrace_probe_free(void *probe_data, void *call_data,
> > +				 const char *format, va_list *args)
> > +{
> > +	unsigned long flags;
> > +	struct kmemtrace_event ev;
> > +
> > +	/*
> > +	 * Don't convert this to use structure initializers,
> > +	 * C99 does not guarantee the rvalues evaluation order.
> > +	 */
> > +	ev.event_id = KMEMTRACE_EVENT_FREE;
> > +	ev.type_id = va_arg(*args, int);
> > +	ev.event_size = sizeof(struct kmemtrace_event);
> > +	ev.call_site = va_arg(*args, unsigned long);
> > +	ev.ptr = va_arg(*args, unsigned long);
> > +	/* Don't trace ignored allocations. */
> > +	if (!ev.ptr)
> > +		return;
> > +	/* ev.timestamp set below, to preserve event ordering. */
> > +
> > +	/* We disable IRQs for timestamps to match event ordering. */
> > +	local_irq_save(flags);
> > +	ev.timestamp = ktime_to_ns(ktime_get());
> > +	kmemtrace_log_event(&ev);
> > +	local_irq_restore(flags);
> > +}
> > +
> > +static struct dentry *
> > +kmemtrace_create_buf_file(const char *filename, struct dentry *parent,
> > +			  int mode, struct rchan_buf *buf, int *is_global)
> > +{
> > +	return debugfs_create_file(filename, mode, parent, buf,
> > +				   &relay_file_operations);
> > +}
> > +
> > +static int kmemtrace_remove_buf_file(struct dentry *dentry)
> > +{
> > +	debugfs_remove(dentry);
> > +
> > +	return 0;
> > +}
> > +
> > +static int kmemtrace_count_overruns(struct rchan_buf *buf,
> > +				    void *subbuf, void *prev_subbuf,
> > +				    size_t prev_padding)
> > +{
> > +	if (relay_buf_full(buf)) {
> > +		/*
> > +		 * We know it's not SMP-safe, but neither
> > +		 * debugfs_create_u32() is.
> > +		 */
> > +		kmemtrace_buf_overruns++;
> > +		return 0;
> > +	}
> > +
> > +	return 1;
> > +}
> > +
> > +static struct rchan_callbacks relay_callbacks = {
> > +	.create_buf_file = kmemtrace_create_buf_file,
> > +	.remove_buf_file = kmemtrace_remove_buf_file,
> > +	.subbuf_start = kmemtrace_count_overruns,
> > +};
> > +
> > +static struct dentry *kmemtrace_dir;
> > +static struct dentry *kmemtrace_overruns_dentry;
> > +static struct dentry *kmemtrace_abi_version_dentry;
> > +
> > +static void kmemtrace_cleanup(void)
> > +{
> > +	marker_probe_unregister("kmemtrace_alloc", kmemtrace_probe_alloc, NULL);
> > +	marker_probe_unregister("kmemtrace_free", kmemtrace_probe_free, NULL);
> > +
> > +	if (kmemtrace_abi_version_dentry)
> > +		debugfs_remove(kmemtrace_abi_version_dentry);
> > +	if (kmemtrace_overruns_dentry)
> > +		debugfs_remove(kmemtrace_overruns_dentry);
> > +
> > +	relay_close(kmemtrace_chan);
> > +	kmemtrace_chan = NULL;
> > +
> > +	if (kmemtrace_dir)
> > +		debugfs_remove(kmemtrace_dir);
> > +}
> > +
> > +static int __init kmemtrace_setup_late(void)
> > +{
> > +	if (!kmemtrace_chan)
> > +		goto failed;
> > +
> > +	kmemtrace_dir = debugfs_create_dir("kmemtrace", NULL);
> > +	if (!kmemtrace_dir)
> > +		goto cleanup;
> > +
> > +	kmemtrace_abi_version_dentry =
> > +		debugfs_create_u32("abi_version", S_IRUSR,
> > +				   kmemtrace_dir, &kmemtrace_abi_version);
> > +	kmemtrace_overruns_dentry =
> > +		debugfs_create_u32("total_overruns", S_IRUSR,
> > +				   kmemtrace_dir, &kmemtrace_buf_overruns);
> > +	if (!kmemtrace_overruns_dentry || !kmemtrace_abi_version_dentry)
> > +		goto cleanup;
> > +
> > +	if (relay_late_setup_files(kmemtrace_chan, "cpu", kmemtrace_dir))
> > +		goto cleanup;
> > +
> > +	printk(KERN_INFO "kmemtrace: fully up.\n");
> > +
> > +	return 0;
> > +
> > +cleanup:
> > +	kmemtrace_cleanup();
> > +failed:
> > +	return 1;
> > +}
> > +late_initcall(kmemtrace_setup_late);
> > +
> > +static int __init kmemtrace_set_boot_enabled(char *str)
> > +{
> > +	if (!str)
> > +		return -EINVAL;
> > +
> > +	if (!strcmp(str, "yes"))

I think the standard is to use =0, =1 here, not =yes, =no ?

Mathieu

> > +		kmemtrace_enabled = 1;
> > +	else if (!strcmp(str, "no"))
> > +		kmemtrace_enabled = 0;
> > +	else
> > +		return -EINVAL;
> > +
> > +	return 0;
> > +}
> > +early_param("kmemtrace.enable", kmemtrace_set_boot_enabled);
> > +
> > +static int __init kmemtrace_set_subbufs(char *str)
> > +{
> > +	get_option(&str, &kmemtrace_n_subbufs);
> > +	return 0;
> > +}
> > +early_param("kmemtrace.subbufs", kmemtrace_set_subbufs);
> > +
> > +void kmemtrace_init(void)
> > +{
> > +	int err;
> > +
> > +	if (!kmemtrace_enabled)
> > +		return;
> > +
> > +	if (!kmemtrace_n_subbufs)
> > +		kmemtrace_n_subbufs = KMEMTRACE_N_SUBBUFS;
> > +
> > +	kmemtrace_chan = relay_open(NULL, NULL, KMEMTRACE_SUBBUF_SIZE,
> > +				    kmemtrace_n_subbufs, &relay_callbacks,
> > +				    NULL);
> > +	if (!kmemtrace_chan) {
> > +		printk(KERN_INFO "kmemtrace: could not open relay channel\n");
> > +		return;
> > +	}
> > +
> > +	err = marker_probe_register("kmemtrace_alloc", "type_id %d "
> > +				    "call_site %lu ptr %lu "
> > +				    "bytes_req %lu bytes_alloc %lu "
> > +				    "gfp_flags %lu node %d",
> > +				    kmemtrace_probe_alloc, NULL);
> > +	if (err)
> > +		goto probe_fail;
> > +	err = marker_probe_register("kmemtrace_free", "type_id %d "
> > +				    "call_site %lu ptr %lu",
> > +				    kmemtrace_probe_free, NULL);
> > +	if (err)
> > +		goto probe_fail;
> > +
> > +	printk(KERN_INFO "kmemtrace: early init successful.\n");
> > +	return;
> > +
> > +probe_fail:
> > +	printk(KERN_INFO "kmemtrace: could not register marker probes!\n");
> > +	kmemtrace_cleanup();
> > +}
> > +
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
