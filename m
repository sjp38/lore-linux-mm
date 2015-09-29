Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB5B6B0254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:54:51 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so203695814pac.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 00:54:51 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id v10si35373035pbs.184.2015.09.29.00.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 00:54:50 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] mm: optimize PageHighMem() check
Date: Tue, 29 Sep 2015 13:24:20 +0530
Message-ID: <1443513260-14598-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, "Kirill A.  Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Jennifer Herbert <jennifer.herbert@citrix.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org

This came up when implementing HIHGMEM/PAE40 for ARC.
The kmap() / kmap_atomic() generated code seemed needlessly bloated due
to the way PageHighMem() macro is implemented.
It derives the exact zone for page and then does pointer subtraction
with first zone to infer the zone_type.
The pointer arithmatic in turn generates the code bloat.

PageHighMem(page)
  is_highmem(page_zone(page))
     zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones

Instead use is_highmem_idx() to work on zone_type available in page flags

   ----- Before -----
80756348:	mov_s      r13,r0
8075634a:	ld_s       r2,[r13,0]
8075634c:	lsr_s      r2,r2,30
8075634e:	mpy        r2,r2,0x2a4
80756352:	add_s      r2,r2,0x80aef880
80756358:	ld_s       r3,[r2,28]
8075635a:	sub_s      r2,r2,r3
8075635c:	breq       r2,0x2a4,80756378 <kmap+0x48>
80756364:	breq       r2,0x548,80756378 <kmap+0x48>

   ----- After  -----
80756330:	mov_s      r13,r0
80756332:	ld_s       r2,[r13,0]
80756334:	lsr_s      r2,r2,30
80756336:	sub_s      r2,r2,1
80756338:	brlo       r2,2,80756348 <kmap+0x30>

For x86 defconfig build (32 bit only) it saves around 900 bytes.
For ARC defconfig with HIGHMEM, it saved around 2K bytes.

   ---->8-------
./scripts/bloat-o-meter x86/vmlinux-defconfig-pre x86/vmlinux-defconfig-post
add/remove: 0/0 grow/shrink: 0/36 up/down: 0/-934 (-934)
function                                     old     new   delta
saveable_page                                162     154      -8
saveable_highmem_page                        154     146      -8
skb_gro_reset_offset                         147     131     -16
...
...
__change_page_attr_set_clr                  1715    1678     -37
setup_data_read                              434     394     -40
mon_bin_event                               1967    1927     -40
swsusp_save                                 1148    1105     -43
_set_pages_array                             549     493     -56
   ---->8-------

e.g. For ARC kmap()

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Jennifer Herbert <jennifer.herbert@citrix.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 include/linux/page-flags.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 41c93844fb1d..2953aaa06d67 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -252,7 +252,7 @@ PAGEFLAG(Readahead, reclaim) TESTCLEARFLAG(Readahead, reclaim)
  * Must use a macro here due to header dependency issues. page_zone() is not
  * available at this point.
  */
-#define PageHighMem(__p) is_highmem(page_zone(__p))
+#define PageHighMem(__p) is_highmem_idx(page_zonenum(__p))
 #else
 PAGEFLAG_FALSE(HighMem)
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
