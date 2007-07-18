Subject: init_mm locking
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Wed, 18 Jul 2007 14:28:15 +1000
Message-Id: <1184732895.25235.215.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Another things I stumbled on lately when toying with some mm rework on
powerpc, is the lack of any locking when manipulating init_mm page
tables. We don't use the pte_lockptr (well, we don't know where the pmd
comes from here, we can't toy around with that struct page), but we
don't use anything else either.

Granted, we shouldn't manipulate kernel PTEs racily in the sense that we
only touch them when mapping or when unmapping and those two things
shouldn't race... except that while remove_vm_area takes the vmlinux
lock while calling unmap_vm_areas, there are a couple of callers of it
that don't, and we never seem to have any lock around map_vm_area.

That means that while the allocation mechanism ensures somewhat that we
won't be accessing the same area both ways, we don't provide any
ordering/barriers for the PTE accesses to those, and I can well imagine
unlikely scenarii like:

	CPU A				CPU B
	map_vm_area
		set_pte_at
					unmap_vm_area
						ptep_get_and_clear

(CPU B immediately unmapping what CPU A just mapped)

Where the store of CPU A's set_pte_at will end up after the
ptep_get_and_clear(). Granted, I have never seen a real life case of it,
but I'm a little bit annoyed that we have a set of PTE accessors that
aren't protected by a lock of any sort (not even preemption) here.

Should't we at least take a sem or maybe use init_mm's PTL for that ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
