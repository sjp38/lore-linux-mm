Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 974FC6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 04:24:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ex14so1608725pac.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 01:24:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a68si2861037pfb.39.2016.09.09.01.24.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 01:24:55 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
 <57D04192.5070704@intel.com>
 <8b800d72-9b28-237c-47a6-604d98a40315@linux.intel.com>
 <57D1703E.4070504@intel.com>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <01bcbbe2-5560-ea42-4d75-6ab50c3060d4@linux.intel.com>
Date: Fri, 9 Sep 2016 16:19:15 +0800
MIME-Version: 1.0
In-Reply-To: <57D1703E.4070504@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com



On 09/08/2016 10:05 PM, Dave Hansen wrote:
> On 09/07/2016 08:36 PM, Xiao Guangrong wrote:>> The user will see two
> VMAs in their output:
>>>
>>>     A: 0x1000->0x2000
>>>     C: 0x1000->0x3000
>>>
>>> Will it confuse them to see the same virtual address range twice?  Or is
>>> there something preventing that happening that I'm missing?
>>>
>>
>> You are right. Nothing can prevent it.
>>
>> However, it is not easy to handle the case that the new VMA overlays
>> with the old VMA
>> already got by userspace. I think we have some choices:
>> 1: One way is completely skipping the new VMA region as current kernel
>> code does but i
>>    do not think this is good as the later VMAs will be dropped.
>>
>> 2: show the un-overlayed portion of new VMA. In your case, we just show
>> the region
>>    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new
>> created
>>    region with different attributions.
>>
>> 3: completely show the new VMA as this patch does.
>>
>> Which one do you prefer?
>
> I'd be willing to bet that #3 will break *somebody's* tooling.
> Addresses going backwards is certainly screwy.  Imagine somebody using
> smaps to search for address holes and doing hole_size=0x1000-0x2000.
>
> #1 can lies about there being no mapping in place where there there may
> have _always_ been a mapping and is very similar to the bug you were
> originally fixing.  I think that throws it out.
>
> #2 is our best bet, I think.  It's unfortunately also the most code.
> It's also a bit of a fib because it'll show a mapping that never
> actually existed, but I think this is OK.  I'm not sure what the
> downside is that you're referring to, though.  Can you explain?

Yes. I was talking the case as follows:
    1: read() #1: prints vma-A(0x1000 -> 0x2000)
    2: unmap vma-A(0x1000 -> 0x2000)
    3: create vma-B(0x80 -> 0x3000) on other file with different permission
       (w, r, x)
    4: read #2: prints vma-B(0x2000 -> 0x3000)

Then userspace will get just a portion of vma-B. well, maybe it is not too bad. :)

How about this changes:

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84e..10ca648 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
  {
         if (m->count < m->size) /* vma is copied successfully */
-               m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
+               m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
  }

  static void *m_start(struct seq_file *m, loff_t *ppos)
@@ -176,14 +176,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)

         if (last_addr) {
                 vma = find_vma(mm, last_addr);
-               if (vma && (vma = m_next_vma(priv, vma)))
+               if (vma)
                         return vma;
         }

         m->version = 0;
         if (pos < mm->map_count) {
                 for (vma = mm->mmap; pos; pos--) {
-                       m->version = vma->vm_start;
+                       m->version = vma->vm_end;
                         vma = vma->vm_next;
                 }
                 return vma;
@@ -293,7 +293,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
         vm_flags_t flags = vma->vm_flags;
         unsigned long ino = 0;
         unsigned long long pgoff = 0;
-       unsigned long start, end;
+       unsigned long end, start = m->version;
         dev_t dev = 0;
         const char *name = NULL;

@@ -304,8 +304,13 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
                 pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
         }

+       /*
+        * the region [0, m->version) has already been handled, do not
+        * handle it doubly.
+        */
+       start = max(vma->vm_start, start);
+
         /* We don't show the stack guard page in /proc/maps */
-       start = vma->vm_start;
         if (stack_guard_page_start(vma, start))
                 start += PAGE_SIZE;
         end = vma->vm_end;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
