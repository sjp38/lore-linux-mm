Date: Thu, 15 Feb 2007 13:39:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/7] Opportunistically move mlocked pages off the LRU
Message-Id: <20070215133936.47ca3640.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070215012525.5343.71985.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
	<20070215012525.5343.71985.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, hch@infradead.org, a.p.zijlstra@chello.nl, mbligh@mbligh.org, arjan@infradead.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, mpm@selenic.com, nigel@nigel.suspend2.net, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007 17:25:26 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Opportunistically move mlocked pages off the LRU
> 
> Add a new function try_to_mlock() that attempts to
> move a page off the LRU and marks it mlocked.
> 
> This function can then be used in various code paths to move
> pages off the LRU immediately. Early discovery will make NR_MLOCK
> track the actual number of mlocked pages in the system more closely.
> 

How about adding this check ?

>  struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
> @@ -979,6 +1008,8 @@
>  			set_page_dirty(page);
>  		mark_page_accessed(page);
>  	}
> +	if (vma->vm_flags & VM_LOCKED)
> +		try_to_set_mlocked(page);

if (page != ZERO_PAGE(addres) && vma->vm_flags & VM_LOCKED)
		try_to_set_mlocked(pages);


I'm sorry if I misunderstand how ZERO_PAGE works.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
