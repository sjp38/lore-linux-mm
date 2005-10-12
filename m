From: Arnd Bergmann <arnd@arndb.de>
Subject: ppc64/cell: local TLB flush with active SPEs
Date: Wed, 12 Oct 2005 20:03:58 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510122003.59701.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc64-dev@ozlabs.org, linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mark Nutter <mnutter@us.ibm.com>, Mike Day <mnday@us.ibm.com>, Ulrich Weigand <Ulrich.Weigand@de.ibm.com>
List-ID: <linux-mm.kvack.org>

I'm looking for a clean solution to detect the need for global
TLB flush when an mm_struct is only used on one logical PowerPC
CPU (PPE) and also mapped with the memory flow controller of an
SPE on the Cell CPU.

Normally, we set bits in mm_struct:cpu_vm_mask for each CPU that
accesses the mm and then do global flushes instead of local flushes
when CPUs other than the currently running one are marked as used
in that mask. When an SPE does DMA to that mm, it also gets local
TLB entries that are only flushed with a global tlbie broadcast.

The current hack is to always set cpu_vm_mask to all bits set
when we map an mm into an SPE to ensure receiving the broadcast,
but that is obviously not how it's meant to be used. In particular,
it doesn't work in UP configurations where the cpumask contains
only one bit.

One solution that might be better could be to introduce a new special
flag in addition to cpu_vm_mask for this purpose. We already have
a bit field in mm_struct for dumpable, so adding another bit there
at least does not waste space for other platforms, and it's likely
to be in the same cache line as cpu_vm_mask. However, I'm reluctant
to add more bit fields to such a prominent place, because it might
encourage other people to add more bit fields or thing that they
are accepted coding practice.

Another idea would be to add a new field to mm_context_t, so it stays
in the architecture specific code. Again, adding an int here does
not waste space because there is currently padding in that place on
ppc64.

Or maybe there is a completely different solution.

Suggestions?

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
