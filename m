Date: Fri, 14 Mar 2008 23:36:11 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH 0/3 (RFC)](memory hotplug) freeing pages allocated by bootmem for hotremove
Message-Id: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@osdl.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello.

I would like to post patch set to free pages which is allocated by bootmem
for memory-hotremove.

Basic my idea is using remain members of struct page to remember
information of users of bootmem (section number or node id).
When the section is removing, kernel can confirm it.
By this information, some issues can be solved.

  1) When the memmap of removing section is allocated on other
     section by bootmem, it should/can be free. 
  2) When the memmap of removing section is allocated on the
     same section, it shouldn't be freed. Because the section has to be
     offlined already and all pages must be isolated against
     page allocater. Kernel keeps it as is.
  3) When removing section has other section's memmap, 
     kernel will be able to show easily which section should be removed
     before it for user. (Not implemented yet)
  4) When the above case 2), the page migrator will be able to check and skip
     memmap againt page isolation when page offline.
     Current page migration fails in this case because this page is 
     just reserved page and it can't distinguish this pages can be
     removed or not. But, it will be able to do by this patch.
     (Not implemented yet.)
  5) The node information like pgdat has similar issues. But, this
     will be able to be solved too by this.
     (Not implemented yet, but, remembering node id in the pages.)

Fortunately, current bootmem allocator just keeps PageReserved flags,
and doesn't use any other members of page struct. The users of
bootmem doesn't use them too.

This patch set needs Badari-san's generic __remove_pages() support patch.
http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-03/msg02881.html

I think this patch set is not perfect. Because, some of section/node
informations are smaller than one page, and bootmem allocator may
mix other data. This patch is still trial.
But I suppose this is good start for everyone to understand what is necessary.

Please comments.

Other Todo:
  - for SPARSEMEM_VMEMMAP.
    Freeing vmemmap's page is more diffcult than normal sparsemem.
    Because not only memmap's page, but also the pages like page table must
    be removed too. If removing section has pages for , then it must
    be migrated too. Relocatable page table is necessary.
    
  - compile with other config.
    This version is just for requesting comments.
    If this way is accepted, I'll check it.
  - Follow fix bootmem by Yinghai Lu-san.
    (This patch set is for 2.6.25-rc3-mm1 with Badari-san's patch yet.)

Thanks.



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
