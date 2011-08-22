Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F19F86B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 18:25:46 -0400 (EDT)
Date: Mon, 22 Aug 2011 15:25:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v3] avoid null pointer access in vm_struct
Message-Id: <20110822152505.22b58998.akpm@linux-foundation.org>
In-Reply-To: <20110821082132.28358.72280.stgit@ltc219.sdl.hitachi.co.jp>
References: <20110821082132.28358.72280.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yrl.pp-manager.tt@hitachi.com, David Rientjes <rientjes@google.com>, Namhyung Kim <namhyung@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

On Sun, 21 Aug 2011 17:21:32 +0900
Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:

> The /proc/vmallocinfo shows information about vmalloc allocations in vmlist
> that is a linklist of vm_struct. It, however, may access pages field of
> vm_struct where a page was not allocated. This results in a null pointer
> access and leads to a kernel panic.
> 
> Why this happen:
> In __vmalloc_node_range() called from vmalloc(), newly allocated vm_struct
> is added to vmlist at __get_vm_area_node() and then, some fields of
> vm_struct such as nr_pages and pages are set at __vmalloc_area_node(). In
> other words, it is added to vmlist before it is fully initialized. At the
> same time, when the /proc/vmallocinfo is read, it accesses the pages field
> of vm_struct according to the nr_pages field at show_numa_info(). Thus, a
> null pointer access happens.
> 
> Patch:
> This patch adds newly allocated vm_struct to the vmlist *after* it is fully
> initialized. So, it can avoid accessing the pages field with unallocated
> page when show_numa_info() is called.

Seems rather ugly, but I guess it's OK.  vmalloc() is "special" in that
it fills the area with allocated pages, whereas all the
get_vm_area()-type callers don't do that.

>
> ...
>
> @@ -1381,17 +1403,20 @@ struct vm_struct *remove_vm_area(const void *addr)
>  	va = find_vmap_area((unsigned long)addr);
>  	if (va && va->flags & VM_VM_AREA) {
>  		struct vm_struct *vm = va->private;
> -		struct vm_struct *tmp, **p;
> -		/*
> -		 * remove from list and disallow access to this vm_struct
> -		 * before unmap. (address range confliction is maintained by
> -		 * vmap.)
> -		 */
> -		write_lock(&vmlist_lock);
> -		for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
> -			;
> -		*p = tmp->next;
> -		write_unlock(&vmlist_lock);
> +
> +		if (!(vm->flags & VM_UNLIST)) {
> +			struct vm_struct *tmp, **p;
> +			/*
> +			 * remove from list and disallow access to
> +			 * this vm_struct before unmap. (address range
> +			 * confliction is maintained by vmap.)
> +			 */
> +			write_lock(&vmlist_lock);
> +			for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
> +				;
> +			*p = tmp->next;
> +			write_unlock(&vmlist_lock);
> +		}

Is this needed?  How can remove_vm_area() actually be called with a
VM_UNLIST area?


I think I'll let this patch cook in linux-next for a while and shall
tag it for backporting into 3.1.x later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
