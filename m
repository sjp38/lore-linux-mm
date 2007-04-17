Message-ID: <46255446.6060204@google.com>
Date: Tue, 17 Apr 2007 16:12:06 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: meminfo returns inaccurate NR_FILE_PAGES
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Node 2 MemTotal:        64640 kB
Node 2 MemFree:         59816 kB
Node 2 MemUsed:          4824 kB
Node 2 Active:              0 kB
Node 2 Inactive:            8 kB
Node 2 HighTotal:           0 kB
Node 2 HighFree:            0 kB
Node 2 LowTotal:        64640 kB
Node 2 LowFree:         59816 kB
Node 2 Dirty:               0 kB
Node 2 Writeback:           0 kB
Node 2 FilePages:       62040 kB
Node 2 Mapped:              8 kB
Node 2 AnonPages:           0 kB
Node 2 PageTables:          0 kB
Node 2 NFS_Unstable:        0 kB
Node 2 Bounce:              0 kB
Node 2 Slab:             4696 kB
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0

   
    Note that File Pages is 62040kB when MemUsed is only 4824kB. We do 
__(dec|inc)_zone_page_state(page, NR_FILE_PAGES) whenever doing a 
radix_tree_(delete|insert) from/to mapping->page_tree. Except we missed one:

migrate.c:migrate_page_move_mapping()

    Here we replace the page* in the radix tree, but we don't dec on the 
old page and add on the new. Bug fix -- add:

__dec_zone_page_state(page, NR_FILE_PAGES)
__inc_zone_page_state(newpage, NR_FILE_PAGES)

    into migrate_page_move_mapping() immediately after writing to 
radix_pointer.

    If I get agreement that this is a bug I'll write up a patch.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
