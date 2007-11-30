Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUGknTJ032210
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 11:46:49 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUGkmAI111044
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 09:46:48 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUGkmZZ007999
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 09:46:48 -0700
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071130161155.GA29634@Krystal>
References: <20071113194025.150641834@polymtl.ca>
	 <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal>
	 <1195164977.27759.10.camel@localhost> <20071116143019.GA16082@Krystal>
	 <1195495485.27759.115.camel@localhost> <20071128140953.GA8018@Krystal>
	 <1196268856.18851.20.camel@localhost> <20071129023421.GA711@Krystal>
	 <1196317552.18851.47.camel@localhost>  <20071130161155.GA29634@Krystal>
Content-Type: text/plain
Date: Fri, 30 Nov 2007 09:46:41 -0800
Message-Id: <1196444801.18851.127.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-30 at 11:11 -0500, Mathieu Desnoyers wrote:
> +static inline swp_entry_t page_swp_entry(struct page *page)
> +{
> +       swp_entry_t entry;
> +       VM_BUG_ON(!PageSwapCache(page));
> +       entry.val = page_private(page);
> +       return entry;
> +}

This probably needs to be introduced (and used) in a separate patch.
Please fix up those other places in the code that can take advantage of
it.

>  #ifdef CONFIG_MIGRATION
>  static inline swp_entry_t make_migration_entry(struct page *page, int
> write)
>  {
> Index: linux-2.6-lttng/mm/swapfile.c
> ===================================================================
> --- linux-2.6-lttng.orig/mm/swapfile.c  2007-11-30 09:18:38.000000000
> -0500
> +++ linux-2.6-lttng/mm/swapfile.c       2007-11-30 10:21:50.000000000
> -0500
> @@ -1279,6 +1279,7 @@ asmlinkage long sys_swapoff(const char _
>         swap_map = p->swap_map;
>         p->swap_map = NULL;
>         p->flags = 0;
> +       trace_mark(mm_swap_file_close, "filp %p", swap_file);
>         spin_unlock(&swap_lock);
>         mutex_unlock(&swapon_mutex);
>         vfree(swap_map);
> @@ -1660,6 +1661,8 @@ asmlinkage long sys_swapon(const char __
>         } else {
>                 swap_info[prev].next = p - swap_info;
>         }
> +       trace_mark(mm_swap_file_open, "filp %p filename %s",
> +               swap_file, name); 

You print out the filp a number of times here, but how does that help in
a trace?  If I was trying to figure out which swapfile, I'd probably
just want to know the swp_entry_t->type, then I could look at this:

dave@foo:~/garbage$ cat /proc/swaps 
Filename                                Type            Size    Used    Priority
/dev/sda2                               partition       1992052 649336  -1

to see the ordering.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
