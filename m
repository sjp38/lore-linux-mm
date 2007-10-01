From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Inconsistent mmap()/mremap() flags
Date: Mon, 1 Oct 2007 13:13:30 +0200
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
In-Reply-To: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710011313.30171.andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: thayne@c2.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

> @@ -388,6 +392,9 @@
>  			if (vma->vm_flags & VM_MAYSHARE)
>  				map_flags |= MAP_SHARED;
>  
> +			if (flags & MAP_32BIT)
> +				map_flags |= MAP_32BIT;
> +
>  			new_addr = get_unmapped_area(vma->vm_file, 0, new_len,
>  						vma->vm_pgoff, map_flags);
>  			ret = new_addr;

That's not enough -- you would also need to fail the mremap when the result
is > 2GB (MAP_32BIT is actually a MAP_31BIT) 

But that would be ugly to implement without a new architecture wrapper
or better changing arch_get_unmapped_area()

It might be better to just not bother. MAP_32BIT is a kind of hack anyways
that at least for mmap can be easily emulated in user space anyways.
Given for mremap() it is not that easy because there is no "hint" argument
without MREMAP_FIXED; but unless someone really needs it i would prefer
to not propagate the hack. If it's really needed it's probably better
to implement a start search hint for mremap()

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
