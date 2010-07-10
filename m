Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8276B600922
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 21:17:14 -0400 (EDT)
Subject: Re: [PATCH 1/2] Add trace events to mmap and brk
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
References: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Fri, 09 Jul 2010 21:17:11 -0400
Message-ID: <1278724631.1537.176.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-09 at 16:53 +0100, Eric B Munson wrote:
> As requested by Peter Zijlstra, this patch builds on my earlier patch
> and adds the corresponding trace points to mmap and brk.
> 
> Signed-off-by: Eric B Munson <emunson@mgebm.net>
> ---
>  include/trace/events/mm.h |   38 ++++++++++++++++++++++++++++++++++++++
>  mm/mmap.c                 |   10 +++++++++-
>  2 files changed, 47 insertions(+), 1 deletions(-)
> 
> diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
> index c3a3857..1563988 100644
> --- a/include/trace/events/mm.h
> +++ b/include/trace/events/mm.h
> @@ -24,6 +24,44 @@ TRACE_EVENT(munmap,
>  	TP_printk("unmapping %u bytes at %lu\n", __entry->len, __entry->start)
>  );
>  
> +TRACE_EVENT(brk,
> +	TP_PROTO(unsigned long addr, unsigned long len),
> +
> +	TP_ARGS(addr, len),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, addr)
> +		__field(unsigned long, len)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->addr = addr;
> +		__entry->len = len;
> +	),
> +
> +	TP_printk("brk mmapping %lu bytes at %lu\n", __entry->len,
> +		   __entry->addr)
> +);
> +
> +TRACE_EVENT(mmap,
> +	TP_PROTO(unsigned long addr, unsigned long len),
> +
> +	TP_ARGS(addr, len),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, addr)
> +		__field(unsigned long, len)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->addr = addr;
> +		__entry->len = len;
> +	),
> +
> +	TP_printk("mmapping %lu bytes at %lu\n", __entry->len,
> +		   __entry->addr)
> +);
> +

Please convert the above two into DECLARE_EVENT_CLASS() and
DEFINE_EVENT(). You don't need the "mapping" and "brk mapping" in the
TP_printk() format since the event name will be displayed as well to
differentiate the two.

Thanks,

-- Steve

>  #endif /* _TRACE_MM_H_ */
>  
>  /* This part must be outside protection */
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0775a30..252e3e0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -952,6 +952,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	unsigned int vm_flags;
>  	int error;
>  	unsigned long reqprot = prot;
> +	unsigned long ret;
>  
>  	/*
>  	 * Does the application expect PROT_READ to imply PROT_EXEC?
> @@ -1077,7 +1078,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	if (error)
>  		return error;
>  
> -	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
> +	ret =  mmap_region(file, addr, len, flags, vm_flags, pgoff);
> +
> +	if (!(ret & ~PAGE_MASK))
> +		trace_mmap(addr, len);
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL(do_mmap_pgoff);
>  
> @@ -2218,6 +2224,8 @@ out:
>  		if (!mlock_vma_pages_range(vma, addr, addr + len))
>  			mm->locked_vm += (len >> PAGE_SHIFT);
>  	}
> +
> +	trace_brk(addr, len);
>  	return addr;
>  }
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
