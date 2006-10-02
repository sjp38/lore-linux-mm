From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch 1/2] htlb shared page table
Date: Mon, 2 Oct 2006 15:35:24 -0700
Message-ID: <000101c6e673$0d3d3360$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0609302009270.9929@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Saturday, September 30, 2006 12:53 PM
> > +	unsigned long sbase = saddr & PUD_MASK;
> > +	unsigned long s_end = sbase + PUD_SIZE;
> > +
> > +	/*
> > +	 * match the virtual addresses, permission and the alignment of the
> > +	 * page table page.
> > +	 */
> > +	if (pmd_index(addr) != pmd_index(saddr) ||
> > +	    vma->vm_flags != svma->vm_flags ||
> > +	    base < vma->vm_start || vma->vm_end < end ||
> > +	    sbase < svma->vm_start || svma->vm_end < s_end)
> > +		return 0;
> > +
> > +	return saddr;
> > +}
> 
> If I've got the levels right, there's no chance of sharing htlb
> table on i386 2level, and on i386 3level (PAE) there's a chance,
> but only if non-standard address space layout or statically linked
> (in the standard layout, text+data+bss occupy the first pmd, shared
> libraries the second pmd, stack the third pmd, kernel the fourth).

You are correct.  It has very limited value on 32-bit arch. After all,
being able to address amount of physical memory bigger than the standard
3GB of user space virtual address has far more overhead then what hugetlb
is going to save it from.

I originally have the entire code wrapped with if CONFIG_X86_64, I'm
tempted to put it back.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
