Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 915F46B0727
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:25:51 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j124so8805516itj.12
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:25:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j13si1159379itd.85.2017.08.04.01.25.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 01:25:50 -0700 (PDT)
Message-Id: <201708040825.v748Pkul053862@www262.sakura.ne.jp>
Subject: Re: Re: [PATCH] mm, oom: fix potential data corruption when
 =?ISO-2022-JP?B?b29tX3JlYXBlciByYWNlcyB3aXRoIHdyaXRlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 04 Aug 2017 17:25:46 +0900
References: <201708040646.v746kkhC024636@www262.sakura.ne.jp> <20170804074212.GA26029@dhcp22.suse.cz>
In-Reply-To: <20170804074212.GA26029@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

Well, while lockdep warning is gone, this problem is remaining.

diff --git a/mm/memory.c b/mm/memory.c
index edabf6f..1e06c29 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3931,15 +3931,14 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
        /*
         * This mm has been already reaped by the oom reaper and so the
         * refault cannot be trusted in general. Anonymous refaults would
-        * lose data and give a zero page instead e.g. This is especially
-        * problem for use_mm() because regular tasks will just die and
-        * the corrupted data will not be visible anywhere while kthread
-        * will outlive the oom victim and potentially propagate the date
-        * further.
+        * lose data and give a zero page instead e.g.
         */
-       if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
-                               && test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
+       if (unlikely(!(ret & VM_FAULT_ERROR)
+                    && test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
+               if (ret & VM_FAULT_RETRY)
+                       down_read(&vma->vm_mm->mmap_sem);
                ret = VM_FAULT_SIGBUS;
+       }

        return ret;
 }

$ cat /tmp/file.* | od -b | head
0000000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
420330000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
*
420340000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
457330000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
*
457340000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
