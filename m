Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8126B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 10:59:16 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id as1so7085989iec.31
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:59:16 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id i2si11695305igm.7.2014.05.12.07.59.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 07:59:15 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id hl10so4749219igb.2
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:59:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140512124344.GA26865@node.dhcp.inet.fi>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
	<20140508160205.A0EC7E009B@blue.fi.intel.com>
	<CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
	<20140509140536.F06BFE009B@blue.fi.intel.com>
	<CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
	<20140512124344.GA26865@node.dhcp.inet.fi>
Date: Mon, 12 May 2014 18:59:15 +0400
Message-ID: <CALYGNiMY=f0M2gAJWgUSxa5z61PS3H8nXvJsiXp3XPbsJE+jyQ@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Mon, May 12, 2014 at 4:43 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Fri, May 09, 2014 at 08:14:08AM -0700, Linus Torvalds wrote:
>> On Fri, May 9, 2014 at 7:05 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> >
>> > Hm. I'm confused here. Do we have any limit forced per-user?
>>
>> Sure we do. See "struct user_struct". We limit max number of
>> processes, open files, signals etc.
>>
>> > I only see things like rlimits which are copied from parrent.
>> > Is it what you want?
>>
>> No, rlimits are per process (although in some cases what they limit
>> are counted per user despite the _limits_ of those resources then
>> being settable per thread).
>>
>> So I was just thinking that if we raise the per-mm default limits,
>> maybe we should add a global per-user limit to make it harder for a
>> user to use tons and toms of vma's.
>
> Here's the first attempt.
>
> I'm not completely happy about current_user(). It means we rely on that
> user of mm owner task is always equal to user of current. Not sure if it's
> always the case.
>
> Other option is to make MM_OWNER is always on and lookup proper user
> through task_cred_xxx(rcu_dereference(mm->owner), user).
>
> From 5ee6f6dd721ada8eb66c84a91003ac1e3eb2970a Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 12 May 2014 15:13:12 +0300
> Subject: [PATCH] mm: add per-user limit on mapping count
>
> We're going to increase per-mm map_count. To avoid non-obvious memory
> abuse by creating a lot of VMA's, let's introduce per-user limit.
>
> The limit is implemented as sysctl. For now value of limit is pretty
> arbitrary -- 2^20.
>
> sizeof(vm_area_struct) with my kernel config (DEBUG_KERNEL=n) is 184
> bytes. It means with the limit user can use up to 184 MiB of RAM in
> VMAs.
>
> The limit is not applicable for root (INIT_USER).

I don't like this.

Maybe we could just account VMAs into OOM-badness points and let
OOM-killer do its job?

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -170,7 +170,9 @@ unsigned long oom_badness(struct task_struct *p,
struct mem_cgroup *memcg,
         * task's rss, pagetable and swap space use.
         */
        points = get_mm_rss(p->mm) + atomic_long_read(&p->mm->nr_ptes) +
-                get_mm_counter(p->mm, MM_SWAPENTS);
+                get_mm_counter(p->mm, MM_SWAPENTS) +
+                (long)p->mm->map_count *
+                       sizeof(struct vm_area_struct) / PAGE_SIZE;
        task_unlock(p);

        /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
