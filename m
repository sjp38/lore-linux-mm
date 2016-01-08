Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id EEB6E6B025F
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:23:55 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b14so193017685wmb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:23:55 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id z87si2227163wmh.54.2016.01.08.15.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:23:54 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id u188so154398954wmu.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:23:54 -0800 (PST)
Date: Sat, 9 Jan 2016 01:23:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: possible deadlock in mm_take_all_locks
Message-ID: <20160108232352.GA13046@node.shutemov.name>
References: <CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, Jan 08, 2016 at 05:58:33PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've hit the following deadlock warning while running syzkaller fuzzer
> on commit b06f3a168cdcd80026276898fd1fee443ef25743. As far as I
> understand this is a false positive, because both call stacks are
> protected by mm_all_locks_mutex.

+Michal

I don't think it's false positive.

The reason we don't care about order of taking i_mmap_rwsem is that we
never takes i_mmap_rwsem under other i_mmap_rwsem, but that's not true for
i_mmap_rwsem vs. hugetlbfs_i_mmap_rwsem_key. That's why we have the
annotation in the first place.

See commit b610ded71918 ("hugetlb: fix lockdep splat caused by pmd
sharing").

Consider totally untested patch below.

diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..63aefcf409e1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3203,7 +3203,16 @@ int mm_take_all_locks(struct mm_struct *mm)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (signal_pending(current))
 			goto out_unlock;
-		if (vma->vm_file && vma->vm_file->f_mapping)
+		if (vma->vm_file && vma->vm_file->f_mapping &&
+				!is_vm_hugetlb_page(vma))
+			vm_lock_mapping(mm, vma->vm_file->f_mapping);
+	}
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (signal_pending(current))
+			goto out_unlock;
+		if (vma->vm_file && vma->vm_file->f_mapping &&
+				is_vm_hugetlb_page(vma))
 			vm_lock_mapping(mm, vma->vm_file->f_mapping);
 	}
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
