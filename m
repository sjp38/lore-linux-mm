Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id DE5546B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 22:25:42 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so14763864qcy.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 19:25:42 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.230])
        by mx.google.com with ESMTP id f199si709719qhc.20.2015.05.06.19.25.40
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 19:25:41 -0700 (PDT)
Date: Wed, 6 May 2015 22:25:51 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 3/3] tracing: add trace event for memory-failure
Message-ID: <20150506222551.56108f53@grimm.local.home>
In-Reply-To: <1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
	<1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, mingo@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, koct9i@gmail.com, hpa@linux.intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@amacapital.net, nasa4836@gmail.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On Mon, 20 Apr 2015 16:44:40 +0800
Xie XiuQi <xiexiuqi@huawei.com> wrote:

> --- a/include/ras/ras_event.h
> +++ b/include/ras/ras_event.h
> @@ -11,6 +11,7 @@
>  #include <linux/pci.h>
>  #include <linux/aer.h>
>  #include <linux/cper.h>
> +#include <linux/mm.h>
>  
>  /*
>   * MCE Extended Error Log trace event
> @@ -232,6 +233,90 @@ TRACE_EVENT(aer_event,
>  		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
>  );
>  
> +/*
> + * memory-failure recovery action result event
> + *
> + * unsigned long pfn -	Page Frame Number of the corrupted page
> + * int type	-	Page types of the corrupted page
> + * int result	-	Result of recovery action
> + */
> +
> +#ifdef CONFIG_MEMORY_FAILURE
> +#define MF_ACTION_RESULT	\
> +	EM ( MF_IGNORED, "Ignord" )	\

 "Ignored" ?

> +	EM ( MF_FAILED,  "Failed" )	\
> +	EM ( MF_DELAYED, "Delayed" )	\
> +	EMe ( MF_RECOVERED, "Recovered" )
> +
> +#define MF_PAGE_TYPE		\
> +	EM ( MF_MSG_KERNEL, "reserved kernel page" )			\
> +	EM ( MF_MSG_KERNEL_HIGH_ORDER, "high-order kernel page" )	\
> +	EM ( MF_MSG_SLAB, "kernel slab page" )				\
> +	EM ( MF_MSG_DIFFERENT_COMPOUND, "different compound page after locking" ) \
> +	EM ( MF_MSG_POISONED_HUGE, "huge page already hardware poisoned" )	\
> +	EM ( MF_MSG_HUGE, "huge page" )					\
> +	EM ( MF_MSG_FREE_HUGE, "free huge page" )			\
> +	EM ( MF_MSG_UNMAP_FAILED, "unmapping failed page" )		\
> +	EM ( MF_MSG_DIRTY_SWAPCACHE, "dirty swapcache page" )		\
> +	EM ( MF_MSG_CLEAN_SWAPCACHE, "clean swapcache page" )		\
> +	EM ( MF_MSG_DIRTY_MLOCKED_LRU, "dirty mlocked LRU page" )	\
> +	EM ( MF_MSG_CLEAN_MLOCKED_LRU, "clean mlocked LRU page" )	\
> +	EM ( MF_MSG_DIRTY_UNEVICTABLE_LRU, "dirty unevictable LRU page" )	\
> +	EM ( MF_MSG_CLEAN_UNEVICTABLE_LRU, "clean unevictable LRU page" )	\
> +	EM ( MF_MSG_DIRTY_LRU, "dirty LRU page" )			\
> +	EM ( MF_MSG_CLEAN_LRU, "clean LRU page" )			\
> +	EM ( MF_MSG_TRUNCATED_LRU, "already truncated LRU page" )	\
> +	EM ( MF_MSG_BUDDY, "free buddy page" )				\
> +	EM ( MF_MSG_BUDDY_2ND, "free buddy page (2nd try)" )		\
> +	EMe ( MF_MSG_UNKNOWN, "unknown page" )
> +
> +/*
> + * First define the enums in MM_ACTION_RESULT to be exported to userspace
> + * via TRACE_DEFINE_ENUM().
> + */
> +#undef EM
> +#undef EMe
> +#define EM(a,b) TRACE_DEFINE_ENUM(a);
> +#define EMe(a,b)	TRACE_DEFINE_ENUM(a);
> +
> +MF_ACTION_RESULT
> +MF_PAGE_TYPE
> +
> +/*
> + * Now redefine the EM() and EMe() macros to map the enums to the strings
> + * that will be printed in the output.
> + */
> +#undef EM
> +#undef EMe
> +#define EM(a,b)		{ a, b },
> +#define EMe(a,b)	{ a, b }
> +
> +TRACE_EVENT(memory_failure_event,
> +	TP_PROTO(unsigned long pfn,
> +		 int type,
> +		 int result),
> +
> +	TP_ARGS(pfn, type, result),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, pfn)
> +		__field(int, type)
> +		__field(int, result)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn	= pfn;
> +		__entry->type	= type;
> +		__entry->result	= result;
> +	),
> +
> +	TP_printk("pfn %#lx: recovery action for %s: %s",

Hmm, "%#" is new to me. I'm not sure libtraceevent handles that.

Not your problem, I need to make sure that it does, and if it does not,
I need to fix it.

I'm not even sure what %# does.

Other than the typo,

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve


> +		__entry->pfn,
> +		__print_symbolic(__entry->type, MF_PAGE_TYPE),
> +		__print_symbolic(__entry->result, MF_ACTION_RESULT)
> +	)
> +);
> +#endif /* CONFIG_MEMORY_FAILURE */
>  #endif /* _TRACE_HW_EVENT_MC_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f074f8e..42c5981 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -56,6 +56,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/kfifo.h>
>  #include "internal.h"
> +#include "ras/ras_event.h"
>  
>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>  
> @@ -850,6 +851,8 @@ static struct page_state {
>  static void action_result(unsigned long pfn, enum mf_action_page_type type,
>  			  enum mf_result result)
>  {
> +	trace_memory_failure_event(pfn, type, result);
> +
>  	pr_err("MCE %#lx: recovery action for %s: %s\n",
>  		pfn, action_page_types[type], action_name[result]);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
