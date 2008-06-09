Date: Mon, 9 Jun 2008 03:29:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/5] mm: introduce get_user_pages_fast
Message-Id: <20080609032928.e3270194.akpm@linux-foundation.org>
In-Reply-To: <20080529122602.208851000@nick.local0.net>
References: <20080529122050.823438000@nick.local0.net>
	<20080529122602.208851000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 May 2008 22:20:52 +1000 npiggin@suse.de wrote:

> Introduce a new get_user_pages_fast mm API, which is basically a get_user_pages
> with a less general API (but still tends to be suited to the common case):
> 
> - task and mm are always current and current->mm
> - force is always 0
> - pages is always non-NULL
> - don't pass back vmas
> 
> This restricted API can be implemented in a much more scalable way on
> many architectures when the ptes are present, by walking the page tables
> locklessly (no mmap_sem or page table locks). When the ptes are not
> populated, get_user_pages_fast() could be slower.
> 
> This is implemented locklessly on x86, and used in some key direct IO call
> sites, in later patches, which provides nearly 10% performance improvement
> on a threaded database workload.
> 
> Lots of other code could use this too, depending on use cases (eg. grep
> drivers/). And it might inspire some new and clever ways to use it.
> 
> ...
>
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -12,6 +12,7 @@
>  #include <linux/prio_tree.h>
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
> +#include <linux/uaccess.h> /* for __HAVE_ARCH_GET_USER_PAGES_FAST */
>  

That breaks ia64:

In file included from include/linux/mm.h:15,
                 from include/asm/uaccess.h:39,
                 from include/linux/poll.h:13,
                 from include/linux/rtc.h:113,
                 from include/linux/efi.h:19,
                 from include/asm/sal.h:40,
                 from include/asm-ia64/mca.h:20,
                 from arch/ia64/kernel/asm-offsets.c:17:
include/linux/uaccess.h: In function `__copy_from_user_inatomic_nocache':
include/linux/uaccess.h:46: error: implicit declaration of function `__copy_from_user_inatomic'
include/linux/uaccess.h: In function `__copy_from_user_nocache':
include/linux/uaccess.h:52: error: implicit declaration of function `__copy_from_user'


It shouldn't have been a __HAVE_ARCH_whatever anyway - it should have
been a CONFIG_whatever.

I'll fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
