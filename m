Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id EDC0D6B005A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:18:46 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RESEND][PATCH v5 2/3] fix hugetlb memory check in vma_dump_size()
Date: Wed, 10 Apr 2013 12:17:48 -0400
Message-Id: <1365610669-16625-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365610669-16625-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1365610669-16625-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Documentation/filesystems/proc.txt says about coredump_filter bitmask,

  Note bit 0-4 doesn't effect any hugetlb memory. hugetlb memory are only
  effected by bit 5-6.

However current code can go into the subsequent flag checks of bit 0-4
for vma(VM_HUGETLB). So this patch inserts 'return' and makes it work
as written in the document.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: stable@vger.kernel.org
---
 fs/binfmt_elf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git v3.9-rc3.orig/fs/binfmt_elf.c v3.9-rc3/fs/binfmt_elf.c
index 3939829..86af964 100644
--- v3.9-rc3.orig/fs/binfmt_elf.c
+++ v3.9-rc3/fs/binfmt_elf.c
@@ -1137,6 +1137,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
 			goto whole;
 		if (!(vma->vm_flags & VM_SHARED) && FILTER(HUGETLB_PRIVATE))
 			goto whole;
+		return 0;
 	}
 
 	/* Do not dump I/O mapped devices or special mappings */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
