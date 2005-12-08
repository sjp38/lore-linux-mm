From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 00/07][RFC] Remove mapcount from struct page
Date: Thu,  8 Dec 2005 20:26:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

This patchset tries to remove page->_mapcount. On x86 systems this saves
4 bytes lowmem per page which means a 0.1% memory reduction. For small
embedded systems this saves one 4 K page per 4 M of memory. For systems
with large amounts of highmem this helps saving valuable lowmem.

The patches introduce a new bit in page->flags called PG_mapped. This bit
is used to determine if the page is mapped or not. The value zero means that 
the page is guaranteed to be unmapped. A one tells us that the page is either
mapped or unmapped, probably the former. So, page_mapped() might be lying.

This PG_mapped bit can go from 0 to 1 at any time, see page_add_anon_rmap() and
page_add_file_rmap(). The transition from 1 to 0 for an active page is more 
complicated and is implemented in the new function update_page_mapped(). The 
PG_mapped bit is also checked when pages are freed. PG_locked protects us.

In order to determine if a page is unmapped or not, the rmap data structures
must be traversed. For this to work correctly an usage counter has been added
to struct anon_vma.

Apart from performace, there are some issues such as:

- The number of maps limit (INT_MAX/2) is removed.
- can_share_swap_page() always returns 0 for now, ie sharing is disabled.
- Nonlinear file backed vmas are not handled yet.
- Is the anon_vma use count really correct?
- Is the PG_locked bit enough protection?
- There might be other places where update_page_mapped() should be used.

Some testing, but no benchmarking has been done. Have fun. Wear a helmet.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
