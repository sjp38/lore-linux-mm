Date: Wed, 5 Apr 2006 11:17:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Some ideas on lazy migration with swapless migration
In-Reply-To: <1144256328.5203.36.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604051055370.1832@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
  <1144248362.5203.22.camel@localhost.localdomain>
 <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
 <1144256328.5203.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I think it is possible to do lazy migration without having to resort to a 
migration cache by either

A. Forbidding write to the page. The corresponding invocation to
   to do_wp_page() on a write attempt can then be used to migrate the 
   page. However, this would only work for write attempts.

B. Clear the present bit. The corresponding invocation of do_swap_page 
   may check for the type of pte and do the lazy migration and then set 
   the present bit again.

Hmm... B. would be an even better way to replace SWP_TYPE_MIGRATION and 
not use the swap code at all (which would simply take a lock on the page 
and redo the fault after releasing the lock) but it would require some 
work to get arch support for clearing and setting the present bit. 
However, there are only a few arches supporting NUMA and migration. So it 
should be doable.

Maybe the idea with the present bit can be used to further simplify 
migration:

1. Before migration clear all the present bits which guarantees
   that the faults will stall in do_swap_page() since the page is
   locked. No need to reduce the mapcount since the ptes are still there
   and can be switched back to working condition by do_swap_page().

2. do_swap_page() will lock the page (and therefore stall during 
   migration). After the page lock is obtained we check the present bit if
   it is now set then redo the fault. If not then do lazy migration if 
   needed and set the bit.

3. Migration will move the page and then replace ptes with cleared 
   present bits with ptes pointing to the new page with the present bit 
   enabled. 

Since we do not reduce the mapcount, we can use that mapcount to verify 
that it is still safe to get to the corresponding anonymous vma for 
anonymous pages. Some portions of the vm would have to be fixed up to know 
how to deal with valid ptes that are not present (fork and unmap code).

For file backed pages we would not have to remove the references anymore. 
We can migrate in the same way as the anonymous pages. We just need to 
make sure to first change the mapping. That would be an important feature 
for us because it preserves the page state in a better way. We could also 
preserve the dirty bits and accessed bits in the pte.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
