From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ppc64/cell: local TLB flush with active SPEs
Date: Thu, 13 Oct 2005 01:45:12 +0200
References: <OF66519BDB.81F21C74-ON85257098.0078C43D-86257098.0079BEBE@us.ibm.com>
In-Reply-To: <OF66519BDB.81F21C74-ON85257098.0078C43D-86257098.0079BEBE@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Message-Id: <200510130145.15377.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Nutter <mnutter@us.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, Michael Day <mnday@us.ibm.com>, Paul Mackerras <paulus@samba.org>, Ulrich Weigand <Ulrich.Weigand@de.ibm.com>, Max Aguilar <maguilar@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Dunnersdag 13 Oktober 2005 00:09, Mark Nutter wrote:
> As long as we are thinking about a proper solution, the whole 
> mm->cpu_vm_mask thing is broken, at least as a selector for local -vs- 
> global TLBIE.  The problem, as I see it, is that memory regions can shared 
> among processes (via mmap/shmat), with each task bound to different 
> processors.  If we are to continue using a cpumask as selector for TLBIE, 
> then we really need a vma->cpu_vma_mask. 
>  
No, because different tasks mapping the same address_space result in distinct
virtual (though not necessarily effective) addresses, so the TLB entries
are never shared across processes. A TLB entry on ppc64 always maps between
the (mm_struct,effective address) tuple and the real address and is local to
one CPU or SPU.
If we want to be clever, we could optimize the case where an mm_struct has
been used on exactly on CPU (the currently running one) and at least one
SPU. In that case, doing a TLBIEL plus a separate flush of each of the
MFCs that were used (by writing to their TLB_Invalidate_Entry registers)
is probably better than a global TLBIE.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
