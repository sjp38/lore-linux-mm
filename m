Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B46D6B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 10:38:06 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id o6so3632554oag.22
        for <linux-mm@kvack.org>; Thu, 01 May 2014 07:38:05 -0700 (PDT)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id na3si7537536obb.77.2014.05.01.07.38.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 07:38:05 -0700 (PDT)
Received: by mail-ob0-f178.google.com with SMTP id va2so415722obc.37
        for <linux-mm@kvack.org>; Thu, 01 May 2014 07:38:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140430154230.GA23371@node.dhcp.inet.fi>
References: <534DE5C0.2000408@oracle.com>
	<20140430154230.GA23371@node.dhcp.inet.fi>
Date: Thu, 1 May 2014 22:38:05 +0800
Message-ID: <CAJd=RBDi8j4tc40rbitZAtGzv0H8Vp=VtqN6aspsQWGXUmofEg@mail.gmail.com>
Subject: Re: mm: hangs in collapse_huge_page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

hi all

On Wed, Apr 30, 2014 at 11:42 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Apr 15, 2014 at 10:06:56PM -0400, Sasha Levin wrote:
>> Hi all,
>>
>> I often see hung task triggering in khugepaged within collapse_huge_page().
>>
>> I've initially assumed the case may be that the guests are too loaded and
>> the warning occurs because of load, but after increasing the timeout to
>> 1200 sec I still see the warning.
>
> I suspect it's race (although I didn't track down exact scenario) with
> __khugepaged_exit().
>
> Comment in __khugepaged_exit() says that khugepaged_test_exit() always
> called under mmap_sem:
>
> 2045 void __khugepaged_exit(struct mm_struct *mm)
> ...
> 2063         } else if (mm_slot) {
> 2064                 /*
> 2065                  * This is required to serialize against
> 2066                  * khugepaged_test_exit() (which is guaranteed to run
> 2067                  * under mmap sem read mode). Stop here (after we
> 2068                  * return all pagetables will be destroyed) until
> 2069                  * khugepaged has finished working on the pagetables
> 2070                  * under the mmap_sem.
> 2071                  */
> 2072                 down_write(&mm->mmap_sem);
> 2073                 up_write(&mm->mmap_sem);
> 2074         }
> 2075 }
>
> But this is not true. At least khugepaged_scan_mm_slot() calls it without
> the sem:
>
> 2566 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
> 2567                                             struct page **hpage)
> ...
> 2046 {
> 2047         struct mm_slot *mm_slot;
> 2048         int free = 0;
> 2049
> 2050         spin_lock(&khugepaged_mm_lock);
> 2051         mm_slot = get_mm_slot(mm);
> 2052         if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
> 2053                 hash_del(&mm_slot->hash);
> 2054                 list_del(&mm_slot->mm_node);
> 2055                 free = 1;
> 2056         }
> 2057         spin_unlock(&khugepaged_mm_lock);
> 2058
> 2059         if (free) {
> 2060                 clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
> 2061                 free_mm_slot(mm_slot);
> 2062                 mmdrop(mm);
>
> Not sure yet if it's a real problem or not. Andrea, could you comment on
> this?
>
> Sasha, please try patch below.
>
This box is quite,

 CPU:  0 PID: 0 Comm: swapper/0
 CPU:  1 PID: 0 Comm: swapper/1
 CPU:  2 PID: 0 Comm: swapper/2
 CPU:  3 PID: 0 Comm: swapper/3
 CPU:  4 PID: 0 Comm: swapper/4
 CPU:  5 PID: 0 Comm: swapper/5
 CPU:  6 PID: 0 Comm: swapper/6
 CPU:  7 PID: 0 Comm: swapper/7
 CPU:  8 PID: 0 Comm: swapper/8
 CPU:  9 PID: 0 Comm: swapper/9
 CPU: 10 PID: 0 Comm: swapper/10
 CPU: 11 PID: 0 Comm: swapper/11
 CPU: 12 PID: 0 Comm: swapper/12
 CPU: 13 PID: 0 Comm: swapper/13
 CPU: 14 PID: 0 Comm: swapper/14
 CPU: 15 PID: 0 Comm: swapper/15
 CPU: 16 PID: 0 Comm: swapper/16
 CPU: 17 PID: 0 Comm: swapper/17
 CPU: 18 PID: 0 Comm: swapper/18
 CPU: 19 PID: 0 Comm: swapper/19
 CPU: 20 PID: 0 Comm: swapper/20
 CPU: 21 PID: 3540 Comm: khungtaskd
 CPU: 22 PID: 0 Comm: swapper/22
 CPU: 23 PID: 0 Comm: swapper/23

and lets make more noise.

Hillf
---

--- a/mm/huge_memory.c Thu May  1 22:20:20 2014
+++ b/mm/huge_memory.c Thu May  1 22:24:06 2014
@@ -2732,7 +2732,8 @@ static void khugepaged_wait_work(void)
  }

  if (khugepaged_enabled())
- wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
+ wait_event_freezable_timeout(khugepaged_wait, khugepaged_wait_event(),
+ msecs_to_jiffies(2000));
 }

 static int khugepaged(void *none)
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
