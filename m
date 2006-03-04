Date: Sat, 4 Mar 2006 01:07:08 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: numa_maps update
Message-Id: <20060304010708.31697f71.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: hugh@veritas.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Change the format

uh-oh.

> of numa_maps to be more compact and contain additional
> information that is useful for managing and troubleshooting memory on a NUMA
> system. Numa_maps can now also support huge pages.

What will be the userspace impact (ie: breakage) due to this change?

> New items shown:
>
> ... 
> locked
> 	Number of pages locked. Only displayed if >0.

I doubt if the PageLocked() count will be useful.  The only occasion upon
which pages are locked for more than a fleeting period is when they're
initially being brought up to date from backing store - readahead, swapin,
etc.

A more useful statistic would be the number of PageWriteback() pages.

> +	if (file) {
> +
> +		seq_printf(m, " file=");
> +		seq_path(m, file->f_vfsmnt, file->f_dentry, "\n\t");
> +
> +	} else if (vma->vm_start <= mm->brk &&
> +		   vma->vm_end >= mm->start_brk)
> +
> +			seq_printf(m, " heap");
> +
> +	else if (vma->vm_start <= mm->start_stack &&
> +		vma->vm_end >= mm->start_stack)
> +
> +			seq_printf(m, " stack");
> +
> +	if (is_vm_hugetlb_page(vma)) {
> +
> +		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
> +		seq_printf(m, " huge");
> +
> +	} else

What bizarre layout!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
