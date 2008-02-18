Message-ID: <47B94FF7.3030200@goop.org>
Date: Mon, 18 Feb 2008 20:29:27 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [rfc][patch] mm: scalable vmaps
References: <20080218082219.GA2018@wotan.suse.de>
In-Reply-To: <20080218082219.GA2018@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, David Chinner <dgc@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> One thing that will be common to any high performance vmap implementation,
> however, will be the use of lazy TLB flushing. So I'm mainly interested
> in comments about this. AFAIK, Xen must be able to eliminate these aliases
> on demand,

Yep.

>  and CPA also doesn't want aliases around even if they don't
> get explicitly referenced by software (because the hardware may do a
> random speculative operation through the TLB).
>   

Yes, but presumably the page is in a "normal" state before CPA changes 
its cache attributes; it can shoot down aliases before doing that.

> So I just wonder if it is enough to provide a (quite heavyweight) function
> to flush aliases? (vm_unmap_aliases)
>   

Assuming that aliased pages are relatively rare, then its OK for this 
function to be heavyweight if it can exit quickly in the non-aliased 
case (or there's some other cheap way to tell if a page has aliases).  
Hm, even then, Xen would only need to call this on pages being turned 
into parts of a pagetable, so probably not all that often.  So, if its 
easy to avoid vm_unmap_aliases we would do so, but it's probably worth 
profiling before going to heroic efforts.

> Also, what consequences will this have for non-paravirtualized Xen? If
> any, do we care? (IMO no) I'm not going to take references on these
> lazy flush pages, because that will increase VM pressure by a great deal.
>   

Not sure what you mean here.  Unparavirtualized Xen would just use 
shadow pagetables, and be effectively the same as kvm as far as the 
kernel is concerned (unless there's some subtle difference I'm missing).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
