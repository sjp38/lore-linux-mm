Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 498B86B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 16:46:13 -0400 (EDT)
Date: Wed, 19 Oct 2011 13:46:07 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: regression in /proc/self/numa_maps with huge pages
Message-ID: <20111019134607.5ee1254e@nehalam.linuxnetplumber.net>
In-Reply-To: <20111019131007.e0d1c561.akpm@linux-foundation.org>
References: <20111019123530.2e59b86c@nehalam.linuxnetplumber.net>
	<20111019131007.e0d1c561.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Wilson <wilsons@start.ca>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>

On Wed, 19 Oct 2011 13:10:07 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 19 Oct 2011 12:35:30 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> > We are working on an application that uses a library that uses
> > both huge pages and parses numa_maps.  This application is no longer
> > able to identify the socket id correctly for huge pages because the
> > that 'huge' is no longer part of /proc/self/numa_maps.
> > 
> > Basically, application sets up huge page mmaps, then reads /proc/self/numa_maps
> > and skips all entries without the string " huge ".  Then it looks for address
> > and socket info.
> > 
> > Why was this information dropped?
> 
> Mistake?
> 
> > Looks like the desire to be generic
> > overstepped the desire to remain compatible.
> 
> Or it was a mistake.
> 
> This?
> 
> --- a/fs/proc/task_mmu.c~a
> +++ a/fs/proc/task_mmu.c
> @@ -1009,6 +1009,9 @@ static int show_numa_map(struct seq_file
>  		seq_printf(m, " stack");
>  	}
>  
> +	if (is_vm_hugetlb_page(vma))
> +		seq_printf(m, " huge");
> +
>  	walk_page_range(vma->vm_start, vma->vm_end, &walk);
>  
>  	if (!md->pages)
> 

That works, the application is happy.
Never would have found it except someone put the CPU in the wrong socket
on one dual CPU motherboard so everything is reported as socket 1!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
