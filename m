Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 617016B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 07:47:38 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id f206so21728757wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 04:47:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z16si5059779wmc.124.2016.01.05.04.47.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 04:47:37 -0800 (PST)
Date: Tue, 5 Jan 2016 13:47:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Message-ID: <20160105124735.GA15324@dhcp22.suse.cz>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
> As far as I can see we explicitly munlock pages everywhere before unmap
> them. The only case when we don't to that is OOM-reaper.

Very well spotted!

> I don't think we should bother with munlocking in this case, we can just
> skip the locked VMA.

Why cannot we simply munlock them here for the private mappings?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b0a5d8b92e1..25dd7cd6fb5e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -456,9 +456,12 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 		 * we do not want to block exit_mmap by keeping mm ref
 		 * count elevated without a good reason.
 		 */
-		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
+		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_all(vma);
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
 					 &details);
+		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	up_read(&mm->mmap_sem);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
