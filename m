Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4156B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:17:17 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 2-v6so2666882plc.11
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:17:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23-v6sor4151810pfh.16.2018.07.31.10.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 10:17:16 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH] staging: ashmem: Fix SIGBUS crash when traversing mmaped ashmem pages
Date: Tue, 31 Jul 2018 10:17:04 -0700
Message-Id: <1533057424-25933-1-git-send-email-john.stultz@linaro.org>
In-Reply-To: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
References: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, aarcange@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, youling 257 <youling257@gmail.com>

Amit Pundir and Youling in parallel reported crashes with recent
mainline kernels running Android:

F DEBUG   : *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
F DEBUG   : Build fingerprint:
'Android/db410c32_only/db410c32_only:Q/OC-MR1/102:userdebug/test-key
F DEBUG   : Revision: '0'
F DEBUG   : ABI: 'arm'
F DEBUG   : pid: 2261, tid: 2261, name: zygote  >>> zygote <<<
F DEBUG   : signal 7 (SIGBUS), code 2 (BUS_ADRERR), fault addr 0xec00008
... <snip> ...
F DEBUG   : backtrace:
F DEBUG   :     #00 pc 00001c04  /system/lib/libc.so (memset+48)
F DEBUG   :     #01 pc 0010c513  /system/lib/libart.so
(create_mspace_with_base+82)
F DEBUG   :     #02 pc 0015c601  /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateMspace(void*, unsigned int,
unsigned int)+40)
F DEBUG   :     #03 pc 0015c3ed  /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateFromMemMap(art::MemMap*,
std::__1::basic_string<char, std::__
1::char_traits<char>, std::__1::allocator<char>> const&, unsigned int,
unsigned int, unsigned int, unsigned int, bool)+36)
...

This was bisected back to commit bfd40eaff5ab ("mm: fix vma_is_anonymous()
false-positives").

create_mspace_with_base() in the trace above, utilizes ashmem, and
with ashmem, for shared mappings we use shmem_zero_setup(), which sets
the vma->vm_ops to &shmem_vm_ops. But for private ashmem mappings
nothing sets the vma->vm_ops.

Looking at the problematic patch, it seems to add a requirement that
one call vma_set_anonymous() on a vma, otherwise the dummy_vm_ops will
be used. Using the dummy_vm_ops seem to triggger SIGBUS when traversing
unmapped pages.

Thus, this patch adds a call to vma_set_anonymous() for ashmem private
mappings and seems to avoid the reported problem.

Cc: Amit Pundir <amit.pundir@linaro.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: aarcange@redhat.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Colin Cross <ccross@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: youling 257 <youling257@gmail.com>
Fixes: bfd40eaff5ab ("mm: fix vma_is_anonymous() false-positives")
Reported-by: Amit Pundir <amit.pundir@linaro.org>
Reported-by: Youling 257 <youling257@gmail.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---

Hopefully my explanation make sense here. Please let me know if it
needs corrections.
thanks
-john

---
 drivers/staging/android/ashmem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index a1a0025..d5d33e1 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -402,6 +402,8 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 			fput(asma->file);
 			goto out;
 		}
+	} else {
+		vma_set_anonymous(vma);
 	}
 
 	if (vma->vm_file)
-- 
2.7.4
