From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 000/005](memory hotplug) freeing pages allocated by bootmem for hotremove v3.
Date: Mon, 07 Apr 2008 21:43:03 +0900
Message-ID: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758193AbYDGMoc@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-Id: linux-mm.kvack.org


Hello.

This is v3 for freeing pages which is allocated by bootmem
for memory hot-remove.

Please apply.

---
This patch set is to free pages which is allocated by bootmem for
memory-hotremove. Some structures of memory management are
allocated by bootmem. ex) memmap, etc.
To remove memory physically, some of them must be freed according
to circumstance.
This patch set makes basis to free those pages, and free memmaps.

Basic my idea is using remain members of struct page to remember
information of users of bootmem (section number or node id).
When the section is removing, kernel can confirm it.
By this information, some issues can be solved.

  1) When the memmap of removing section is allocated on other
     section by bootmem, it should/can be free. 
  2) When the memmap of removing section is allocated on the
     same section, it shouldn't be freed. Because the section has to be
     logical memory offlined already and all pages must be isolated against
     page allocater. If it is freed, page allocator may use it which will
     be removed physically soon.
  3) When removing section has other section's memmap, 
     kernel will be able to show easily which section should be removed
     before it for user. (Not implemented yet)
  4) When the above case 2), the page isolation will be able to check and skip
     memmap's page when logical memory offline (offline_pages()).
     Current page isolation code fails in this case because this page is 
     just reserved page and it can't distinguish this pages can be
     removed or not. But, it will be able to do by this patch.
     (Not implemented yet.)
  5) The node information like pgdat has similar issues. But, this
     will be able to be solved too by this.
     (Not implemented yet, but, remembering node id in the pages.)

Fortunately, current bootmem allocator just keeps PageReserved flags,
and doesn't use any other members of page struct. The users of
bootmem doesn't use them too.

This patch set is for 2.6.25-rc8-mm1.

Change log since v2.
  - Rebase for 2.6.25-rc8-mm1.
  - Fix panic at boot when CONFIG_SPARSEMEM_VMEMMAP is selected,
    and kernel returns EBUSY for physical removing.
    (This should be removed after it can do.)
  - Change not good comments.

Change log since v1.
  - allocate usemap on same section of pgdat. usemap's page is hard to be removed
    until other sections removing. This is avoid dependency problem between
    sections.
  - make alloc_bootmem_section() for above.
  - fix compile error for other config.
  - Add user counting. If a page is used by some user, it can be checked.

Todo:
  - for SPARSEMEM_VMEMMAP.
    Freeing vmemmap's page is more diffcult than normal sparsemem.
    Because not only memmap's page, but also the pages like page table must
    be removed too. If removing section has pages for , then it must
    be migrated too. Relocatable page table is necessary.
    (Ross Biro-san is working for it.)
    http://marc.info/?l=linux-mm&m=120110502617654&w=2



Thanks.



-- 
Yasunori Goto 
