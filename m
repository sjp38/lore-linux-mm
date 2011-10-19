Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 418966B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 16:52:41 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p9JKqSR5029792
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 13:52:28 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq11.eem.corp.google.com with ESMTP id p9JKpAhO021197
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 13:52:27 -0700
Received: by pzk36 with SMTP id 36so8698258pzk.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 13:52:22 -0700 (PDT)
Date: Wed, 19 Oct 2011 13:52:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: regression in /proc/self/numa_maps with huge pages
In-Reply-To: <20111019131007.e0d1c561.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1110191345290.5687@chino.kir.corp.google.com>
References: <20111019123530.2e59b86c@nehalam.linuxnetplumber.net> <20111019131007.e0d1c561.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Hemminger <shemminger@vyatta.com>, Stephen Wilson <wilsons@start.ca>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>

On Wed, 19 Oct 2011, Andrew Morton wrote:

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

Hmm, Dave Hansen (cc'd) was working on a patch that would add a pagesize= 
field to /proc/pid/numa_maps because there's now a discrepency in what is 
labeled "huge."  Hugetlbfs pages, for which "huge" would now be shown 
again for the patch above, always have their page counts shown in their 
appropriate hugepage size (2M, 1G for x86, others for other archs) which 
is ambiguous with just "huge" shown.  THP page counts, on the other hand, 
are always shown in PAGE_SIZE pages.

So adding "huge" back is ambiguous in terms of hugetlbfs size and doesn't 
represent THP hugepages.  No objection to the patch if it's strictly for 
numa_maps compatibility starting from 3.0, but we need to extend the 
output with a pagesize= type field unless we want to require users to use 
/proc/pid/smaps anytime they want to parse the page counts emitted by 
numa_maps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
