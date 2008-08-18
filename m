Date: Mon, 18 Aug 2008 12:57:44 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2/5] kmemtrace: Additional documentation.
Message-Id: <20080818125744.b4fdc958.randy.dunlap@oracle.com>
In-Reply-To: <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>
	<1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>
	<1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, mathieu.desnoyers@polymtl.ca, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Sun, 10 Aug 2008 20:14:04 +0300 Eduard - Gabriel Munteanu wrote:

> Documented kmemtrace's ABI, purpose and design. Also includes a short
> usage guide, FAQ, as well as a link to the userspace application's Git
> repository, which is currently hosted at repo.or.cz.
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> ---
>  Documentation/ABI/testing/debugfs-kmemtrace |   71 +++++++++++++++
>  Documentation/vm/kmemtrace.txt              |  126 +++++++++++++++++++++++++++
>  2 files changed, 197 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
>  create mode 100644 Documentation/vm/kmemtrace.txt
> 
> diff --git a/Documentation/ABI/testing/debugfs-kmemtrace b/Documentation/ABI/testing/debugfs-kmemtrace
> new file mode 100644
> index 0000000..a5ff9a6
> --- /dev/null
> +++ b/Documentation/ABI/testing/debugfs-kmemtrace
> @@ -0,0 +1,71 @@
> +What:		/sys/kernel/debug/kmemtrace/
> +Date:		July 2008
> +Contact:	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> +Description:
> +
> +In kmemtrace-enabled kernels, the following files are created:
> +
> +/sys/kernel/debug/kmemtrace/
> +	cpu<n>		(0400)	Per-CPU tracing data, see below. (binary)
> +	total_overruns	(0400)	Total number of bytes which were dropped from
> +				cpu<n> files because of full buffer condition,
> +				non-binary. (text)
> +	abi_version	(0400)	Kernel's kmemtrace ABI version. (text)
> +
> +Each per-CPU file should be read according to the relay interface. That is,
> +the reader should set affinity to that specific CPU and, as currently done by
> +the userspace application (though there are other methods), use poll() with
> +an infinite timeout before every read(). Otherwise, erroneous data may be
> +read. The binary data has the following _core_ format:
> +
> +	Event ID	(1 byte)	Unsigned integer, one of:
> +		0 - represents an allocation (KMEMTRACE_EVENT_ALLOC)
> +		1 - represents a freeing of previously allocated memory
> +		    (KMEMTRACE_EVENT_FREE)
> +	Type ID		(1 byte)	Unsigned integer, one of:
> +		0 - this is a kmalloc() / kfree()
> +		1 - this is a kmem_cache_alloc() / kmem_cache_free()
> +		2 - this is a __get_free_pages() et al.
> +	Event size	(2 bytes)	Unsigned integer representing the
> +					size of this event. Used to extend
> +					kmemtrace. Discard the bytes you
> +					don't know about.
> +	Sequence number	(4 bytes)	Signed integer used to reorder data
> +					logged on SMP machines. Wraparound
> +					must be taken into account, although
> +					it is unlikely.
> +	Caller address	(8 bytes)	Return address to the caller.
> +	Pointer to mem	(8 bytes)	Pointer to target memory area. Can be
> +					NULL, but not all such calls might be
> +					recorded.
> +
> +In case of KMEMTRACE_EVENT_ALLOC events, the next fields follow:
> +
> +	Requested bytes	(8 bytes)	Total number of requested bytes,
> +					unsigned, must not be zero.
> +	Allocated bytes (8 bytes)	Total number of actually allocated
> +					bytes, unsigned, must not be lower
> +					than requested bytes.
> +	Requested flags	(4 bytes)	GFP flags supplied by the caller.
> +	Target CPU	(4 bytes)	Signed integer, valid for event id 1.
> +					If equal to -1, target CPU is the same
> +					as origin CPU, but the reverse might
> +					not be true.
> +
> +The data is made available in the same endianness the machine has.
> +
> +Other event ids and type ids may be defined and added. Other fields may be
> +added by increasing event size, but see below for details.
> +Every modification to the ABI, including new id definitions, are followed
> +by bumping the ABI version by one.
> +
> +Adding new data to the packet (features) is done at the end of the mandatory
> +data:
> +	Feature size	(2 byte)
> +	Feature ID	(1 byte)
> +	Feature data	(Feature size - 4 bytes)

Why is this "- 4 bytes"?  Is there an implied alignment byte somewhere in the
features "struct"?  How about making it explicit?


> +
> +
> +Users:
> +	kmemtrace-user - git://repo.or.cz/kmemtrace-user.git
> +
> diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
> new file mode 100644
> index 0000000..75360b1
> --- /dev/null
> +++ b/Documentation/vm/kmemtrace.txt
> @@ -0,0 +1,126 @@
> +			kmemtrace - Kernel Memory Tracer
> +
> +			  by Eduard - Gabriel Munteanu
> +			     <eduard.munteanu@linux360.ro>
> +
> +I. Introduction
> +===============
> +
> +kmemtrace helps kernel developers figure out two things:
> +1) how different allocators (SLAB, SLUB etc.) perform
> +2) how kernel code allocates memory and how much
> +
> +To do this, we trace every allocation and export information to the userspace
> +through the relay interface. We export things such as the number of requested
> +bytes, the number of bytes actually allocated (i.e. including internal
> +fragmentation), whether this is a slab allocation or a plain kmalloc() and so
> +on.
> +
> +The actual analysis is performed by a userspace tool (see section III for
> +details on where to get it from). It logs the data exported by the kernel,
> +processes it and (as of writing this) can provide the following information:
> +- the total amount of memory allocated and fragmentation per call-site
> +- the amount of memory allocated and fragmentation per allocation
> +- total memory allocated and fragmentation in the collected dataset
> +- number of cross-CPU allocation and frees (makes sense in NUMA environments)
> +
> +Moreover, it can potentially find inconsistent and erroneous behavior in
> +kernel code, such as using slab free functions on kmalloc'ed memory or
> +allocating less memory than requested (but not truly failed allocations).
> +
> +kmemtrace also makes provisions for tracing on some arch and analysing the
> +data on another.
> +
> +II. Design and goals
> +====================
> +
> +kmemtrace was designed to handle rather large amounts of data. Thus, it uses
> +the relay interface to export whatever is logged to userspace, which then
> +stores it. Analysis and reporting is done asynchronously, that is, after the
> +data is collected and stored. By design, it allows one to log and analyse
> +on different machines and different arches.
> +
> +As of writing this, the ABI is not considered stable, though it might not
> +change much. However, no guarantees are made about compatibility yet. When
> +deemed stable, the ABI should still allow easy extension while maintaining
> +backward compatibility. This is described further in Documentation/ABI.
> +
> +Summary of design goals:
> +	- allow logging and analysis to be done across different machines
> +	- be fast and anticipate usage in high-load environments (*)
> +	- be reasonably extensible
> +	- make it possible for GNU/Linux distributions to have kmemtrace
> +	included in their repositories
> +
> +(*) - one of the reasons Pekka Enberg's original userspace data analysis
> +    tool's code was rewritten from Perl to C (although this is more than a
> +    simple conversion)
> +
> +
> +III. Quick usage guide
> +======================
> +
> +1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
> +CONFIG_KMEMTRACE and CONFIG_DEFAULT_ENABLED).

                        CONFIG_KMEMTRACE_DEFAULT_ENABLED

> +
> +2) Get the userspace tool and build it:

...


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
