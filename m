Date: Tue, 30 Oct 2007 17:00:09 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071030170009.6057cbd5@cuia.boston.redhat.com>
In-Reply-To: <20071030191827.GB31038@dmt>
References: <20071030191827.GB31038@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007 15:18:27 -0400
Marcelo Tosatti <marcelo@kvack.org> wrote:

> The basic idea here is that applications can be part of the memory
> reclaim process. The notification is loosely defined as "please free
> some small percentage of your memory".

This will be especially useful for things like databases, JVMs
and applications that cache data that can be easily recreated
or read in from disk.  File IO tends to be much faster than
swap IO.

It could also be useful for glibc.  When a userland process
calls free(), a lot of the time the memory is not given back
to the kernel.  After all, chances are the process will need
it again.

If the kernel needs the memory, however, it will be faster for
applications to simply give it back than for the apps to wait
on disk IO.
 
> There is no easy way of finding whether the system is approaching a
> state where swapping is required in the reclaim paths, so a defensive
> approach is taken by using a timer with 1Hz frequency which verifies
> whether swapping has occurred.

Good enough for initial testing.  I will make sure that we will
have a more clearly defined threshold in the split VM code that
I am working on, so we can send the signal before we actually
start swapping.

> +void oom_check_fn(unsigned long unused)
> +{
> +	bool wake = 0;
> +	unsigned int swapped_pages;
> +
> +	swapped_pages = sum_vm_event(PSWPOUT);
> +	if (swapped_pages > prev_swapped_pages)
> +		wake = 1;
> +	prev_swapped_pages = swapped_pages;
> +
> +	oom_notify_status = wake;
> +
> +	if (wake)
> +		wake_up_all(&oom_wait);
> +
> +	return;
> +}

Maybe it would be better if we could do the wakeup earlier, so
we could wake up fewer processes at a time?  Maybe only one?

Thundering herd problems could be bad...

On the other hand, if memory is low on one NUMA node it would
not help at all if we woke up processes from other NUMA nodes...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
