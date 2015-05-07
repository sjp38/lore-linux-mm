Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9774C6B0070
	for <linux-mm@kvack.org>; Wed,  6 May 2015 21:13:33 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so24735879pab.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 18:13:33 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id e5si594771pat.91.2015.05.06.18.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 18:13:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 3/3] tracing: add trace event for memory-failure
Date: Thu, 7 May 2015 00:55:11 +0000
Message-ID: <20150507005510.GB7745@hori1.linux.bs1.fc.nec.co.jp>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
 <1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3442825A51C8DC45BB4B8E741E5F85B3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On Mon, Apr 20, 2015 at 04:44:40PM +0800, Xie XiuQi wrote:
> RAS user space tools like rasdaemon which base on trace event, could
> receive mce error event, but no memory recovery result event. So, I
> want to add this event to make this scenario complete.
>=20
> This patch add a event at ras group for memory-failure.
>=20
> The output like below:
> #  tracer: nop
> #
> #  entries-in-buffer/entries-written: 2/2   #P:24
> #
> #                               _-----=3D> irqs-off
> #                              / _----=3D> need-resched
> #                             | / _---=3D> hardirq/softirq
> #                             || / _--=3D> preempt-depth
> #                             ||| /     delay
> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #               | |       |   ||||       |         |
>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pf=
n 0x19869: recovery action for free buddy page: Delayed
>=20
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/ras/ras_event.h | 85 +++++++++++++++++++++++++++++++++++++++++++=
++++++
>  mm/memory-failure.c     |  3 ++
>  2 files changed, 88 insertions(+)
>=20
> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
> index 79abb9c..258ed89 100644
> --- a/include/ras/ras_event.h
> +++ b/include/ras/ras_event.h
> @@ -11,6 +11,7 @@
>  #include <linux/pci.h>
>  #include <linux/aer.h>
>  #include <linux/cper.h>
> +#include <linux/mm.h>
> =20
>  /*
>   * MCE Extended Error Log trace event
> @@ -232,6 +233,90 @@ TRACE_EVENT(aer_event,
>  		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
>  );
> =20
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
> +	EM ( MF_FAILED,  "Failed" )	\
> +	EM ( MF_DELAYED, "Delayed" )	\
> +	EMe ( MF_RECOVERED, "Recovered" )
> +
> +#define MF_PAGE_TYPE		\
> +	EM ( MF_MSG_KERNEL, "reserved kernel page" )			\
> +	EM ( MF_MSG_KERNEL_HIGH_ORDER, "high-order kernel page" )	\
> +	EM ( MF_MSG_SLAB, "kernel slab page" )				\
> +	EM ( MF_MSG_DIFFERENT_COMPOUND, "different compound page after locking"=
 ) \
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
> + * First define the enums in MM_ACTION_RESULT to be exported to userspac=
e
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
> + * Now redefine the EM() and EMe() macros to map the enums to the string=
s
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
> +		__entry->pfn	=3D pfn;
> +		__entry->type	=3D type;
> +		__entry->result	=3D result;
> +	),
> +
> +	TP_printk("pfn %#lx: recovery action for %s: %s",
> +		__entry->pfn,
> +		__print_symbolic(__entry->type, MF_PAGE_TYPE),
> +		__print_symbolic(__entry->result, MF_ACTION_RESULT)
> +	)
> +);
> +#endif /* CONFIG_MEMORY_FAILURE */
>  #endif /* _TRACE_HW_EVENT_MC_H */
> =20
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
> =20
>  int sysctl_memory_failure_early_kill __read_mostly =3D 0;
> =20
> @@ -850,6 +851,8 @@ static struct page_state {
>  static void action_result(unsigned long pfn, enum mf_action_page_type ty=
pe,
>  			  enum mf_result result)
>  {
> +	trace_memory_failure_event(pfn, type, result);
> +
>  	pr_err("MCE %#lx: recovery action for %s: %s\n",
>  		pfn, action_page_types[type], action_name[result]);
>  }
> --=20
> 1.8.3.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
