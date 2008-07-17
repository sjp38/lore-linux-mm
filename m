Received: from chimera.site ([96.225.228.12]) by xenotime.net for <linux-mm@kvack.org>; Thu, 17 Jul 2008 14:34:34 -0700
Date: Thu, 17 Jul 2008 14:34:34 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-Id: <20080717143434.79b33fe9.rdunlap@xenotime.net>
In-Reply-To: <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
	<4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jul 2008 03:46:45 +0300 Eduard - Gabriel Munteanu wrote:

> kmemtrace provides tracing for slab allocator functions, such as kmalloc,
> kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
> to the userspace application in order to analyse allocation hotspots,
> internal fragmentation and so on, making it possible to see how well an
> allocator performs, as well as debug and profile kernel code.
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> ---
>  Documentation/kernel-parameters.txt |    6 +
>  Documentation/vm/kmemtrace.txt      |   96 ++++++++++++++++
>  MAINTAINERS                         |    6 +
>  include/linux/kmemtrace.h           |  110 ++++++++++++++++++
>  init/main.c                         |    2 +
>  lib/Kconfig.debug                   |    4 +
>  mm/Makefile                         |    2 +-
>  mm/kmemtrace.c                      |  208 +++++++++++++++++++++++++++++++++++
>  8 files changed, 433 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/vm/kmemtrace.txt
>  create mode 100644 include/linux/kmemtrace.h
>  create mode 100644 mm/kmemtrace.c
> 
> diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
> new file mode 100644
> index 0000000..1147ecb
> --- /dev/null
> +++ b/Documentation/vm/kmemtrace.txt

> +II. Quick usage guide
> +=====================
> +
> +1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
> +CONFIG_KMEMTRACE).
> +
> +2) Get the userspace tool and build it:
> +$ git-clone git://repo.or.cz/kmemtrace-user.git		# current repository
> +$ cd kmemtrace-user/
> +$ autoreconf
> +$ ./configure		# Supply KERNEL_SOURCES=/path/to/sources/ if you're
> +			# _not_ running this on a kmemtrace-enabled kernel.
> +$ make
> +
> +3) Boot the kmemtrace-enabled kernel if you haven't, preferably in the
> +'single' runlevel (so that relay buffers don't fill up easily), and run
> +kmemtrace:
> +# '$' does not mean user, but root here.
> +$ mount -t debugfs none /debug

Please mount at /sys/kernel/debug, i.e., the expected debugfs mount point.

> +$ mount -t proc none /proc
> +$ cd path/to/kmemtrace-user/
> +$ ./kmemtraced
> +Wait a bit, then stop it with CTRL+C.
> +$ cat /debug/kmemtrace/total_overruns	# Check if we didn't overrun, should
> +					# be zero.
> +$ (Optionally) [Run kmemtrace_check separately on each cpu[0-9]*.out file to
> +		check its correctness]
> +$ ./kmemtrace-report
> +
> +Now you should have a nice and short summary of how the allocator performs.


Otherwise looks nice.  Thanks.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
