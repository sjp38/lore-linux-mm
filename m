Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 81207900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 02:50:29 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p956oLgU013448
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 23:50:21 -0700
Received: from gyg8 (gyg8.prod.google.com [10.243.50.136])
	by hpaq6.eem.corp.google.com with ESMTP id p956oJWR017545
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 23:50:20 -0700
Received: by gyg8 with SMTP id 8so1465853gyg.20
        for <linux-mm@kvack.org>; Tue, 04 Oct 2011 23:50:19 -0700 (PDT)
Date: Tue, 4 Oct 2011 23:50:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
In-Reply-To: <20111001000900.BD9248B8@kernel>
Message-ID: <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel> <20111001000900.BD9248B8@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Fri, 30 Sep 2011, Dave Hansen wrote:

> 
> The output of /proc/$pid/numa_maps is in terms of number of pages
> like anon=22 or dirty=54.  Here's some output:
> 
> 7f4680000000 default file=/hugetlb/bigfile anon=50 dirty=50 N0=50
> 7f7659600000 default file=/anon_hugepage\040(deleted) anon=50 dirty=50 N0=50
> 7fff8d425000 default stack anon=50 dirty=50 N0=50
> 
> Looks like we have a stack and a couple of anonymous hugetlbfs
> areas page which both use the same amount of memory.  They don't.
> 
> The 'bigfile' uses 1GB pages and takes up ~50GB of space.  The
> anon_hugepage uses 2MB pages and takes up ~100MB of space while
> the stack uses normal 4k pages.  You can go over to smaps to
> figure out what the page size _really_ is with KernelPageSize
> or MMUPageSize.  But, I think this is a pretty nasty and
> counterintuitive interface as it stands.
> 
> The following patch adds a pagesize= field.  Note that this only
> shows the kernel's notion of page size.  For transparent
> hugepages, it still shows the base page size.  Here's some real
> output.  Note the anon_hugepage in there.
> 
> # cat /proc/`pidof memknobs`/numa_maps
> 00400000 default file=/root/memknobs pagesize=4KiB dirty=3 active=2 N0=3
> 00602000 default file=/root/memknobs pagesize=4KiB anon=1 dirty=1 N0=1
> 00603000 default file=/root/memknobs pagesize=4KiB anon=1 dirty=1 N0=1
> 00604000 default heap pagesize=4KiB anon=6 dirty=6 N0=6
> 7f6766216000 default file=/lib/libc-2.9.so pagesize=4KiB mapped=98 mapmax=25 active=97 N0=98
> 7f676637e000 default file=/lib/libc-2.9.so
> 7f676657e000 default file=/lib/libc-2.9.so pagesize=4KiB anon=4 dirty=4 N0=4
> 7f6766582000 default file=/lib/libc-2.9.so pagesize=4KiB anon=1 dirty=1 N0=1
> 7f6766583000 default pagesize=4KiB anon=3 dirty=3 N0=3
> 7f6766588000 default file=/lib/ld-2.9.so pagesize=4KiB mapped=25 mapmax=24 N0=25
> 7f676679d000 default pagesize=4KiB anon=2 dirty=2 N0=2
> 7f67667a3000 default pagesize=4KiB anon=4 dirty=4 N0=4
> 7f67667a7000 default file=/lib/ld-2.9.so pagesize=4KiB anon=1 dirty=1 N0=1
> 7f67667a8000 default file=/lib/ld-2.9.so pagesize=4KiB anon=1 dirty=1 N0=1
> 7f6766800000 default file=/anon_hugepage\040(deleted) pagesize=2MiB anon=10 dirty=10 N0=10
> 7fff5b948000 default stack pagesize=4KiB anon=2 dirty=2 N0=2
> 7fff5b96d000 default
> 

This would be great if all the /proc/pid/numa_maps consumers were human, 
but unfortuantely that's not the case.  

I understand that this patchset was probably the result of me asking for 
the pagesize= to be specified in each line and using pagesize=4K and 
pagesize=2M as examples, but that exact usage is probably not what we 
want.

As long as there are scripts that go through and read this information 
(we have some internally), expressing them with differing units just makes 
it more difficult to parse.  I'd rather them just be the byte count.

That way, 1G pages would just show pagesize=1073741824.  I don't think 
that's too long and is much easier to parse systematically.

> Signed-off-by: Dave Haneen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/fs/proc/task_mmu.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff -puN fs/proc/task_mmu.c~show-page-size fs/proc/task_mmu.c
> --- linux-2.6.git/fs/proc/task_mmu.c~show-page-size	2011-09-30 16:41:06.125953955 -0700
> +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-09-30 16:41:06.133953941 -0700
> @@ -1044,6 +1044,11 @@ static int show_numa_map(struct seq_file
>  	if (!md->pages)
>  		goto out;
>  
> +	/* Only interesting for hugetlbfs pages.
> +	 * Transparent hugepages are still pagesize=4k */

Strange comment style (and may not be 4K if thp is extended beyond x86).

> +	seq_puts(m, " pagesize=");
> +	seq_print_pow2(m, vma_kernel_pagesize(vma));
> +
>  	if (md->anon)
>  		seq_printf(m, " anon=%lu", md->anon);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
