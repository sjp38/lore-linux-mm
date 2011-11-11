Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0EC6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 03:52:57 -0500 (EST)
Date: Fri, 11 Nov 2011 08:52:39 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mm: convert vma->vm_flags to 64bit
Message-ID: <20111111085239.GA12913@n2100.arm.linux.org.uk>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com> <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com> <alpine.DEB.2.00.1111092048520.27280@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111092048520.27280@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nai Xia <nai.xia@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>

On Wed, Nov 09, 2011 at 08:49:58PM -0800, David Rientjes wrote:
> On Thu, 10 Nov 2011, Nai Xia wrote:
> 
> > Did this patch get merged at last, or on this way being merged, or
> > just dropped ?
> > 
> 
> I thought we were waiting to find out if it caused a problem on arm.  
> Either Russell should be able to clarify that or a couple months in 
> linux-next.

As I said last time, these flags are passed into assembly on ARM.  For
example, we pass a pointer to the VMA, and the assembly code them loads
the vma flags to check whether VM_EXEC is set, so it knows whether it
needs to flush the instruction TLB.

Making this a 64-bit quantity then means we have to deal with the host
endian issues and the position of the VM_EXEC bit inside that 64-bit
quantity.  Remembering that ARM is 32-bit, that needs additional
complexity to sort out, something like:

#ifdef __ARMEB__
#define VM_FLAGS_LOWWORD	4
#else
#define VM_FLAGS_LOWWORD	0
#endif

#if VM_EXEC >= 1<<32
#define VM_FLAG_EXEC		(VM_EXEC >> 32)
#define VM_FLAG_EXECWORD	4
#else
#define VM_FLAG_EXEC		VM_EXEC
#define VM_FLAG_EXECWORD	0
#endif

	ldr	rd, [rn, #VMA_VM_FLAGS + (VM_FLAGS_LOWWORD ^ VM_FLAG_EXECWORD)]
...
	tst	rd, #VM_FLAG_EXEC

which is not only rather horrible, but I also wonder whether VM_EXEC >> 32
will provide the right answer with a binutils targetting 32-bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
