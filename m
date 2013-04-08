Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0F0006B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 18:14:45 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so430920pbc.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 15:14:45 -0700 (PDT)
Date: Mon, 8 Apr 2013 17:00:40 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if
 memory is added or removed
Message-ID: <20130408210039.GA3396@localhost.localdomain>
References: <20130408190738.GC2321@localhost.localdomain>
 <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, Apr 08, 2013 at 01:37:12PM -0700, Andrew Morton wrote:
> On Mon, 8 Apr 2013 15:07:38 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:
> 
> > This patch alters the admin and user reserves of the previous patches 
> > in this series when memory is added or removed.
> > 
> > If memory is added and the reserves have been eliminated or increased above
> > the default max, then we'll trust the admin.
> > 
> > If memory is removed and there isn't enough free memory, then we
> > need to reset the reserves.
> > 
> > Otherwise keep the reserve set by the admin.
> > 
> > The reserve reset code is the same as the reserve initialization code.
> > 
> > Does this sound reasonable to other people? I figured that hot removal
> > with too large of memory in the reserves was the most important case 
> > to get right.
> 
> Seems reasonable to me.
> 
> I don't understand the magic numbers 1<<13 and 1<<17.  How could I? 
> Please add comments explaining how and why these were chosen.

I'm preparing a new version with this and the other changes you 
gave me. Thank you!

Should I add the memory notifier code to mm/nommu.c too?
I'm guessing that if a system doesn't have an mmu that it also 
won't be hotplugging memory.

> Your patch adds 400 bytes of unusable code to the
> CONFIG_MEMORY_HOTPLUG=n kernel.  We have a fix for that in the CPU
> hotplug case: register_hotcpu_notifier().  Memory hotplug has its own
> hotplug_memory_notifier() but a) it's broken and b) it just doesn't
> work!  With my gcc-4.4.4, the unused functions are still included in
> the .o file.
> 
> So I did this:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: include/linux/memory.h: implement register_hotmemory_notifier()
> 
> When CONFIG_MEMORY_HOTPLUG=n, we don't want the memory-hotplug notifier
> handlers to be included in the .o files, for space reasons.
> 
> The existing hotplug_memory_notifier() tries to handle this but testing
> with gcc-4.4.4 shows that it doesn't work - the hotplug functions are
> still present in the .o files.
> 
> So implement a new register_hotmemory_notifier() which is a copy of
> register_hotcpu_notifier(), and which actually works as desired. 
> hotplug_memory_notifier() and register_memory_notifier() callsites should
> be converted to use this new register_hotmemory_notifier().
> 
> While we're there, let's repair the existing hotplug_memory_notifier(): it
> simply stomps on the register_memory_notifier() return value, so
> well-behaved code cannot check for errors.  Apparently non of the existing
> callers were well-behaved :(
> 
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/memory.h   |   15 ++++++++++++---
>  include/linux/notifier.h |    5 ++++-
>  2 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff -puN include/linux/memory.h~include-linux-memoryh-implement-register_hotmemory_notifier include/linux/memory.h
> --- a/include/linux/memory.h~include-linux-memoryh-implement-register_hotmemory_notifier
> +++ a/include/linux/memory.h
> @@ -18,6 +18,7 @@
>  #include <linux/node.h>
>  #include <linux/compiler.h>
>  #include <linux/mutex.h>
> +#include <linux/notifier.h>
>  
>  #define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
>  
> @@ -127,13 +128,21 @@ enum mem_add_context { BOOT, HOTPLUG };
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -#define hotplug_memory_notifier(fn, pri) {			\
> +#define hotplug_memory_notifier(fn, pri) ({			\
>  	static __meminitdata struct notifier_block fn##_mem_nb =\
>  		{ .notifier_call = fn, .priority = pri };	\
>  	register_memory_notifier(&fn##_mem_nb);			\
> -}
> +})
> +#define register_hotmemory_notifier(nb)		register_memory_notifier(nb)
> +#define unregister_hotmemory_notifier(nb) 	unregister_memory_notifier(nb)
>  #else
> -#define hotplug_memory_notifier(fn, pri) do { } while (0)
> +static inline int hotplug_memory_notifier(notifier_fn_t fn, int priority)
> +{
> +	return 0;
> +}
> +/* These aren't inline functions due to a GCC bug. */
> +#define register_hotmemory_notifier(nb)    ({ (void)(nb); 0; })
> +#define unregister_hotmemory_notifier(nb)  ({ (void)(nb); })
>  #endif
>  
>  /*
> diff -puN include/linux/notifier.h~include-linux-memoryh-implement-register_hotmemory_notifier include/linux/notifier.h
> --- a/include/linux/notifier.h~include-linux-memoryh-implement-register_hotmemory_notifier
> +++ a/include/linux/notifier.h
> @@ -47,8 +47,11 @@
>   * runtime initialization.
>   */
>  
> +typedef	int (*notifier_fn_t)(struct notifier_block *nb,
> +			unsigned long action, void *data);
> +
>  struct notifier_block {
> -	int (*notifier_call)(struct notifier_block *, unsigned long, void *);
> +	notifier_fn_t notifier_call;
>  	struct notifier_block __rcu *next;
>  	int priority;
>  };
> _
> 
> 
> And then I changed your patch thusly:
> 
> --- a/mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix
> +++ a/mm/mmap.c
> @@ -3198,7 +3198,7 @@ static struct notifier_block reserve_mem
>  
>  int __meminit init_reserve_notifier(void)
>  {
> -	if (register_memory_notifier(&reserve_mem_nb))
> +	if (register_hotmemory_notifier(&reserve_mem_nb))
>  		printk("Failed registering memory add/remove notifier for admin reserve");
>  
>  	return 0;
> _
> 
> and voila, no more bloat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
